	component altera_system_pll is
		port (
			refclk   : in  std_logic := 'X'; -- clk
			locked   : out std_logic;        -- export
			rst      : in  std_logic := 'X'; -- reset
			outclk_0 : out std_logic;        -- clk
			outclk_1 : out std_logic         -- clk
		);
	end component altera_system_pll;

	u0 : component altera_system_pll
		port map (
			refclk   => CONNECTED_TO_refclk,   --  refclk.clk
			locked   => CONNECTED_TO_locked,   --  locked.export
			rst      => CONNECTED_TO_rst,      --   reset.reset
			outclk_0 => CONNECTED_TO_outclk_0, -- outclk0.clk
			outclk_1 => CONNECTED_TO_outclk_1  -- outclk1.clk
		);

