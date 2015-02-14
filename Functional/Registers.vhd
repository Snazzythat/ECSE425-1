LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity registers is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock			: in std_logic;
		read_reg_1	: in std_logic_vector(4 downto 0);
		read_reg_2	: in std_logic_vector(4 downto 0);
		write_reg_1	: in std_logic_vector(4 downto 0);
		writedata	: in std_logic_vector(31 downto 0);
		regwrite		: in std_logic;
		readdata_1	: out std_logic_vector(31 downto 0);
		readdata_2	: out std_logic_vector(31 downto 0)
	);
end registers;

architecture behaviour of registers is

	constant	reg_width	: integer := 32;
	constant	data_width	: integer := 32;

	type MEM is array(reg_width-1 downto 0) OF std_logic_vector(data_width-1 downto 0);
	signal regs: MEM;
	
	signal readdata_1_reg: std_logic_vector(data_width-1 downto 0);
	signal readdata_2_reg: std_logic_vector(data_width-1 downto 0);
	
begin

	reg_process: process (clock)
	begin
		if (clock'event AND clock = '1') then
			readdata_1_reg <= regs(to_integer(unsigned(read_reg_1)));
			readdata_2_reg <= regs(to_integer(unsigned(read_reg_2)));
		end if;
		
		if (clock'event AND clock = '0') then
			if(regwrite = '1') then
				regs(to_integer(unsigned(write_reg_1))) <= writedata;
			end if;
		end if;
	end process;
	
	readdata_1 <= readdata_1_reg;
	readdata_2 <= readdata_2_reg;
end behaviour;