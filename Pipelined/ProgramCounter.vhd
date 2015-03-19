LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ProgramCounter IS
	PORT
	(
		clock		: in std_logic;
		PC_Write	: in std_logic;
		address_in	: in std_logic_vector(31 downto 0);
		address_out	: out std_logic_vector(31 downto 0)

	);
END ProgramCounter;

ARCHITECTURE ARCH OF ProgramCounter IS

signal address_tmp : std_logic_vector(31 downto 0);

BEGIN

address_tmp <= address_in;

ProgramCounter: process (clock)
begin
	if (clock'event AND clock = '1') then
		if(PC_Write = '1') then
			address_out <= address_tmp;
		end if;
	end if;
end process;
	
	
END ARCH;
