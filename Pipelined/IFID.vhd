LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY IFID IS
	PORT
	(
		clock			: IN STD_LOGIC;
		IFID_Write		: IN STD_LOGIC;
		address_in		: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
		instruction_in	: IN STD_LOGIC_VECTOR  (31 DOWNTO 0);
		address_out		: OUT STD_LOGIC_VECTOR  (31 DOWNTO 0);
		instruction_out	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END IFID;

ARCHITECTURE ARCH OF IFID IS

signal address_tmp : std_logic_vector(31 downto 0);
signal instruction_tmp : std_logic_vector(31 downto 0);

BEGIN

IDIF: process (clock)
begin
	if (clock'event AND clock = '1') then
		if(IFID_Write = '1') then
			address_out <= address_tmp;
			instruction_out <= instruction_tmp;
			
			address_tmp <= address_in;
			address_tmp <= instruction_in;
		end if;
	end if;
end process;
	
	
END ARCH;
