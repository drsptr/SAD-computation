library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SAD_C is
	port (
		PA : in std_logic_vector (7 downto 0);	-- input pixel value image A
		PB : in std_logic_vector (7 downto 0);	-- input pixel value image B
		enable : in std_logic;	-- enable
		SAD : out std_logic_vector (15 downto 0);	-- ouput SAD
		data_valid : out std_logic;	-- specify if the output SAD is valid or not
		clock : in std_logic;	-- clock, active high
		reset : in std_logic	-- reset, active high
	);
end SAD_C;

architecture BEHAVIOURAL of SAD_C is
		signal sumdiffs : std_logic_vector (15 downto 0);	-- it mantains the sum of all the absolute differences until now, starting from the reset 
		signal op_count : integer;	-- it counts the number of operations performed until now, starting from the reset
	begin
		sad_calc : process (clock, reset)  
		-- internal variables
		variable extPA : std_logic_vector (15 downto 0);	-- it adapts the input 'PA' to the output length
		variable extPB : std_logic_vector (15 downto 0);	-- it adapts the input 'PB' to the output length
		variable diff : std_logic_vector (15 downto 0);		-- it keeps the difference between 'PA' and 'PB'														
			begin
				-- reset event; it clears the output vars and the internal ones
				if(reset = '1') then
					data_valid <= '0';
					op_count <= 0;
					extPA := (others => '0');
					extPB := (others => '0');
					diff := (others => '0');
					sumdiffs <= (others => '0');
				-- clock positive edge; perform the computation
				elsif(clock'event and clock = '1') then
					data_valid <= '0';
					-- it checks the 'enable' input; it skips all the operations if the latter is equal to 0
					if(enable = '1') then
						-- SAD computation is finished; it sets 'data_valid' to 1	
						if(op_count + 1 = 256) then
							data_valid <= '1';
						end if;
						-- it alligns the inputs'lenght to the output's one
						extPA := "00000000" & PA;
						extPB := "00000000" & PB;
						-- it computes the difference between the extended inputs
						diff := std_logic_vector(unsigned(extPA) - unsigned(extPB));
						-- it checks if the result is positive or not, and performs the abs eventually
						-- negative result; it changes the sign of the difference
						if(diff(8) = '1') then
							diff := std_logic_vector(-(signed(diff)));
						end if;
						-- it adds the current difference to the ones computed until now
						sumdiffs <= std_logic_vector(unsigned(sumdiffs) + unsigned(diff));
						-- it increments the 'op_cont' and set the output
						op_count <= op_count + 1;
					end if;
				end if;
			end process;
			SAD <= sumdiffs;
end BEHAVIOURAL;