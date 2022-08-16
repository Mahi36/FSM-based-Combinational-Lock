library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity CodeLock is
 port( CLOCK_50: in std_logic;
 sw: in std_logic_vector(9 downto 0);
 LEDR: out std_logic_vector(4 downto 0) );
end CodeLock ;

architecture behavior of CodeLock is

signal state, nextstate: std_logic_vector(4 downto 0) := "00000";
signal UNLOCK : std_logic :='0';
signal code1 : std_logic_vector(3 downto 0) := "0000";
signal clk : std_logic := '0' ;

begin
		--nextstate_decoder: -- next state decoding part assume codelock-0123
	process(state, sw)
		begin
			case state is
				when "00000" => if (sw = "1000000000")  
											then     
												nextstate <= "00001"; 	code1 <="0000";   	--in s0 state,when pressed goes to s1 state
										else 
												nextstate <= "00000"; 	code1 <="0000";
								end if;
				 when "00001" => if (sw = "1000000000") 
											then     
												nextstate <= "00001";	code1 <="0000";   	--waiting in s1 state
										elsif (sw = "0000000000" ) 
											then  
												nextstate <= "00010";	code1 <="0001"; 	--released ,goes to s2 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00010" => if ( sw = "0000000000") 
											then     
												nextstate <= "00010";	code1 <="0001";    	--waiting in s2 state
										elsif (sw = "0100000000") 
											then  
												nextstate <= "00011";	code1 <="0001";  	--in s2 state,when pressed goes to s3 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00011" => if (sw = "0100000000") 
											then     
												nextstate <= "00011";	code1 <="0001";     --waiting in s3 state
										elsif (sw = "0000000000") 
											then  
												nextstate <= "00100";	code1 <="0011";     --released ,goes to s4 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00100" => if (sw = "0000000000") 
											then 
												nextstate <= "00100";	code1 <="0011";     --waiting in s4 state
										elsif (sw = "0010000000") 
											then 
												nextstate <= "00101";	code1 <="0011";    	--in s4 state,when pressed goes to s5 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00101" => if (sw = "0010000000") 
											then 
												nextstate <= "00101";	code1 <="0011";     --waiting in s5 state
										elsif (sw = "0000000000") 
											then 
												nextstate <= "00110";	code1 <="0111";     --released ,goes to s6 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00110" => if (sw ="0000000000") 
											then 
												nextstate <= "00110";	code1 <="0111";     --waiting in s6 state
										elsif (sw = "0001000000") 
											then 
												nextstate <= "00111";	code1 <="0111";     --in s6 state,when pressed goes to s7 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "00111" => if (sw = "0001000000") 
											then 
												nextstate <= "00111";	code1 <="0111";     --waiting in s7 state
										elsif (sw ="0000000000") 
											then 
												nextstate <= "01000";	code1 <="1111";     --released ,goes to s8 state
										else 
												nextstate <= "00000";	code1 <="0000";
								end if;
				 when "11111" => 	nextstate <= "00000";			code1 <="0000";
				 when others => 	nextstate <= state + "00001";	code1 <="1111";
			end case;
	end process;

--debug_output: -- display the state
LEDR(3 downto 0) <= code1;
LEDR(4)			 <=	UNLOCK;

--output_decoder: -- output decoder part
	process(state)
		begin
			case state is
				when "00000"|"00001"|"00010"|"00011"|"00100"|"00101"|"00110"|"00111" => UNLOCK <= '0';
				when others => UNLOCK <= '1';												-- unlocked for 24 clock pulses.
			end case;
	end process;

--state_register: -- the state register part (the flipflops)
	process(clk)
		begin
			if rising_edge(clk) 
				then
					state <= nextstate;
			end if;
	end process;

	process(CLOCK_50)
        variable v_count_fast_cycles : integer := 0 ;
        variable v_slow_down_factor : integer := 4096*4096 ;
--        variable v_slow_down_factor : integer := 2048*2048 ;
--        variable v_slow_down_factor : integer := 2*2 ;
        
		begin
			if rising_edge(CLOCK_50) 
				then
					if ( v_count_fast_cycles < v_slow_down_factor/2 ) 
						then
							v_count_fast_cycles := v_count_fast_cycles + 1 ;
					else 
						clk <= not clk ;
						v_count_fast_cycles := 0 ;
					end if ;
			end if ;    
    end process ;
    
end behavior;