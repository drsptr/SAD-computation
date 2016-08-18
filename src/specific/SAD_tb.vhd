library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity SAD_TB is
end SAD_TB;

architecture SAD_TEST of SAD_TB is
	component SAD_C
		port (
			PA : in std_logic_vector (7 downto 0);	-- input pixel value image A
			PB : in std_logic_vector (7 downto 0);	-- input pixel value image B
			enable : in std_logic;	-- enable
			SAD : out std_logic_vector (15 downto 0);	-- ouput SAD
			data_valid : out std_logic;	-- specify if the output SAD is valid or not
			clock : in std_logic;	-- clock, active high
			reset : in std_logic	-- reset, active high
		); 
	end component;
	
-- C O N S T A N T S	
	constant MckPer : time := 200 ns;	-- Master Clk period
	constant TestLen : integer := 600;
-- I N P U T	S I G N A L S
	signal PA : std_logic_vector (7 downto 0) := "00001111";
	signal PB : std_logic_vector (7 downto 0) := "00001110";
	signal enable : std_logic := '0';
	signal clock : std_logic := '0';
	signal reset : std_logic := '0';	
-- O U T P U T	S I G N A L S
	signal SAD : std_logic_vector (15 downto 0);
	signal data_valid : std_logic;
	signal clk_cycle : integer;
	signal testing : boolean := true;
	
	begin
		-- port mapping
		I : SAD_C port map (
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
						when 21 => PA <= "00001101";	PB <= "00001111";	-- changes the inputs with enable = '0'
						when 25 => enable <= '1';	-- able again
						when 29 => PA <= "00001111";	PB <= "00001110";	-- changes the inputs with enable = '1' 
						when (TestLen - 1) => testing <= false;
						when others => null;
					end case;
					count := count + 1;
		end process test_proc;
end SAD_TEST;