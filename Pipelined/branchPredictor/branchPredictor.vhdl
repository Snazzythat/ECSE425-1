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
		clk : in std_logic
	);
end branchPredictor;

architecture behaviour of branchPredictor is

	constant	reg_width	: integer := 255;

	type MEM is array(reg_width downto 0) OF std_logic_vector(1 downto 0);
	signal regs: MEM;
	
	signal prediction_ouput : std_logic  := '0';
	
begin

	predictor :process (clk)
	begin
		if(clk'event and clk='0') then
			if (init = '1') then
				for i in 0 to reg_width loop 
					regs(i) <= (others => '0');
				end loop;
					
			elsif (update = '1') then
			
				case regs(to_integer(unsigned(address))) is
					when "00" =>
						if (update_value = '1') then
							regs(to_integer(unsigned(address))) <= "01";
						end if;
					when "01" =>
						if (update_value = '1') then
							regs(to_integer(unsigned(address))) <= "11";
						else
							regs(to_integer(unsigned(address))) <= "00";
						end if;
					when "10" =>
						if (update_value = '1') then
							regs(to_integer(unsigned(address))) <= "11";
						else
							regs(to_integer(unsigned(address))) <= "00";
						end if;
					when "11" =>
						if (update_value = '0') then
							regs(to_integer(unsigned(address))) <= "10";
						end if;			
					when others =>
				end case;
				
						end if;
				
				case regs(to_integer(unsigned(address))) is
					when "00" =>
						prediction_ouput <= '0';
					when "01" =>
						prediction_ouput <= '0';
					when "10" =>
						prediction_ouput <= '1';
					when "11" =>
						prediction_ouput <='1';			
					when others =>
				end case;
				
				prediction <= prediction_ouput;
		end if;
	end process;
	
end behaviour;