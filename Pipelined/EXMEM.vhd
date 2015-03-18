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
		RegWrite_out	: OUT STD_LOGIC;
		MemtoReg_out	: OUT STD_LOGIC;
		--Mem
		Branch_in		: IN STD_LOGIC;
		MemRead_in		: IN STD_LOGIC;
		MemWrite_in		: IN STD_LOGIC;
		Branch_out		: OUT STD_LOGIC;
		MemRead_out		: OUT STD_LOGIC;
		MemWrite_out	: OUT STD_LOGIC
	);
END EXMEM;

ARCHITECTURE ARCH OF EXMEM IS

signal RegWrite_tmp		: STD_LOGIC;
signal MemtoReg_tmp		: STD_LOGIC;
signal Branch_tmp		: STD_LOGIC;
signal MemRead_tmp		: STD_LOGIC;
signal MemWrite_tmp		: STD_LOGIC;

BEGIN

IDIF: process (clock)
begin
	if (clock'event AND clock = '1') then
		RegWrite_out <= RegWrite_tmp;
		MemtoReg_out <= MemtoReg_tmp;
		Branch_out <= Branch_tmp;
		MemRead_out <= MemRead_tmp;		
		MemWrite_out <= MemWrite_tmp;
		
		RegWrite_tmp <= RegWrite_in;
		MemtoReg_tmp <= MemtoReg_in;
		Branch_tmp <= Branch_in;
		MemRead_tmp <= MemRead_in;		
		MemWrite_tmp <= MemWrite_in;
	end if;
end process;
	
	
END ARCH;
