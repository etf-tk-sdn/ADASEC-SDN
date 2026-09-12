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


// Module: alt_xcvr_native_anlg_reset_seq
//
// Description:
//  Stratix 10 transceiver analog reset local sequencer
//  
//  Parameters:
//    CLK_FREQ_IN_HZ
//      - Specifies the input clock frequency in HZ
//    DEFAULT_RESET_SEPARATION_NS
//      - Specifies the default reset separation delay provided by the Master Transceiver Reset Sequencer 
//    RESET_SEPARATION_NS 
//      - Specifies the required reset separation delay for analog reset 
//    NUM_RESETS
//      - Specifies the number of analog reset inputs to the local sequencer
//

`timescale 1ps/1ps

module alt_xcvr_native_anlg_reset_seq #(	
    parameter CLK_FREQ_IN_HZ = 100000000,
	parameter DEFAULT_RESET_SEPARATION_NS = 100,	// reset separation guaranteed by master sequencer
	parameter RESET_SEPARATION_NS = 100,			// reset separation requested
	parameter NUM_RESETS = 1,
	parameter REDUCED_RESET_SIM_TIME = 0
)(
	input clk,		
	input reset_n,
	input [NUM_RESETS-1:0] reset_in,
	output [NUM_RESETS-1:0] reset_out,
	output [NUM_RESETS-1:0] reset_stat_out
);

// These parameters calculate the counter width and count for reset separation
localparam ADDED_RESET_SEPARATION_NS = (RESET_SEPARATION_NS > DEFAULT_RESET_SEPARATION_NS) ? (RESET_SEPARATION_NS - DEFAULT_RESET_SEPARATION_NS) : 0;
localparam [63:0] INITIAL_RESET_COUNT = (CLK_FREQ_IN_HZ * ADDED_RESET_SEPARATION_NS) / 1000000000;

// Round counter limit up if needed
localparam [63:0] RESET_ROUNT_COUNT = (((INITIAL_RESET_COUNT * 1000000000) / CLK_FREQ_IN_HZ) < ADDED_RESET_SEPARATION_NS)
						? (INITIAL_RESET_COUNT + 1) : INITIAL_RESET_COUNT;

localparam RESET_COUNT_MAX = (RESET_ROUNT_COUNT > 0) ? RESET_ROUNT_COUNT - 1 : 0;
localparam RESET_COUNT_SIZE = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(RESET_COUNT_MAX);
localparam [RESET_COUNT_SIZE-1:0] RESET_COUNT_ADD = {{RESET_COUNT_SIZE-1{1'b0}},1'b1};

// TRE reset signals
reg [NUM_RESETS-1:0] reset_req;	
reg [NUM_RESETS-1:0] reset_req_stage;	
wire [NUM_RESETS-1:0] reset_ack;

// Reset inputs
wire [NUM_RESETS-1:0] reset_in_sync;
reg [NUM_RESETS-1:0] reset_sample;
wire [NUM_RESETS-1:0] sample_data;
wire [NUM_RESETS-1:0] reset_match;
		
// Reset output registers (must be synchronized at destination logic)
reg [NUM_RESETS-1:0] reset_stat_reg;	
reg [NUM_RESETS-1:0] reset_out_reg;	
reg [NUM_RESETS-1:0] reset_stat_stage;
reg [NUM_RESETS-1:0] reset_out_stage;	

// Reset counter
wire [NUM_RESETS-1:0] reset_timeout; // time to restart reset separation counter	
reg [RESET_COUNT_SIZE-1:0] reset_counter [NUM_RESETS-1:0];

//***************************************************************************//************************* Reset logic *************************************

assign reset_out = reset_out_stage;
assign reset_stat_out = reset_stat_stage;

// Add register stage after reset output register. 
// Drive destination nodes with output from final stage register and drive reset feedback logic with output from reset output register
// This is to give fitter more freedom in placing the registers without having to meet the constraints for both feedback logic and destination nodes
always @(posedge clk) begin 
	reset_out_stage <= reset_out_reg;
	reset_stat_stage <= reset_stat_reg;
end 

genvar ig;
generate
	for(ig=0;ig<NUM_RESETS;ig=ig+1) begin : g_anlg_trs_inst	

		assign reset_timeout[ig] = (reset_counter[ig] == RESET_COUNT_MAX);
		assign reset_match[ig] = (reset_stat_reg[ig] == reset_sample[ig]);

		// Synchronizer
		alt_xcvr_resync_std #(
			.SYNC_CHAIN_LENGTH(3),
			.WIDTH(1),
			.INIT_VALUE(0)		
		) reset_synchronizers (
			.clk	(clk),
			.reset	(~reset_n),
			.d		(reset_in[ig]),
			.q		(reset_in_sync[ig])
		);

		
	`ifdef ALTERA_RESERVED_QIS
		// TRE instance
		altera_s10_xcvr_reset_endpoint altera_s10_xcvr_reset_endpoint_inst (
			.tre_reset_req(reset_req_stage[ig]),
			.tre_reset_ack(reset_ack[ig]),
			.clk_in()
		);
	`else
		if (REDUCED_RESET_SIM_TIME) begin
			assign reset_ack[ig] = reset_req_stage[ig];
		end else begin
			// TRE instance
			altera_s10_xcvr_reset_endpoint altera_s10_xcvr_reset_endpoint_inst (
				.tre_reset_req(reset_req_stage[ig]),
				.tre_reset_ack(reset_ack[ig]),
				.clk_in()
			);
		end
	`endif  // (NOT ALTERA_RESERVED_QIS)	

		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
			    reset_req[ig] <= 1'b0;
				reset_req_stage[ig] <= 1'b0;
			end else begin
			    reset_req[ig] <= ~reset_match[ig];
				reset_req_stage[ig] <= reset_req[ig];
			end
		end 		

		// Sample the reset signal when reset_ack is low
		assign sample_data[ig] = ~reset_ack[ig];
		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				reset_sample[ig] <= 1'b0;
			end else if (sample_data[ig]) begin
				reset_sample[ig] <= reset_in_sync[ig];
			end			
		end

		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				reset_out_reg[ig] <= 1'b0;
				reset_stat_reg[ig] <= 1'b0;
				reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};							
			end else begin
				if ( reset_match[ig] ) begin
					reset_out_reg[ig] <= reset_sample[ig];	
					reset_stat_reg[ig] <= reset_sample[ig];	
					reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};	
				end else if ( reset_ack[ig] && reset_timeout[ig] ) begin					
					reset_out_reg[ig] <= reset_sample[ig];	
					reset_stat_reg[ig] <= reset_sample[ig];
					reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};	
				end else if (reset_ack[ig]) begin
					reset_out_reg[ig] <= reset_sample[ig];
					reset_counter[ig] <= reset_counter[ig] + RESET_COUNT_ADD;
				end
			end
		end	
	end
