LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity Control is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock			: in std_logic;
		Instruction		: in std_logic_vector(31 downto 26);
		RegDst		: out std_logic;
		Branch		: out std_logic;
		MemRead		: out std_logic;
		MemtoReg	: out std_logic;
		MemWrite	: out std_logic;
		AluSrc		: out std_logic;
		RegWrite	: out std_logic;
		ALUOp		: out std_logic_vector(1 downto 0)
	);
end Control;

architecture behaviour of Control is
	signal tempRegDst		: out std_logic;
	signal tempBranch		: out std_logic;
	signal tempMemRead		: out std_logic;
	signal tempMemtoReg		: out std_logic;
	signal tempMemWrite		: out std_logic;
	signal tempAluSrc		: out std_logic;
	signal tempRegWrite		: out std_logic;
	signal tempALUOp		: out std_logic_vector(1 downto 0)
	
begin

	reg_process: process (clock)
	begin
	if (clock'event AND clock = '1') then
		case Instruction is
			-- r-format
			when "000000" =>
				tempRegDst <= "1";
				tempBranch <= "0";
				tempMemRead <= "0";
				tempMemtoReg <= "0";
				tempMemWrite <= "0";
				tempAluSrc <= "0";
				tempRegWrite <= "1";
				tempALUOp <= "10";
			-- lw
			when "100011" =>
				tempRegDst <= "0";
				tempBranch <= "0";
				tempMemRead <= "1";
				tempMemtoReg <= "1";
				tempMemWrite <= "0";
				tempAluSrc <= "1";
				tempRegWrite <= "1";
				tempALUOp <= "00";
			-- sw
			when "101011" =>
				tempRegDst <= "0";
				tempBranch <= "0";
				tempMemRead <= "0";
				tempMemtoReg <= "0";
				tempMemWrite <= "1";
				tempAluSrc <= "1";
				tempRegWrite <= "0";
				tempALUOp <= "00";
			-- beq
			when "000100" =>
				tempRegDst <= "0";
				tempBranch <= "1";
				tempMemRead <= "0";
				tempMemtoReg <= "0";
				tempMemWrite <= "0";
				tempAluSrc <= "0";
				tempRegWrite <= "0";
				tempALUOp <= "01";
		end case;
	end if;
	end process;
	
	RegDst <= tempRegDst;
	Branch <= tempBranch;
	MemRead <= tempMemRead;
	MemtoReg <= tempMemtoReg;
	MemWrite <= tempMemWrite;
	AluSrc <= tempAluSrc;
	RegWrite <= tempRegWrite;
	ALUOp <= tempALUOp;
end behaviour;