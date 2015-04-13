
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY tb_branch_predictor IS
END tb_branch_predictor;
 
ARCHITECTURE behavior OF tb_branch_predictor IS 
 
	type state_type is (init);
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	COMPONENT branchPredictor
    PORT(
			init 			: in std_logic;
			address 		: in std_logic_vector(7 downto 0);
			update			: in std_logic;
			update_value 	: in std_logic;
			prediction 		: out std_logic;
        );
    END COMPONENT;
    
	
   --Inputs
   signal clk : std_logic := '0';
   

   -- Clock period definitions
   constant clk_period : time := 5 ns;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
	
	init_predictor 			: std_logic;
	address 		: std_logic_vector(7 downto 0);
	update			: std_logic;
	update_value 	: std_logic;
	prediction 		: std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: functionalProcessor 
		PORT MAP (
			init 			=> init_predictor;
			address 		=> address;
			update			=> update;
			update_value 	=> update_value;
			prediction 		=> prediction;
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
					init_predictor <= '1';
					state <= init;				
				when others =>
			end case;
			
		end if;
   end process;

END behavior;
