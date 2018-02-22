library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys2RSACRT is
    Generic (KEYSIZE: integer := 80);
    port ( btnC : in std_logic;
           btnU : in std_logic;
           btnL : in std_logic;
           txd : out std_logic;
           clk : in std_logic;
           led : out std_logic_vector(1 downto 0));
end Nexys2RSACRT;

architecture synthesis of Nexys2RSACRT is

component RSA_CRT is
    Generic (KEYSIZE: integer);
    port ( plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
           fault_signal : in std_logic;
           ledout : out std_logic;
           clk: in std_logic;
           ds: in std_logic;
           reset: in std_logic;
           ready: out std_logic);
end component;

component uart_transmitter is
    Generic(DATA_SIZE: integer);
    port( clock: in std_logic;
          txd: out std_logic;
          reset: in std_logic;
          ds: in std_logic;
          data_to_send: in std_logic_vector(DATA_SIZE-1 downto 0));
end component;

signal plaintext: std_logic_vector(KEYSIZE-1 downto 0);
signal rsa_ready: std_logic;


begin
 
    led(0) <= rsa_ready;
  
    rsa: RSA_CRT
    GENERIC MAP(KEYSIZE => KEYSIZE)
    PORT MAP( plaintext => plaintext,
              fault_signal => btnL,
              ledout => led(1),
              clk => clk,
              ds => btnU,
              reset => btnC,
              ready => rsa_ready);

    uart: uart_transmitter
    GENERIC MAP(DATA_SIZE => KEYSIZE)
    PORT MAP( clock => clk,
              txd => txd,
              reset => btnC,
              ds => rsa_ready,
              data_to_send => plaintext);
         
end synthesis;
