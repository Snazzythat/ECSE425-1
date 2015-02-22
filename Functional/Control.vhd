LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity control is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock			: in std_logic;
		Instruction	: in std_logic_vector(31 downto 26);
		RegDst		: out std_logic;
		Jump			: out std_logic;
		Branch		: out std_logic;
		MemRead		: out std_logic;
		MemtoReg		: out std_logic;
		MemWrite		: out std_logic;
		AluSrc		: out std_logic;
		RegWrite		: out std_logic;
		ALUOp			: out std_logic_vector(1 downto 0)
	);
end Control;

architecture behaviour of Control is
	signal RegDst_reg 	: std_logic;
	signal Jump_reg		: std_logic;
	signal Branch_reg 	: std_logic;
	signal MemRead_reg 	: std_logic;
	signal MemtoReg_reg 	: std_logic;
	signal MemWrite_reg 	: std_logic;
	signal AluSrc_reg 	: std_logic;
	signal RegWrite_reg 	: std_logic;
	signal ALUOp_reg 		: std_logic_vector(1 downto 0);
	
begin

	reg_process: process (clock)
	begin
	if (clock'event AND clock = '1') then
		RegDst_reg 		<= '0';
		Branch_reg 		<= '0';
		MemRead_reg 	<= '0';
		MemtoReg_reg	<= '0';
		MemWrite_reg	<= '0';
		AluSrc_reg 		<= '0';
		RegWrite_reg	<= '0';
		ALUOp_reg 		<= "00";
		case Instruction is
			-- r-format
			when "000000" =>
				RegDst_reg 		<= '1';
				RegWrite_reg	<= '1';
				ALUOp_reg		<= "10";
			-- addi
			when "001000" =>
				AluSrc_reg 		<= '1';
				RegWrite_reg	<= '1';
			-- slti
			when "001010" =>
				null;
			-- andi
			when "001100" =>
				null;
			-- ori
			when "001101" =>
				null;
			-- xori
			when "001110" =>
				null;
			-- lui
			when "001111" =>
				null;
			-- lw
			when "100011" =>
				MemRead_reg		<= '1';
				MemtoReg_reg	<= '1';
				AluSrc_reg		<= '1';
				RegWrite_reg	<= '1';
			-- lb
			when "100000" =>
				null;
			-- sw
			when "101011" =>
				MemWrite_reg 	<= '1';
				AluSrc_reg		<= '1';
			-- sb
			when "101000" =>
				null;
			-- beq
			when "000100" =>
				Branch_reg		<= '1';
				AluOp_reg		<= "01";
			-- bne
			when "000101" =>
				null;
			-- j
			when "000010" =>
				Jump_reg			<= '1';
				AluOp_reg		<= "10";
			-- jal
			when "000011" =>
				null;
			when others =>
				null;
		end case;
	end if;
	end process;
	
	RegDst 	<= RegDst_reg;
	Jump		<= Jump_reg;
	Branch 	<= Branch_reg;
	MemRead 	<= MemRead_reg;
	MemtoReg <= MemtoReg_reg;
	MemWrite <= MemWrite_reg;
	AluSrc 	<= AluSrc_reg;
	RegWrite <= RegWrite_reg;
	ALUOp 	<= AluOp_reg;
end behaviour;