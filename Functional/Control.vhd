LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity control is
	generic(
		clock_period : time := 1 ns
	);
	port (
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
		LUI		: out std_logic;
		ALUOp		: out std_logic_vector(2 downto 0)
	);
end control;

architecture behaviour of Control is
	signal RegDst_reg 	: std_logic;
	signal Jump_reg		: std_logic;
	signal Branch_reg 	: std_logic;
	signal MemRead_reg 	: std_logic;
	signal MemtoReg_reg 	: std_logic;
	signal MemWrite_reg 	: std_logic;
	signal AluSrc_reg 	: std_logic;
	signal RegWrite_reg 	: std_logic;
	signal NotZero_reg	: std_logic;
	signal LUI_reg			: std_logic;
	signal ALUOp_reg 	: std_logic_vector(2 downto 0);
	
begin

	reg_process: process (clock)
	begin
	if (clock'event AND clock = '0') then
		-- initialize signals
		RegDst_reg 	<= 'X';
		Jump_reg	<= '0';
		Branch_reg 	<= '0';
		MemRead_reg 	<= '0';
		MemtoReg_reg	<= 'X';
		MemWrite_reg	<= '0';
		AluSrc_reg 	<= '0';
		RegWrite_reg	<= '0';
		NotZero_reg	<= '0';
		LUI_reg		<= '0';
		ALUOp_reg 	<= "XXX";
		
		case Instruction is
			-- r-format
			when "000000" =>
				RegDst_reg 	<= '1';
				MemtoReg_reg	<= '0';
				RegWrite_reg	<= '1';
				ALUOp_reg 	<= "010";
			-- addi
			when "001000" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg	<= "000";
			-- slti
			when "001010" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg	<= "100";
			-- andi
			when "001100" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg	<= "101";
			-- ori
			when "001101" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg	<= "110";
			-- xori
			when "001110" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg	<= "111";
			-- lui
			when "001111" =>
				RegDst_reg 	<= '0';
				MemtoReg_reg	<= '0';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				LUI_reg		<= '1';
				ALUOp_reg	<= "000";
			-- lw
			when "100011" =>
				RegDst_reg 	<= '0';
				MemRead_reg 	<= '1';
				MemtoReg_reg	<= '1';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg 	<= "000";
			-- lb
			when "100000" =>
				RegDst_reg 	<= '0';
				MemRead_reg 	<= '1';
				MemtoReg_reg	<= '1';
				AluSrc_reg 	<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg 	<= "000";
			-- sw
			when "101011" =>
				MemWrite_reg	<= '1';
				AluSrc_reg 	<= '1';
				ALUOp_reg 	<= "000";
			-- sb
			when "101000" =>
				MemWrite_reg	<= '1';
				AluSrc_reg 	<= '1';
				ALUOp_reg 	<= "000";
			-- beq
			when "000100" =>
				Branch_reg 	<= '1';
				ALUOp_reg 	<= "001"; -- sub
			-- bne
			when "000101" =>
				Branch_reg 	<= '1';
				NotZero_reg	<= '1';
				AluOp_reg	<= "001"; -- sub
			-- j
			when "000010" =>
				Jump_reg	<= '1';
				ALUOp_reg	<= "000"; -- add
			-- jal
			when "000011" =>
				Jump_reg	<= '1';
				ALUOp_reg	<= "000"; -- add
			when others =>
				null;
		end case;
	end if;
	end process;
	
	Jump		<= Jump_reg;
	RegDst 	<= RegDst_reg;
	Branch 	<= Branch_reg;
	MemRead 	<= MemRead_reg;
	MemtoReg <= MemtoReg_reg;
	MemWrite <= MemWrite_reg;
	AluSrc 	<= AluSrc_reg;
	RegWrite <= RegWrite_reg;
	NotZero <= NotZero_reg;
	LUI		<= LUI_reg;
	ALUOp 	<= AluOp_reg;
end behaviour;