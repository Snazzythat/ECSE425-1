LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY tb_functional_processor IS
END tb_functional_processor;
 
ARCHITECTURE behavior OF tb_functional_processor IS 
 
	type state_type is (init);
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	COMPONENT functionalProcessor
    PORT(
         clock : IN  std_logic;
			reset : IN std_logic
        );
    END COMPONENT;
    
	
   --Inputs
   signal clk : std_logic := '0';
   

   -- Clock period definitions
   constant clk_period : time := 5 ns;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: functionalProcessor 
		PORT MAP (
          clock => clk,
		reset => '0'
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process (clk)
   begin		
      if(clk'event and clk='1') then
			case state is
				when init =>
					state <= init;				
				when others =>
			end case;
			
		end if;
   end process;

END behavior;
