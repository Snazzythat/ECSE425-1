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
			shampt	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			result 	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			HI 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			LO 		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			zero	: OUT STD_LOGIC
	);
END ALU;

ARCHITECTURE ARCH OF ALU IS

	-- SIGNALS
	SIGNAL addSubResult 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL multiplyerResult : STD_LOGIC_VECTOR (63 DOWNTO 0);
	SIGNAL dividerResult 	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL dividerRemainder : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL aluResult 		: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL sltResult	 	: STD_LOGIC;
	
	
	-- ADDITION AND SUBSTRACTION
	COMPONENT AddSub
	PORT
	(
		add_sub		: IN STD_LOGIC ;
		dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
	END COMPONENT;
	
	-- MULTIPLICATION
	COMPONENT multiplyer
		PORT
			(
				dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				result	: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
			);
	END COMPONENT;
	
	-- DIVIDER
	COMPONENT divider
		PORT
			(
				denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				quotient	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
				remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
			);
	END COMPONENT;
	
	-- SET LESS THAN --
	COMPONENT setLessThanComp 
		PORT
			(
				dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
				AlB		: OUT STD_LOGIC 
			);
	END COMPONENT;
	
	-- IS ZERO --
	COMPONENT isZero 
	PORT
		(
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			AeB		: OUT STD_LOGIC 
		);
	END COMPONENT;

	

BEGIN
	
	---------------
	-- OPERATORS --
	---------------
	
	-- ADDITION AND SUBSTRACTION
	addAndSubstract : AddSub
	PORT MAP (
		dataa => dataa,
		add_sub => NOT control(2),
		datab => datab,
		result => addSubResult
	);
	
	-- MULTIPLICATION
	multiply : multiplyer
	PORT MAP (
		dataa	=> dataa,
		datab	=> datab,
		result	=> multiplyerResult
	);
	
	-- DIVIDER
	divide : divider
	PORT MAP (
		denom		=> datab,
		numer		=> dataa,
		quotient	=> dividerResult,
		remain		=> dividerRemainder
	);
	
	-- SET LESS THAN --
	slt : setLessThanComp 
	PORT MAP (
		dataa	=> dataa,
		datab	=> datab,
		AlB		=> sltResult
	);
	
	-- IS ZERO --
	equalZero : isZero 
	PORT MAP (
		dataa	=> aluResult,
		AeB		=> zero 
	);
	
	------------------
	-- MULTIPLEXERS --
	------------------
	
	-- MULTIPLEXER FOR result OUTPUT
	WITH control SELECT
		aluResult <=
			dataa AND datab 				WHEN "0000",
			dataa OR datab 					WHEN "0001",
			addSubResult 					WHEN "0010",
			addSubResult 					WHEN "0110",
			(0 => sltResult, OTHERS => '0') WHEN "0111",
			dataa NOR datab 				WHEN "1100",
			dataa XOR datab 				WHEN "1101",
			std_logic_vector(unsigned(dataa) sll to_integer(unsigned(shampt)))		WHEN "1000",
			std_logic_vector(unsigned(dataa) sll to_integer(unsigned(shampt)))		WHEN "1001",
			to_stdlogicvector(to_bitvector(dataa) sra to_integer(unsigned(shampt)))	WHEN "1010",
			addSubResult 					WHEN OTHERS;
			
	-- MULTIPLEXER FOR HI OUTPUT
	WITH control SELECT
		HI <=
			multiplyerResult(63 DOWNTO 32) 	WHEN "0011",
			dividerRemainder 			   	WHEN OTHERS;
			
	-- MULTIPLEXER FOR LO OUTPUT
	WITH control SELECT
		LO <=
			multiplyerResult(31 DOWNTO 0) 	WHEN "0011",
			dividerResult					WHEN OTHERS;
			
	result <= aluResult;

END ARCH;

