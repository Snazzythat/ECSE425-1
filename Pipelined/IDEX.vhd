LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IDEX IS
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

    address_in: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata1_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata2_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		signextend_in	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rs_in			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rt_in			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rd_in			: IN STD_LOGIC_VECTOR(4 DOWNTO 0);
	
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
		
		address_out: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata1_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		readdata2_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		signextend_out	: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rs_out			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rt_out			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rd_out			: OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
	);
END IDEX;

ARCHITECTURE ARCH OF IDEX IS

--WB
signal RegWrite_tmp		: STD_LOGIC;
signal MemtoReg_tmp		: STD_LOGIC;
--Mem
signal Branch_tmp		: STD_LOGIC;
signal MemRead_tmp		: STD_LOGIC;
signal MemWrite_tmp		: STD_LOGIC;
--Ex
signal ALUop_tmp		: STD_LOGIC_VECTOR(2 DOWNTO 0);
signal RegDst_tmp		: STD_LOGIC;
signal ALUsrc_tmp		: STD_LOGIC;

signal address_tmp: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal readdata1_tmp	: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal readdata2_tmp	: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal signextend_tmp	: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal Rs_tmp			: STD_LOGIC_VECTOR(4 DOWNTO 0);
signal Rt_tmp			: STD_LOGIC_VECTOR(4 DOWNTO 0);
signal Rd_tmp			: STD_LOGIC_VECTOR(4 DOWNTO 0);


BEGIN
	--WB
	RegWrite_tmp <= RegWrite_in;
	MemtoReg_tmp <= MemtoReg_in;
	--Mem
	Branch_tmp <= Branch_in;
	MemRead_tmp <= MemRead_in;		
	MemWrite_tmp <= MemWrite_in;		
	--Ex
	ALUop_tmp <= ALUop_in;		
	RegDst_tmp <= RegDst_in;		
	ALUsrc_tmp <= ALUsrc_in;		
	
	address_tmp <= address_in;
	readdata1_tmp <= readdata1_in;	
	readdata2_tmp <= readdata2_in;	
	signextend_tmp <= signextend_in;	
	Rs_tmp <= Rs_in;	
	Rt_tmp <= Rt_in;
	Rd_tmp <= Rd_in;
		
IDEX: process (clock)
begin
	if (clock'event AND clock = '1') then
		--WB
		RegWrite_out <= RegWrite_tmp;
		MemtoReg_out <= MemtoReg_tmp;
		--Mem
		Branch_out <= Branch_tmp;
		MemRead_out <= MemRead_tmp;		
		MemWrite_out <= MemWrite_tmp;		
		--Ex
		ALUop_out <= ALUop_tmp;		
		RegDst_out <= RegDst_tmp;		
		ALUsrc_out <= ALUsrc_tmp;		
		
		address_out <= address_tmp;
		readdata1_out <= readdata1_tmp;	
		readdata2_out <= readdata2_tmp;	
		signextend_out <= signextend_tmp;
		Rs_out <= Rs_tmp;	
		Rt_out <= Rt_tmp;
		Rd_out <= Rd_tmp;
	end if;
end process;
	
	
END ARCH;
