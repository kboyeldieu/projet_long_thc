library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_transmitter is
	generic(DATA_SIZE: integer := 40);
	port(clock: in std_logic;
		  txd: out std_logic);
		  --reset: in std_logic);
		  ---ds: in std_logic);
		  --data_to_send: in std_logic_vector(DATA_SIZE-1 downto 0));
end uart_transmitter;

architecture Behavioral of uart_transmitter is
constant system_speed: natural := 50e6;

signal baudrate_clock, second_clock, old_second_clock: std_logic;
signal bit_counter: unsigned(3 downto 0) := x"9";
signal shift_register: unsigned(9 downto 0) := (others => '0');
signal char_index: natural range 0 to DATA_SIZE-1 := 0;
signal data_to_send: std_logic_vector(DATA_SIZE-1 downto 0)	:= x"1234567890";

component clock_generator 
	generic(clock_in_speed, clock_out_speed: integer);
	port(clock_in: in std_logic;
		  clock_out: out std_logic);
end component;

begin

	baudrate_generator: clock_generator
	generic map(clock_in_speed => system_speed, clock_out_speed => 115200)
	port map(clock_in => clock,
				clock_out => baudrate_clock);

	second_generator: clock_generator
	generic map(clock_in_speed => system_speed, clock_out_speed => 1)
	port map(
		clock_in => clock,
		clock_out => second_clock);

	
	send: process(baudrate_clock)
	
	begin
		
		
		--if reset = '1' then
		--	bit_counter <= x"9";
		--	char_index <= 0;
		--else
			---if ds = '1' then
			--	bit_counter <= x"9";
			--	char_index <= 0;
			--else
				if baudrate_clock'event and baudrate_clock = '1' then
					txd <= '1';
					if bit_counter = 9 then
						if second_clock /= old_second_clock then
							old_second_clock <= second_clock;
							if second_clock = '1' then
								bit_counter <= x"0";
								shift_register <= b"1" & unsigned(data_to_send(char_index+7 downto char_index)) & b"0";
								char_index <= char_index + 8;
							end if;
						end if;
					else
						txd <= shift_register(0);
						bit_counter <= bit_counter + 1;
						shift_register <= shift_register ror 1;
					end if;
				end if;
			--end if;
		--end if;
	end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_generator is
generic(clock_in_speed, clock_out_speed: integer);
port(
clock_in: in std_logic;
clock_out: out std_logic);
end entity clock_generator;

architecture Behavioral of clock_generator is

function num_bits(n: natural) return natural is
begin
if n > 0 then
return 1 + num_bits(n / 2);
else
return 1;
end if;
end num_bits;

constant max_counter: natural := clock_in_speed / clock_out_speed / 2;
constant counter_bits: natural := num_bits(max_counter);

signal counter: unsigned(counter_bits - 1 downto 0) := (others => '0');
signal clock_signal: std_logic;

begin
update_counter: process(clock_in)
begin
if clock_in'event and clock_in = '1' then
if counter = max_counter then
counter <= to_unsigned(0, counter_bits);
clock_signal <= not clock_signal;
else
counter <= counter + 1;
end if;
end if;
end process;

clock_out <= clock_signal;
end Behavioral;
