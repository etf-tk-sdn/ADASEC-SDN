// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
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
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "HYNrcV8z2ucRsYHwk2df82iuyngdG/1dopzJ54cizcojKq3J4C/OdPtKPhFeCsSBTOFSuVOy+xHS9eRKSaEYmyGH0ahxv7qGSULgJ4FEK6P3sGZ3KSxn9k0lVIL6SJ9pn1TH2pW/MtolPovW8ugpkOAUZKoXwyx+zhCOoqgGMhHrxPyfKvjgJYEcYy5cjNrjsmZGl9xON2TkEdFzlTnNAkBnLpAcpzWKYwj3mwPjHnD18tBS1/09ufy62eaOhaheSsQfO8qIDPA9Gbk+vvEqt126NurQmCxwHW6BEZEJMpfPooSZ4tmkeZTsCsVkU00kejmT46lvLEMefDPCP4RhI/mQ1S70shbEoZg5Gjrwpr8Z+aOG6EEofRgVHIVpz7gQ0uqKz9623Tf7YZQHlW6rcfLKP9CJWKhyfmM5SmQnWp2u4IyllbgRItKrzCWtXanhV4ygDUbBZrRB2GqksCWckYK7Q6tmsqeYTnP2nkFDUSi2QrU1ylm5FKnDTBU7fWbiBqaFYsew6KRmkvbp8ZOqP4WNf8jCjHtvJNffhpP31LMhd6LsmHymSjmYSEBHgI9N6ZeLq4D9AGi4pKNKK1RVSDbKgweUUnfQO/emL7XwEYQkjOtTjUSmqPvdrKZS+Kt6kVW4KAHoLV3SSfjDTH8pBLOZSYI/G06WlR1DlyeSIcbCStyJsn4hVbHiyN8ly+WEZ7gPwi4XuouMyaIfaY285OvGO/rj6ucxGqzE2sCdLpiq3LKJpG6D9N3XD2XbFHNu8ckfPi2J6LnzDJ/bb2Xktc1iAnKsI8jowjuZEDIMSPCXo6Jo8oGYuhubhdzhdJro9frXwGuipNypMVUoCd/K1LLDTyseQZBw/NRFOrc4/+OF6ELadFyeGzs/Qiu6CTwxiq1IaebL0h+1shsE6xR5Mx4nNt8+m8h5211CVaHF6bUXucSSWAmdyxH6477+z9tUKD/r79uNmFGwzN3iPddtr1DkEhOMeo5thpPTOqPrQ04tUIPsB1JsjTWsASzi+2bL"
`endif