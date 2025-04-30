	component ex_100g is
		port (
			clk_status            : in  std_logic                      := 'X';             -- clk_status
			status_write          : in  std_logic                      := 'X';             -- status_write
			status_read           : in  std_logic                      := 'X';             -- status_read
			status_addr           : in  std_logic_vector(15 downto 0)  := (others => 'X'); -- status_addr
			status_writedata      : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- status_writedata
			status_readdata       : out std_logic_vector(31 downto 0);                     -- status_readdata
			status_readdata_valid : out std_logic;                                         -- status_readdata_valid
			status_waitrequest    : out std_logic;                                         -- status_waitrequest
			clk_txmac             : out std_logic;                                         -- clk_txmac
			l8_tx_startofpacket   : in  std_logic                      := 'X';             -- l8_tx_startofpacket
			l8_tx_endofpacket     : in  std_logic                      := 'X';             -- l8_tx_endofpacket
			l8_tx_valid           : in  std_logic                      := 'X';             -- l8_tx_valid
			l8_tx_ready           : out std_logic;                                         -- l8_tx_ready
			l8_tx_error           : in  std_logic                      := 'X';             -- l8_tx_error
			l8_tx_empty           : in  std_logic_vector(5 downto 0)   := (others => 'X'); -- l8_tx_empty
			l8_tx_data            : in  std_logic_vector(511 downto 0) := (others => 'X'); -- l8_tx_data
			clk_rxmac             : out std_logic;                                         -- clk_rxmac
			l8_rx_error           : out std_logic_vector(5 downto 0);                      -- l8_rx_error
			l8_rx_valid           : out std_logic;                                         -- l8_rx_valid
			l8_rx_startofpacket   : out std_logic;                                         -- l8_rx_startofpacket
			l8_rx_endofpacket     : out std_logic;                                         -- l8_rx_endofpacket
			l8_rx_empty           : out std_logic_vector(5 downto 0);                      -- l8_rx_empty
			l8_rx_data            : out std_logic_vector(511 downto 0);                    -- l8_rx_data
			tx_serial             : out std_logic_vector(3 downto 0);                      -- tx_serial
			rx_serial             : in  std_logic_vector(3 downto 0)   := (others => 'X'); -- rx_serial
			reconfig_clk          : in  std_logic                      := 'X';             -- reconfig_clk
			reconfig_reset        : in  std_logic                      := 'X';             -- reconfig_reset
			reconfig_write        : in  std_logic                      := 'X';             -- reconfig_write
			reconfig_read         : in  std_logic                      := 'X';             -- reconfig_read
			reconfig_address      : in  std_logic_vector(12 downto 0)  := (others => 'X'); -- reconfig_address
			reconfig_writedata    : in  std_logic_vector(31 downto 0)  := (others => 'X'); -- reconfig_writedata
			reconfig_readdata     : out std_logic_vector(31 downto 0);                     -- reconfig_readdata
			reconfig_waitrequest  : out std_logic;                                         -- reconfig_waitrequest
			tx_lanes_stable       : out std_logic;                                         -- tx_lanes_stable
			rx_pcs_ready          : out std_logic;                                         -- rx_pcs_ready
			rx_block_lock         : out std_logic;                                         -- rx_block_lock
			rx_am_lock            : out std_logic;                                         -- rx_am_lock
			clk_ref               : in  std_logic                      := 'X';             -- clk_ref
			csr_rst_n             : in  std_logic                      := 'X';             -- csr_rst_n
			tx_rst_n              : in  std_logic                      := 'X';             -- tx_rst_n
			rx_rst_n              : in  std_logic                      := 'X';             -- rx_rst_n
			tx_serial_clk         : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_serial_clk
			tx_pll_locked         : in  std_logic_vector(1 downto 0)   := (others => 'X'); -- tx_pll_locked
			l8_txstatus_valid     : out std_logic;                                         -- l8_txstatus_valid
			l8_txstatus_data      : out std_logic_vector(39 downto 0);                     -- l8_txstatus_data
			l8_txstatus_error     : out std_logic_vector(6 downto 0);                      -- l8_txstatus_error
			l8_rxstatus_valid     : out std_logic;                                         -- l8_rxstatus_valid
			l8_rxstatus_data      : out std_logic_vector(39 downto 0)                      -- l8_rxstatus_data
		);
	end component ex_100g;

	u0 : component ex_100g
		port map (
			clk_status            => CONNECTED_TO_clk_status,            --       status.clk_status
			status_write          => CONNECTED_TO_status_write,          --             .status_write
			status_read           => CONNECTED_TO_status_read,           --             .status_read
			status_addr           => CONNECTED_TO_status_addr,           --             .status_addr
			status_writedata      => CONNECTED_TO_status_writedata,      --             .status_writedata
			status_readdata       => CONNECTED_TO_status_readdata,       --             .status_readdata
			status_readdata_valid => CONNECTED_TO_status_readdata_valid, --             .status_readdata_valid
			status_waitrequest    => CONNECTED_TO_status_waitrequest,    --             .status_waitrequest
			clk_txmac             => CONNECTED_TO_clk_txmac,             -- avalon_st_tx.clk_txmac
			l8_tx_startofpacket   => CONNECTED_TO_l8_tx_startofpacket,   --             .l8_tx_startofpacket
			l8_tx_endofpacket     => CONNECTED_TO_l8_tx_endofpacket,     --             .l8_tx_endofpacket
			l8_tx_valid           => CONNECTED_TO_l8_tx_valid,           --             .l8_tx_valid
			l8_tx_ready           => CONNECTED_TO_l8_tx_ready,           --             .l8_tx_ready
			l8_tx_error           => CONNECTED_TO_l8_tx_error,           --             .l8_tx_error
			l8_tx_empty           => CONNECTED_TO_l8_tx_empty,           --             .l8_tx_empty
			l8_tx_data            => CONNECTED_TO_l8_tx_data,            --             .l8_tx_data
			clk_rxmac             => CONNECTED_TO_clk_rxmac,             -- avalon_st_rx.clk_rxmac
			l8_rx_error           => CONNECTED_TO_l8_rx_error,           --             .l8_rx_error
			l8_rx_valid           => CONNECTED_TO_l8_rx_valid,           --             .l8_rx_valid
			l8_rx_startofpacket   => CONNECTED_TO_l8_rx_startofpacket,   --             .l8_rx_startofpacket
			l8_rx_endofpacket     => CONNECTED_TO_l8_rx_endofpacket,     --             .l8_rx_endofpacket
			l8_rx_empty           => CONNECTED_TO_l8_rx_empty,           --             .l8_rx_empty
			l8_rx_data            => CONNECTED_TO_l8_rx_data,            --             .l8_rx_data
			tx_serial             => CONNECTED_TO_tx_serial,             -- serial_lanes.tx_serial
			rx_serial             => CONNECTED_TO_rx_serial,             --             .rx_serial
			reconfig_clk          => CONNECTED_TO_reconfig_clk,          --     reconfig.reconfig_clk
			reconfig_reset        => CONNECTED_TO_reconfig_reset,        --             .reconfig_reset
			reconfig_write        => CONNECTED_TO_reconfig_write,        --             .reconfig_write
			reconfig_read         => CONNECTED_TO_reconfig_read,         --             .reconfig_read
			reconfig_address      => CONNECTED_TO_reconfig_address,      --             .reconfig_address
			reconfig_writedata    => CONNECTED_TO_reconfig_writedata,    --             .reconfig_writedata
			reconfig_readdata     => CONNECTED_TO_reconfig_readdata,     --             .reconfig_readdata
			reconfig_waitrequest  => CONNECTED_TO_reconfig_waitrequest,  --             .reconfig_waitrequest
			tx_lanes_stable       => CONNECTED_TO_tx_lanes_stable,       --        other.tx_lanes_stable
			rx_pcs_ready          => CONNECTED_TO_rx_pcs_ready,          --             .rx_pcs_ready
			rx_block_lock         => CONNECTED_TO_rx_block_lock,         --             .rx_block_lock
			rx_am_lock            => CONNECTED_TO_rx_am_lock,            --             .rx_am_lock
			clk_ref               => CONNECTED_TO_clk_ref,               --             .clk_ref
			csr_rst_n             => CONNECTED_TO_csr_rst_n,             --             .csr_rst_n
			tx_rst_n              => CONNECTED_TO_tx_rst_n,              --             .tx_rst_n
			rx_rst_n              => CONNECTED_TO_rx_rst_n,              --             .rx_rst_n
			tx_serial_clk         => CONNECTED_TO_tx_serial_clk,         --             .tx_serial_clk
			tx_pll_locked         => CONNECTED_TO_tx_pll_locked,         --             .tx_pll_locked
			l8_txstatus_valid     => CONNECTED_TO_l8_txstatus_valid,     --        stats.l8_txstatus_valid
			l8_txstatus_data      => CONNECTED_TO_l8_txstatus_data,      --             .l8_txstatus_data
			l8_txstatus_error     => CONNECTED_TO_l8_txstatus_error,     --             .l8_txstatus_error
			l8_rxstatus_valid     => CONNECTED_TO_l8_rxstatus_valid,     --             .l8_rxstatus_valid
			l8_rxstatus_data      => CONNECTED_TO_l8_rxstatus_data       --             .l8_rxstatus_data
		);

