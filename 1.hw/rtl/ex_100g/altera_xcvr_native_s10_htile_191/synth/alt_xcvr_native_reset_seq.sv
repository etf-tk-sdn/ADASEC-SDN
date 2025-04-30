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

module alt_xcvr_native_reset_seq
#(	
	parameter CLK_FREQ_IN_HZ = 100000000,
	parameter DEFAULT_RESET_SEPARATION_NS = 100,
	parameter TX_ANALOG_RESET_SEPARATION_NS = 100,	
	parameter RX_ANALOG_RESET_SEPARATION_NS = 100,	
	parameter DIGITAL_RESET_SEPARATION_NS = 100,	
	parameter TX_PCS_RESET_EXTENSION_NS = 0,
	parameter RX_PCS_RESET_EXTENSION_NS = 0,
	parameter ENABLE_RESET_SEQUENCER = 0,	
	parameter TX_ENABLE = 1,
	parameter RX_ENABLE = 1,	
	parameter TX_RESET_MODE = "non_bonded",		// non_bonded, bonded, non_bonded_simultaneous
	parameter RX_RESET_MODE = "non_bonded",		// non_bonded, bonded, non_bonded_simultaneous
	parameter TX_BONDING_MASTER = 0,
	parameter RX_BONDING_MASTER = 0,
	parameter NUM_CHANNELS = 1,
	parameter REDUCED_RESET_SIM_TIME = 0
)(    
	input wire tx_release_aib_first,	
	input wire [NUM_CHANNELS-1:0] tx_analog_reset,
	input wire [NUM_CHANNELS-1:0] rx_analog_reset,	
	input wire [NUM_CHANNELS-1:0] tx_digital_reset,	
	input wire [NUM_CHANNELS-1:0] rx_digital_reset,	
	input wire [NUM_CHANNELS-1:0] tx_transfer_ready,	
	input wire [NUM_CHANNELS-1:0] rx_transfer_ready,	
	output wire [NUM_CHANNELS-1:0] tx_analogreset_stat,
	output wire [NUM_CHANNELS-1:0] rx_analogreset_stat,	
	output wire [NUM_CHANNELS-1:0] tx_analog_reset_out,
	output wire [NUM_CHANNELS-1:0] rx_analog_reset_out,	
	output wire [NUM_CHANNELS-1:0] tx_digitalreset_stat,
	output wire [NUM_CHANNELS-1:0] rx_digitalreset_stat,
	output wire [NUM_CHANNELS-1:0] tx_digitalreset_timeout,
	output wire [NUM_CHANNELS-1:0] rx_digitalreset_timeout,
	output wire [NUM_CHANNELS-1:0] tx_aib_reset_out,	
	output wire [NUM_CHANNELS-1:0] rx_aib_reset_out,	
	output wire [NUM_CHANNELS-1:0] tx_pcs_reset_out,
	output wire [NUM_CHANNELS-1:0] rx_pcs_reset_out
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
	.clk	(clk),
	.reset	(1'b0),
	.d		(1'b1),
	.q		(reset_n)
);

//***************************************************************************
//*********************** Reset sequencer************************************
genvar ig;
generate	
	if (ENABLE_RESET_SEQUENCER) begin : g_trs		
		if (TX_ENABLE) begin
			// tx_analog_reset
			alt_xcvr_native_anlg_reset_seq #(	
				.CLK_FREQ_IN_HZ					(CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			(TX_ANALOG_RESET_SEPARATION_NS),	
				.NUM_RESETS						(NUM_CHANNELS),
				.REDUCED_RESET_SIM_TIME         (REDUCED_RESET_SIM_TIME)
			) tx_anlg_reset_seq (
				.clk				(clk),		
				.reset_n			(reset_n),
				.reset_in			(tx_analog_reset),
				.reset_out			(tx_analog_reset_out),
				.reset_stat_out		(tx_analogreset_stat)
			);

			// tx_digital_reset	
			alt_xcvr_native_dig_reset_seq #(	
				.CLK_FREQ_IN_HZ					(CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			(DIGITAL_RESET_SEPARATION_NS),
				.PCS_RESET_EXTENSION_NS			(TX_PCS_RESET_EXTENSION_NS),
				.BONDING_MASTER					(TX_BONDING_MASTER),
				.RESET_MODE						(TX_RESET_MODE),
				.NUM_CHANNELS					(NUM_CHANNELS),						
				.RESET_AIB_FIRST				(0),
				.REDUCED_RESET_SIM_TIME         (REDUCED_RESET_SIM_TIME)
			) tx_dig_reset_seq (	
				.clk					(clk),
				.reset_n				(reset_n),	
				.reset_in				(tx_digital_reset),
				.release_aib_first		(tx_release_aib_first),
				.transfer_ready_in		(tx_transfer_ready),	
				.aib_reset_out			(tx_aib_reset_out),	
				.pcs_reset_out			(tx_pcs_reset_out),
				.reset_out				(tx_digitalreset_stat),
				.reset_timeout			(tx_digitalreset_timeout)			
			);
		end else begin
		   assign tx_analog_reset_out = {NUM_CHANNELS{1'b0}};
		   assign tx_aib_reset_out = {NUM_CHANNELS{1'b0}};
		   assign tx_pcs_reset_out = {NUM_CHANNELS{1'b0}};
		   assign tx_analogreset_stat = {NUM_CHANNELS{1'b0}};
		   assign tx_digitalreset_stat = {NUM_CHANNELS{1'b0}};
		   assign tx_digitalreset_timeout = {NUM_CHANNELS{1'b0}};
		end
		
		if (RX_ENABLE) begin
			// rx_analog_reset
			alt_xcvr_native_anlg_reset_seq #(	
				.CLK_FREQ_IN_HZ					(CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			(RX_ANALOG_RESET_SEPARATION_NS),	
				.NUM_RESETS						(NUM_CHANNELS),
				.REDUCED_RESET_SIM_TIME         (REDUCED_RESET_SIM_TIME)
			) rx_anlg_reset_seq (
				.clk				(clk),		
				.reset_n			(reset_n),
				.reset_in			(rx_analog_reset),
				.reset_out			(rx_analog_reset_out),
				.reset_stat_out		(rx_analogreset_stat)
			);

			// rx_digital_reset
			alt_xcvr_native_dig_reset_seq #(	
				.CLK_FREQ_IN_HZ					(CLK_FREQ_IN_HZ),
				.DEFAULT_RESET_SEPARATION_NS	(DEFAULT_RESET_SEPARATION_NS),
				.RESET_SEPARATION_NS			(DIGITAL_RESET_SEPARATION_NS),
				.PCS_RESET_EXTENSION_NS			(RX_PCS_RESET_EXTENSION_NS),
				.BONDING_MASTER					(RX_BONDING_MASTER),
				.RESET_MODE						(RX_RESET_MODE),
				.NUM_CHANNELS					(NUM_CHANNELS),									
				.RESET_AIB_FIRST				(1),
				.REDUCED_RESET_SIM_TIME         (REDUCED_RESET_SIM_TIME)
			) rx_dig_reset_seq (	
				.clk					(clk),
				.reset_n				(reset_n),	
				.reset_in				(rx_digital_reset),
				.release_aib_first		(1'b1),	
				.transfer_ready_in		(rx_transfer_ready),	
				.aib_reset_out			(rx_aib_reset_out),	
				.pcs_reset_out			(rx_pcs_reset_out),
				.reset_out				(rx_digitalreset_stat),
				.reset_timeout			(rx_digitalreset_timeout)						
			);
		end else begin
		   assign rx_analog_reset_out = {NUM_CHANNELS{1'b0}};
		   assign rx_aib_reset_out = {NUM_CHANNELS{1'b0}};
		   assign rx_pcs_reset_out = {NUM_CHANNELS{1'b0}};
		   assign rx_analogreset_stat = {NUM_CHANNELS{1'b0}};
		   assign rx_digitalreset_stat = {NUM_CHANNELS{1'b0}};
		   assign rx_digitalreset_timeout = {NUM_CHANNELS{1'b0}};
		end
	end else begin : g_no_trs
		wire [NUM_CHANNELS-1:0] tx_pcs_reset;
		wire [NUM_CHANNELS-1:0] rx_pcs_reset;
		wire [NUM_CHANNELS-1:0] tx_transfer_ready_sync;
		wire [NUM_CHANNELS-1:0] rx_transfer_ready_sync;
		wire [NUM_CHANNELS-1:0] tx_digital_reset_sync;
		wire [NUM_CHANNELS-1:0] rx_digital_reset_sync;
		reg [NUM_CHANNELS-1:0] tx_pcs_reset_req;
		reg [NUM_CHANNELS-1:0] rx_pcs_reset_req;		
		
		assign tx_analogreset_stat = tx_analog_reset;	
		assign rx_analogreset_stat = rx_analog_reset;		
		assign tx_analog_reset_out = tx_analog_reset;
		assign rx_analog_reset_out = rx_analog_reset;

		assign tx_aib_reset_out = tx_digital_reset;		
		assign rx_aib_reset_out = rx_digital_reset;								
		assign tx_pcs_reset_out = tx_pcs_reset;
		assign rx_pcs_reset_out = rx_pcs_reset;						

		if (TX_ENABLE) begin : g_tx
			for(ig=0; ig<NUM_CHANNELS; ig=ig+1) begin : g_reset	
				assign tx_digitalreset_stat[ig] = tx_digital_reset_sync[ig] ? ~tx_transfer_ready_sync[ig] : tx_pcs_reset[ig];				
							
				alt_xcvr_resync_std #(
					.SYNC_CHAIN_LENGTH(2),
					.WIDTH(1)				
				) tx_transfer_ready_synchronizer (
					.clk		(clk),
					.reset	    (~reset_n),
					.d			(tx_transfer_ready[ig]),
					.q			(tx_transfer_ready_sync[ig])
				);
					
				alt_xcvr_resync_std #(
					.SYNC_CHAIN_LENGTH(2),
					.WIDTH(1)				
				) tx_digital_reset_synchronizer (
					.clk		(clk),
					.reset		(~reset_n),
					.d			(tx_digital_reset[ig]),
					.q			(tx_digital_reset_sync[ig])
				);
								
				always @(posedge clk or negedge reset_n) begin
					if (~reset_n) begin
						tx_pcs_reset_req[ig] <= 1'b0;
					end else if (tx_digital_reset_sync[ig])	begin
						tx_pcs_reset_req[ig] <= 1'b1;					
					end else if (tx_pcs_reset_req[ig]) begin
						tx_pcs_reset_req[ig] <= ~tx_transfer_ready_sync[ig];
					end
				end

				alt_xcvr_reset_counter_s10 #(
					.CLKS_PER_SEC (CLK_FREQ_IN_HZ				), // Clock frequency in Hz
					.RESET_PER_NS (TX_PCS_RESET_EXTENSION_NS	), // Reset period in ns
					.RESET_COUNT  (0							)  // Reset count override
				) counter_tx_pcs_reset (
					.clk        (clk							),
					.async_req  (tx_pcs_reset_req[ig]			),  // asynchronous reset request
					.sync_req   (1'b0							),  // synchronous reset request
					.reset_or   (1'b0							),  // auxilliary reset override
					.reset      (tx_pcs_reset[ig]				),  // synchronous reset out
					.reset_n    (/*unused*/						),
					.reset_stat (/*unused*/						)
				);	
			end
		end else begin
		    assign tx_digitalreset_stat = {NUM_CHANNELS{1'b0}};
			assign tx_pcs_reset = {NUM_CHANNELS{1'b0}};
		end

		if (RX_ENABLE) begin : g_rx
			for(ig=0; ig<NUM_CHANNELS; ig=ig+1) begin : g_reset				
				assign rx_digitalreset_stat[ig] = rx_digital_reset_sync[ig] ? ~rx_transfer_ready_sync[ig] : rx_pcs_reset[ig];				
								
				alt_xcvr_resync_std #(
					.SYNC_CHAIN_LENGTH(2),
					.WIDTH(1)			
				) rx_transfer_ready_synchronizer (
					.clk		(clk),
					.reset		(~reset_n),
					.d			(rx_transfer_ready[ig]),
					.q			(rx_transfer_ready_sync[ig])
				);
					
				alt_xcvr_resync_std #(
					.SYNC_CHAIN_LENGTH(2),
					.WIDTH(1)				
				) rx_digital_reset_synchronizer (
					.clk		(clk),
					.reset		(~reset_n),
					.d			(rx_digital_reset[ig]),
					.q			(rx_digital_reset_sync[ig])
				);

				always @(posedge clk or negedge reset_n) begin
					if (~reset_n) begin
						rx_pcs_reset_req[ig] <= 1'b0;	
					end else if (rx_digital_reset_sync[ig])	begin
						rx_pcs_reset_req[ig] <= 1'b1;					
					end else if (rx_pcs_reset_req[ig]) begin
						rx_pcs_reset_req[ig] <= ~rx_transfer_ready_sync[ig];
					end 
				end

				alt_xcvr_reset_counter_s10 #(
					.CLKS_PER_SEC (CLK_FREQ_IN_HZ				), // Clock frequency in Hz
					.RESET_PER_NS (RX_PCS_RESET_EXTENSION_NS	),  // Reset period in ns
					.RESET_COUNT  (0							)   // Reset count override
				) counter_rx_pcs_reset (
					.clk        (clk							),
					.async_req  (rx_pcs_reset_req[ig]			),  // asynchronous reset request
					.sync_req   (1'b0							),  // synchronous reset request
					.reset_or   (1'b0							),  // auxilliary reset override
					.reset      (rx_pcs_reset[ig]				),  // synchronous reset out
					.reset_n    (/*unused*/						),
					.reset_stat (/*unused*/						)
				);	
			end		
		end else begin
		    assign rx_digitalreset_stat = {NUM_CHANNELS{1'b0}};
			assign rx_pcs_reset = {NUM_CHANNELS{1'b0}};
		end
	end
endgenerate

//******************* End reset sequencer ***********************************
//***************************************************************************

endmodule
