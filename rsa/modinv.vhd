----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:08:54 02/06/2018 
-- Design Name: 
-- Module Name:    modinv - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modinv is
	Generic(MPWID: integer := 40);
	Port( invop : in std_logic_vector(MPWID-1 downto 0);
			modulus : in std_logic_vector(MPWID-1 downto 0);
			result : out std_logic_vector(MPWID-1 downto 0);
			clk : in std_logic;
			ds : in std_logic;
			reset : in std_logic;
			ready : out std_logic
			);
end modinv;

architecture modinv1 of modinv is

component modmult is
	Generic (MPWID: integer := 40);
    Port ( mpand : in std_logic_vector(MPWID-1 downto 0);
           mplier : in std_logic_vector(MPWID-1 downto 0);
           modulus : in std_logic_vector(MPWID-1 downto 0);
           product : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;

component divunsigned is
Generic (MPWID: integer := 40);
    Port ( dividend : in std_logic_vector(MPWID-1 downto 0);
           divisor : in std_logic_vector(MPWID-1 downto 0);
           quotient : out std_logic_vector(MPWID-1 downto 0);
			  remainder : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;



--local signals for this component
signal localmodulus : std_logic_vector(MPWID-1 downto 0);
signal localinvop : std_logic_vector(MPWID-1 downto 0);
signal localx0 : std_logic_vector(MPWID-1 downto 0);
signal localsavex0 : std_logic_vector(MPWID-1 downto 0);
signal localx1 : std_logic_vector(MPWID-1 downto 0);
signal localquotient : std_logic_vector(MPWID-1 downto 0);

signal step : std_logic_vector(3 downto 0);
signal first : std_logic;


--local signals for division
signal tmpresult : std_logic_vector(MPWID-1 downto 0);
signal tmpquotient : std_logic_vector(MPWID-1 downto 0);
signal tmpremainder : std_logic_vector(MPWID-1 downto 0);
signal tmpdividend : std_logic_vector(MPWID-1 downto 0);
signal tmpdivisor : std_logic_vector(MPWID-1 downto 0);
signal divrdy : std_logic;
signal divgo : std_logic;

--local signals for modular multiplication
signal tmpmpand : std_logic_vector(MPWID-1 downto 0);
signal tmpmplier : std_logic_vector(MPWID-1 downto 0);
signal tmpmodulus : std_logic_vector(MPWID-1 downto 0);
signal tmpproduct : std_logic_vector(MPWID-1 downto 0);
signal multgo : std_logic;
signal multrdy : std_logic;


begin
	
	

	-- Modular multiplier to produce products
	modmultiply: modmult
	Generic Map(MPWID => MPWID)
	Port Map(mpand => tmpmpand,
				mplier => tmpmplier,
				modulus => tmpmodulus,
				product => tmpproduct,
				clk => clk,
				ds => multgo,
				reset => reset,
				ready => multrdy);
				
	-- Modular multiplier to produce products
   div: divunsigned 
	Generic Map (MPWID => MPWID)
	PORT MAP(dividend => tmpdividend,
				divisor => tmpdivisor,
				quotient => tmpquotient,
				remainder => tmpremainder,
				clk => clk,
				ds => divgo,
				reset => reset,
				ready => divrdy
				);
				
	result <= localx1;
	
	modinv : process(clk, reset, ds, first) is
	begin
		if reset = '1' then
			first <= '1';
			ready <= '0';
		elsif rising_edge(clk) then
			if first = '1' then
				if ds = '1' then
					localmodulus <= modulus;
					localinvop <= invop;
					localx0 <= (others => '0');
					localx1(MPWID-1 downto 1) <= (others => '0');
					localx1(0) <= '1';
					first <= '0';
					divrdy <= '0';
					multrdy <= '0';
					step <= "0000";
				end if;
			elsif localinvop > "1" then
				if step = "0000" then
					--tmpdividend <= localinvop;
					--tmpdivisor <= localmodulus;
					--divgo <= '1';
					--if divrdy = '1' then
					--	localquotient <= tmpquotient;
					--	divgo <= '0';
					--	step <= "0001";
					--end if;
					localquotient <= std_logic_vector(unsigned(localinvop) / unsigned(localmodulus));
					step <= "0001";
				elsif step = "0001" then	
					tmpmpand <= localinvop;
					tmpmplier(0) <= '1';
					tmpmplier(MPWID-1 downto 1) <= (others => '0');
					tmpmodulus <= localmodulus;
					multgo <= '1';
					if multrdy = '1' then
						localinvop <= localmodulus;
						localmodulus <= tmpproduct;
						multgo <= '0';
						step <= "0010";
					end if;
				elsif step = "0010" then
					localsavex0 <= localx0;
					localx0 <= std_logic_vector(signed (signed(localx1) - (signed(localquotient) * signed(localx0))));
					localx1 <= localsavex0;
					step <= "0000";
				else
					if signed(localx1) < 0 then
						localx1 <= localx1 + modulus;
					end if;
					ready <= '1';
				end if;
			end if;
		end if;
	end process modinv;
	
	

end modinv1;

