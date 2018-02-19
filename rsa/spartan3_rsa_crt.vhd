library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Spartan3RSACRT is
  port ( btnC : in std_logic;
         btnU : in std_logic;
         btnL : in std_logic;
			txd : out std_logic;
         clk : in std_logic;
         led : out std_logic_vector(1 downto 0));
end Spartan3RSACRT;

architecture synthesis of Spartan3RSACRT is

component RSA_CRT is
  Generic (KEYSIZE: integer := 40);
  port ( plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
         fault_signal : in std_logic;
         ledout : out std_logic;
         clk: in std_logic;
         ds: in std_logic;
         reset: in std_logic;
         ready: out std_logic);
end component;

component uart_transmitter is
	generic(DATA_SIZE: integer := 40);
	port(clock: in std_logic;
		  txd: out std_logic;
		  reset: in std_logic;
		  ds: in std_logic;
		  data_to_send: in std_logic_vector(DATA_SIZE-1 downto 0));
end component;

signal plaintext: std_logic_vector(39 downto 0);
signal rsa_ready: std_logic;


begin
 
  led(0) <= rsa_ready;
  
  rsa: RSA_CRT 
  PORT MAP( plaintext => plaintext,
            fault_signal => btnL,
            ledout => led(1),
            clk => clk,
            ds => btnU,
            reset => btnC,
            ready => rsa_ready);

	uart: uart_transmitter
	PORT MAP( clock => clk,
		       txd => txd,
				 reset => btnU,
				 ds => rsa_ready,
				 data_to_send => plaintext);
				 
end synthesis;
