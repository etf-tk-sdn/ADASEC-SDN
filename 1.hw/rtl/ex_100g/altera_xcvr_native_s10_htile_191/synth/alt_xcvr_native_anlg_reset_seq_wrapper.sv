// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ps/1ps

module alt_xcvr_native_anlg_reset_seq_wrapper
#(	
	parameter CLK_FREQ_IN_HZ = 100000000,
	parameter DEFAULT_RESET_SEPARATION_NS = 100,
	parameter TX_ANALOG_RESET_SEPARATION_NS = 100,	
	parameter RX_ANALOG_RESET_SEPARATION_NS = 100,	
	parameter ENABLE_RESET_SEQUENCER = 0,	
	parameter TX_ENABLE = 1,
	parameter RX_ENABLE = 1,	
	parameter NUM_CHANNELS = 1,
	parameter REDUCED_RESET_SIM_TIME = 0
)(    
	input wire  [NUM_CHANNELS-1:0] tx_analog_reset,
	input wire  [NUM_CHANNELS-1:0] rx_analog_reset,	
	output wire [NUM_CHANNELS-1:0] tx_analogreset_stat,
	output wire [NUM_CHANNELS-1:0] rx_analogreset_stat,	
	output wire [NUM_CHANNELS-1:0] tx_analog_reset_out,
	output wire [NUM_CHANNELS-1:0] rx_analog_reset_out	
);

wire clk;
wire reset_n;

//***************************************************************************
// Getting the clock from Master TRS
//***************************************************************************
altera_s10_xcvr_clkout_endpoint clock_endpoint (	
	.clk_out(clk)
);	

//***************************************************************************
// Need to self-generate internal reset signal
//***************************************************************************
alt_xcvr_resync_std #(
	.SYNC_CHAIN_LENGTH(3),
	.INIT_VALUE(0)
) reset_n_generator (
	.clk	 (clk),
	.reset (1'b0),
	.d		 (1'b1),
	.q		 (reset_n)
);

//***************************************************************************
//*********************** Reset sequencer************************************
genvar ig;
generate	
	if (ENABLE_RESET_SEQUENCER) begin : g_trs		
		if (TX_ENABLE) begin
			// tx_analog_reset
			alt_xcvr_native_anlg_reset_seq #(	
				.CLK_FREQ_IN_HZ					      (CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			    (TX_ANALOG_RESET_SEPARATION_NS),	
				.NUM_RESETS						        (NUM_CHANNELS),
				.REDUCED_RESET_SIM_TIME       (REDUCED_RESET_SIM_TIME)
			) tx_anlg_reset_seq (
				.clk				    (clk),		
				.reset_n			  (reset_n),
				.reset_in			  (tx_analog_reset),
				.reset_out			(tx_analog_reset_out),
				.reset_stat_out	(tx_analogreset_stat)
			);

		end else begin
		   assign tx_analog_reset_out = {NUM_CHANNELS{1'b0}};
		   assign tx_analogreset_stat = {NUM_CHANNELS{1'b0}};
		end
		
		if (RX_ENABLE) begin
			// rx_analog_reset
			alt_xcvr_native_anlg_reset_seq #(	
				.CLK_FREQ_IN_HZ					      (CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			    (RX_ANALOG_RESET_SEPARATION_NS),	
				.NUM_RESETS						        (NUM_CHANNELS),
				.REDUCED_RESET_SIM_TIME       (REDUCED_RESET_SIM_TIME)
			) rx_anlg_reset_seq (
				.clk				    (clk),		
				.reset_n			  (reset_n),
				.reset_in			  (rx_analog_reset),
				.reset_out			(rx_analog_reset_out),
				.reset_stat_out	(rx_analogreset_stat)
			);

		end else begin
		   assign rx_analog_reset_out = {NUM_CHANNELS{1'b0}};
		   assign rx_analogreset_stat = {NUM_CHANNELS{1'b0}};
		end
	end else begin : g_no_trs
		
		assign tx_analogreset_stat = tx_analog_reset;	
		assign rx_analogreset_stat = rx_analog_reset;		
		assign tx_analog_reset_out = tx_analog_reset;
		assign rx_analog_reset_out = rx_analog_reset;

	end

endgenerate

//******************* End reset sequencer ***********************************
//***************************************************************************

endmodule
