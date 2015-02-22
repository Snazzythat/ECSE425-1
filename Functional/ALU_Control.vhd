LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity ALU_control is
	port (
		ALUOp			: in std_logic_vector(1 downto 0);
		funct 		: in std_logic_vector(5 downto 0);
		operation	: out std_logic_vector(3 downto 0)
	);
end ALU_control;

architecture behaviour of ALU_control is
	signal op_reg: std_logic_vector(3 downto 0);
	
begin

	reg_process: process (ALUOp, funct)
	begin
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
				-- AND
				when "100100"=>
					op_reg <= "0000";
				-- OR
				when "100101"=>
					op_reg <= "0001";
				-- add
				when "100000"=>
					op_reg <= "0010";
				-- multiply
				when "011000"=>
					op_reg <= "0011";
				-- divide
				when "011010"=>
					op_reg <= "0100";
				-- subtract
				when "100010"=>
					op_reg <= "0110";
				-- set on less than
				when "101010"=>
					op_reg <= "0111";
				-- shift left logical
				when "000000"=>
					op_reg <= "1000";
				-- shift right logical
				when "000010"=>
					op_reg <= "1001";
				-- shift right arithmetic
				when "000011"=>
					op_reg <= "1010";
				-- NOR
				when "100111"=>
					op_reg <= "1100";
				-- XOR
				when "100110"=>
					op_reg <= "1101";
				when others =>
					null;
			end case;
		when others =>
			null;
	end case;
	end process;
	
	operation <= op_reg;
end behaviour;