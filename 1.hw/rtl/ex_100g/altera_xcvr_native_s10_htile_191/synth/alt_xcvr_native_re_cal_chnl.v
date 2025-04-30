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


`timescale 1 ps/1 ps

module alt_xcvr_native_re_cal_chnl #( //This module is per channel based
parameter                                 PRESET_RECAL_WAIT_CYCLE             = 20 // need 1000000 to be 10s
) 
(

//CUSTOMER AVMM SIDE
input user_clk,
input user_avmm_reset,
output cntr_clk,

input user_read,
input user_write,
input [10:0] user_address,
input [7:0] user_writedata,
output [7:0] user_readdata,
output user_waitrequest,
//output reg recal_waitrequest,

//CORE-IP AVMM SIDE
output avmm_read,
output avmm_write,
output [10:0] avmm_address,
output [7:0] avmm_writedata,
input [7:0] avmm_readdata,
input avmm_waitrequest,

output avmm_clk,
output avmm_reset,

// Recal SM
input r_bg_cal, // "1" to enable recal
input pld_cal_done,
input pld_avmm1_busy,

output out_bg_cal_pld_avmm1_busy
);

`ifdef ALTERA_RESERVED_QIS
  localparam  RECAL_WAIT_CYCLE = 120000000;
`else
  localparam  RECAL_WAIT_CYCLE = 10;
//  localparam  RECAL_WAIT_CYCLE = 10;
`endif 


reg recal_waitrequest;
wire trs_clk;
wire user_avmm_clk;
assign user_avmm_clk = user_clk;
//***************************************************************************
// Getting the clock from Master TRS
//***************************************************************************
altera_s10_xcvr_clkout_endpoint clock_endpoint (        
        .clk_out(trs_clk)
);
assign cntr_clk = trs_clk;

wire rst_n, rst_n_trs, rst_n_div64;
  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(3),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b0)
  ) alt_xcvr_resync_reset (
    .clk    (user_avmm_clk      ),
    .reset  (user_avmm_reset      ),
    .d      (1'd1       ),
    .q      (rst_n )
  );

  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(3),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b0)
  ) alt_xcvr_resync_reset_trs (
    .clk    (trs_clk      ),
    .reset  (user_avmm_reset      ),
    .d      (1'd1       ),
    .q      (rst_n_trs )
  );


reg clk_div8;
reg [5:0] clk_div_cntr;
always @(posedge trs_clk or negedge rst_n_trs) begin
    if(!rst_n_trs) begin
        clk_div_cntr <= 6'h00;
        clk_div8 <= 1'b0;
    end else if (clk_div_cntr < 4) begin
        clk_div_cntr <= clk_div_cntr + 1'b1;
        clk_div8 <= clk_div8;
    end else begin
        clk_div_cntr <= 6'h00;
        clk_div8 <= ~ clk_div8;
    end
end

  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(3),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b0)
  ) alt_xcvr_resync_reset_div64 (
    .clk    (clk_div8      ),
    .reset  (user_avmm_reset      ),
    .d      (1'd1       ),
    .q      (rst_n_div64 )
  );

//**************************************************************************************
//************************ Synchronize pld_avmm1_busy Input ****************************
//************************ Calcode won't toggle pld_cal_done, use avmm1_done instead ***
wire recal_wait;
  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(3),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b1)
  ) alt_xcvr_resync_avmm1_busy (
    .clk    (clk_div8      ),
    .reset  (!rst_n_div64      ),
    .d      (pld_avmm1_busy       ),
    .q      (recal_wait )
  );

wire r_bg_cal_sync;
  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(3),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b1)
  ) alt_xcvr_resync_bg_en (
    .clk    (clk_div8      ),
    .reset  (!rst_n_div64      ),
    .d      (r_bg_cal       ),
    .q      (r_bg_cal_sync )
  );

reg cntr_done;
reg [28:0] cntr;
reg [2:0] cntr_state;

