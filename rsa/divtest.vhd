--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:03:11 02/06/2018
-- Design Name:   
-- Module Name:   /mnt/nosave/ttanguy/Xilinx/rsa/divtest.vhd
-- Project Name:  rsa
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: divunsigned
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY divtest IS
END divtest;
 
ARCHITECTURE behavior OF divtest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT divunsigned
    PORT(
         dividend : IN  std_logic_vector(39 downto 0);
         divisor : IN  std_logic_vector(39 downto  0);
         quotient : OUT  std_logic_vector(39 downto  0);
         remainder : OUT  std_logic_vector(39 downto  0);
         clk : IN  std_logic;
         ds : IN  std_logic;
         reset : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal dividend : std_logic_vector(39 downto  0) := (others => '0');
   signal divisor : std_logic_vector(39 downto  0) := (others => '0');
   signal clk : std_logic := '0';
   signal ds : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal quotient : std_logic_vector(39 downto  0);
   signal remainder : std_logic_vector(39 downto  0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 3 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: divunsigned PORT MAP (
          dividend => dividend,
          divisor => divisor,
          quotient => quotient,
          remainder => remainder,
          clk => clk,
          ds => ds,
          reset => reset,
          ready => ready
        );


	tb : process
	
	begin
		reset <= '1';
		wait until clk = '1';
		reset <= '0';
		wait until clk = '0';
		ds <= '1';
		dividend <= x"000000002a";
		divisor <= x"00000007e1";
		wait;
	end process;

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 



END;
