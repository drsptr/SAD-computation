library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SADg_C is
	generic (
		Npixel : integer := 4 * 4;	-- total # of pixels of the image
		Nin : integer := 8;		-- # of bits needed to represent the value of each pixel
		Nout : integer := 12 	-- # of bits needed to represent the output
	);
	port (
		PA : in std_logic_vector ((Nin - 1) downto 0);	-- input pixel value image A
		PB : in std_logic_vector ((Nin - 1) downto 0);	-- input pixel value image B
		enable : in std_logic;	-- enable
		SAD : out std_logic_vector ((Nout - 1) downto 0);	-- ouput SAD
		data_valid : out std_logic;	-- specify if the output SAD is valid or not
		clock : in std_logic;	-- clock, active high
		reset : in std_logic	-- reset, active high
	);
end SADg_C;

architecture BEHAVIOURAL of SADg_C is
	signal sumdiffs : std_logic_vector ((Nout - 1) downto 0);	-- it mantains the sum of all the absolute differences until now, starting from the reset
	signal op_count : integer;	-- it counts the number of operations performed until now, starting from the reset
	constant zeros : std_logic_vector((Nout - Nin - 1) downto 0) := (others => '0'); -- constant string of 0s; it is used to extend the inputs
	begin
		sadg_calc : process (clock, reset, enable)  
		-- internal variables
		variable extPA : std_logic_vector ((Nout - 1) downto 0);	-- it adapts the input 'PA' to the output length
		variable extPB : std_logic_vector ((Nout - 1) downto 0);	-- it adapts the input 'PB' to the output length
		variable diff : std_logic_vector ((Nout - 1) downto 0);		-- it keeps the difference between 'PA' and 'PB' 
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
						if(op_count + 1 = Npixel) then
							data_valid <= '1';
						end if;
						extPA := zeros & PA;
						extPB := zeros & PB;
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