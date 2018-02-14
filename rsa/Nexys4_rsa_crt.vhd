use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4RSACRT is
  port ( btnC : in std_logic;
         btnU : in std_logic;
         clk : in std_logic;
         led : out std_logic_vector(1 downto 0));
end Nexys4RSACRT;

architecture synthesis of Spartan3RSA is

component RSA_CRT is
  Generic (KEYSIZE: integer := 40);
  port ( plaintext: out std_logic_vector(KEYSIZE-1 downto 0);
         fault_signal : in std_logic;
         ledout : out std_logic
         clk: in std_logic;
         ds: in std_logic;
         reset: in std_logic;
         ready: out std_logic);
end component;

signal plaintext: std_logic_vector(39 downto 0);

begin
 
  rsa: RSA_CRT 
  PORT MAP( plaintext => plaintext,
            fault_signal => btnL,
            ledout => led(1),
            clk => clk,
            ds => btnU,
            reset => btnC,
            ready => led(0));

end synthesis;
