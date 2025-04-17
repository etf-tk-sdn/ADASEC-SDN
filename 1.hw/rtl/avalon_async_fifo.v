/*
  Avalon_async_fifo module - axis_async_fifo module wrapped with Avalon ST input/output interface 
*/

module avalon_async_fifo(

    //Input - RX signali iz ex_100g
    input wire in_clk,
	 input wire in_rst,
	 input wire [511:0] in_data,
	 input wire in_valid,
	 input wire in_eop,
	 input wire in_sop,
	 input wire [5:0] in_empty,
	 output wire in_ready, //Nepovezan signal
	 
	 //Output - TX signali u ex_100g
	 input wire out_clk,
	 input wire out_rst,
	 output wire [511:0] out_data,
	 output wire out_valid,
	 output wire out_eop,
	 output wire out_sop,
	 output wire [5:0] out_empty,
	 input wire out_ready
);

axis_async_fifo #(
        .DEPTH  (32768),
	     .DATA_WIDTH  (512),
		  .USER_WIDTH  (7), //sop(1)+empty(6)
		  .FRAME_FIFO  (1),
		  .DROP_WHEN_FULL (1)
	 ) fifo (
	     .s_clk(in_clk),
		  .s_rst(in_rst),
		  .s_axis_tdata(in_data),
		  .s_axis_tkeep({64{1'b1}}), //KEEP_WIDTH = (DATA_WIDTH+7)/8=(512+7)/8=64  
		  .s_axis_tvalid(in_valid),
		  .s_axis_tready(in_ready),
		  .s_axis_tlast(in_eop),
		  .s_axis_tid({8{1'b0}}),   //ID_WIDTH=8  
		  .s_axis_tdest({8{1'b0}}),  //DEST_WIDTH=8
		  .s_axis_tuser({in_sop, in_empty}),
		  
		  .m_clk(out_clk),
		  .m_rst(out_rst),
		  .m_axis_tdata(out_data),
		  .m_axis_tkeep(),
		  .m_axis_tvalid(out_valid),
		  .m_axis_tready(out_ready),
		  .m_axis_tlast(out_eop),
		  .m_axis_tid(),
		  .m_axis_tdest(),
		  .m_axis_tuser({out_sop, out_empty}),
		  
		  .s_pause_req(1'b0),
		  .s_pause_ack(),
		  .m_pause_req(1'b0),
		  .m_pause_ack(),
		  
		  .s_status_depth(),
		  .s_status_depth_commit(),
		  .s_status_overflow(),
		  .s_status_bad_frame(),
		  .s_status_good_frame(),
		  .m_status_depth(),
		  .m_status_depth_commit(),
		  .m_status_overflow(),
		  .m_status_bad_frame(),
		  .m_status_good_frame()
	 );


endmodule