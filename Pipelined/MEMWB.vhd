LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY MEMWB IS
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
END MEMWB;

ARCHITECTURE ARCH OF MEMWB IS

--wb
signal RegWrite_tmp		: STD_LOGIC;
signal MemtoReg_tmp		: STD_LOGIC;
--Data Mem
signal wr_done_tmp		: STD_LOGIC; 
signal rd_ready_tmp		: STD_LOGIC;
signal data_tmp 		: STD_LOGIC_VECTOR(31 downto 0);        
--ALU
signal result_tmp 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal HI_tmp 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal LO_tmp 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal zero_tmp			: STD_LOGIC;

signal Rd_tmp			: STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN
	--WB
	RegWrite_tmp <= RegWrite_in;
	MemtoReg_tmp <= MemtoReg_in;
	--Data Mem
	wr_done_tmp <= wr_done_in;
	rd_ready_tmp <= rd_ready_in;
	data_tmp <= data_in;   
	--ALU
	result_tmp <= result_in;
	HI_tmp <= HI_in;
	LO_tmp <= LO_in;
	zero_tmp <= zero_in;
	
	Rd_tmp <= Rd_in;

IDIF: process (clock)
begin
	if (clock'event AND clock = '1') then
		--WB
		RegWrite_out <= RegWrite_tmp;
		MemtoReg_out <= MemtoReg_tmp;
		--Data Mem
		wr_done_out <= wr_done_tmp;
		rd_ready_out <= rd_ready_tmp;
		data_out <= data_tmp;   
		--ALU
		result_out <= result_tmp;
		HI_out <= HI_tmp;
		LO_out <= LO_tmp;
		zero_out <= zero_tmp;
		
		Rd_out <= Rd_tmp;
	end if;
end process;
	
	
END ARCH;
