library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SADg_TB is
end SADg_TB;

architecture SADg_TEST of SADg_TB is
	component SADg_C
		generic (
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
	end component;
	
-- C O N S T A N T S	
	constant MckPer : time := 200 ns;	-- Master Clk period
	constant TestLen : integer := 600;
	constant Nin : integer := 8;
	constant Nout : integer := 12;
-- I N P U T	S I G N A L S
	signal PA : std_logic_vector ((Nin - 1) downto 0) := "00000000";
	signal PB : std_logic_vector ((Nin - 1) downto 0) := "11111111";
	signal enable : std_logic := '1';
	signal clock : std_logic := '0';
	signal reset : std_logic := '0';	
-- O U T P U T	S I G N A L S
	signal SAD : std_logic_vector ((Nout - 1) downto 0);
	signal data_valid : std_logic;
	signal clk_cycle : integer;
	signal testing : boolean := true;
	
	begin
		-- port mapping
		I : SADg_C port map (
				PA => PA,
				PB => PB,
				enable => enable,
				SAD => SAD,
				data_valid => data_valid,
				clock => clock,
				reset => reset
			);
		-- clock generation
		clock <= not clock after MckPer/2 when testing else '0';
		-- Runs simulation for TestLen cycles
		test_proc : process(clock)
			variable count : integer := 0;
				begin
					clk_cycle <= (count + 1)/2;
					case count is
						when 5 => reset <= '1';		-- sends the reset
						when 7 => reset <= '0';
						when 15 => enable <= '0';	-- disable
						when 25 => enable <= '1';	-- able again
						when (TestLen - 1) => testing <= false;
						when others => null;
					end case;
					count := count + 1;
		end process test_proc;
end SADg_TEST;