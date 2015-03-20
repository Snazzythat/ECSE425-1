LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY EXMEM IS
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
END EXMEM;

ARCHITECTURE ARCH OF EXMEM IS

--WB
signal RegWrite_tmp		: STD_LOGIC;
signal MemtoReg_tmp		: STD_LOGIC;
--Mem
signal Branch_tmp		: STD_LOGIC;
signal MemRead_tmp		: STD_LOGIC;
signal MemWrite_tmp		: STD_LOGIC;
--ALU
signal result_tmp		: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal HI_tmp			: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal LO_tmp 			: STD_LOGIC_VECTOR (31 DOWNTO 0);
signal zero_tmp			: STD_LOGIC;
signal datab_tmp 		: STD_LOGIC_VECTOR (31 DOWNTO 0);

signal address_tmp: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal Rd_tmp			: STD_LOGIC_VECTOR(4 DOWNTO 0);	

BEGIN
	--WB
	RegWrite_tmp <= RegWrite_in;
	MemtoReg_tmp <= MemtoReg_in;
	--Mem
	Branch_tmp <= Branch_in;
	MemRead_tmp <= MemRead_in;		
	MemWrite_tmp <= MemWrite_in;
	--ALU
	result_tmp <= result_in;
	HI_tmp <= HI_in;
	LO_tmp <= LO_in;
	zero_tmp <= zero_in;

  address_tmp <= address_in;
	Rd_tmp <= Rd_in;
		datab_tmp <= datab_in;

IDIF: process (clock)
begin
	if (clock'event AND clock = '1') then
		--WB
		RegWrite_out <= RegWrite_tmp;
		MemtoReg_out <= MemtoReg_tmp;
		--Mem
		Branch_out <= Branch_tmp;
		MemRead_out <= MemRead_tmp;		
		MemWrite_out <= MemWrite_tmp;
		--ALU
		result_out <= result_tmp;
		HI_out <= HI_tmp;
		LO_out <= LO_tmp;
		zero_out <= zero_tmp;
		datab_out <= datab_tmp;

    address_out <= address_tmp;
		Rd_out <= Rd_tmp;
	end if;
end process;
	
	
END ARCH;
