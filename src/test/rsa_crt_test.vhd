LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY rsacypher_crttest IS
END rsacypher_crttest;
 
ARCHITECTURE behavior OF rsacypher_crttest IS 
  
    COMPONENT RSA_CRT
    PORT( plaintext : OUT  std_logic_vector(39 downto 0);
          fault_signal: IN std_logic;
          ledout: OUT std_logic;
          clk : IN  std_logic;
          ds : IN  std_logic;
          reset : IN  std_logic;
          ready : OUT  std_logic);
    END COMPONENT;
    

    --Inputs
    signal clk : std_logic := '0';
    signal ds : std_logic := '0';
    signal reset : std_logic := '0';
    signal fault_signal: std_logic := '0';

    --Outputs
    signal plaintext : std_logic_vector(39 downto 0);
    signal ready : std_logic;
    signal ledout: std_logic;
    
    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: RSA_CRT PORT MAP (
       plaintext => plaintext,
       fault_signal => fault_signal,
       ledout => ledout,
       clk => clk,
       ds => ds,
       reset => reset,
       ready => ready);

    TB: PROCESS
    BEGIN
        -- non faulted signature
        wait for 120ns;
        reset <= '1';
        ds <= '0';
        wait for 20ns;
        wait until clk = '0';
        reset <= '0';
        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';
        wait for 2ns;
        ds <= '1';
        wait until ready = '0';
        ds <= '0';
        wait until ready = '1';
        
        -- faulted signature
        wait for 120ns;
        reset <= '1';
        ds <= '0';
        wait for 20ns;
        wait until clk = '0';
        reset <= '0';
        wait until clk = '1';
        wait until clk = '0';
        wait until clk = '1';
        wait for 2ns;
        ds <= '1';
        wait until ready = '0';
        ds <= '0';
        wait for 3000ns;
        fault_signal <= '1';
        wait for 120ns;
        fault_signal <= '0';
        wait until ready = '1';
        wait;
    END PROCESS;


   ClkGen : PROCESS
   BEGIN
        wait for 5300ps;
        if clk = '1' then
            clk <= '0';
        else
            clk <= '1';
        end if;
   END PROCESS;

END;
