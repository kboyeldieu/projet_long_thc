library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RSA_CRT is
	Generic (KEYSIZE: integer := 40);
    Port (plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic);
end RSA_CRT;

architecture Behavioral of RSA_CRT is

component modmult is
	Generic (MPWID: integer);
    Port (mpand : in std_logic_vector(MPWID-1 downto 0);
          mplier : in std_logic_vector(MPWID-1 downto 0);
          modulus : in std_logic_vector(MPWID-1 downto 0);
          product : out std_logic_vector(MPWID-1 downto 0);
          clk : in std_logic;
          ds : in std_logic;
			 reset : in std_logic;
			 ready: out std_logic);
end component;

component exponentiation is
	Generic (KEYSIZE: integer := 40);
    Port (inData: in std_logic_vector(KEYSIZE-1 downto 0);
			 inExp: in std_logic_vector(KEYSIZE-1 downto 0); 
			 inMod: in std_logic_vector(KEYSIZE-1 downto 0);
			 exponentiation: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic);
end component;

signal modin: std_logic_vector(KEYSIZE-1 downto 0);	-- value to get the modulus
signal modout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of modulus
signal modmod: std_logic_vector(KEYSIZE-1 downto 0);	-- store the modulus value during operation
signal one: std_logic_vector(KEYSIZE-1 downto 0);	   -- constant 1 (beneath its a modular multiplication by 1)

signal prodin1: std_logic_vector(KEYSIZE-1 downto 0);	-- first operand of product
signal prodin2: std_logic_vector(KEYSIZE-1 downto 0);	-- second operand of product
signal prodout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of modular product
signal prodmod: std_logic_vector(KEYSIZE-1 downto 0);	-- modulus of product

signal expin: std_logic_vector(KEYSIZE-1 downto 0);	-- value to get the exponentiation
signal expout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of exponentiation
signal expexp: std_logic_vector(KEYSIZE-1 downto 0);	-- exponent of exponentiation
signal expmod: std_logic_vector(KEYSIZE-1 downto 0);	-- modulus of exponentiation

signal modinvin: std_logic_vector(KEYSIZE-1 downto 0);	-- value to get the modular inverse
signal modinvout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of modular inverse
signal modinvexp: std_logic_vector(KEYSIZE-1 downto 0);	-- exponent of modular inverse
signal modinvmod: std_logic_vector(KEYSIZE-1 downto 0);	-- modulus of modular inverse

signal modrdy, prodrdy, exprdy, modinvrdy: std_logic;	-- signals to indicate completion of modulus, product, exponentiation, modular inverse
signal modgo, prodgo, expgo, modinvgo: std_logic;	-- signals to trigger start of modulus, product, exponentiation, modular inverse
signal done: std_logic;	-- signal to indicate encryption complete

signal step: INTEGER RANGE 0 to 7; -- signal to track the current operation to perform

signal iq, dp, dq, sp, sq: std_logic_vector(KEYSIZE-1 downto 0); -- temporal results 
signal tmp_large: std_logic_vector(KEYSIZE*2-1 downto 0); -- signal to store temporal large products

-- constants
signal c: std_logic_vector(KEYSIZE-1 downto 0); -- data to crypt/decrypt
signal p, q: std_logic_vector(KEYSIZE-1 downto 0); -- factors of the modulus
signal d: std_logic_vector(KEYSIZE-1 downto 0); -- private key

begin
	
	-- initialize constants
	c <= x"0000123456"; 
	p <= x"000000258d"; -- 9613
	q <= x"0000002405"; -- 9221
	d <= x"1111111111";
	one <= x"0000000001";
	ready <= done;
	
	-- Modular multiplier to compute modulus
	modulus: modmult
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => modin,
				mplier => one,
				modulus => modmod,
				product => modout,
				clk => clk,
				ds => modgo,
				reset => reset,
				ready => modrdy);
	
	-- Modular multiplier to produce products
	product: modmult
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => prodin1,
				mplier => prodin2,
				modulus => prodmod,
				product => prodout,
				clk => clk,
				ds => prodgo,
				reset => reset,
				ready => prodrdy);
				
	-- Exponentiation		
	expo: exponentiation
	Generic Map(KEYSIZE => KEYSIZE)
	Port Map(inData => expin,
				inExp => expexp,
				inMod => expmod,
	         exponentiation => expout,
				clk => clk,
				ds => expgo,
				reset => reset,
				ready => exprdy);
				
	-- Modular inverse
	--modinv: modinv
	--Generic Map(KEYSIZE => KEYSIZE)
	--Port Map(inData => expin,
	--			inExp => expexp,
	--			inMod => expmod,
	--       exponentiation => expout,
	--			clk => clk,
	--			ds => expgo,
	--			reset => reset,
	--			ready => exprdy);
				
	crypto: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
			done <= '1';
			modgo <= '0';
			prodgo <= '0';
			expgo <= '0';
			step <= 1;
			iq <= (others => '0');
			dp <= (others => '0');
			dq <= (others => '0');
			sp <= (others => '0');
			sq <= (others => '0');
			
		elsif rising_edge(clk) then
		
			if done = '1' then
				if ds = '1' then
					done <= '0';
					step <= 1;
				end if;
				
			elsif step = 1 then
			-- compute dp = d mod (p-1)
				if modrdy = '1' then
					step <= step + 1;
					dp <= modout;
					modgo <= '0';
				else
					modmod <= p - 1;
					modin <= d;
					modgo <= '1';
				end if;
				
			elsif step = 2 then
			-- compute dq = d mod (q-1)
				if modrdy = '1' then
					step <= step + 1;
					dq <= modout;
					modgo <= '0';
				else
					modmod <= q - 1;
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
				if exprdy = '1' then
					step <= step + 1;
					sp <= expout;
					expgo <= '0';
				else
					expexp <= dp;
					expmod <= p;
					expin <= c;
					expgo <= '1';
				end if;
				
			elsif step = 5 then
			-- compute sq = c^dq mod q
				if exprdy = '1' then
					step <= step + 1;
					sq <= expout;
					expgo <= '0';
				else
					expexp <= dq;
					expmod <= q;
					expin <= c;
					expgo <= '1';
				end if;

			elsif step = 6 then
			-- compute plaintext = sq + q(iq(sp - sq) mod p)
				if modrdy = '1' then
					tmp_large <= sq + q * expout; -- tmp_large contains sq + q(iq(sp - sq) mod p) but on KEYSIZE*2 bits
					plaintext <= tmp_large(KEYSIZE-1 downto 0);
					done <= '1';
					modgo <= '0';
				else
					modmod <= p;
					tmp_large <= iq * (sp - sq); -- the multiplication is on KEYSIZE*2 bits
					modin <= tmp_large(KEYSIZE-1 downto 0);
					modgo <= '1';
				end if;
			elsif step > 6 then
			
			end if;
				
		end if;

	end process crypto;
	
end Behavioral;
