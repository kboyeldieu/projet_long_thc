library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_signed.all;

entity modinv is
	Generic(MPWID: integer);
	Port( invop : in std_logic_vector(MPWID-1 downto 0);
	      modulus : in std_logic_vector(MPWID-1 downto 0);
	      result : out std_logic_vector(MPWID-1 downto 0);
	      clk : in std_logic;
	      ds : in std_logic;
	      reset : in std_logic;
	      ready : out std_logic);
end modinv;

architecture modinv1 of modinv is

component divunsigned is
Generic (MPWID: integer);
    Port ( dividend : in std_logic_vector(MPWID-1 downto 0);
           divisor : in std_logic_vector(MPWID-1 downto 0);
           quotient : out std_logic_vector(MPWID-1 downto 0);
			  remainder : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
			  reset : in std_logic;
			  ready: out std_logic);
end component;

component modmult is
    Generic (MPWID: integer);
    Port ( mpand : in std_logic_vector(MPWID-1 downto 0);
           mplier : in std_logic_vector(MPWID-1 downto 0);
           modulus : in std_logic_vector(MPWID-1 downto 0);
           product : out std_logic_vector(MPWID-1 downto 0);
           clk : in std_logic;
           ds : in std_logic;
           reset : in std_logic;
           ready : out std_logic);
end component;


--local signals for this component
signal localmodulus : std_logic_vector(MPWID-1 downto 0); 
signal localinvop : std_logic_vector(MPWID-1 downto 0); 
signal localx0 : std_logic_vector(MPWID-1 downto 0); 
signal localx0mult : std_logic_vector(2*MPWID-1 downto 0);
signal localsavex0 : std_logic_vector(MPWID-1 downto 0);
signal localx1 : std_logic_vector(MPWID-1 downto 0);
signal localquotient : std_logic_vector(MPWID-1 downto 0);
signal tmpmodulus : std_logic_vector(MPWID-1 downto 0);
signal step : std_logic_vector(3 downto 0);
signal first : std_logic;


--local signals to comunicate with divunsigned
signal dividend_local : std_logic_vector(MPWID-1 downto 0);
signal divisor_local : std_logic_vector(MPWID-1 downto 0);
signal quotient_local: std_logic_vector(MPWID-1 downto 0);
signal remainder_local : std_logic_vector(MPWID-1 downto 0);
signal ds_div : std_logic;
signal ready_div : std_logic;
signal is_negative : std_logic;


--local signals to comunicate with modmult
signal mpand_local : std_logic_vector(MPWID-1 downto 0);
signal mplier_local : std_logic_vector(MPWID-1 downto 0);
signal modulus_local: std_logic_vector(MPWID-1 downto 0);
signal product_local : std_logic_vector(MPWID-1 downto 0);
signal ds_mult : std_logic;
signal ready_mult : std_logic;
begin
	div: divunsigned
	Generic Map(MPWID => MPWID)
	PORT MAP(dividend => dividend_local,
           divisor => divisor_local,
           quotient => quotient_local,
			  remainder => remainder_local,
           clk  => clk,
           ds => ds_div,
			  reset => reset,
			  ready => ready_div);
			  
			  
	mult : modmult
	Generic Map(MPWID => MPWID)
	PORT MAP(mpand => mpand_local,
           mplier => mplier_local,
           modulus => modulus_local,
           product => product_local,
           clk => clk,
           ds => ds_mult,
           reset => reset,
           ready => ready_mult);
	
	modinv : process(clk, reset, ds, first) is
	begin
		if reset = '1' then
			first <= '1';
			ready <= '0';
		elsif rising_edge(clk) then
			if first = '1' then
				if ds = '1' then
                                        --initialization of all variables useful for the computation
					ready <= '0';
					localmodulus <= modulus;
					localinvop <= invop;
					localx0 <= (others => '0');
					localx1(MPWID-1 downto 1) <= (others => '0');
					localx1(0) <= '1';
					first <= '0';
					result <= (others => '0');
					step <= "0000";
				end if;
			elsif signed(localinvop) <= 1 and step = "0000" then
                            --computation finished, we return the result
				step <= "1111";
				if signed(localx1) < 0 then
                                        --if result <0, we add the modulus
					result <= std_logic_vector(signed(localx1) + signed(modulus));
				else
					result <= localx1;
				end if;
                                --component ready to deliver the result
				ready <= '1';
				first <= '1';
			else
				if step = "0000" then
            --first step of computation, we need the result of the euclidian division of localinvop by localmodulus
					
					if ready_div = '1' then
						if is_negative = '1' then
							localquotient <= std_logic_vector(signed(-quotient_local));
						else
							localquotient <= quotient_local;
						end if;
						tmpmodulus <= localmodulus;
						ds_div <= '0';
						step <= "0001";
					else
						is_negative <= localinvop(MPWID-1);
						dividend_local <= std_logic_vector(abs(signed(localinvop)));
						divisor_local <= localmodulus;
						ds_div <= '1';
					end if;
						
				elsif step = "0001" then
				--second step, we need the result of localinvop % localmodulus assigned to localmodulus
				
               if ready_div = '1' then
						if is_negative = '1' then
							localmodulus <= localmodulus - remainder_local;
						else
							localmodulus <= remainder_local;						
						end if;
						ds_div <= '0';
						step <= "0010"; 
					else
						is_negative <= localinvop(MPWID-1);
						dividend_local <= std_logic_vector(abs(signed(localinvop)));
						divisor_local <= localmodulus;
						ds_div <= '1';
					end if;
				elsif step = "0010" then
                                        --third step, we need x0 = x1 - q * x0
					localinvop <= tmpmodulus;
					localsavex0 <= localx0;
					localx0mult <= std_logic_vector(signed(localx1) - (signed(localquotient) * signed(localx0)));
					--go to next step
                                        step <= "0011";
				elsif step = "0011" then
                                        --last step, we assign previous result to local signals
					localx0 <= localx0mult(MPWID-1 downto 0);
					localx1 <= localsavex0;
                                        --loop to first step
					step <= "0000";
				end if;
			end if;
		end if;
	end process modinv;
	
	

end modinv1;

