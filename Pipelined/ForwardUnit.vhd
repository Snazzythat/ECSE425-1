LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY ForwardUnit IS
	PORT
	(
		forwardA : out std_logic_vector(2 downto 0);
		forwardB : out std_logic_vector(2 downto 0);
		EXMEM_RegWrite : in std_logic;
		EXMEM_RegRd : std_logic_vector(4 downto 0);
		IDEX_RegRs : std_logic_vector(4 downto 0);
		IDEX_RegRt : std_logic_vector(4 downto 0);
		MEMWB_RegWrite : in std_logic;
		MEMWB_RegRd : std_logic_vector(4 downto 0)
		
	);
END ForwardUnit;

ARCHITECTURE ARCH OF ForwardUnit IS

BEGIN

Forward: process (EXMEM_RegWrite,EXMEM_RegRd,IDEX_RegRs,IDEX_RegRt,MEMWB_RegWrite,MEMWB_RegRd)
begin
	forwardA <= "00";
	forwardB <= "00";
	
	-- EX Hazard
	if(EXMEM_RegWrite = '1' 
		and(EXMEM_RegRd /= "00000") 
		and (EXMEM_RegRd = IDEX_RegRs)) then
			forwardA <= "10";
	end if;
	if(EXMEM_RegWrite = '1' 
		and(EXMEM_RegRd /= "00000") 
		and (EXMEM_RegRd = IDEX_RegRt)) then
			forwardB <= "10";
	end if;
	
	-- MEM Hazard
	if(MEMWB_RegWrite = '1'
		and(MEMWB_RegRd /= "00000")
		and not(EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000"))
			and (EXMEM_RegRd /= IDEX_RegRs)
		and (MEMWB_RegRd = IDEX_RegRs)) then
			forwardA <= "01";
	end if;
	if(MEMWB_RegWrite = '1'
		and(MEMWB_RegRd /= "00000")
		and not(EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000"))
			and (EXMEM_RegRd /= IDEX_RegRt)
		and (MEMWB_RegRd = IDEX_RegRt)) then
			forwardB <= "01";
	end if;
		
end process;
	
	
END ARCH;
