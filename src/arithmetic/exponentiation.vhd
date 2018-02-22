library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
                                                            
entity exponentiation is
    Generic (KEYSIZE: integer);
    Port ( indata: in std_logic_vector(KEYSIZE-1 downto 0);
           inExp: in std_logic_vector(KEYSIZE-1 downto 0);
           inMod: in std_logic_vector(KEYSIZE-1 downto 0);
           exponentiation: out std_logic_vector(KEYSIZE-1 downto 0);
           clk: in std_logic;
           ds: in std_logic;
           reset: in std_logic;
           ready: out std_logic);
end exponentiation;

architecture Behavioral of exponentiation is
attribute keep: string;

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

signal modreg: std_logic_vector(KEYSIZE-1 downto 0);   -- store the modulus value during operation
signal root: std_logic_vector(KEYSIZE-1 downto 0);     -- value to be squared
signal square: std_logic_vector(KEYSIZE-1 downto 0);   -- result of square operation
signal sqrin: std_logic_vector(KEYSIZE-1 downto 0);    -- 1 or copy of root
signal tempin: std_logic_vector(KEYSIZE-1 downto 0);   -- 1 or copy of square
signal tempout: std_logic_vector(KEYSIZE-1 downto 0);  -- result of multiplication
signal count: std_logic_vector(KEYSIZE-1 downto 0);    -- working copy of exponent

signal multrdy, sqrrdy, bothrdy: std_logic; -- signals to indicate completion of multiplications
signal multgo, sqrgo: std_logic;            -- signals to trigger start of multiplications
signal done: std_logic;                     -- signal to indicate encryption complete

begin

    bothrdy <= multrdy and sqrrdy;
    
    -- Modular multiplier to produce products
    modmultiply: modmult
    Generic Map(MPWID => KEYSIZE)
    Port Map( mpand => sqrin,
              mplier => tempin,
              modulus => modreg,
              product => tempout,
              clk => clk,
              ds => multgo,
              reset => reset,
              ready => multrdy);

    -- Modular multiplier to take care of squaring operations
    modsqr: modmult
    Generic Map(MPWID => KEYSIZE)
    Port Map( mpand => root,
              mplier => root,
              modulus => modreg,
              product => square,
              clk => clk,
              ds => multgo,
              reset => reset,
              ready =>sqrrdy);

    --counter manager process tracks counter and enable flags
    mngcount: process (clk, reset, done, ds, count, bothrdy) is
    begin
    -- handles DONE and COUNT signals
        
        if reset = '1' then
            count <= (others => '0');
            done <= '1';
            ready <= '0';
        elsif rising_edge(clk) then
            if done = '1' then
                ready <= '0';
                if ds = '1' then
                -- first time through
                    count <= '0' & inExp(KEYSIZE-1 downto 1);
                    done <= '0';
                end if;
            -- after first time
            elsif count = 0 then
                if bothrdy = '1' and multgo = '0' then
                    exponentiation <= tempout;        -- set output value
                    done <= '1';
                    ready <= '1';
                end if;
            elsif bothrdy = '1' then
                if multgo = '0' then
                    count <= '0' & count(KEYSIZE-1 downto 1); -- shift l'exposant après chaque multiplication
                end if;
            end if;
        end if;

    end process mngcount;

    -- This process sets the input values for the squaring multitplier
    setupsqr: process (clk, reset, done, ds) is
    begin
        
        if reset = '1' then
            root <= (others => '0');
            modreg <= (others => '0');
        elsif rising_edge(clk) then
            if done = '1' then
                if ds = '1' then
                -- first time through, input is sampled only once
                    modreg <= inMod;
                    root <= indata;
                end if;
            -- after first time, square result is fed back to multiplier
            else
                root <= square;
            end if;
        end if;

    end process setupsqr;
    
    -- This process sets input values for the product multiplier
    setupmult: process (clk, reset, done, ds) is
    begin
        
        if reset = '1' then
            tempin <= (others => '0');
            sqrin <= (others => '0');
            modreg <= (others => '0');
        elsif rising_edge(clk) then
            if done = '1' then
                if ds = '1' then
                -- first time through, input is sampled only once
                -- if the least significant bit of the exponent is '1' then we seed the
                -- multiplier with the message value. Otherwise, we seed it with 1.
                -- The square is set to 1, so the result of the first multiplication will be
                -- either 1 or the initial message value
                    if inExp(0) = '1' then
                        tempin <= indata;
                    else
                        tempin(KEYSIZE-1 downto 1) <= (others => '0');
                        tempin(0) <= '1';
                    end if;
                    modreg <= inMod;
                    sqrin(KEYSIZE-1 downto 1) <= (others => '0');
                    sqrin(0) <= '1';
                end if;
            -- after first time, the multiplication and square results are fed back through the multiplier.
            -- The counter (exponent) has been shifted one bit to the right
            -- If the least significant bit of the exponent is '1' the result of the most recent
            -- squaring operation is fed to the multiplier.
            -- Otherwise, the square value is set to 1 to indicate no multiplication.
            else
                tempin <= tempout;
                if count(0) = '1' then
                    sqrin <= square;
                else
                    sqrin(KEYSIZE-1 downto 1) <= (others => '0');
                    sqrin(0) <= '1';
                end if;
            end if;
        end if;

    end process setupmult;
    
    -- this process enables the multipliers when it is safe to do so
    crypto: process (clk, reset, done, ds, count, bothrdy) is
    begin
        
        if reset = '1' then
            multgo <= '0';
        elsif rising_edge(clk) then
            if done = '1' then
                if ds = '1' then
                -- first time through - automatically trigger first multiplier cycle
                    multgo <= '1';
                end if;
            -- after first time, trigger multipliers when both operations are complete
            elsif count /= 0 then
                if bothrdy = '1' then
                    multgo <= '1';
                end if;
            end if;
            -- when multipliers have been started, disable multiplier inputs
            if multgo = '1' then
                multgo <= '0';
            end if;
        end if;

    end process crypto;

end Behavioral;
