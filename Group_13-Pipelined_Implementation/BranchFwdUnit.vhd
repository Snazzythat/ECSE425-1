LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BranchFwdUnit IS
	PORT
	(
		forwardBranchA : out std_logic_vector(1 downto 0);
		forwardBranchB : out std_logic_vector(1 downto 0);
		Branch : in std_logic;
		IFID_RegRs : in std_logic_vector(4 downto 0);
		IFID_RegRt : in std_logic_vector(4 downto 0);
		EXMEM_RegWrite : in std_logic;
		EXMEM_RegRd : in std_logic_vector(4 downto 0);
		MEMWB_RegWrite : in std_logic;
		MEMWB_RegRd : in std_logic_vector(4 downto 0)
		
	);
END BranchFwdUnit;

ARCHITECTURE ARCH OF BranchFwdUnit IS
signal MEMWB_RegWrite_equal_one : boolean;
signal MEMWB_RegRd_not_equal_zero : boolean;

BEGIN


Forward: process (EXMEM_RegWrite,EXMEM_RegRd,IFID_RegRs,IFID_RegRt,MEMWB_RegWrite,MEMWB_RegRd)
begin
	forwardBranchA <= "00";
	forwardBranchB <= "00";
	
	if(Branch = '1') then
		-- EX Hazard
		if(EXMEM_RegWrite = '1' 
			and(EXMEM_RegRd /= "00000") 
			and (EXMEM_RegRd = IFID_RegRs)) then
				forwardBranchA <= "10";
		end if;
		if(EXMEM_RegWrite = '1' 
			and(EXMEM_RegRd /= "00000") 
			and (EXMEM_RegRd = IFID_RegRt)) then
				forwardBranchB <= "10";
		end if;
		
		-- MEM Hazard
		if(     (MEMWB_RegWrite = '1')
		    and (MEMWB_RegRd /= "00000") 
		    and (not(EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000") and (EXMEM_RegRd = IFID_RegRs) ))
			  and (MEMWB_RegRd = IFID_RegRs)) 
			  then
				     forwardBranchA <= "01";
		end if;
		if(MEMWB_RegWrite = '1'
			and(MEMWB_RegRd /= "00000")
			and(not(EXMEM_RegWrite = '1' and (EXMEM_RegRd /= "00000") and (EXMEM_RegRd = IFID_RegRt)))
			and (MEMWB_RegRd = IFID_RegRt)) 
			then
				forwardBranchB <= "01";
		end if;
	end if;
		
end process;
	
	
END ARCH;
