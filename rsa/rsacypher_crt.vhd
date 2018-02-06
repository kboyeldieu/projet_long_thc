----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:08:13 02/06/2018 
-- Design Name: 
-- Module Name:    RSA_CRT - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RSA_CRT is
	Generic (KEYSIZE: integer := 40);
    Port (cypher: out std_logic_vector(KEYSIZE-1 downto 0);
			 clk: in std_logic;
			 ds: in std_logic;
			 reset: in std_logic;
			 ready: out std_logic
			 );
end RSA_CRT;

architecture Behavioral of RSA_CRT is

component modmult is
	Generic (MPWID: integer);
    Port ( mpand : in std_logic_vector(MPWID-1 downto 0);
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
    Port ( inData: in std_logic_vector(KEYSIZE-1 downto 0);
			  inExp: in std_logic_vector(KEYSIZE-1 downto 0); 
			  inMod: in std_logic_vector(KEYSIZE-1 downto 0);
			  exponentiation: out std_logic_vector(KEYSIZE-1 downto 0);
			  clk: in std_logic;
			  ds: in std_logic;
			  reset: in std_logic;
			  ready: out std_logic);
end component;

signal modreg: std_logic_vector(KEYSIZE-1 downto 0);	-- store the modulus value during operation
signal modin: std_logic_vector(KEYSIZE-1 downto 0);	-- value to get the modulus
signal modout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of modulus
signal one: std_logic_vector(KEYSIZE-1 downto 0);	-- constant 1

signal expout: std_logic_vector(KEYSIZE-1 downto 0);	-- result of exponentiation
signal expin: std_logic_vector(KEYSIZE-1 downto 0);	-- result of exponentiation
signal expexp: std_logic_vector(KEYSIZE-1 downto 0);	-- result of exponentiation
signal expmod: std_logic_vector(KEYSIZE-1 downto 0);	-- result of exponentiation

signal modrdy, exprdy: std_logic;	-- signals to indicate completion of modulus, exponentiation
signal modgo, expgo: std_logic;	-- signals to trigger start of modulus, exponentiation
signal done: std_logic;	-- signal to indicate encryption complete

signal cpt: INTEGER RANGE 0 to 7; -- signal to track the current operation to perform

signal dp, dq, sp, sq: std_logic_vector(KEYSIZE-1 downto 0); -- temporal results 

-- constants
signal inData: std_logic_vector(KEYSIZE-1 downto 0);
signal inExp: std_logic_vector(KEYSIZE-1 downto 0);
signal inMod: std_logic_vector(KEYSIZE-1 downto 0);
signal p, q: std_logic_vector(KEYSIZE-1 downto 0); -- factors of the modulus inMod
signal d: std_logic_vector(KEYSIZE-1 downto 0); -- private key

begin
	
	-- initialize constants
	inData <= x"03273923ff";
	inExp <= x"02103f7fff";
	inMod <= x"0ef03f7fff";
	p <= x"0ef03f7fff";
	q <= x"0ef03f7fff";
	d <= x"0ef03f7fff";
	one <= "1";
	ready <= done;
	
	-- Modular multiplier to compute modulus
	modulus: modmult
	Generic Map(MPWID => KEYSIZE)
	Port Map(mpand => modin,
				mplier => one,
				modulus => modreg,
				product => modout,
				clk => clk,
				ds => modgo,
				reset => reset,
				ready => modrdy);
				
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
				
	crypto: process (clk, reset, done, ds) is
	begin
		
		if reset = '1' then
			done <= '1';
			modin <= (others => '0');
			expin <= (others => '0');
			modgo <= '0';
			expgo <= '0';
			cpt <= 0;
			dp <= (others => '0');
			dq <= (others => '0');
			sp <= (others => '0');
			sq <= (others => '0');
			
		elsif rising_edge(clk) then
		
			if done = '1' then
				if ds = '1' then
					done <= '0';
					cpt <= 1;
				end if;
				
			elsif cpt = 1 then
			-- compute dp = d mod (p-1)
				if modrdy = '1' then
					cpt <= cpt + 1;
				else
					modreg <= p - 1;
					modin <= d;
					modgo <= '1';
				end if;
			elsif cpt = 2 then
			-- compute dq = d mod (q-1)
			
			elsif cpt = 3 then
			-- compute iq = q^-1 mod p
			
			elsif cpt = 4 then
			-- compute sp = m^dp mod p
			
			elsif cpt = 5 then
			-- compute sq = m^dq mod q
			
			end if;
				
		end if;

	end process crypto;
	
end Behavioral;

