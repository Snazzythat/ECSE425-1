LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity branchPredictor is
	port (
		init : in std_logic;
		address : in std_logic_vector(7 downto 0);
		update	: in std_logic;
		update_value : in std_logic;
		prediction 	: out std_logic;
	);
end branchPredictor;

architecture behaviour of branchPredictor is

	constant	reg_width	: integer := 255;

	type MEM is array(reg_width downto 0) OF std_logic_vector(1 downto 0);
	signal regs: MEM;
	-- Register 0 : connected to ground
	-- Register 31: return address
	-- Register 32: LO
	-- Register 33: HI
	begin
		if (init = '1') then
			for i in 0 to reg_width-1 loop 
				regs(i) <= (others => '0');
			end loop;
				
		elsif (update = '1') then
		
			case regs(to_integer(unsigned(address))) is
				when "00" =>
					if (update_value == '1') 
						regs(to_integer(unsigned(address))) <= "01";
					end if;
				when "01" =>
					if (update_value == '1') 
						regs(to_integer(unsigned(address))) <= "11";
					elsif
						regs(to_integer(unsigned(address))) <= "00";
					end if;
				when "10" =>
					if (update_value == '1') 
						regs(to_integer(unsigned(address))) <= "11";
					elsif
						regs(to_integer(unsigned(address))) <= "00";
					end if;
				when "11" =>
					if (update_value == '0') 
						regs(to_integer(unsigned(address))) <= "10";
					end if;			
				when others =>
			end case;
			
		else
			case regs(to_integer(unsigned(address))) is
				when "00" =>
					prediction <= '0';
				when "01" =>
					prediction <= '0';
				when "10" =>
					prediction <= '1';
				when "11" =>
					prediction <='1';			
				when others =>
			end case;
		end if;
	end process;
	
end behaviour;