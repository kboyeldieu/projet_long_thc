--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:06:48 02/07/2018
-- Design Name:   
-- Module Name:   /mnt/nosave/ttanguy/Xilinx/rsa/modinvtest.vhd
-- Project Name:  rsa
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: modinv
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
 
ENTITY modinvtest IS
END modinvtest;
 
ARCHITECTURE behavior OF modinvtest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT modinv
    PORT(
         invop : IN  std_logic_vector(39 downto 0);
         modulus : IN  std_logic_vector(39 downto 0);
         result : OUT  std_logic_vector(39 downto 0);
         clk : IN  std_logic;
         ds : IN  std_logic;
         reset : IN  std_logic;
         ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal invop : std_logic_vector(39 downto 0) := (others => '0');
   signal modulus : std_logic_vector(39 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal ds : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal result : std_logic_vector(39 downto 0);
   signal ready : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: modinv PORT MAP (
          invop => invop,
          modulus => modulus,
          result => result,
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
		invop <= x"000000002a";
		modulus <= x"00000007e1";
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
