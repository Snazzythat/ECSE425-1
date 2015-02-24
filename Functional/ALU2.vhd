LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY lpm;
USE lpm.all;

ENTITY ALU IS
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
END ALU;

ARCHITECTURE ARCH OF ALU IS

	-- SIGNALS
	SIGNAL addResult 		: INTEGER;
	SIGNAL subResult		: INTEGER;
	SIGNAL multiplierResult : INTEGER;
	SIGNAL dividerResult 	: INTEGER;
	SIGNAL dividerRemainder : INTEGER;
	SIGNAL aluResult 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sltResult	 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL add_sub			: INTEGER;
	
	

BEGIN
	
	---------------
	-- OPERATORS --
	---------------
	addResult <= to_integer(signed(dataa)) + to_integer(signed(datab));
	subResult <= to_integer(signed(dataa)) - to_integer(signed(datab));
	sltResult <= std_logic_vector(to_signed(subResult, 32)); -- Only the MSB is needed
	------------------
	-- MULTIPLEXERS --
	------------------
	
	-- MULTIPLEXER FOR result OUTPUT
	WITH control SELECT
		aluResult <=
			dataa AND datab 				WHEN "0000",
			dataa OR datab 					WHEN "0001",
			std_logic_vector(to_signed(subResult, 32)) WHEN "0110",
			std_logic_vector(to_signed(addResult, 32)) WHEN "0010",
			std_logic_vector(unsigned(sltResult) srl 31) WHEN "0111", -- The MSB is 1 if negative of 0 if positve
			dataa NOR datab 				WHEN "1100",
			dataa XOR datab 				WHEN "1101",
			std_logic_vector(unsigned(dataa) sll to_integer(unsigned(shamt)))		WHEN "1000",
			std_logic_vector(unsigned(dataa) srl to_integer(unsigned(shamt)))		WHEN "1001",
			to_stdlogicvector(to_bitvector(dataa) sra to_integer(unsigned(shamt)))	WHEN "1010",
			std_logic_vector(to_signed(addResult, 32)) 								WHEN OTHERS;
			
	-- MULTIPLEXER FOR HI OUTPUT
--	WITH control SELECT
--		HI <=
--			multiplierResult(63 DOWNTO 32) 	WHEN "0011",
--			dividerRemainder 			   	WHEN OTHERS;
			
	-- MULTIPLEXER FOR LO OUTPUT
--	WITH control SELECT
--		LO <=
--			multiplierResult(31 DOWNTO 0) 	WHEN "0011",
--			dividerResult					WHEN OTHERS;
			
	result <= aluResult;
	
END ARCH;

