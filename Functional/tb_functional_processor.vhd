
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY tb_Main_Memory IS
END tb_Main_Memory;
 
ARCHITECTURE behavior OF tb_Main_Memory IS 
 
	type state_type is (init);
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	COMPONENT functional
    PORT(
         clock : IN  std_logic
        );
    END COMPONENT;
    
	
   --Inputs
   signal clk : std_logic := '0';
   

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: functional 
		PORT MAP (
          clock => clk,
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
			data <= (others=>'Z');
			case state is
				when init =>
					state <= init;				
				when others =>
			end case;
			
		end if;
   end process;

END;
