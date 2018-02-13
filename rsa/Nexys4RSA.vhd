library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4RSA is
  port ( btnC : in std_logic; -- les 2 boutons
         btnU : in std_logic;
         clk : in std_logic; -- horloge
         led : out std_logic_vector (1 downto 0); -- les 2 leds);
end Nexys4RSA;

architecture synthesis of Nexys4RSA is

component RSACypher is
  Generic (KEYSIZE: integer := 40);
  port ( plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
         clk: in std_logic;
         ds: in std_logic;
         reset: in std_logic;
         ready: out std_logic);
end component;

signal plaintext: std_logic_vector(39 downto 0);

begin

  -- 2 leds éteintes
  led(1 downto 0) <= (others => '0');
  
  rsa: RSAcypher 
  PORT MAP( plaintext => plaintext,
            clk => clk,
            ds => btnU,
            reset => btnC,
            ready => led(0));

end synthesis;
