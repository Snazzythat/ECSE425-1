LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity functional is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock			: in std_logic;
		instruction	: in std_logic_vector(31 downto 0)
	);
end functional;

architecture behaviour of functional is
	
	component registers is
		generic(
			clock_period : time := 1 ns
		);
		port (
			clock			: in std_logic;
			read_reg_1	: in std_logic_vector(4 downto 0);
			read_reg_2	: in std_logic_vector(4 downto 0);
			write_reg	: in std_logic_vector(4 downto 0);
			writedata	: in std_logic_vector(31 downto 0);
			regwrite		: in std_logic;
			readdata_1	: out std_logic_vector(31 downto 0);
			readdata_2	: out std_logic_vector(31 downto 0)
		);
	end component;
	
	component control is
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
			ALUOp			: out std_logic_vector(2 downto 0)
		);
	end component;

	component ALU_control is
		port (
			ALUOp			: in std_logic_vector(2 downto 0);
			funct 		: in std_logic_vector(5 downto 0);
			operation	: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component ALU is
		port
		(
				dataa 	: in std_logic_vector (31 downto 0);
				datab 	: in std_logic_vector (31 downto 0);
				control 	: in std_logic_vector (3  downto 0);
				shamt		: in std_logic_vector (4  downto 0);
				result 	: out std_logic_vector(31 downto 0);
				HI 		: out std_logic_vector(31 downto 0);
				LO 		: out std_logic_vector(31 downto 0);
				zero		: out std_logic
		);
	end component;
	
	signal write_reg	: std_logic_vector(4  downto 0);
	signal write_data : std_logic_vector(31 downto 0);
	signal regwrite	: std_logic;
	signal readdata_1 : std_logic_vector(31 downto 0);
	signal readdata_2 : std_logic_vector(31 downto 0);
	
	signal regDst		: std_logic;
	signal jump			: std_logic;
	signal branch		: std_logic;
	signal memRead		: std_logic;
	signal memtoReg	: std_logic;
	signal memWrite	: std_logic;
	signal aLUSrc		: std_logic;
	signal aLUOp		: std_logic_vector(2 downto 0);
	
	signal operation 	: std_logic_vector(3 downto 0);
	
	signal dataa 	: std_logic_vector (31 downto 0);
	signal datab 	: std_logic_vector (31 downto 0);
	signal result 	: std_logic_vector (31 downto 0);
	signal HI 		: std_logic_vector (31 downto 0);
	signal LO 		: std_logic_vector (31 downto 0);
	signal zero		: std_logic;
	
	signal signext	: std_logic_vector (31 downto 0);
	
begin

	with regDst select
		write_reg <= 
			instruction(20 downto 16) when '0',
			instruction(15 downto 11) when '1',
			"XXXXX" when others;
	
	reg_file: registers
	port map(
		clock			=> clock,
		read_reg_1	=> instruction(25 downto 21),
		read_reg_2	=> instruction(20 downto 16),
		write_reg	=> write_reg,
		writedata	=> write_data,
		regwrite		=> regwrite,
		readdata_1	=> readdata_1,
		readdata_2	=> readdata_2
	);
	
	controller: control
	port map(
		clock			=> clock,
		Instruction	=> instruction(31 downto 26),
		RegDst		=> regDst,
		Jump			=> jump,
		Branch		=> branch,
		MemRead		=> memRead,
		MemtoReg		=> memToReg,
		MemWrite		=> memWrite,
		AluSrc		=> aLUSrc,
		RegWrite		=> regWrite,
		ALUOp			=> aLUOp
	);
	
	alu_controller: ALU_control
	port map(
		ALUOp			=> aLUOp,
		funct 		=> instruction(5 downto 0),
		operation	=> operation
	);
	
	dataa <= readdata_1;
	with aLUSrc select
		datab <= 
			readdata_2 when '0',
			signext when '1',
			(others => 'X') when others;
	
	
	-- sign extension
	signext(15 downto 0) <= instruction(15 downto 0);
	signext(31 downto 16) <= (others => instruction(15));
	
	alu_unit: ALU
	port map(
		dataa 	=> dataa,
		datab 	=> datab,
		control 	=> operation,
		shamt		=> instruction(10 downto 6),
		result 	=> result,
		HI 		=> HI,
		LO 		=> LO,
		zero		=> zero
	);
	

end behaviour;