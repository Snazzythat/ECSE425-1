LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY BranchResolution IS
	PORT(
	  currPCAdd      : in std_logic_vector  (31 downto 0);
	  instruction    : in std_logic_vector  (31 downto 0);
	  regValA        : in std_logic_vector  (31 downto 0);
	  regValB        : in std_logic_vector  (31 downto 0);
	  
	  ifFlush        : out std_logic;
	  nextPCAdd      : out std_logic_vector (31 downto 0)
	);
END BranchResolution;

ARCHITECTURE ARCH OF BranchResolution IS
  
signal regValsDiff  : signed (31 downto 0);
signal regValsEqual : boolean;
signal desiredPCAdd : signed (31 downto 0);
signal sig_ifFlush  : std_logic;
signal PC_offset    : signed (15 downto 0);

BEGIN
  
PC_offset <= signed (instruction (15 downto 0)) srl 2;

action: process (currPCAdd, instruction, regValA, regValB)
begin
  
  regValsDiff <= signed(regValA) - signed(regValB);
  regValsEqual <= regValsDiff = "0000000000000000000000000000";
  
  -- BEQ
  if(instruction (31 downto 26) = "000100") then
    --if reg values are equal, branch
    if(regValsEqual = true) then
       desiredPCAdd <= signed(currPCAdd) + 4 + signed(PC_offset);
       sig_ifFlush <= '1';
    --if reg values are not equal, do not branch
	  elsif (regValsEqual = false) then
	     desiredPCAdd <= signed(currPCAdd) + 4;
	     sig_ifFlush <= '0';
	  end if;
	 
	 -- BNE
  elsif(instruction (31 downto 26) = "000101") then
    --if reg values are not equal, branch
    if(regValsEqual = false) then
       desiredPCAdd <= signed(currPCAdd) + 4 + signed(PC_offset);
       sig_ifFlush <= '1';
	  --if reg values are equal, do not branch
	  elsif (regValsEqual = true) then
	     desiredPCAdd <= signed(currPCAdd) + 4;
	     sig_ifFlush <= '0';
	  end if;
	end if;
		
end process;

nextPCAdd <= std_logic_vector(desiredPCAdd);

END ARCH;


