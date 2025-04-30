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


// Module: alt_xcvr_native_dig_reset_seq
//
// Description:
//  Stratix 10 transceiver digital reset local sequencer
//  
//  Parameters:
//    CLK_FREQ_IN_HZ
//      - Specifies the input clock frequency in HZ
//    DEFAULT_RESET_SEPARATION_NS
//      - Specifies the separation delay guaranteed by Master Transceiver Reset Sequencer 
//    RESET_SEPARATION_NS 
//      - Specifies the required separation delay for digital reset assertion and deassertion (adapter reset and PCS reset)
//    PCS_RESET_EXTENSION_NS 
//      - Specifies the required delay to hold the PCS reset after transfer ready is asserted
//    RESET_MODE
//      - non_bonded : Non-bonded mode independent reset
//		- bonded : Bonded mode simultaneous reset
//		- non_bonded_simultaneous  : Non-bonded mode simultaneous reset
//    NUM_CHANNELS
//      - Specifies the number of channels which resets are serviced by the local sequencer
//    ENABLE_PCS_RESET
//      - 1 : Enable PCS reset 
//        0 : Disable PCS reset 
//    RESET_AIB_FIRST
//      - 1 : Reset AIB before PCS
//        0 : Reset PCS before AIB
//

`timescale 1ps/1ps

module alt_xcvr_native_dig_reset_seq
#(
	parameter [63:0] CLK_FREQ_IN_HZ = 100000000,	
	parameter [63:0] DEFAULT_RESET_SEPARATION_NS = 100,	
	parameter [63:0] RESET_SEPARATION_NS = 100,
	parameter [63:0] PCS_RESET_EXTENSION_NS = 0,	
	parameter RESET_MODE = "non_bonded",					// non_bonded, bonded, non_bonded_simultaneous
	parameter BONDING_MASTER = 0,
	parameter NUM_CHANNELS = 1,		
	parameter ENABLE_PCS_RESET = 1,
	parameter RESET_AIB_FIRST = 0,
	parameter REDUCED_RESET_SIM_TIME = 0	
)(	
	input wire clk,
	input wire reset_n,	
	input wire release_aib_first,						// 0:release PCS first 1:release AIB first
	input wire [NUM_CHANNELS-1:0] reset_in,		
	input wire [NUM_CHANNELS-1:0] transfer_ready_in,	 
	output wire [NUM_CHANNELS-1:0] aib_reset_out,	
	output wire [NUM_CHANNELS-1:0] pcs_reset_out,
	output wire [NUM_CHANNELS-1:0] reset_out,
	output wire [NUM_CHANNELS-1:0] reset_timeout
);

localparam BONDED_MODE_RESET = (RESET_MODE == "non_bonded") ? 0 : 1;
localparam NUM_RESETS = BONDED_MODE_RESET ? 1 : NUM_CHANNELS;

localparam  SAMPLE_RESET           = 3'd0;
localparam  RESET_REQ	           = 3'd1;	
localparam  RESET_ACK	           = 3'd2;	
localparam  TRANSFER_READY_TIMEOUT = 3'd3;
localparam  RESUME_RESET           = 3'd4;

// These parameters calculate the counter width and count for reset separation
localparam ADDED_RESET_SEPARATION_NS = (RESET_SEPARATION_NS > DEFAULT_RESET_SEPARATION_NS) ? (RESET_SEPARATION_NS - DEFAULT_RESET_SEPARATION_NS) : 0;

localparam [63:0] ADDED_RESET_COUNT = (CLK_FREQ_IN_HZ * ADDED_RESET_SEPARATION_NS) / 1000000000;
localparam [63:0] ADDED_RESET_ROUNT_COUNT = (((ADDED_RESET_COUNT * 1000000000) / CLK_FREQ_IN_HZ) < ADDED_RESET_SEPARATION_NS)
							? (ADDED_RESET_COUNT + 1) : ADDED_RESET_COUNT;
localparam ADDED_RESET_COUNT_MAX = (ADDED_RESET_ROUNT_COUNT > 0) ? ADDED_RESET_ROUNT_COUNT - 1 : 0;							
							
localparam [63:0] RESET_COUNT = (CLK_FREQ_IN_HZ * RESET_SEPARATION_NS) / 1000000000;
localparam [63:0] RESET_ROUNT_COUNT = (((RESET_COUNT * 1000000000) / CLK_FREQ_IN_HZ) < RESET_SEPARATION_NS)
							? (RESET_COUNT + 1) : RESET_COUNT;
localparam RESET_COUNT_MAX = (RESET_ROUNT_COUNT > 0) ? RESET_ROUNT_COUNT - 1 : 0;							
							
localparam [63:0] PCS_RESET_EXT_COUNT = (CLK_FREQ_IN_HZ * PCS_RESET_EXTENSION_NS) / 1000000000;
localparam [63:0] PCS_RESET_EXT_ROUND_COUNT = (((PCS_RESET_EXT_COUNT * 1000000000) / CLK_FREQ_IN_HZ) < PCS_RESET_EXTENSION_NS)
							? (PCS_RESET_EXT_COUNT + 1) : PCS_RESET_EXT_COUNT;
localparam PCS_RESET_EXT_COUNT_MAX = (PCS_RESET_EXT_ROUND_COUNT > 0) ? PCS_RESET_EXT_ROUND_COUNT - 1 : 0;

localparam AIB_RESET_COUNT_MAX = RESET_AIB_FIRST ? ADDED_RESET_COUNT_MAX : RESET_COUNT_MAX;
localparam PCS_RESET_COUNT_MAX = RESET_AIB_FIRST ? RESET_COUNT_MAX : ADDED_RESET_COUNT_MAX;

localparam RESET_COUNT_SIZE = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(RESET_COUNT_MAX);
localparam PCS_RESET_EXT_COUNT_SIZE = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(PCS_RESET_EXT_COUNT_MAX);

localparam [RESET_COUNT_SIZE-1:0] ADDED_RESET_COUNT_ADD = {{RESET_COUNT_SIZE-1{1'b0}},1'b1};
localparam [RESET_COUNT_SIZE-1:0] RESET_COUNT_ADD = {{RESET_COUNT_SIZE-1{1'b0}},1'b1};
localparam [PCS_RESET_EXT_COUNT_SIZE-1:0] PCS_RESET_EXT_COUNT_ADD = {{PCS_RESET_EXT_COUNT_SIZE-1{1'b0}},1'b1};

// Bonded mode reset sequencing parameters
localparam  CHANNEL_COUNT_MAX   = NUM_CHANNELS-1;
localparam  CHANNEL_COUNT_SIZE  = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(NUM_CHANNELS-1);
localparam  [CHANNEL_COUNT_SIZE-1:0] CHANNEL_COUNT_ADD = {{CHANNEL_COUNT_SIZE-1{1'b0}},1'b1};

// Sync signals
wire release_aib_first_sync;
wire [NUM_RESETS-1:0] reset_in_sync;
wire [NUM_RESETS-1:0] transfer_ready_in_sync;

// TRE reset signals
reg [NUM_RESETS-1:0] reset_req_comb;
reg [NUM_RESETS-1:0] update_reset;
reg [NUM_RESETS-1:0] reset_req;
reg [NUM_RESETS-1:0] reset_req_stage;
wire [NUM_RESETS-1:0] reset_ack;

// Reset state machine
reg [NUM_RESETS*3-1:0] reset_sm_cs;
reg [NUM_RESETS*3-1:0] reset_sm_ns;	

// Reset inputs
reg [NUM_RESETS-1:0] reset_sample;
reg [NUM_RESETS-1:0] sample_data;
reg [NUM_RESETS-1:0] clear_timeout;

wire [NUM_RESETS-1:0] pcs_reset_req;	
wire [NUM_RESETS-1:0] aib_reset_req;	

wire [NUM_RESETS-1:0] reset_match;
wire [NUM_RESETS-1:0] aib_reset_match;
wire [NUM_RESETS-1:0] pcs_reset_match;	
		
// Reset output registers (must be synchronized at destination logic)
reg [NUM_RESETS-1:0] aib_reset_out_reg;	
reg [NUM_RESETS-1:0] pcs_reset_out_reg;	
reg [NUM_RESETS-1:0] reset_out_reg;	
reg [NUM_RESETS-1:0] int_reset_out_reg;	
reg [NUM_RESETS-1:0] int_pcs_reset_reg;	

reg [NUM_RESETS-1:0] aib_reset_out_stage;	
reg [NUM_RESETS-1:0] pcs_reset_out_stage;	
reg [NUM_RESETS-1:0] reset_out_stage;
reg [NUM_RESETS-1:0] reset_timeout_stage;

// error status
reg [NUM_RESETS-1:0] transfer_ready_stat;
reg [NUM_RESETS-1:0] transfer_ready_timeout;

// Reset counters			
wire [NUM_RESETS-1:0] pcs_reset_timeout; 
wire [NUM_RESETS-1:0] aib_reset_timeout; 
wire [NUM_RESETS-1:0] pcs_reset_ext_timeout;
reg [RESET_COUNT_SIZE-1:0] pcs_reset_counter [NUM_RESETS-1:0];
reg [RESET_COUNT_SIZE-1:0] aib_reset_counter [NUM_RESETS-1:0];	
reg [PCS_RESET_EXT_COUNT_SIZE-1:0] pcs_reset_ext_counter [NUM_RESETS-1:0];	

wire [RESET_COUNT_SIZE-1:0]  aib_reset_release_count_max[NUM_RESETS-1:0];
wire [RESET_COUNT_SIZE-1:0]  pcs_reset_release_count_max[NUM_RESETS-1:0];

// Temporary wires
wire [NUM_RESETS-1:0] w_reset_in;
wire [NUM_RESETS-1:0] w_transfer_ready_in;

assign w_reset_in = BONDED_MODE_RESET ? (|reset_in) : reset_in;
assign w_transfer_ready_in = BONDED_MODE_RESET ? (RESET_MODE == "bonded") ? transfer_ready_in[BONDING_MASTER] : (&transfer_ready_in)
								: transfer_ready_in;


//***************************************************************************
// Reset output
//***************************************************************************
assign aib_reset_out = BONDED_MODE_RESET ? {NUM_CHANNELS{aib_reset_out_stage}} : aib_reset_out_stage;		
assign pcs_reset_out = (ENABLE_PCS_RESET) ? BONDED_MODE_RESET ? {NUM_CHANNELS{pcs_reset_out_stage}} : pcs_reset_out_stage 
						: {NUM_CHANNELS{1'b0}};
assign reset_out = BONDED_MODE_RESET ? {NUM_CHANNELS{reset_out_stage}} : reset_out_stage;
assign reset_timeout = BONDED_MODE_RESET ? {NUM_CHANNELS{reset_timeout_stage}} : reset_timeout_stage;
		
// Add register stage to AIB reset and reset_out outputs		
always @(posedge clk) begin 	
	aib_reset_out_stage <= aib_reset_out_reg;			
	pcs_reset_out_stage <= pcs_reset_out_reg;
	reset_out_stage <= reset_out_reg;
	reset_timeout_stage <= transfer_ready_timeout;
end 

//***************************************************************************
// Synchronizers
//***************************************************************************
alt_xcvr_resync_std #(
	.SYNC_CHAIN_LENGTH(3),
	.WIDTH(NUM_RESETS),
	.INIT_VALUE(0)
) transfer_ready_synchronizers (
	.clk	(clk),
	.reset	(~reset_n),
	.d		(w_transfer_ready_in),
	.q		(transfer_ready_in_sync)
);

alt_xcvr_resync_std #(
	.SYNC_CHAIN_LENGTH(3),
	.WIDTH(1),
	.INIT_VALUE(0)
) release_aib_first_synchronizers (
	.clk	(clk),
	.reset	(~reset_n),
	.d		(release_aib_first),
	.q		(release_aib_first_sync)
);														

alt_xcvr_resync_std #(
	.SYNC_CHAIN_LENGTH(3),
	.WIDTH(NUM_RESETS),
	.INIT_VALUE(0)
) reset_synchronizers (
	.clk	(clk),
	.reset	(~reset_n),
	.d		(w_reset_in),
	.q		(reset_in_sync)
);

//***************************************************************************
// User reset sequencer Logic 
//***************************************************************************
genvar ig;
generate
	for(ig=0;ig<NUM_RESETS;ig=ig+1) begin : g_dig_trs_inst	

		//****************
		// Reset release count max value
		//****************
		assign aib_reset_release_count_max[ig] = release_aib_first_sync ? ADDED_RESET_COUNT_MAX : RESET_COUNT_MAX;
		assign pcs_reset_release_count_max[ig] = release_aib_first_sync ? RESET_COUNT_MAX : ADDED_RESET_COUNT_MAX;												
		
	`ifdef ALTERA_RESERVED_QIS
		//****************				
		// TRE instance
		//****************
		altera_s10_xcvr_reset_endpoint altera_s10_xcvr_reset_endpoint_inst (
			.tre_reset_req(reset_req_stage[ig]),
			.tre_reset_ack(reset_ack[ig])
		);
	`else
		if (REDUCED_RESET_SIM_TIME) begin
			assign reset_ack[ig] = reset_req_stage[ig];
		end else begin
			// TRE instance
			altera_s10_xcvr_reset_endpoint altera_s10_xcvr_reset_endpoint_inst (
				.tre_reset_req(reset_req_stage[ig]),
				.tre_reset_ack(reset_ack[ig])
			);
		end
	`endif  // (NOT ALTERA_RESERVED_QIS)	
		
		assign reset_match[ig] = (int_reset_out_reg[ig] == reset_sample[ig]);		

		//********************************************************************
		// Reset State Machine 
		//********************************************************************
		always @(posedge clk or negedge reset_n) begin		
		   if (~reset_n) begin
		      reset_sm_cs[ig*3 +: 3] <= SAMPLE_RESET;				
		   end else begin
		      reset_sm_cs[ig*3 +: 3] <= reset_sm_ns[ig*3 +: 3];				
		   end
		end		

		always @(*) begin
		   reset_sm_ns[ig*3 +: 3] = reset_sm_cs[ig*3 +: 3];
		   sample_data[ig] = 1'b0;
		   reset_req_comb[ig] = 1'b0;	
		   update_reset[ig] = 1'b0;
		   clear_timeout[ig] = 1'b0;
		       
		   case(reset_sm_cs[ig*3 +: 3])
		      SAMPLE_RESET: 
		      begin
		         if(!reset_match[ig] && !reset_ack[ig]) begin
                    reset_sm_ns[ig*3 +: 3]  = RESET_REQ;
			     end
			     sample_data[ig] = !reset_ack[ig];			 					
              end
        
		      RESET_REQ:
              begin
		         if(reset_ack[ig]) begin
                    reset_sm_ns[ig*3 +: 3]  = RESET_ACK;
			     end
			     sample_data[ig] = 1'b1;
			     reset_req_comb[ig] = 1'b1;					
		      end
      
		      RESET_ACK:
		      begin
			     if (transfer_ready_timeout[ig]) begin
				    if (!reset_match[ig]) begin
					   reset_sm_ns[ig*3 +: 3]  = RESET_ACK;
					end else begin
				       reset_sm_ns[ig*3 +: 3]  = TRANSFER_READY_TIMEOUT;
					end					
		         end else if (reset_match[ig]) begin
                    reset_sm_ns[ig*3 +: 3]  = SAMPLE_RESET;
				 end
			     reset_req_comb[ig] = 1'b1;
				 update_reset[ig] = 1'b1;  
              end

			  TRANSFER_READY_TIMEOUT:
		      begin
			    if (transfer_ready_timeout[ig]) begin
				   reset_sm_ns[ig*3 +: 3]  = TRANSFER_READY_TIMEOUT;	
				end else begin
				   reset_sm_ns[ig*3 +: 3]  = RESUME_RESET;
				end				
				reset_req_comb[ig] = 1'b1;
				clear_timeout[ig] = 1'b1;				       			 			 
              end

			  RESUME_RESET:
		      begin
			     if (reset_match[ig]) begin
                    reset_sm_ns[ig*3 +: 3]  = SAMPLE_RESET;
				 end
			     reset_req_comb[ig] = 1'b1;
				 update_reset[ig] = 1'b1;
				 clear_timeout[ig] = 1'b1;
              end

		      default: 
		      begin
		         reset_sm_ns[ig*3 +: 3] = SAMPLE_RESET;
			     sample_data[ig] = 1'b0;
			     reset_req_comb[ig] = 1'b0;   
				 update_reset[ig] = 1'b0; 
				 clear_timeout[ig] = 1'b0;             
		      end
		   endcase
		end

		//****************
		// Reset sampling
		//****************
		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				reset_sample[ig] <= 1'b0;
			end else if (clear_timeout[ig]) begin
			    reset_sample[ig] <= 1'b1;
			end else if (sample_data[ig]) begin
				reset_sample[ig] <= reset_in_sync[ig];
			end			
		end		

		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin				
				reset_req[ig] <= 1'b0;		
				reset_req_stage[ig] <= 1'b0;
			end else begin
				reset_req[ig] <= reset_req_comb[ig];
				reset_req_stage[ig] <= reset_req[ig];
			end
		end
		
		//****************
		// AIB reset request and PCS reset request update
		//
		// Reset assertion (reset_sample 0->1)
		//	   * (RESET_AIB_FIRST=1) Reset AIB first and followed by PCS. AIB reset request listens to reset sample and PCS reset request listens to AIB reset output
		//	   * (RESET_AIB_FIRST=0) Reset PCS first and followed by AIB. PCS reset request listens to reset sample and AIB reset request listens to PCS reset output
		//
		// Reset deassertion (reset_sample 1->0)
		//	   * (release_aib_first_sync=0) Release PCS reset first and followed by AIB reset. PCS reset request listens to reset sample and AIB reset request listens to PCS reset output 
		//	   * (release_aib_first_sync=1) Release AIB reset first and followed by PCS reset. AIB reset request listens to reset sample and PCS reset request listens to AIB reset output  
		//
		//****************		
		assign aib_reset_match[ig] = (aib_reset_out_reg[ig] == aib_reset_req[ig]);
		assign aib_reset_timeout[ig] = aib_reset_req[ig] ? (aib_reset_counter[ig] == AIB_RESET_COUNT_MAX) : (aib_reset_counter[ig] == aib_reset_release_count_max[ig]);		
		
		assign pcs_reset_match[ig] = (int_pcs_reset_reg[ig] == pcs_reset_req[ig]);
		assign pcs_reset_timeout[ig] = pcs_reset_req[ig] ? (pcs_reset_counter[ig] == PCS_RESET_COUNT_MAX) : (pcs_reset_counter[ig] == pcs_reset_release_count_max[ig]);		
		assign pcs_reset_ext_timeout[ig] = (pcs_reset_ext_counter[ig] == PCS_RESET_EXT_COUNT_MAX);		
		
		if (ENABLE_PCS_RESET) begin			
			assign aib_reset_req[ig] = reset_sample[ig] ? 
											RESET_AIB_FIRST ? reset_sample[ig] : pcs_reset_out_reg[ig]
											: release_aib_first_sync ? reset_sample[ig] : pcs_reset_out_reg[ig];
										
			assign pcs_reset_req[ig] = reset_sample[ig] ? 
											RESET_AIB_FIRST ? aib_reset_out_reg[ig] : reset_sample[ig]
											: release_aib_first_sync ? aib_reset_out_reg[ig] : reset_sample[ig];
		end else begin
			assign aib_reset_req[ig] = reset_sample[ig];
		end

		//****************
		// AIB reset sequencing
		//****************
		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				aib_reset_out_reg[ig] <= 1'b0;					
				aib_reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};			
			end else if (update_reset[ig]) begin
				if (aib_reset_timeout[ig] || aib_reset_match[ig]) begin									
					aib_reset_out_reg[ig] <= aib_reset_req[ig];				
					aib_reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};						
				end else begin
					aib_reset_counter[ig] <= aib_reset_counter[ig] + RESET_COUNT_ADD;
				end
			end
		end	

		//****************
		// PCS reset sequencing
		//****************
		if (ENABLE_PCS_RESET) begin			
			always @(posedge clk or negedge reset_n) begin
				if (~reset_n) begin				
					int_pcs_reset_reg[ig] <= 1'b0;					
					pcs_reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};			
				end else if (update_reset[ig]) begin
					if (pcs_reset_timeout[ig] || pcs_reset_match[ig]) begin									
						int_pcs_reset_reg[ig] <= pcs_reset_req[ig];				
						pcs_reset_counter[ig] <= {RESET_COUNT_SIZE{1'b0}};						
					end else begin
						pcs_reset_counter[ig] <= pcs_reset_counter[ig] + RESET_COUNT_ADD;
					end
				end
			end	

			// Additional PCS reset extension after transfer_ready is asserted		
			always @(posedge clk or negedge reset_n) begin
				if (~reset_n) begin								
					pcs_reset_ext_counter[ig] <= {PCS_RESET_EXT_COUNT_SIZE{1'b0}};			
				end else begin
					if (~transfer_ready_in_sync[ig]) begin
						pcs_reset_ext_counter[ig] <= {PCS_RESET_EXT_COUNT_SIZE{1'b0}};	
					end else if (pcs_reset_ext_timeout[ig]) begin									
						pcs_reset_ext_counter[ig] <= pcs_reset_ext_counter[ig];					
					end else if (transfer_ready_in_sync[ig]) begin
						pcs_reset_ext_counter[ig] <= pcs_reset_ext_counter[ig] + PCS_RESET_EXT_COUNT_ADD;
					end
				end
			end
		
			// Only reset the PCS when the reset signal is asserted. De-assertion of transfer_ready_in without a user reset event will not reset the PCS.		
			// Hold PCS in reset for PCS_RESET_EXTENSION_NS after transfer_ready_in is asserted before releasing the reset.
			always @(posedge clk or negedge reset_n) begin
				if (~reset_n) begin
					pcs_reset_out_reg[ig] <= 1'b0;					
				end else if (int_pcs_reset_reg[ig]) begin
					pcs_reset_out_reg[ig] <= int_pcs_reset_reg[ig];								
				end else if (pcs_reset_out_reg[ig]) begin					
					if (transfer_ready_timeout[ig] || ~release_aib_first_sync || (pcs_reset_ext_timeout[ig] && transfer_ready_stat[ig])) begin					
						pcs_reset_out_reg[ig] <= int_pcs_reset_reg[ig];
					end
				end
			end	
		end
		
		//****************
		// Assert transfer_ready_timeout if reset_ack is deasserted before transfer_ready is asserted after reset is released
		//****************		
		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin				
				transfer_ready_timeout[ig] <= 1'b0;				
				transfer_ready_stat[ig] <= 1'b1;
			end else if (reset_sample[ig]) begin
				transfer_ready_timeout[ig] <= 1'b0;				
				transfer_ready_stat[ig] <= 1'b1;
			end else if (~transfer_ready_timeout[ig]) begin
				if (reset_ack[ig]) begin
					transfer_ready_stat[ig] <= transfer_ready_in_sync[ig];
				end else begin
					transfer_ready_timeout[ig] <= ~transfer_ready_stat[ig];
				end
			end
		end	

		//****************
		// Reset output status reflects the AIB/PCS reset output that is asserted/de-asserted last
		//****************
		always @(posedge clk or negedge reset_n) begin
			if (~reset_n) begin
				int_reset_out_reg[ig] <= 1'b0;	
				reset_out_reg[ig] <= 1'b0;							
			end else begin					
				if (reset_sample[ig]) begin
					int_reset_out_reg[ig] <= ENABLE_PCS_RESET ? RESET_AIB_FIRST ? pcs_reset_out_reg[ig] : aib_reset_out_reg[ig]
												: aib_reset_out_reg[ig];
					if (!clear_timeout[ig]) begin
					   reset_out_reg[ig] <= int_reset_out_reg[ig];
					end
				end else begin
					if (ENABLE_PCS_RESET) begin
						if (release_aib_first_sync) begin
							int_reset_out_reg[ig] <= pcs_reset_out_reg[ig];
						end else if (transfer_ready_in_sync[ig] || transfer_ready_timeout[ig]) begin
							int_reset_out_reg[ig] <= aib_reset_out_reg[ig];
						end
					end else begin
						if (transfer_ready_in_sync[ig] || transfer_ready_timeout[ig]) begin
							int_reset_out_reg[ig] <= aib_reset_out_reg[ig];
						end
					end
					
					if (transfer_ready_stat[ig]) begin				
						reset_out_reg[ig] <= int_reset_out_reg[ig];
					end	
				end			
			end
		end	
	end // End for loop
endgenerate

endmodule



