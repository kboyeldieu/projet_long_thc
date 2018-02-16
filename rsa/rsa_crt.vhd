library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

entity RSA_CRT is
    Generic (KEYSIZE: integer := 40);
    Port ( plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
           fault_signal: in std_logic;
           ledout: out std_logic;
           clk: in std_logic;
           ds: in std_logic;
           reset: in std_logic;
           ready: out std_logic);
end RSA_CRT;

architecture Behavioral of RSA_CRT is

component exponentiation is
    Generic (KEYSIZE: integer := 40);
    Port ( inData: in std_logic_vector(KEYSIZE-1 downto 0);
           inExp: in std_logic_vector(KEYSIZE-1 downto 0); 
           inMod: in std_logic_vector(KEYSIZE-1 downto 0);
           exponentiation: out std_logic_vector(KEYSIZE-1 downto 0);
           clk: in std_logic;
           ds: in std_logic;
           reset: in std_logic;
           ready: out std_logic);
end component;

component modinv is
    Generic(MPWID: integer := 40);
    Port( invop : in std_logic_vector(MPWID-1 downto 0);
          modulus : in std_logic_vector(MPWID-1 downto 0);
          result : out std_logic_vector(MPWID-1 downto 0);
          clk : in std_logic;
          ds : in std_logic;
          reset : in std_logic;
          ready : out std_logic);
end component;

