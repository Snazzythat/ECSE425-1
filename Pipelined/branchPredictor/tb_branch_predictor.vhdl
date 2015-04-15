
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY tb_branch_predictor IS
END tb_branch_predictor;
 
ARCHITECTURE behavior OF tb_branch_predictor IS 
 
	type state_type is (init, scenario1, scenario2,scenario3,scenario4,scenario5,scenario6,scenario7,scenario8,scenario9,scenario10,scenario11,scenario12);
 
    -- Component Declaration for the Unit Under Test (UUT)
	 
	COMPONENT branchPredictor
    PORT(
			init 			: in std_logic;
			address 		: in std_logic_vector(7 downto 0);
			update			: in std_logic;
			update_value 	: in std_logic;
			prediction 		: out std_logic;
			clk				: in std_logic
        );
    END COMPONENT;
    
	
   --Inputs
   signal clk : std_logic := '0';
   

   -- Clock period definitions
   constant clk_period : time := 5 ns;
	
	-- Tests Simulation State 
	signal state:	state_type:=init;
	
	signal init_predictor 	: std_logic;
	signal address 			: std_logic_vector(7 downto 0);
	signal update			: std_logic;
	signal update_value 	: std_logic;
	signal prediction 		: std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: branchPredictor 
		PORT MAP (
			init 			=> init_predictor,
			address 		=> address,
			update			=> update,
			update_value 	=> update_value,
			prediction 		=> prediction,
			clk				=> clk
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
					state <= scenario1;	
				when scenario1 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '0';
					update_value <= '1';
					state <= scenario8;	
				when scenario8 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '1';
					update_value <= '1';
					state <= scenario2;	
				when scenario2 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '1';
					update_value <= '1';
					state <= scenario3;	
				when scenario3 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '0';
					update_value <= '1';
					state <= scenario4;	
				when scenario4 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '1';
					update_value <= '0';
					state <= scenario5;	
				when scenario5 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '0';
					update_value <= '0';
					state <= scenario6;	
				when scenario6 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '1';
					update_value <= '0';
					state <= scenario7;	
				when scenario7 =>
					init_predictor <= '0';
					address <= "11111100";
					update <= '0';
					update_value <= '0';
					--state <= scenario8;	
				when others =>
			end case;
			
		end if;
   end process;

END behavior;
