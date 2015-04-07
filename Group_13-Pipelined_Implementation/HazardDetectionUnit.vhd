LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY HazardDetectionUnit IS
	PORT
	(
		IDEX_MemRead : in std_logic;
		IDEX_RegRt : in std_logic_vector(4 downto 0);
		IFID_RegRs : in std_logic_vector(4 downto 0);
		IFID_RegRt : in std_logic_vector(4 downto 0);
		IFID_Write : out std_logic;
		PC_Write : out std_logic;
		stall : out std_logic
	);
END HazardDetectionUnit;

ARCHITECTURE ARCH OF HazardDetectionUnit IS

BEGIN

Hazard: process (IDEX_MemRead,IDEX_RegRt,IFID_RegRs,IFID_RegRt)
begin
	IFID_Write <= '1';
	PC_Write <= '1';
	stall <= '0';

	if(IDEX_MemRead = '1' and
		((IDEX_RegRt = IFID_RegRs) or
		 (IDEX_RegRt = IFID_RegRt))) then
			IFID_Write <= '0';
			PC_Write <= '0';
			stall <= '1';
	end if;
		
end process;
	
	
END ARCH;
