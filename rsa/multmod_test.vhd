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

END;
