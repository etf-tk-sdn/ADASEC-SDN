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



// File Name: alt_xcvr_early_spd_chng_s10_htile.sv
//
// Description:
//
//    An early speed change IP is for Crete2E PIPE mode, intented to provide early speed change notice to PMA ahead of
//  the actually speed change rate switch signal. This can give PMA enough time to do internal staggering to reduce noise.
//	

`timescale 1ns / 1ns
//`timescale 1ps / 1ps


module  alt_xcvr_early_spd_chng_s10_htile
#(
    // General Options
    parameter NUM_CHANNELS           = 1,		// Number of CHANNELS
    parameter WIDTH                  = 32,		// Datapath width
    parameter BONDING_MASTER         = 0,		// Master channel number


    parameter T1                     = 60,   // minimum time requirement from tx_elec_idle to early_spd_chng
    parameter T2                     = 150,  // minimum pulse width of early_spd_chng
    parameter T3                     = 1000  // minimum time requirement from early_spd_chng to pcie_sw

) (
  // User inputs and outputs
  input   wire                       clk  ,  // System clock
  input   wire                       reset_n, // reset request for from User

  input   wire  [NUM_CHANNELS-1:0]   tx_elec_idle,        
  input   wire  [2*NUM_CHANNELS-1:0] pipe_rate,         

  //output
  output  reg                        early_spd_chng,
  output  reg   [1:0]                pcie_sw

);

// Synchronizer
alt_xcvr_resync_std #(
	.SYNC_CHAIN_LENGTH(3),
	.WIDTH(1),
	.INIT_VALUE(0)		
) reset_n_synchronizers (
	.clk	(clk),
	.reset	(~reset_n),
	.d		(1'b1),
	.q		(reset_n_sync)
);



wire [1:0] width;
assign     width = (WIDTH == 32) ? 2'b10 : (WIDTH == 16) ? 2'b01 : (WIDTH == 8) ? 2'b00 : 2'b11;

//=========================================================================================================
//    PCLK Freq      Gen1(pcie_sw=2'b00)           Gen2(pcie_sw=2'b01)          Gen3(pcie_sw=2'b10)
//     62.5MHz       width: 32(2'b10)                
//     125 MHz       width: 16(2'b01)              width: 32(2'b10)
//     250 MHz       width: 8 (2'b00)              width: 16(2'b01)              wdith: 32(2'b10)         
//=========================================================================================================



wire        [2:0]  count_mult     = (width[1:0] == pcie_sw[1:0]) ? 4 : (width[1:0] == pcie_sw[1:0] + 1'b1) ? 2 : 1;
localparam         CLK_FREQ_MHZ   = 62;
localparam         T1_COUNT_X1    = (CLK_FREQ_MHZ * T1) / 1000 + 1;	//always round up
localparam         T2_COUNT_X1    = (CLK_FREQ_MHZ * T2) / 1000 + 1;	//always round up
localparam         T3_COUNT_X1    = (CLK_FREQ_MHZ * T3) / 1000 + 1;	//always round up
localparam         T1_COUNT_X2    = T1_COUNT_X1 * 2;
localparam         T2_COUNT_X2    = T2_COUNT_X1 * 2;
localparam         T3_COUNT_X2    = T3_COUNT_X1 * 2;
localparam         T1_COUNT_X4    = T1_COUNT_X1 * 4;
localparam         T2_COUNT_X4    = T2_COUNT_X1 * 4;
localparam         T3_COUNT_X4    = T3_COUNT_X1 * 4;
wire        [15:0]  t1_count      = (count_mult == 4) ? T1_COUNT_X4 : (count_mult == 2) ? T1_COUNT_X2 : T1_COUNT_X1;
wire        [15:0]  t2_count      = (count_mult == 4) ? T2_COUNT_X4 : (count_mult == 2) ? T2_COUNT_X2 : T2_COUNT_X1;
wire        [15:0]  t3_count      = (count_mult == 4) ? T3_COUNT_X4 : (count_mult == 2) ? T3_COUNT_X2 : T3_COUNT_X1;
 
wire       l_tx_elec_idle;
wire [1:0] l_pipe_rate;
wire       spd_chng_head;
wire       spd_chng_tail;
wire       rate_sw_point;
wire       rate_chng_start;
wire       valid_period;

reg [15:0]  rate_dly_cnt;
reg [1:0]  rate_d;
reg        pulse_period;
reg        rate_chng_hold;


assign     l_tx_elec_idle = tx_elec_idle[BONDING_MASTER];
assign     l_pipe_rate    = pipe_rate[BONDING_MASTER*2 + 1:BONDING_MASTER*2];
assign     spd_chng_head  =  rate_dly_cnt == t1_count;
assign     spd_chng_tail  =  rate_dly_cnt == (t1_count + t2_count); 
assign     rate_sw_point  =  rate_dly_cnt == (t1_count + t3_count); 

always @ (posedge clk or negedge reset_n_sync) begin
   if(!reset_n_sync) begin
      rate_dly_cnt      <= 16'd0;
      rate_d            <= 2'd0;   
   end  
   else begin
      rate_d            <= l_pipe_rate;
      if(pulse_period)
         rate_dly_cnt      <= rate_dly_cnt + 1'd1;
      else
         rate_dly_cnt      <= 16'd0;
   end
 end

//detect a change in the rate going to the PCS
assign rate_chng_start =  (rate_d[1:0] != l_pipe_rate[1:0]);

always @ (posedge clk or negedge reset_n_sync) begin
   if(!reset_n_sync) begin
     rate_chng_hold<=  1'b0;
   end 
   else begin 
     if (rate_chng_start) begin 
       rate_chng_hold<=  1'b1;
     end 
     else if (rate_sw_point) begin 
       rate_chng_hold<=  1'b0;
     end  
   end 
end 

assign valid_period = l_tx_elec_idle & rate_chng_hold;


always @ (posedge clk or negedge reset_n_sync) begin
   if(!reset_n_sync) begin
     pulse_period  <=  1'b0;
   end 
   else begin 
     if (pulse_period & rate_sw_point) begin 
       pulse_period  <=  1'b0;
     end 
     else if (valid_period) begin 
       pulse_period  <=  1'b1;
     end  
   end 
end 
always @ (posedge clk or negedge reset_n_sync) begin
   if(!reset_n_sync) begin
     early_spd_chng      <=  1'b0;
   end
   else begin
     if (!l_tx_elec_idle) begin
         early_spd_chng <=1'b0;
     end
     else if (pulse_period & spd_chng_head) begin
       early_spd_chng  <=  1'b1;
     end
     else if (pulse_period & spd_chng_tail) begin 
       early_spd_chng  <=  1'b0;
     end
   end
end 
always @ (posedge clk or negedge reset_n_sync) begin
   if(!reset_n_sync) begin
     pcie_sw      <=  2'b00;
   end
   else begin
     if (rate_chng_start) begin 
       pcie_sw      <=  rate_d;
     end
     else if (rate_chng_hold) begin 
       pcie_sw      <=  pcie_sw;
     end
     else begin
       pcie_sw      <=  l_pipe_rate;
     end
   end
end 
endmodule

