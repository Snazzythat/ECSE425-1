LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity functionalProcessor is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock : in std_logic;
		reset : in std_logic
	);
end functionalProcessor;

architecture behaviour of functionalProcessor is

	-- CONSTANTS --
	Constant Num_Bits_in_Byte	: integer := 8; 
	Constant Num_Bytes_in_Word	: integer := 4; 
	Constant Memory_Size		: integer := 256; 

	-- MULTI-STATE SIGNAL --
	signal currentInstruction : std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
	
	-- FSM --
	type state_type is (init, readInstruction1, readInstruction2, done);
	signal state: state_type:=init;
	
	-- Instruction Memory signal
	signal programCounter		: integer 	:= 0;
	signal InstMem_word_byte 	: std_logic	:= '1';
	signal InstMem_re 			: std_logic := '0';
	signal InstMem_rd_ready 	: std_logic	:= '0';
	signal InstMem_data 		: std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
	signal InstMem_init 		: std_logic	:= '0';
	signal InstMem_dump 		: std_logic	:= '0';

	 
	COMPONENT Main_Memory
		generic (
			File_Address_Read : string :="Init.dat";
			File_Address_Write : string :="MemCon.dat";
			Mem_Size_in_Word : integer:=256;	
			Num_Bytes_in_Word: integer:=4;
			Num_Bits_in_Byte: integer := 8; 
			Read_Delay: integer:=0; 
			Write_Delay:integer:=0
		 );
		PORT(
			clk 		: IN  std_logic;
			address 	: IN  integer;
			Word_Byte	: in std_logic;
			we 			: IN  std_logic;
			wr_done 	: OUT  std_logic;
			re 			: IN  std_logic;
			rd_ready 	: OUT  std_logic;
			data 		: INOUT  std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
			initialize 	: IN  std_logic;
			dump 		: IN  std_logic
        );
    END COMPONENT;
	
	
begin

	InstMem: Main_Memory 
	generic map (
			File_Address_Read 	=>"Init.dat",
			File_Address_Write 	=>"MemCon.dat",
			Mem_Size_in_Word 	=>256,
			Num_Bytes_in_Word	=>4,
			Num_Bits_in_Byte	=>8,
			Read_Delay			=>0,
			Write_Delay			=>0
		 )
		PORT MAP (
			clk 		=> clock,
			address 	=> programCounter,
			Word_Byte 	=> InstMem_word_byte,
			we 			=> '0',
			re 			=> InstMem_re,
			rd_ready 	=> InstMem_rd_ready,
			data 		=> InstMem_data,          
			initialize 	=> InstMem_init,
			dump 		=> InstMem_dump
        );
        
	
	fsm: process (clock)
	begin		
      if(clock'event and clock='1') then
			
			case state is
				when init =>
					InstMem_init 	<= '1'; 
					state 			<= readInstruction1;
					
				when readInstruction1 =>	
					InstMem_re <='1';
					InstMem_init <= '0';
					state <= readInstruction2;				
				
				when readInstruction2 =>
					
					-- state initialisation --
					InstMem_init 	<= '0';
					InstMem_re 		<= '1';

					-- state processing --
					if (InstMem_rd_ready = '1') then -- the output is ready on the memory bus
						state <= readInstruction1; 
						currentInstruction <= InstMem_data;
						programCounter <= programCounter + 4; -- update program counter
						InstMem_re <='0';
					else
						state <= readInstruction2; -- stay in this state till you see InstMem_rd_ready='1';
					end if;
					
				when done =>
					
				
				when others =>
			end case;
			
		end if;
   end process;

end behaviour;