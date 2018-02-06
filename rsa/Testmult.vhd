
-- VHDL Test Bench Created from source file modmult32.vhd -- 18:42:57 05/04/2003
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends 
-- that these types always be used for the top-level I/O of a design in order 
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench2 IS
END testbench2;

ARCHITECTURE behavior OF testbench2 IS 

	COMPONENT modmult
	PORT(
		mpand : IN std_logic_vector(39 downto 0);
		mplier : IN std_logic_vector(39 downto 0);
		modulus : IN std_logic_vector(39 downto 0);
		clk : IN std_logic;
		ds : IN std_logic;
		reset : IN std_logic;          
		product : OUT std_logic_vector(39 downto 0);
		ready : OUT std_logic
		);
	END COMPONENT;

	SIGNAL mpand :  std_logic_vector(39 downto 0);
	SIGNAL mplier :  std_logic_vector(39 downto 0);
	SIGNAL modulus :  std_logic_vector(39 downto 0);
	SIGNAL product :  std_logic_vector(39 downto 0);
	SIGNAL clk :  std_logic;
	SIGNAL ds :  std_logic;
	SIGNAL reset :  std_logic;
	SIGNAL ready :  std_logic;

BEGIN

	uut: modmult PORT MAP(
		mpand => mpand,
		mplier => mplier,
		modulus => modulus,
		product => product,
		clk => clk,
		ds => ds,
		reset => reset,
		ready => ready
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
		reset <= '1';
		wait until clk = '1';
		reset <= '0';
		wait until clk = '0';
		ds <= '1';
		mpand <= x"00003f7fff";
		mplier <= x"000fff0014";
		modulus <= x"00007f0000";
      wait; -- will wait forever
   END PROCESS;

	clkgen: process
	begin
		wait for 3 ns;
		if clk = '1' then
			clk <= '0';
		else
			clk <= '1';
		end if;
	end process;
-- *** End Test Bench - User Defined Section ***

END;
