LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Sandbox is

end Sandbox;

architecture behaviour of Sandbox is
	
	-- Clock signals
   	constant clk_period : time := 4 ns;
    signal clk : std_logic := '0';
    signal clk_mem : std_logic := '0';
    
	component ProgramCounter IS
		PORT
		(
			clock		: in std_logic;
			PC_Write	: in std_logic;
			address_in	: in std_logic_vector(31 downto 0);
			address_out	: out std_logic_vector(31 downto 0)

		);
	END component;

	COMPONENT Main_Memory
		generic (
			File_Address_Read 	: string :="Init.dat";
			File_Address_Write 	: string :="MemCon.dat";
			Mem_Size_in_Word 	: integer:=2048;	
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
    
    component IFID IS
	PORT
	(
		clock			: IN STD_LOGIC;
		IFID_Write		: IN STD_LOGIC;
		address_in		: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
		instruction_in	: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
		address_out		: OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
		instruction_out	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	end component;
  
  COMPONENT BranchResolution IS
	PORT(
	  currPCAdd      : in std_logic_vector  (31 downto 0);
	  instruction    : in std_logic_vector  (31  downto 0);
	  regValA        : in std_logic_vector  (31 downto 0);
	  regValB        : in std_logic_vector  (31 downto 0);
	  
	  ifFlush        : out std_logic;
	  nextPCAdd      : out std_logic_vector (31 downto 0)
	);
  END COMPONENT;

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
		NotZero		: out std_logic;
		LUI			: out std_logic;
		ALUOp		: out std_logic_vector(2 downto 0)
	);
	END COMPONENT;

	COMPONENT registers
	port (
		clock		: in std_logic;
		init 		: in std_logic;
		read_reg_1	: in std_logic_vector(4 downto 0);
		read_reg_2	: in std_logic_vector(4 downto 0);
		write_reg	: in std_logic_vector(4 downto 0);
		writedata	: in std_logic_vector(31 downto 0);
		regwrite	: in std_logic;
		readdata_1	: out std_logic_vector(31 downto 0);
		readdata_2	: out std_logic_vector(31 downto 0);
		writeLOHI	: in std_logic;
		LOin		: in std_logic_vector(31 downto 0);
		HIin		: in std_logic_vector(31 downto 0);
		LOout		: out std_logic_vector(31 downto 0);
		HIout		: out std_logic_vector(31 downto 0)
	);
	END COMPONENT;

	COMPONENT HazardDetectionUnit IS
	PORT
	(
		IDEX_MemRead : in std_logic;
		IDEX_RegRt : in std_logic_vector(4 downto 0);
		IFID_RegRs : in std_logic_vector(4 downto 0);
		IFID_RegRt : in std_logic_vector(4 downto 0);
		IFID_Write : out std_logic;
		PC_Write : out std_logic;
		stall :	out std_logic
	);
	END COMPONENT;
	
	component IDEX IS
	PORT
	(
		clock			: IN STD_LOGIC;
		--WB
		RegWrite_in		: IN STD_LOGIC;
		MemtoReg_in		: IN STD_LOGIC;
		--Mem
		Branch_in		: IN STD_LOGIC;
		MemRead_in		: IN STD_LOGIC;
		MemWrite_in		: IN STD_LOGIC;
		--Ex
		ALUop_in		: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		RegDst_in		: IN STD_LOGIC;
		ALUsrc_in		: IN STD_LOGIC;
		--WB
		RegWrite_out	: OUT STD_LOGIC;
		MemtoReg_out	: OUT STD_LOGIC;
		--Mem
		Branch_out		: OUT STD_LOGIC;
		MemRead_out		: OUT STD_LOGIC;
		MemWrite_out	: OUT STD_LOGIC;
		--Ex
		ALUop_out		: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		RegDst_out		: OUT STD_LOGIC;
		ALUsrc_out		: OUT STD_LOGIC;
		
		address_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata1_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata2_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		signextend_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rs_in		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rt_in		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rd_in		: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		
		address_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata1_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata2_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		signextend_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rs_out	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rt_out	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rd_out	: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)

	);
	END component;

 	component ALU_Control IS
	PORT
	(
		ALUOp			: in std_logic_vector(2 downto 0);
		funct 			: in std_logic_vector(5 downto 0);
		operation		: out std_logic_vector(3 downto 0);
		writeLOHI		: out std_logic;
		readLOHI		: out std_logic_vector(1 downto 0)
	);
	END component;

    component ALU IS
	PORT
	(
		dataa 	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab 	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		control : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		shamt	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);

		result 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		HI 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		LO 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero	: OUT STD_LOGIC
	);
	END component;

	component ForwardUnit IS
	PORT
	(
		IDEX_RegRs 		: in std_logic_vector(4 downto 0);
		IDEX_RegRt 		: in std_logic_vector(4 downto 0);
		EXMEM_RegWrite 	: in std_logic;
		EXMEM_RegRd 	: in std_logic_vector(4 downto 0);
		MEMWB_RegWrite 	: in std_logic;
		MEMWB_RegRd 	: in std_logic_vector(4 downto 0);

		forwardA 		: out std_logic_vector(1 downto 0);
		forwardB 		: out std_logic_vector(1 downto 0)
	);
	END component;
	
	component EXMEM IS
	PORT
	(
		clock			: IN STD_LOGIC;
		
		--WB
		RegWrite_in		: IN STD_LOGIC;
		MemtoReg_in		: IN STD_LOGIC;
		--Mem
		Branch_in		: IN STD_LOGIC;
		MemRead_in		: IN STD_LOGIC;
		MemWrite_in		: IN STD_LOGIC;
		--ALU
		result_in 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		HI_in 			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		LO_in 			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero_in			: IN STD_LOGIC;
		datab_in 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
  
    address_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rd_in			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

		--WB
		RegWrite_out	: OUT STD_LOGIC;
		MemtoReg_out	: OUT STD_LOGIC;
		--Mem
		Branch_out		: OUT STD_LOGIC;
		MemRead_out		: OUT STD_LOGIC;
		MemWrite_out	: OUT STD_LOGIC;
		--ALU
		result_out 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		HI_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		LO_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero_out		: OUT STD_LOGIC;
		datab_out 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

    address_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rd_out			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
	END component;

	component MEMWB IS
	PORT
	(
		clock			: IN STD_LOGIC;

		--WB
		RegWrite_in		: IN STD_LOGIC;
		MemtoReg_in		: IN STD_LOGIC;
		--Data Mem
		wr_done_in		: IN STD_LOGIC; 
		rd_ready_in		: IN STD_LOGIC;
		data_in 		: IN STD_LOGIC_VECTOR(31 downto 0);        
		--ALU
		result_in 		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		HI_in 			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		LO_in 			: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero_in			: IN STD_LOGIC;

		Rd_in			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

		--WB
		RegWrite_out	: OUT STD_LOGIC;
		MemtoReg_out	: OUT STD_LOGIC;
		--Data Mem
		wr_done_out		: OUT STD_LOGIC; 
		rd_ready_out	: OUT STD_LOGIC;
		data_out 		: OUT STD_LOGIC_VECTOR(31 downto 0);   
		--ALU
		result_out 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		HI_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		LO_out 			: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		zero_out		: OUT STD_LOGIC;

		Rd_out			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
	END component;

	-- Signals for program counter
	signal PC_Write : std_logic := '0';
	signal address_in : std_logic_vector(31 downto 0);
	signal PCSrcMux : std_logic_vector(31 downto 0);
	signal PC_address : std_logic_vector(31 downto 0);
	signal stall : std_logic := '0';

	-- Instruction Memory signal
	type inst_state_type is (init, read_inst1, read_inst2);
	signal inst_state:	inst_state_type:=init;
	signal InstMem_word_byte 	: std_logic	:= '1';
	signal InstMem_re 			: std_logic := '0';
	signal InstMem_rd_ready 	: std_logic	:= '0';
	signal InstMem_data 		: std_logic_vector(31 downto 0);
	signal InstMem_init 		: std_logic	:= '0';
	signal InstMem_dump 		: std_logic	:= '0';
	signal InstMem_address		: integer:=0;

	-- Data Memory signals
	type data_state_type is (init, idle, read_mem1, read_mem2, write_mem1, write_mem2, dum, fin);
	signal data_state:	data_state_type:=init;
	signal data : std_logic_vector(31 downto 0) := (others => 'Z');
	signal MDR: std_logic_vector(31 downto 0);
	signal DataMem_word_byte 	: std_logic	:= '1';
	signal DataMem_re 			: std_logic := '0';
	signal DataMem_rd_ready 	: std_logic	:= '0';
	signal DataMem_we 			: std_logic;
	signal DataMem_wr_done		: std_logic;
	signal DataMem_data 		: std_logic_vector(31 downto 0);
	signal DataMem_init 		: std_logic	:= '0';
	signal DataMem_dump 		: std_logic	:= '0';
	signal DataMem_address		: integer:=0;

  	signal RegInit : std_logic :='0';
	signal RegWrite	: std_logic;
	signal MemtoReg	: std_logic;
	signal Branch	: std_logic;
	signal MemRead	: std_logic;
	signal MemWrite	: std_logic;
	signal ALUop	: std_logic_vector(2 downto 0);
	signal RegDst	: std_logic;
	signal ALUsrc	: std_logic;
	signal Jump 	: std_logic;
	signal NotZero 	: std_logic;
	signal ID_Zero 	: STD_LOGIC;
	signal LUI		: std_logic;

	signal readdata1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal readdata2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal signextend	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal Rs			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal Rt			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal Rd			: STD_LOGIC_VECTOR(4 DOWNTO 0);

	signal IFID_Write		: std_logic;
	signal IFID_address		: std_logic_vector  (31 DOWNTO 0);
	signal IFID_instruction	: std_logic_vector  (31 DOWNTO 0);
	
	signal IFID_ifFlush : std_logic;
	
	signal IDEX_RegWrite : std_logic;
	signal IDEX_MemtoReg : std_logic;
	signal IDEX_Branch	 : std_logic;
	signal IDEX_MemRead	 : std_logic;
	signal IDEX_MemWrite : std_logic;
	signal IDEX_ALUop	 : std_logic_vector(2 downto 0);
	signal IDEX_RegDst	 : std_logic;
	signal IDEX_ALUsrc	 : std_logic;
	signal IDEX_address : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal IDEX_readdata1	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal IDEX_readdata2	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal IDEX_signextend	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	signal IDEX_Rs			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal IDEX_Rt			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal IDEX_Rd			: STD_LOGIC_VECTOR(4 DOWNTO 0);
	signal IDEX_RegisterRd : STD_LOGIC_VECTOR (4 DOWNTO 0);	

	--ALU Control
	signal operation : std_logic_vector(3 downto 0);
	signal writeLOHI : std_logic;
	signal readLOHI	 : std_logic_vector(1 downto 0);
	signal readLOHImux : std_logic_vector(31 downto 0);


	--ALU signals
	signal 	dataa 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	datab 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	AluSrcMux : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	shamt	: STD_LOGIC_VECTOR (4 DOWNTO 0);
	signal	result 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	HI 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	LO 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal	zero	: STD_LOGIC;

	--Forward Unit signals
	signal forwardA : std_logic_vector(1 downto 0);
	signal forwardB : std_logic_vector(1 downto 0);
	
	--Branch Jump signals
	signal ALU_2shift_databb : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal branch_adr : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal PCSrc : STD_LOGIC;
	signal branch_mux_out: STD_LOGIC_VECTOR (31 DOWNTO 0);

	signal EXMEM_RegWrite	: STD_LOGIC;
	signal EXMEM_MemtoReg	: STD_LOGIC;
	signal EXMEM_Branch		: STD_LOGIC;
	signal EXMEM_MemRead	: STD_LOGIC;
	signal EXMEM_MemWrite	: STD_LOGIC;
	signal EXMEM_result 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal EXMEM_HI 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal EXMEM_LO 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal EXMEM_zero		: STD_LOGIC;
	signal EXMEM_datab 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal EXMEM_address : STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal EXMEM_Rd			: STD_LOGIC_VECTOR (4 DOWNTO 0);

	signal MEMWB_RegWrite	: STD_LOGIC;
	signal MEMWB_MemtoReg	: STD_LOGIC;
	signal MEMWB_wr_done	: STD_LOGIC; 
	signal MEMWB_rd_ready	: STD_LOGIC;
	signal MEMWB_data 		: STD_LOGIC_VECTOR(31 downto 0);        
	signal MEMWB_result 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal MEMWB_HI			: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal MEMWB_LO 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal MEMWB_zero		: STD_LOGIC;
	signal MEMWB_Rd			: STD_LOGIC_VECTOR(4 DOWNTO 0);

	--Misc.
	signal writeDataMux : std_logic_vector(31 downto 0);
	signal MemtoRegMux 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	signal ALU_LO		: std_logic_vector(31 downto 0);
	signal ALU_HI		: std_logic_vector(31 downto 0);
	signal reg_HI : std_logic_vector(31 downto 0);
	signal reg_LO : std_logic_vector(31 downto 0);
	signal hazard_control : std_logic_vector(9 downto 0);

BEGIN

 -- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	 -- Mem Clock process definitions
	mem_clk_process :process
	begin
		clk_mem <= '0';
		wait for clk_period/16;
		clk_mem <= '1';
		wait for clk_period/16;
	end process;
	

	PC_inst: ProgramCounter	PORT MAP
	(
		clock		=> clk,
		PC_Write	=> PC_Write,
		address_in	=> PCSrcMux,
		address_out => PC_address
	);


	------------------------
	-- Instruction Memory --
	------------------------
	InstMem_address <= to_integer(unsigned(PC_address));
	InstMem: Main_Memory 
	generic map (
			File_Address_Read 	=>"Init.dat",
			File_Address_Write 	=>"MemCon.dat",
			Mem_Size_in_Word 	=>2048,
			Num_Bytes_in_Word	=>4,
			Num_Bits_in_Byte	=>8,
			Read_Delay			=>0,
			Write_Delay			=>0
		 )
		PORT MAP (
			clk 		=> clk_mem,
			address 	=> InstMem_address,
			Word_Byte 	=> InstMem_word_byte,
			we 			=> '0',
			re 			=> InstMem_re,
			rd_ready 	=> InstMem_rd_ready,
			data 		=> InstMem_data,          
			initialize 	=> InstMem_init,
			dump 		=> InstMem_dump
        );

	IFID_inst: IFID PORT MAP
	(
		clock			=> clk,
		IFID_Write		=> '1',--IFID_Write,
		address_in		=> PC_address,
		instruction_in	=> InstMem_data,
		address_out		=> IFID_address,
		instruction_out	=> IFID_instruction
	);

	 ----------------------------
	-- Main Control Component --
	----------------------------    
	control_inst : control 
	PORT MAP (
		clock		=> clk,
		Instruction	=> IFID_instruction(31 downto 26),
		RegDst		=> RegDst,
		Jump		=> Jump,
		Branch		=> Branch,
		MemRead		=> MemRead,
		MemtoReg	=> MemtoReg,
		MemWrite	=> MemWrite,
		AluSrc		=> AluSrc,
		RegWrite	=> RegWrite,
		NotZero		=> NotZero,
		LUI			=> LUI,
		ALUOp		=> ALUOp
	);

	---------------------------
	-- Registers Component --
	---------------------------- 
	register_file : registers
	PORT MAP (
		clock		=> clk,
		init		=> RegInit,
		read_reg_1	=> IFID_instruction(25 downto 21),
		read_reg_2	=> IFID_instruction(20 downto 16),
		write_reg	=> MEMWB_Rd,
		writedata	=> MemtoRegMux,
		regwrite	=> MEMWB_RegWrite,
		readdata_1	=> readdata1,
		readdata_2	=> readdata2,
		writeLOHI	=> writeLOHI,
		LOin		=> LO,
		HIin		=> HI,
		LOout		=> reg_LO,
		HIout		=> reg_HI
	);


	with (readdata1 = readdata2) select
		ID_Zero <= '1' when TRUE,
				'0' when others;

	PCSrc <= Branch AND (ID_zero XOR NotZero); -- select line for branch mux
	
	------------------------------
	-- branch Mux 2-1 Component --
	------------------------------
	with PCSrc select
		PCSrcMux <= 
			PC_address when '1',
			address_in when others;
			
	-----------------------
	-- branch resolution --
	-----------------------
	resolveBranch : BranchResolution
	PORT MAP (		
    currPCAdd      => IFID_address (31 downto 0),
	  instruction    => IFID_instruction	(31 downto 0),
	  regValA        => readdata1,
	  regValB        => readdata2,
	  
	  ifFlush        => IFID_ifFlush,
	  nextPCAdd      => PC_address
	);
	
	------------------------------
	-- branch Mux 2-1 Component --
	------------------------------
	with IFID_ifFlush select
		IFID_instruction <= 
			"0000000000000000000000000000" when '1',
			InstMem_data when others;
			
	-----------------
	-- Sign-extend --
	-----------------
	
	with LUI select
		signextend(15 downto 0) <= 
			IFID_instruction(15 downto 0) when '0',
			(others => '0') when '1',
			(others => 'X') when others;
			
	with LUI select
		signextend(31 downto 16) <= 
			(others => IFID_instruction(15)) when '0',
			IFID_instruction(15 downto 0) when '1',
			(others => 'X') when others;	

	Rs	<= IFID_instruction(25 downto 21);
	Rt	<= IFID_instruction(20 downto 16);
	Rd	<= IFID_instruction(15 downto 11);

	----------------------------
	-- Hazard Detection Unit
	----------------------------
	HazardDetection_inst: HazardDetectionUnit
	PORT MAP
	(
		IDEX_MemRead=> IDEX_MemRead,
		IDEX_RegRt 	=> Rt,
		IFID_RegRs 	=> Rs,
		IFID_RegRt 	=> Rt,
		IFID_Write 	=> IFID_Write,
		PC_Write 	=> PC_Write,
		stall 		=> stall

	);

	with stall select
		hazard_control <= 
			RegWrite & MemtoReg & Branch & MemRead & MemWrite & ALUop & RegDst & AluSrc when '0',
			"0000000000" when '1',
			(others => 'X') when others;

	IDEX_inst: IDEX PORT MAP
	(
		clock			=> clk,
		
		RegWrite_in		=> hazard_control(9),
		MemtoReg_in		=> hazard_control(8),
		Branch_in		=> hazard_control(7),
		MemRead_in		=> hazard_control(6),
		MemWrite_in		=> hazard_control(5),
		ALUop_in		=> hazard_control(4 downto 2),
		RegDst_in		=> hazard_control(1),
		ALUsrc_in		=> hazard_control(0),
		address_in => IFID_address,
		readdata1_in	=> readdata1,
		readdata2_in	=> readdata2,
		signextend_in	=> signextend,
		Rs_in			=> Rs,
		Rt_in			=> Rt,
		Rd_in			=> Rd,

		RegWrite_out	=> IDEX_RegWrite,
		MemtoReg_out	=> IDEX_MemtoReg,
		Branch_out		=> IDEX_Branch,
		MemRead_out		=> IDEX_MemRead,
		MemWrite_out	=> IDEX_MemWrite,
		ALUop_out		=> IDEX_ALUop,
		RegDst_out		=> IDEX_RegDst,
		ALUsrc_out		=> IDEX_ALUsrc,
	  	address_out => IDEX_address,
		readdata1_out	=> IDEX_readdata1,
		readdata2_out	=> IDEX_readdata2,
		signextend_out	=> IDEX_signextend,
		Rs_out			=> IDEX_Rs,
		Rt_out			=> IDEX_Rt,
		Rd_out			=> IDEX_Rd
	);


	ALU_Control_inst: ALU_Control PORT MAP
	(
		ALUOp		=> IDEX_ALUop,
		funct 		=> IDEX_signextend(5 downto 0),

		operation	=> operation,
		writeLOHI	=> writeLOHI,
		readLOHI	=> readLOHI	
	);

	ForwardUnit_inst: ForwardUnit PORT MAP
	(
		IDEX_RegRs 		=> IDEX_Rs,
		IDEX_RegRt 		=> IDEX_Rt,
		EXMEM_RegWrite 	=> EXMEM_RegWrite,
		EXMEM_RegRd 	=> EXMEM_Rd,
		MEMWB_RegWrite 	=> MEMWB_RegWrite,
		MEMWB_RegRd 	=> MEMWB_Rd,

		forwardA 		=> forwardA,
		forwardB 		=> forwardB
	);

	--MUX for Data A
	WITH forwardA SELECT
		dataa <=
			IDEX_readdata1 			WHEN "00",
			MemtoRegMux				WHEN "01",
			EXMEM_result			WHEN "10",
			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"		WHEN OTHERS;
	
	--MUX for Data B
	WITH forwardB SELECT
		datab <=
			IDEX_readdata2 			WHEN "00",
			MemtoRegMux				WHEN "01",
			EXMEM_result			WHEN "10",
			"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"		WHEN OTHERS;

	with IDEX_ALUsrc select
		AluSrcMux <= 
					datab when '0',
					IDEX_signextend when '1',
					"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"		WHEN OTHERS;

	--MUX for IDEX_RegisterRd
	WITH IDEX_RegDst SELECT
		IDEX_RegisterRd <=
			IDEX_Rt		WHEN '0',
			IDEX_Rd		WHEN OTHERS;

	ALU_inst: ALU PORT MAP
	(
		dataa 	=> dataa, 
		datab 	=> AluSrcMux, 
		control => operation,
		shamt	=> IDEX_signextend(10 downto 6), 

		result 	=> result,
		HI 		=> HI,
		LO 		=> LO,
		zero	=> zero
	);

	-- WriteData Mux 2-1 Component --
	with readLOHI select
		readLOHImux <= 
			result 		when "00",
			reg_HI 		when "10",
			reg_LO 		when "11",
			(others => 'X') when others;
	
	------------------------
	-- ALU Jump Component --
	------------------------
	ALU_2shift_databb <=  IDEX_signextend(29 downto 0) & "00";
	ALUJump: ALU
	PORT MAP(
		dataa 	=> IDEX_address,
		datab 	=> ALU_2shift_databb,
		control => "0010", --add
		shamt => IDEX_signextend(10 downto 6),
		result 	=> branch_adr
	);

	
	EXMEM_inst: EXMEM PORT MAP
	(
		clock			=> clk,
		
		RegWrite_in		=> IDEX_RegWrite,
		MemtoReg_in		=> IDEX_MemtoReg,
		Branch_in		=> IDEX_Branch,
		MemRead_in		=> IDEX_MemRead,
		MemWrite_in		=> IDEX_MemWrite,
		result_in 		=> readLOHImux,
		HI_in 			=> HI,
		LO_in 			=> LO,
		zero_in			=> zero,
		datab_in 		=> datab,
		address_in => branch_adr,
		Rd_in			=> IDEX_RegisterRd,

		RegWrite_out	=> EXMEM_RegWrite,
		MemtoReg_out	=> EXMEM_MemtoReg,
		Branch_out		=> EXMEM_Branch,
		MemRead_out		=> EXMEM_MemRead,
		MemWrite_out	=> EXMEM_MemWrite,
		result_out 		=> EXMEM_result,
		HI_out 			=> EXMEM_HI,
		LO_out 			=> EXMEM_LO,	
		zero_out		=> EXMEM_zero,	
		datab_out 		=> EXMEM_datab,
		address_out => EXMEM_address,
		Rd_out			=> EXMEM_Rd		
	);

	DataMem: Main_Memory 
	generic map (
			File_Address_Read 	=>"Init.dat",
			File_Address_Write 	=>"MemData.dat",
			Mem_Size_in_Word 	=>2048,
			Num_Bytes_in_Word	=>4,
			Num_Bits_in_Byte	=>8,
			Read_Delay			=>0,
			Write_Delay			=>0
		 )
		PORT MAP (
			clk 		=> clk_mem,
			address 	=> DataMem_address,
			Word_Byte 	=> DataMem_word_byte,
			we 			=> DataMem_we,
			re 			=> DataMem_re,
			rd_ready 	=> DataMem_rd_ready,
			wr_done		=> DataMem_wr_done,
			data 		=> data,          
			initialize 	=> DataMem_init,
			dump 		=> DataMem_dump
        );


	MEMWB_inst: MEMWB PORT MAP
	(
		clock			=> clk,

		RegWrite_in	 	=> EXMEM_RegWrite,
		MemtoReg_in		=> EXMEM_MemtoReg,
		wr_done_in		=> DataMem_wr_done,
		rd_ready_in		=> DataMem_rd_ready,
		data_in 		=> MDR,
		result_in 		=> EXMEM_result,
		HI_in 			=> EXMEM_HI,
		LO_in 			=> EXMEM_LO,
		zero_in			=> EXMEM_zero,
		Rd_in			=> EXMEM_Rd,

		RegWrite_out	=> MEMWB_RegWrite,
		MemtoReg_out	=> MEMWB_MemtoReg,
		wr_done_out		=> MEMWB_wr_done, 
		rd_ready_out	=> MEMWB_rd_ready,
		data_out 		=> MEMWB_data,  
		result_out 		=> MEMWB_result, 
		HI_out 			=> MEMWB_HI,	
		LO_out 			=> MEMWB_LO,
		zero_out		=> MEMWB_zero,
		Rd_out			=> MEMWB_Rd
	);
	
	with MEMWB_MemtoReg select
		MemtoRegMux <= 
			MEMWB_data when '1',
			MEMWB_result when '0',
			(others => 'X') when others;

	-- Stimulus process
   	instruction_proc: process (clk, clk_mem)
   	begin		
		if(clk_mem'event and clk_mem='1') then
			case inst_state is
				when init =>
					PC_Write <= '0';
					InstMem_init <= '1'; --triggerd.
					PC_Write <= '0';
					inst_state <= read_inst1;					
				when read_inst1 =>
					PC_Write <= '1';
					InstMem_re <= '1';
					InstMem_init <= '0';
					if(InstMem_rd_ready = '1') then
						--InstMem_re <= '0';
						address_in <= std_logic_vector(to_unsigned(to_integer(unsigned(PC_address)) + 4,32));
						inst_state <= read_inst2;
					end if;
				when others =>
			end case;
		end if;
		if(clk'event and clk='1' and inst_state = read_inst2) then
			inst_state <= read_inst1;
		end if;
   	end process;

   data_proc: process (clk_mem,clk)
   begin		
      if(clk_mem'event and clk_mem='1') then
			case data_state is
				when init =>
					DataMem_init <= '1'; --triggerd.
					data_state <= idle;
					RegInit <='1';
				when idle =>
					RegInit <='0';
					data <= (others=>'Z');
					DataMem_init <= '0'; 
					DataMem_re<='0';
					DataMem_we<='0';
					DataMem_dump <= '0'; 
					if(EXMEM_MemRead = '1') then
						DataMem_address <= to_integer(unsigned(EXMEM_result));
						DataMem_we <='0';
						DataMem_re <='1';
						DataMem_init <= '0';
						DataMem_dump <= '0';
						data_state <= read_mem1;
					end if;
					if(EXMEM_MemWrite = '1') then
						DataMem_address <= to_integer(unsigned(EXMEM_result));
						DataMem_we <='1';
						DataMem_re <='0';
						DataMem_init <= '0';
						DataMem_dump <= '0';
						data <= EXMEM_datab;
						data_state <= write_mem1;
					end if;
				when write_mem1 =>					
					if (DataMem_wr_done = '1') then -- the output is ready on the memory bus
						data_state <= dum; --write finished go to the dump state 
					else
						data_state <= write_mem1; -- stay in this state till you see rd_ready='1';
					end if;	
				when fin =>
					DataMem_init <= '0'; 
					DataMem_re<='0';
					DataMem_we<='0';
					DataMem_dump <= '0'; 
				when others =>
			end case;
			
		end if;
		if(clk'event and clk = '1') then
			case data_state is
				when dum =>
					DataMem_init <= '0'; 
					DataMem_re<='0';
					DataMem_we<='0';
					DataMem_dump <= '1'; --triggerd
					data_state <= idle;

				when read_mem1 =>
				  if (DataMem_rd_ready = '1') then -- the output is ready on the memory bus
						MDR <= data;
						data_state <= idle; --read finished go to test state write 
						DataMem_re <='0';
					else
						data_state <= read_mem1; -- stay in this state till you see rd_ready='1';
					end if;
				when others =>
			end case;
		end if;
   end process;

end behaviour;