endgenerate

//*********************** End reset logic ***********************************
//***************************************************************************

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "HYNrcV8z2ucRsYHwk2df82iuyngdG/1dopzJ54cizcojKq3J4C/OdPtKPhFeCsSBTOFSuVOy+xHS9eRKSaEYmyGH0ahxv7qGSULgJ4FEK6P3sGZ3KSxn9k0lVIL6SJ9pn1TH2pW/MtolPovW8ugpkOAUZKoXwyx+zhCOoqgGMhHrxPyfKvjgJYEcYy5cjNrjsmZGl9xON2TkEdFzlTnNAkBnLpAcpzWKYwj3mwPjHnAajIr7tvf07zcsqtkP1dfwzWQPM/LbeT1n+IetHdNdU0BlzuH+3irNHDvaXg1/jTSkMl4cB0QpeK6XX/r1UPrctAulbpItXbrW+MWMOVYRJyT5YOEUzId/wKzYwdQK3IDQ3UfUYcpwt3Z5fBjEh7uL2ZPfZVBIMILB8z3rkxl2YesBa97+JYgTbWM/5CQTXzsocWsfbVIfft+m9jYpNsyRiLA9UjNFEr+BdMVa2erFMu25pEKVuJMa5i96i2adNR9OKnrHoF/ud1GnxX0byROWJ/HPrSWyxF3ou0by41XD/StEN4ToxvAItPqI3uYx6ZVKz8ET3akF0qVj6OFIky6v/foqAwLDHtUee3vKDzfitb2BQ9gaP2UrjQwBuuyP4CG0EIvNswHM0LY4FygR4qw0ID4W/AJ/CcJrjjeqeiJv/rnB9TPa97ZV3+hg18WTTiXlcdSLZcpfeH7+5XXp0yiaxbX6OZ4WtwrK0HhqFxx1IN1AMmW06f4BgSte2ol/xE5dcf3sMq6Cx8y6eB9jicWl1THVeRX1lE3g0FY7uE6LOMq+KCXuLCJR3LpG5p7zh3pGBy5A1KEFJ3uFvihvTQx53OIAQdkag3D66rSgcbJWiMz4dQHrvnTtv7d4I2GLqCT6q5H4/mShFfPItifp/pLQz2odU82treNlpeOYmoeaSZIZqcA2pj2VwHtKr3Ic/SGdO+34hbUu/+Ki9CvI6fREEJWDcrzX7PtBpLebAuuciHNyhvnW3zjHulMpFuss6qMeRg93YFKgLG0/8hLOY+dt"
`endif