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





--local signals for this component
signal localmodulus : std_logic_vector(MPWID-1 downto 0);
signal localinvop : std_logic_vector(MPWID-1 downto 0);
signal localx0 : std_logic_vector(MPWID-1 downto 0);
signal localx0mult : std_logic_vector(2*MPWID-1 downto 0);
signal localsavex0 : std_logic_vector(MPWID-1 downto 0);
signal localx1 : std_logic_vector(MPWID-1 downto 0);
signal localquotient : std_logic_vector(MPWID-1 downto 0);
signal tmpmodulus : std_logic_vector(MPWID-1 downto 0);
signal step : std_logic_vector(3 downto 0);
signal first : std_logic;



begin
	
	modinv : process(clk, reset, ds, first) is
	begin
		if reset = '1' then
			first <= '1';
			ready <= '0';
		elsif rising_edge(clk) then
			if first = '1' then
				if ds = '1' then
					ready <= '0';
					localmodulus <= modulus;
					localinvop <= invop;
					localx0 <= (others => '0');
					localx1(MPWID-1 downto 1) <= (others => '0');
					localx1(0) <= '1';
					first <= '0';
					result <= (others => '0');
					step <= "0000";
				end if;
			elsif signed(localinvop) <= 1 and step = "0000" then
				step <= "1111";
				if signed(localx1) < 0 then
					result <= std_logic_vector(signed(localx1) + signed(modulus));
				else
					result <= localx1;
				end if;
				ready <= '1';
				first <= '1';
			else
				if step = "0000" then
					localquotient <= std_logic_vector(signed(localinvop) / signed(localmodulus));
					tmpmodulus <= localmodulus;
					step <= "0001";
				elsif step = "0001" then	
					localmodulus <= std_logic_vector(signed(localinvop) mod signed(localmodulus));
					step <= "0010";	
				elsif step = "0010" then
					localinvop <= tmpmodulus;
					localsavex0 <= localx0;
					localx0mult <= std_logic_vector(signed(localx1) - (signed(localquotient) * signed(localx0)));
					step <= "0011";
				elsif step = "0011" then
					localx0 <= localx0mult(MPWID-1 downto 0);
					localx1 <= localsavex0;
					step <= "0000";
				end if;
			end if;
		end if;
	end process modinv;
	
	

end modinv1;

