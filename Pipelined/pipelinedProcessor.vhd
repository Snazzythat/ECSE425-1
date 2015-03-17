LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity pipelinedProcessor is

end pipelinedProcessor;

architecture behaviour of pipelinedProcessor is

	-- State signals
	type state_type is (init);
	signal state:	state_type:=init;

	-- Clock signals
   	constant clk_period : time := 5 ns;
    signal clk : std_logic := '0';

BEGIN

 -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   pipeline: process (clk)
   begin		
      if(clk'event and clk='1') then
			case state is
				when init =>

					state <= init;				
				when others =>
			end case;
			
		end if;
   end process;

end behaviour;