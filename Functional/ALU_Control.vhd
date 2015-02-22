LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU_control is
	generic(
		clock_period : time := 1 ns
	);
	port (
		clock			: in std_logic;
		ALUOp			: in std_logic_vector(1 downto 0);
		funct 		: in std_logic_vector(5 downto 0);
		operation	: out std_logic_vector(3 downto 0)
	);
end ALU_control;

architecture behaviour of ALU_control is
	signal op_reg: std_logic_vector(3 downto 0);
	
begin

	reg_process: process (clock)
	begin
	if (clock'event AND clock = '1') then
		case ALUOp is
			-- load and store
			when "00" =>
				op_reg <= "0010";
			-- branch equal
			when "01" =>
				op_reg <= "0110";
			-- R-type
			when "10" =>
				case funct is
					-- add
					when "100000"=>
						op_reg <= "0010";
					-- subtract
					when "100010"=>
						op_reg <= "0110";
					-- AND
					when "100100"=>
						op_reg <= "0000";
					-- OR
					when "100101"=>
						op_reg <= "0001";
					-- set on less than
					when "101010"=>
						op_reg <= "0111";
					when others =>
						op_reg <= "0000";
				end case;
			when others =>
				null;
		end case;
	end if;
	end process;
	
	operation <= op_reg;
end behaviour;