component divunsigned is
Generic (MPWID: integer);
    Port ( dividend : in std_logic_vector(MPWID-1 downto 0);
           divisor : in std_logic_vector(MPWID-1 downto 0);
           quotient : out std_logic_vector(MPWID-1 downto 0);
			  remainder : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;

signal expin: std_logic_vector(KEYSIZE-1 downto 0);          -- value to get the exponentiation
signal expout: std_logic_vector(KEYSIZE-1 downto 0);      -- result of exponentiation
signal expexp: std_logic_vector(KEYSIZE-1 downto 0);      -- exponent of exponentiation
signal expmod: std_logic_vector(KEYSIZE-1 downto 0);      -- modulus of exponentiation

signal modinvin: std_logic_vector(KEYSIZE-1 downto 0);    -- value to get the modular inverse
signal modinvout: std_logic_vector(KEYSIZE-1 downto 0);   -- result of modular inverse
signal modinvmod: std_logic_vector(KEYSIZE-1 downto 0);   -- modulus of modular inverse

signal modinvrdy, exprdy, modrdy: std_logic;                      -- signals to indicate completion of modular inverse, exponentiation
signal modinvgo, expgo, modgo: std_logic;                        -- signals to trigger start of modular inverse, exponentiation
signal done: std_logic;                                   -- signal to indicate encryption complete

signal modin: std_logic_vector(KEYSIZE-1 downto 0);
signal modout: std_logic_vector(KEYSIZE-1 downto 0);  
signal modmod: std_logic_vector(KEYSIZE-1 downto 0);  
signal unused: std_logic_vector(KEYSIZE-1 downto 0);

signal step: INTEGER RANGE 0 to 9;                        -- signal to track the current operation to perform

signal iq, dp, dq, sp, sq: std_logic_vector(KEYSIZE-1 downto 0); -- temporal results 
signal tmp_large: std_logic_vector(KEYSIZE*2-1 downto 0);        -- signal to store temporal large products

signal waiting: std_logic;

signal alea_cpt: std_logic_vector(KEYSIZE-1 downto 0);      -- cpt to store a random fault
signal wait_fault_injection: INTEGER RANGE 0 to 1000; -- cpt to wait a fault injection
signal signal_faulted: std_logic;

-- constants : input of the rsa algorithm
signal c: std_logic_vector(KEYSIZE-1 downto 0); -- data to crypt/decrypt
signal p, q: std_logic_vector(KEYSIZE-1 downto 0); -- factors of the modulus
signal d: std_logic_vector(KEYSIZE-1 downto 0); -- private key

begin
    
    -- initialize constants
    c <= x"0000000056"; 
    p <= x"000000258d"; -- 9613
    q <= x"0000002405"; -- 9221
    d <= x"1111111111";
    ready <= done;
        
    -- Exponentiation        
    expo: exponentiation
        Generic Map(KEYSIZE => KEYSIZE)
        Port Map( inData => expin,
                  inExp => expexp,
                  inMod => expmod,
                  exponentiation => expout,
                  clk => clk,
                  ds => expgo,
                  reset => reset,
                  ready => exprdy);
                
    -- Modular inverse
    modularinv: modinv
        Generic Map(MPWID => KEYSIZE)
        Port Map( invop => modinvin,
                  modulus => modinvmod,
                  result => modinvout,
                  clk => clk,
                  ds => modinvgo,
                  reset => reset,
                  ready => modinvrdy);
    

	 modulo: divunsigned
		Generic Map(MPWID => KEYSIZE)
		Port Map ( dividend => modin,
             divisor => modmod,
             quotient => unused,
             remainder => modout,
             clk => clk,
             ds => modgo,
             reset => reset,
             ready => modrdy);
				 
    crypto: process (clk, reset, done, ds) is
    begin
        
        if reset = '1' then
            done <= '1';
            expgo <= '0';
            modinvgo <= '0';
				modgo <= '0';
            waiting <= '0';
            step <= 1;
            ledout <= '0';
            alea_cpt <= (others => '0');
            wait_fault_injection <= 10;
            signal_faulted <= '0';
            iq <= (others => '0');
            dp <= (others => '0');
            dq <= (others => '0');
            sp <= (others => '0');
            sq <= (others => '0');
            
        elsif rising_edge(clk) then
            
            alea_cpt <= alea_cpt + 1;
            
            if done = '1' then
                if ds = '1' then
                    done <= '0';
                    step <= 1;
                end if;
                
            elsif step = 1 then
            --compute dp = d mod (p-1)
					 if modgo = '1' and modrdy = '1' then
					    step <= step + 1;
						 dp <= modout;
						 modgo <= '0';
					 else 
						 modmod <= p-1;
						 modin <= d;
						 modgo <= '1';
					 end if;
  
            elsif step = 2 then
            -- compute dq = d mod (q-1)
					 if modgo = '1' and modrdy = '1' then
					    step <= step + 1;
						 dq <= modout;
						 modgo <= '0';
					 else 
						 modmod <= q-1;
						 modin <= d;
						 modgo <= '1';
					 end if;
									 
            elsif step = 3 then
            -- compute iq = q^-1 mod p
                if modinvrdy = '1' then
                    step <= step + 1;
                    iq <= modinvout;
                    modinvgo <= '0';
                else
                    modinvmod <= p;
                    modinvin <= q;
                    modinvgo <= '1';
                end if;
                
            elsif step = 4 then
            -- compute sp = c^dp mod p
                if wait_fault_injection = 0 then
                    if exprdy = '1' and waiting = '1' then
                        step <= step + 1;
                        sp <= expout;
                        expgo <= '0';
                        waiting <= '0';
                        wait_fault_injection <= 10;
                        ledout <= '0';
                    elsif waiting = '1' then
                        expgo <= '0';
                    elsif waiting = '0' then
                        expexp <= dp;
                        expmod <= p;
                        if signal_faulted = '1' then
                            expin <= c + alea_cpt;
                        else
                            expin <= c;
                        end if;
                        expgo <= '1';
                        waiting <= '1';
                    end if;
                else
                    -- let some time for the user to inject the fault
                    ledout <= '1';
                    wait_fault_injection <= wait_fault_injection - 1;
                    if fault_signal = '1' then
                        signal_faulted <= '1';
                    end if;
                end if;

            elsif step = 5 then
            -- compute sq = c^dq mod q
                if exprdy = '1' and waiting = '1' then
                    step <= step + 1;
                    sq <= expout;
                    expgo <= '0';
                    waiting <= '0';
                elsif waiting = '1' then
                    expgo <= '0';
                elsif waiting = '0' then
                    expexp <= dq;
                    expmod <= q;
                    expin <= c;
                    expgo <= '1';
                    waiting <= '1';
                end if;
            
            elsif step = 6 then
            -- compute plaintext = sq + q(iq(sp - sq) mod p)
                tmp_large <= std_logic_vector(unsigned(sq) + unsigned(q) * (unsigned(iq) * (unsigned(sp) - unsigned(sq)) mod unsigned(p)));
                step <= step + 1;
            
            elsif step = 7 then
                plaintext <= tmp_large(KEYSIZE-1 downto 0);
                done <= '1';
            end if;
                
        end if;

    end process crypto;
    
end Behavioral;
