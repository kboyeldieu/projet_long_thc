LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY modinvtest IS
END modinvtest;
 
ARCHITECTURE behavior OF modinvtest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT modinv
    PORT( invop : IN  std_logic_vector(39 downto 0);
          modulus : IN  std_logic_vector(39 downto 0);
          result : OUT  std_logic_vector(39 downto 0);
          clk : IN  std_logic;
          ds : IN  std_logic;
          reset : IN  std_logic;
          ready : OUT  std_logic);
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