localparam CNTR_UP = 3'b000;
localparam USER_AVMM = 3'b001;
localparam WAIT_CAL_UP = 3'b010;
localparam WAIT_CAL_DONE = 3'b011;
always @(posedge clk_div8 or negedge rst_n_div64) begin
   if(rst_n_div64 == 0) begin
        cntr_state <= WAIT_CAL_DONE;
        cntr <= 0;
        cntr_done <= 1'b0;
   end else begin
	case (cntr_state)
   CNTR_UP: begin
	if ((cntr >= RECAL_WAIT_CYCLE) & (r_bg_cal_sync == 1)) begin 
	    cntr_state <= WAIT_CAL_UP;
	    recal_waitrequest <= 1;
	    cntr_done <= 1;
	    cntr <= 0;
	end else if (r_bg_cal_sync == 0) begin
	    cntr_state <= USER_AVMM;
	    cntr <= cntr + 1'b1;
	    recal_waitrequest <= 0;
	end else begin
	    cntr_state <= CNTR_UP;
	    cntr <= (recal_wait == 1'b1)?cntr:cntr + 1'b1; // counter up when cal_busy is low
	    recal_waitrequest <= 1;
	end
   end
   USER_AVMM:begin
	recal_waitrequest <= 0;
	cntr_state <= (r_bg_cal_sync == 1)?CNTR_UP:USER_AVMM;
	cntr <= (cntr >= RECAL_WAIT_CYCLE)? cntr:cntr + 1'b1;
   end
   WAIT_CAL_UP: begin
	recal_waitrequest <= 1;
	cntr_state <= WAIT_CAL_DONE;
   end

   WAIT_CAL_DONE: begin
	recal_waitrequest <= 1;
	cntr_state <= (recal_wait == 1'b1)?WAIT_CAL_DONE:CNTR_UP;
	cntr <= 0;
	cntr_done <= 0;
   end
	   default: cntr_state <= CNTR_UP;
   endcase
end 
end
// ******************************************************************************
// *********** recal SM *************************
// **********************************************
localparam WAIT_CNTR = 3'b000;
localparam READ_CALCODE = 3'b001;
localparam IDLE1 = 3'b010;
localparam SEND_REQ = 3'b011;
localparam IDLE2 = 3'b100;
localparam READ_ARB = 3'b101;
localparam IDLE3 = 3'b110;
localparam SEND_ARB = 3'b111;

wire cntr_done_sync;
reg [2:0] recal_state;

alt_xcvr_resync_std #(.SYNC_CHAIN_LENGTH(3), .WIDTH(1),      .INIT_VALUE(0)) 
start_synchronizer 
     (  .clk    (user_avmm_clk),     
        .reset  (!rst_n|recal_state != 3'b000),   
        .d      (cntr_done),   
        .q      (cntr_done_sync)
        );



reg recal_read;
reg recal_write;
reg [10:0] recal_address;
reg [7:0] recal_writedata;
reg [7:0] recal_readdata;


always @(posedge user_avmm_clk or negedge rst_n) begin
   if(!rst_n) begin
	recal_state <= 3'b000;
	recal_write <= 0;
	recal_read <= 0;
	recal_address <= 0;
	recal_writedata <= 0;
	recal_readdata <= 0;
   end else begin
   case(recal_state)
	WAIT_CNTR: begin
	   recal_write <= 0;
	   recal_read <=0;
	   if (cntr_done_sync == 1) begin
		recal_state <= READ_CALCODE;
	   end else begin
		recal_state <= WAIT_CNTR;
	   end
	end
	READ_CALCODE: begin
		recal_read <= 1;
		recal_address <= 11'h100;
		recal_state <= IDLE1;
	end
	IDLE1: begin
	   if (avmm_waitrequest == 1) begin
		recal_state <= IDLE1;
	   end else begin
	   recal_state <= SEND_REQ;
		recal_read <= 0;
		recal_readdata <= avmm_readdata;
		recal_address <= 11'h000;
	   end
	end
	SEND_REQ: begin
	   recal_write <= 1;
	   recal_address <= 11'h100;
	   recal_writedata <= recal_readdata | 8'b0000_0100;
	   recal_state <= IDLE2;
	end
	IDLE2: begin
	   recal_state <= READ_ARB;
	   recal_write <= 0;
	   recal_address <= 11'h000;
	   recal_writedata <= 8'h00;
	end
	READ_ARB:begin
 	   recal_read <= 1;
	   recal_address <= 11'h000;
	   recal_state <= IDLE3;
	end
	IDLE3:begin
	   if (avmm_waitrequest == 1) begin
		recal_state <= IDLE3;
	   end else begin
	   recal_state <= SEND_ARB;
		recal_read <= 0;
		recal_readdata <= avmm_readdata;
		recal_address <= 11'h000;
	   end
	end
	SEND_ARB: begin
	   recal_write <= 1;
	   recal_address <= 10'h000;
	   recal_writedata <= recal_readdata | 8'b0000_0011;
	   recal_state <= WAIT_CNTR;
	end
	default: recal_state <= WAIT_CNTR;
   endcase
   end
end

wire recal_waitrequest_sync;
alt_xcvr_resync_std #(.SYNC_CHAIN_LENGTH(3), .WIDTH(1),      .INIT_VALUE(0)) 
recal_wreq_synchronizer 
     (  .clk    (user_avmm_clk),     
        .reset  (!rst_n),   
        .d      (recal_waitrequest),   
        .q      (recal_waitrequest_sync)
        );


assign avmm_read = recal_waitrequest_sync? recal_read:user_read;
assign avmm_write = recal_waitrequest_sync? recal_write:user_write;
assign avmm_address = recal_waitrequest_sync? recal_address:user_address;
assign user_waitrequest = recal_waitrequest_sync? 1: avmm_waitrequest;
//assign user_waitrequest = avmm_waitrequest;
assign avmm_writedata = recal_waitrequest_sync? recal_writedata:user_writedata;
assign user_readdata = recal_waitrequest_sync? 8'h00:avmm_readdata;
assign avmm_clk = user_avmm_clk;
assign avmm_reset = user_avmm_reset;
assign out_bg_cal_pld_avmm1_busy = recal_waitrequest_sync? 1: pld_avmm1_busy;
endmodule















