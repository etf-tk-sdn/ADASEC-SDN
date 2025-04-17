module eth_100g(

    //interface to/from QSFP
	 input wire [3:0] rx_serial,
	 input wire clk_ref_r,
	 input wire clk100,
	 input wire rst,
	 output wire [3:0] tx_serial,
	 output wire clk390,
	 
	 input wire fifo_rst,   //za resetovanje fifo strane
	 input wire fifo_clk,
	 
	 //Avalon ST interface from FIFO buffer
	 
	 output wire [511:0] fifo_out_data,
	 output wire fifo_out_valid,
    output wire fifo_out_sop,
    output wire fifo_out_eop,
    output wire [5:0] fifo_out_empty,
    input wire fifo_out_ready,
	 
	 //Avalon ST interface to FIFO buffer
	 
	 input wire [511:0] fifo_in_data,
	 input wire fifo_in_valid,
    input wire fifo_in_sop,
    input wire fifo_in_eop,
    input wire [5:0] fifo_in_empty,
    output wire fifo_in_ready
	 
);

localparam DEVICE_FAMILY = "Stratix 10";

wire serial_clk_1;
wire pll_locked_1;
wire serial_clk_2;
wire pll_locked_2;


wire [1:0] pll_locked;
wire [1:0] serial_clk;

atx_pll_s100 atx1 (
    .pll_refclk0(clk_ref_r),          // pll_refclk0.clk
    .tx_serial_clk_gxt(serial_clk_1),
    .pll_locked(pll_locked_1),      // pll_locked.pll_locked
    .pll_cal_busy()                 // pll_cal_busy.pll_cal_busy
);
    
atx_pll_s100 atx2 (
    .pll_refclk0(clk_ref_r),          // pll_refclk0.clk
    .tx_serial_clk_gxt(serial_clk_2),
    .pll_locked(pll_locked_2),      // pll_locked.pll_locked
    .pll_cal_busy()                 // pll_cal_busy.pll_cal_busy
);

assign pll_locked = {pll_locked_1, pll_locked_2};
assign serial_clk = {serial_clk_1, serial_clk_2};

wire clk_txmac;
wire clk_rxmac;
wire    [511:0] l8_tx_data;
wire      [5:0] l8_tx_empty;
wire            l8_tx_endofpacket;
wire            l8_tx_ready;
wire            l8_tx_startofpacket;
wire            l8_tx_valid;
wire    [511:0] l8_rx_data;
wire      [5:0] l8_rx_empty;
wire            l8_rx_endofpacket;
wire            l8_rx_startofpacket;
wire            l8_rx_valid;
wire      [5:0] l8_rx_error;



ex_100g ex_100g_inst (
        .clk_ref(clk_ref_r),
        .csr_rst_n(~rst),
        .tx_rst_n(1'b1),
        .rx_rst_n(1'b1),
        .clk_status(clk100),
        .status_write(1'b0),
        .status_read(1'b0),
        .status_addr({16{1'b0}}),
        .status_writedata({32{1'b0}}),
        .status_readdata(),
        .status_readdata_valid(),
        .status_waitrequest(),

        .clk_txmac(clk_txmac),
        .l8_tx_startofpacket(l8_tx_startofpacket),
        .l8_tx_endofpacket(l8_tx_endofpacket),
        .l8_tx_valid(l8_tx_valid),
        .l8_tx_ready(l8_tx_ready),
        .l8_tx_empty(l8_tx_empty),
        .l8_tx_data(l8_tx_data),
        .l8_tx_error(1'b0),
        .clk_rxmac(clk_rxmac),
        .l8_rx_error(l8_rx_error),
        .l8_rx_valid(l8_rx_valid),
        .l8_rx_startofpacket(l8_rx_startofpacket),
        .l8_rx_endofpacket(l8_rx_endofpacket),
        .l8_rx_empty(l8_rx_empty),
        .l8_rx_data(l8_rx_data),

        .tx_serial(tx_serial),
        .rx_serial(rx_serial),

        .reconfig_clk(clk100),
        .reconfig_reset(rst),
        .reconfig_write(1'b0),
        .reconfig_read(1'b0),
        .reconfig_address({13{1'b0}}),  //u top level entitetu 11:0, a u dokumentaciji 12:0
        .reconfig_writedata({32{1'b0}}),
        .reconfig_readdata(),
        .reconfig_waitrequest(),

        .tx_lanes_stable(),
        .rx_pcs_ready(),
        .rx_block_lock(),
        .rx_am_lock(),
        .l8_txstatus_valid(),
        .l8_txstatus_data(),
        .l8_txstatus_error(),
        .l8_rxstatus_valid(),
        .l8_rxstatus_data(),
        .tx_serial_clk(serial_clk),
        .tx_pll_locked(pll_locked)
    );


/*wire [511:0] data_fifo;
wire valid_fifo;
wire sop_fifo;
wire eop_fifo;
wire [5:0] empty_fifo;
wire ready_fifo;*/

	 
avalon_async_fifo fifo_rx(
	 .in_clk(clk_rxmac),
	 .in_rst(1'b0),
	 .in_data(l8_rx_data),
	 .in_valid(l8_rx_valid),
    .in_eop(l8_rx_endofpacket),
	 .in_sop(l8_rx_startofpacket),
	 .in_empty(l8_rx_empty),
	 .in_ready(),
		  
	 .out_clk(fifo_clk),
	 .out_rst(fifo_rst),
    .out_data(fifo_out_data),
	 .out_valid(fifo_out_valid),
	 .out_eop(fifo_out_eop),
	 .out_sop(fifo_out_sop),
	 .out_empty(fifo_out_empty),
	 .out_ready(fifo_out_ready)
		  
);
	 
avalon_async_fifo fifo_tx(
	 .in_clk(fifo_clk),
	 .in_rst(fifo_rst),
	 .in_data(fifo_in_data),
	 .in_valid(fifo_in_valid),
	 .in_eop(fifo_in_eop),
	 .in_sop(fifo_in_sop),
	 .in_empty(fifo_in_empty),
	 .in_ready(fifo_in_ready),
		  
	 .out_clk(clk_txmac),
	 .out_rst(1'b0),
	 .out_data(l8_tx_data),
	 .out_valid(l8_tx_valid),
	 .out_eop(l8_tx_endofpacket),
	 .out_sop(l8_tx_startofpacket),
	 .out_empty(l8_tx_empty),
	 .out_ready(l8_tx_ready)
		  
);

assign clk390 = clk_rxmac;

endmodule