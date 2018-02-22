
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity diviseur_horloge is
   Generic ( facteur : INTEGER := 8 );
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
	   new_clk : out STD_LOGIC);
			  
end diviseur_horloge;

architecture Behavioral of diviseur_horloge is

begin

	process (clk, reset)
	
	variable cpt_aux : INTEGER;
	begin
		if (reset = '1') then
			cpt_aux := 0;
		elsif (rising_edge(clk)) then 			
			if (cpt_aux = facteur-1) then
				new_clk <= '1';
				cpt_aux := 0;
			else
				cpt_aux := cpt_aux + 1;
				new_clk <= '0';
			end if;
		end if;
	end process;

end Behavioral;

