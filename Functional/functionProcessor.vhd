LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity functionProcessor is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock : in std_logic;
		reset : in std_logic
	);
end functionProcessor;

architecture behaviour of functionProcessor is

	-- CONSTANTS --
	Constant Num_Bits_in_Byte	: integer := 8; 
	Constant Num_Bytes_in_Word	: integer := 4; 
	Constant Memory_Size		: integer := 256; 

	-- MULTI-STATE SIGNAL --
	signal currentInstruction : std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
	
	-- FSM --
	type state_type is (init, readInstruction1, readInstruction2, processInstruction, done);
	signal state: state_type:=init;
	
	----------------------
	-- Memory Component --
	----------------------

	-- Instruction Memory signal
	signal programCounter		: integer 	:= 0;
	signal programCounter_reg	: integer;
	signal programCounter_adr	: std_logic_vector(31 downto 0);
	signal branch_adr			: std_logic_vector(31 downto 0);
	signal branch_sel			: std_logic;	
	signal branch_mux			: std_logic_vector(31 downto 0);
	signal jump_adr				: std_logic_vector(31 downto 0);
	signal jump_mux				: std_logic_vector(31 downto 0);
	
	signal InstMem_word_byte 	: std_logic	:= '1';
	signal InstMem_re 			: std_logic := '0';
	signal InstMem_rd_ready 	: std_logic	:= '0';
	signal InstMem_data 		: std_logic_vector(Num_Bytes_in_Word*Num_Bits_in_Byte-1 downto 0);
	signal InstMem_init 		: std_logic	:= '0';
	signal InstMem_dump 		: std_logic	:= '0';
 
	COMPONENT Main_Memory
		generic (
			File_Address_Read 	: string :="Init.dat";
			File_Address_Write 	: string :="MemCon.dat";
			Mem_Size_in_Word 	: integer:=256;	
			Num_Bytes_in_Word	: integer:=4;
			Num_Bits_in_Byte	: integer := 8; 
			Read_Delay			: integer:=0; 
			Write_Delay			: integer:=0
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
    
    ----------------------------
	-- Main Control Component --
	----------------------------
	
	-- Main control signal
	signal MC_RegDst	: std_logic	:= '0';
	signal MC_Jump		: std_logic	:= '0';
	signal MC_Branch	: std_logic	:= '0';
	signal MC_MemRead	: std_logic	:= '0';
	signal MC_MemtoReg	: std_logic	:= '0';
	signal MC_MemWrite	: std_logic	:= '0';
	signal MC_AluSrc	: std_logic	:= '0';
	signal MC_RegWrite	: std_logic	:= '0';
	signal MC_NotZero	: std_logic := '0';
	signal MC_LUI	: std_logic := '0';
	signal MC_ALUOp		: std_logic_vector(2 downto 0);
	    
	COMPONENT control 
	PORT (
		clock		: in std_logic;
		Instruction	: in std_logic_vector(31 downto 26);
		RegDst		: out std_logic;
		Jump		: out std_logic;
		Branch		: out std_logic;
		MemRead		: out std_logic;
		MemtoReg	: out std_logic;
		MemWrite	: out std_logic;
		AluSrc		: out std_logic;
		RegWrite	: out std_logic;
		NotZero	: out std_logic;
		LUI		: out std_logic;
		ALUOp		: out std_logic_vector(2 downto 0)
	);
	END COMPONENT;
	
	-------------------------
	-- Registers Component --
	-------------------------
	
	-- Registers output signal
	signal regData_1 : std_logic_vector(31 downto 0);
	signal regData_2 : std_logic_vector(31 downto 0);
	signal writeRegisterMuxResult : STD_LOGIC_VECTOR (4 DOWNTO 0);
	signal writeLOHI : std_logic;
	signal LO_reg	  : std_logic_vector(31 downto 0);
	signal HI_reg	  : std_logic_vector(31 downto 0);
	
	COMPONENT registers
	port (
		clock		: in std_logic;
		read_reg_1	: in std_logic_vector(4 downto 0);
		read_reg_2	: in std_logic_vector(4 downto 0);
		write_reg	: in std_logic_vector(4 downto 0);
		writedata	: in std_logic_vector(31 downto 0);
		regwrite	: in std_logic;
		readdata_1	: out std_logic_vector(31 downto 0);
		readdata_2	: out std_logic_vector(31 downto 0);
		
		writeLOHI	: in std_logic;
		LOin			: in std_logic_vector(31 downto 0);
		HIin			: in std_logic_vector(31 downto 0);
		LOout			: out std_logic_vector(31 downto 0);
		HIout			: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;
	
	---------------------------
	-- ALU Control Component --
	---------------------------
	
	-- ALU control output signal
	signal operation : std_logic_vector(3 downto 0);
	
	COMPONENT ALU_control
		port (
			ALUOp		: in std_logic_vector(2 downto 0);
			funct 		: in std_logic_vector(5 downto 0);
			operation	: out std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	
	-------------------
	-- ALU Component --
	-------------------
	
	-- ALU  signals
	signal signext 	: std_logic_vector(31 downto 0);
	signal databmux: std_logic_vector(31 downto 0);
	signal datab 	: std_logic_vector(31 downto 0);
	signal databadder	: std_logic_vector(31 downto 0);
	signal ALUResult: std_logic_vector(31 downto 0);
	signal HI		: std_logic_vector(31 downto 0);
	signal LO		: std_logic_vector(31 downto 0);
	signal Zero		: std_logic;
		
	COMPONENT ALU
		port
		(
			dataa 	: in std_logic_vector (31 downto 0);
			datab 	: in std_logic_vector (31 downto 0);
			control 	: in std_logic_vector (3  downto 0);
			shamt		: in std_logic_vector (4  downto 0);
			result 	: out std_logic_vector(31 downto 0);
			HI 		: out std_logic_vector(31 downto 0);
			LO 		: out std_logic_vector(31 downto 0);
			zero		: out std_logic
		);
	END COMPONENT;
	
BEGIN

	------------------------
	-- Instruction Memory --
	------------------------
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
        
    ----------------------------
	-- Main Control Component --
	----------------------------    
	MainControl : control 
	PORT MAP (
		clock		=> clock,
		Instruction	=> currentInstruction(31 downto 26),
		RegDst		=> MC_RegDst,
		Jump		=> MC_Jump,
		Branch		=> MC_Branch,
		MemRead		=> MC_MemRead,
		MemtoReg	=> MC_MemtoReg,
		MemWrite	=> MC_MemWrite,
		AluSrc		=> MC_AluSrc,
		RegWrite	=> MC_RegWrite,
		NotZero		=> MC_NotZero,
		LUI		=> MC_LUI,
		ALUOp		=> MC_ALUOp
	);
	
	-------------------------------------
	-- WriteRegister Mux 2-1 Component --
	-------------------------------------
	with MC_RegDst select
		writeRegisterMuxResult <= 
			currentInstruction(20 downto 16) when '0',
			currentInstruction(15 downto 11) when '1',
			(others => 'X') when others;
	
	--------------------
	-- Main Registers --
	--------------------
	MainRegisters : registers
	PORT MAP (
		clock		=> clock,
		read_reg_1	=> currentInstruction(25 downto 21),
		read_reg_2	=> currentInstruction(20 downto 16),
		write_reg	=> writeRegisterMuxResult,
		writedata	=> (OTHERS => '0'), -- TODO CHANGE IT WHEN DATAMEMORY IS IMPLEMENTED
		regwrite	=> MC_RegWrite,
		readdata_1	=> regData_1,
		readdata_2	=> regData_2,
		writeLOHI	=> writeLOHI,
		LOin			=> LO,
		HIin			=> HI,
		LOout			=> LO_reg,
		HIout			=> HI_reg
	);
    
	-----------------
	-- ALU Control --
	-----------------
	ALUControl : ALU_control
	PORT MAP (
		ALUOp		=> MC_ALUOp,
		funct 		=> currentInstruction(5 downto 0),
		operation	=> operation
	);
	
	-----------------
	-- Sign-extend --
	-----------------
	
	with MC_LUI select
		signext(15 downto 0) <= 
			currentInstruction(15 downto 0) when '0',
			(others => '0') when '1',
			(others => 'X') when others;
			
	with MC_LUI select
		signext(31 downto 16) <= 
			(others => currentInstruction(15)) when '0',
			currentInstruction(15 downto 0) when '1',
			(others => 'X') when others;
			
	-----------------------------
	-- datab Mux 2-1 Component --
	-----------------------------
	with MC_RegDst select
		databmux <= 
			regData_2 when '0',
			signext when '1',
			(others => 'X') when others;
	datab <= databmux;
	-------------------
	-- ALU Component --
	-------------------
	ALUComponent: ALU
	PORT MAP(
		dataa 	=> regData_1,
		datab 	=> datab,
		control 	=> operation,
		shamt		=> currentInstruction(10 downto 6),
		result 	=> ALUResult,
		HI 		=> HI,
		LO 		=> LO,
		zero	=> Zero
	);
	
	databadder <=  signext(29 downto 0) & "00";
	-----------------------
	-- ALU Add Component --
	-----------------------
	ALUAdder: ALU
	PORT MAP(
		dataa 	=> programCounter_adr,
		datab 	=> databadder,
		control => "0010", --add
		shamt => currentInstruction(10 downto 6),
		result 	=> branch_adr
	);
	
	branch_sel <= MC_Branch AND (Zero XOR MC_NotZero); -- select line for branch mux
	
	------------------------------
	-- branch Mux 2-1 Component --
	------------------------------
	with branch_sel select
		branch_mux <= 
			programCounter_adr when '0',
			branch_adr when '1',
			(others => 'X') when others;
	
	jump_adr <= programCounter_adr(31 downto 28) & currentInstruction(25 downto 0) & "00";
	
	----------------------------
	-- jump Mux 2-1 Component --
	----------------------------
	with MC_Jump select
		jump_mux <= 
			branch_mux when '0',
			jump_adr when '1',
			(others => 'X') when others;
	
	---------------
	-- FSM LOGIC --
	---------------
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
						currentInstruction <= InstMem_data;
						programCounter <= programCounter + 4; -- update program counter
						InstMem_re <='0';
						state <= processInstruction;
					else
						state <= readInstruction2; -- stay in this state till you see InstMem_rd_ready='1';
					end if;
					
				when processInstruction =>
					
				
				when others =>
			end case;
			
		end if;
   end process;

end behaviour;