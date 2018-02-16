----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:57:15 02/06/2018 
-- Design Name: 
-- Module Name:    divunsigned - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divunsigned is
Generic (MPWID: integer);
    Port ( dividend : in std_logic_vector(MPWID-1 downto 0);
           divisor : in std_logic_vector(MPWID-1 downto 0);
           quotient : out std_logic_vector(MPWID-1 downto 0);
			  remainder : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end divunsigned;

architecture Behavioral of divunsigned is

signal tmpquotient : std_logic_vector(MPWID-1 downto 0);
signal tmpremainder : std_logic_vector(MPWID-1 downto 0);
signal tmpdividend : std_logic_vector (MPWID-1 downto 0);
signal first : std_logic;
signal counter : integer range 0 to MPWID-1;
signal step : std_logic;

begin
	
	quotient <= tmpquotient;
	remainder <= tmpremainder;
	
	divide: process (clk, reset, ds, first, step) is
	
	begin
	if reset = '1' then
		first <= '1';
	elsif rising_edge(clk) then
		if counter = 0 then
			ready <= '1';
			counter <= MPWID-1;
		elsif first = '1' then
			if ds = '1' then
				tmpquotient <= (others => '0');
				tmpremainder <= (others => '0');
				tmpdividend <= dividend;
				first <= '0';
				step <= '0';
				counter <= MPWID-1;
			end if;
		elsif step = '0' then
			tmpremainder <= tmpremainder(MPWID-2 downto 0) & tmpdividend(0);
			tmpdividend <= '0' & tmpdividend(MPWID-1 downto 1);
			step <= '1';
		elsif step = '1' then
			if tmpremainder >= dividend then
				tmpremainder <= tmpremainder - dividend;
				tmpquotient(counter) <= '1';
				counter <= counter - 1;
				step <= '0';
			end if;
		end if;
	end if;
		
	end process divide;

end Behavioral;
