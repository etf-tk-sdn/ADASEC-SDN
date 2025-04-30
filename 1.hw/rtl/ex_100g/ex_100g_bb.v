module ex_100g (
		input  wire         clk_status,            //       status.clk_status
		input  wire         status_write,          //             .status_write
		input  wire         status_read,           //             .status_read
		input  wire [15:0]  status_addr,           //             .status_addr
		input  wire [31:0]  status_writedata,      //             .status_writedata
		output wire [31:0]  status_readdata,       //             .status_readdata
		output wire         status_readdata_valid, //             .status_readdata_valid
		output wire         status_waitrequest,    //             .status_waitrequest
		output wire         clk_txmac,             // avalon_st_tx.clk_txmac
		input  wire         l8_tx_startofpacket,   //             .l8_tx_startofpacket
		input  wire         l8_tx_endofpacket,     //             .l8_tx_endofpacket
		input  wire         l8_tx_valid,           //             .l8_tx_valid
		output wire         l8_tx_ready,           //             .l8_tx_ready
		input  wire         l8_tx_error,           //             .l8_tx_error
		input  wire [5:0]   l8_tx_empty,           //             .l8_tx_empty
		input  wire [511:0] l8_tx_data,            //             .l8_tx_data
		output wire         clk_rxmac,             // avalon_st_rx.clk_rxmac
		output wire [5:0]   l8_rx_error,           //             .l8_rx_error
		output wire         l8_rx_valid,           //             .l8_rx_valid
		output wire         l8_rx_startofpacket,   //             .l8_rx_startofpacket
		output wire         l8_rx_endofpacket,     //             .l8_rx_endofpacket
		output wire [5:0]   l8_rx_empty,           //             .l8_rx_empty
		output wire [511:0] l8_rx_data,            //             .l8_rx_data
		output wire [3:0]   tx_serial,             // serial_lanes.tx_serial
		input  wire [3:0]   rx_serial,             //             .rx_serial
		input  wire         reconfig_clk,          //     reconfig.reconfig_clk
		input  wire         reconfig_reset,        //             .reconfig_reset
		input  wire         reconfig_write,        //             .reconfig_write
		input  wire         reconfig_read,         //             .reconfig_read
		input  wire [12:0]  reconfig_address,      //             .reconfig_address
		input  wire [31:0]  reconfig_writedata,    //             .reconfig_writedata
		output wire [31:0]  reconfig_readdata,     //             .reconfig_readdata
		output wire         reconfig_waitrequest,  //             .reconfig_waitrequest
		output wire         tx_lanes_stable,       //        other.tx_lanes_stable
		output wire         rx_pcs_ready,          //             .rx_pcs_ready
		output wire         rx_block_lock,         //             .rx_block_lock
		output wire         rx_am_lock,            //             .rx_am_lock
		input  wire         clk_ref,               //             .clk_ref
		input  wire         csr_rst_n,             //             .csr_rst_n
		input  wire         tx_rst_n,              //             .tx_rst_n
		input  wire         rx_rst_n,              //             .rx_rst_n
		input  wire [1:0]   tx_serial_clk,         //             .tx_serial_clk
		input  wire [1:0]   tx_pll_locked,         //             .tx_pll_locked
		output wire         l8_txstatus_valid,     //        stats.l8_txstatus_valid
		output wire [39:0]  l8_txstatus_data,      //             .l8_txstatus_data
		output wire [6:0]   l8_txstatus_error,     //             .l8_txstatus_error
		output wire         l8_rxstatus_valid,     //             .l8_rxstatus_valid
		output wire [39:0]  l8_rxstatus_data       //             .l8_rxstatus_data
	);
endmodule

