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

module alt_xcvr_native_prbs_accum (
  input         avmm_clk,
  input         avmm_reset,

  // Control signals from CSR
  input         prbs_reset,
  input         prbs_snapshot,
  input         prbs_counter_en,

  // Status signals from PRBS
  output        prbs_done_sync,
  output [49:0] prbs_err_count,
  output [49:0] prbs_bit_count,

  // Signals from the transceiver
  input         rx_clkout,
  input         prbs_err_signal,
  input         prbs_done_signal
);

/**********************************************************************/
// wires for synchronizers
/**********************************************************************/
wire        avmm_reset_sync;
wire        prbs_reset_sync;
wire        prbs_err_rx_sync;
wire        prbs_done_rx_sync;
wire        avmm_rx_cnt_edge_sync;

/**********************************************************************/
// Synchronizer for avmm_reset to rx_clkout
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH         ( 3 ),
  .WIDTH                     ( 1 ),
  .INIT_VALUE                ( 1 )
) rx_clk_reset_sync (
  .clk                       (rx_clkout),
  .reset                     (avmm_reset),
  .d                         (1'b0),
  .q                         (avmm_reset_sync) 
);

/**********************************************************************/
// Synchronizer for prbs_reset to rx_clkout
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH         ( 3 ),
  .WIDTH                     ( 1 ),
  .INIT_VALUE                ( 1 )
) rx_clk_prbs_reset_sync (
  .clk                       (rx_clkout),
  .reset                     (prbs_reset),
  .d                         (1'b0),
  .q                         (prbs_reset_sync) 
);

/**********************************************************************/
// Synchronizer for prbs_err to rx_clkout
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH         ( 2 ),
  .WIDTH                     ( 1 ),
  .INIT_VALUE                ( 1 )
) rx_clk_prbs_err_sync (
  .clk                       (rx_clkout),
  .reset                     (prbs_err_signal),
  .d                         (1'b0),
  .q                         (prbs_err_rx_sync) 
);

/**********************************************************************/
// Synchronizer for prbs_done to rx_clkout
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH         ( 2 ),
  .WIDTH                     ( 1 ),
  .INIT_VALUE                ( 1 )
) rx_clk_prbs_done_sync (
  .clk                       (rx_clkout),
  .reset                     (prbs_done_signal),
  .d                         (1'b0),
  .q                         (prbs_done_rx_sync) 
);

/**********************************************************************/
// wires and registers
/**********************************************************************/
wire        rx_prbs_err_edge;
wire        rx_prbs_cnt_edge;
wire        avmm_prbs_cnt_edge;
reg         rx_prbs_cnt_edge_reg;
reg         rx_prbs_err_edge_reg;
reg         avmm_prbs_cnt_edge_reg;
reg         rx_error_high;
reg  [3:0]  rx_consecutive_error;
reg  [7:0]  rx_prbs_bit_count;
reg  [7:0]  rx_prbs_err_count;
reg  [7:0]  rx_prbs_err_snapshot;
reg  [49:0] avmm_prbs_err_count;
reg  [49:0] avmm_prbs_bit_count;
reg  [49:0] avmm_prbs_err_snapshot;
reg  [49:0] avmm_prbs_bit_snapshot;

/**********************************************************************/
// Logic on rx_clkout for accumulating bits and errors
/**********************************************************************/
assign rx_prbs_err_edge = (~rx_prbs_err_edge_reg && prbs_err_rx_sync);
assign rx_prbs_cnt_edge = (rx_prbs_cnt_edge_reg ^ rx_prbs_bit_count[7]);
always@(posedge rx_clkout or posedge avmm_reset_sync) begin
  if(avmm_reset_sync) begin
    rx_prbs_err_edge_reg  <= 1'b0;
    rx_prbs_cnt_edge_reg  <= 1'b0;
    rx_prbs_bit_count     <= 8'b0;
    rx_prbs_err_count     <= 8'b0;
    rx_prbs_err_snapshot  <= 8'b0;
    rx_consecutive_error  <= 4'b0;
    rx_error_high         <= 1'b0;
  end else if (prbs_reset_sync == 1'b1) begin
    rx_prbs_err_edge_reg  <= 1'b0;
    rx_prbs_cnt_edge_reg  <= 1'b0;
    rx_prbs_bit_count     <= 8'b0;
    rx_prbs_err_count     <= 8'b0;
    rx_prbs_err_snapshot  <= 8'b0;
    rx_consecutive_error  <= 4'b0;
    rx_error_high         <= 1'b0;
  end else if (prbs_done_rx_sync == 1'b1) begin
    // prbs error edge
    rx_prbs_err_edge_reg  <=  prbs_err_rx_sync;

    // prbs count edge
    rx_prbs_cnt_edge_reg  <=  rx_prbs_bit_count[7];

    // If the error signal is high for more than 7 cycles, constantly count errors
    if(prbs_err_rx_sync == 1'b1) begin
      if(&rx_consecutive_error) begin
        rx_consecutive_error <= rx_consecutive_error;
      end else begin
        rx_consecutive_error <= rx_consecutive_error + 1'b1;
      end
    end else begin
      rx_consecutive_error <= 4'b0;
    end

    rx_error_high         <= (&rx_consecutive_error);

    // error and bit accumulation
    rx_prbs_bit_count     <=  rx_prbs_bit_count + 1'b1;
    rx_prbs_err_count     <=  (rx_prbs_cnt_edge) ? {7'b0, rx_prbs_err_edge} : (rx_prbs_err_count + (rx_prbs_err_edge || rx_error_high));
    rx_prbs_err_snapshot  <=  (rx_prbs_cnt_edge) ? rx_prbs_err_count : rx_prbs_err_snapshot;
  end
end

/**********************************************************************/
// Synchronizer for prbs_done to avmm_clock
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH ( 3 ),
  .WIDTH             ( 1 )
) avmm_clk_prbs_done_sync (
  .clk                       (avmm_clk),
  .reset                     (avmm_reset),
  .d                         (prbs_done_signal),
  .q                         (prbs_done_sync) 
);

/**********************************************************************/
// Synchronizer for bit_count edge to avmm_clock
/**********************************************************************/
alt_xcvr_resync_std #(
  .SYNC_CHAIN_LENGTH ( 3 ),
  .WIDTH             ( 1 )
) avmm_clk_bit_count_edge (
  .clk                       (avmm_clk),
  .reset                     (avmm_reset),
  .d                         (rx_prbs_cnt_edge_reg),
  .q                         (avmm_rx_cnt_edge_sync) 
);


/**********************************************************************/
// Logic for overall bit and error count in avmm_clk
/**********************************************************************/
assign prbs_err_count = avmm_prbs_err_snapshot;
assign prbs_bit_count = avmm_prbs_bit_snapshot;
assign avmm_prbs_cnt_edge = (avmm_prbs_cnt_edge_reg ^ avmm_rx_cnt_edge_sync);
always@(posedge avmm_clk or posedge avmm_reset) begin
  if(avmm_reset) begin
    avmm_prbs_bit_count       <=  50'b0;
    avmm_prbs_err_count       <=  50'b0;
    avmm_prbs_bit_snapshot    <=  50'b0;
    avmm_prbs_err_snapshot    <=  50'b0;
    avmm_prbs_cnt_edge_reg    <=  1'b0;
  end else if(prbs_reset) begin
    avmm_prbs_bit_count       <=  50'b0;
    avmm_prbs_err_count       <=  50'b0;
    avmm_prbs_bit_snapshot    <=  50'b0;
    avmm_prbs_err_snapshot    <=  50'b0;
    avmm_prbs_cnt_edge_reg    <=  1'b0;
  end else if(prbs_counter_en) begin
    avmm_prbs_cnt_edge_reg    <= avmm_rx_cnt_edge_sync;

    // on an edge of prbs count, accumulate the number of errors and bits
    if(avmm_prbs_cnt_edge) begin
      avmm_prbs_bit_count     <=  avmm_prbs_bit_count + 8'd128;
      avmm_prbs_err_count     <=  avmm_prbs_err_count + rx_prbs_err_snapshot;
    end else begin
      avmm_prbs_bit_count     <=  avmm_prbs_bit_count;
      avmm_prbs_err_count     <=  avmm_prbs_err_count;
    end

    // on a snapshot signal, capture the bit and error count to keep them in sync with each other
    if(prbs_snapshot) begin
      avmm_prbs_bit_snapshot  <=  avmm_prbs_bit_count;
      avmm_prbs_err_snapshot  <=  avmm_prbs_err_count;
    end else begin
      avmm_prbs_bit_snapshot  <=  avmm_prbs_bit_snapshot;
      avmm_prbs_err_snapshot  <=  avmm_prbs_err_snapshot;
    end
  end else begin
    avmm_prbs_bit_count       <=  avmm_prbs_bit_count;
    avmm_prbs_err_count       <=  avmm_prbs_err_count;
    avmm_prbs_bit_snapshot    <=  avmm_prbs_bit_snapshot;
    avmm_prbs_err_snapshot    <=  avmm_prbs_err_snapshot;
    avmm_prbs_cnt_edge_reg    <=  avmm_prbs_cnt_edge_reg;
  end
end

endmodule
