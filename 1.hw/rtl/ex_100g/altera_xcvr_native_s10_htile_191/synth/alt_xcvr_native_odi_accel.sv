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

module alt_xcvr_native_odi_accel #(
  parameter                      DATA_WIDTH = 32,
  parameter						 ADDR_WIDTH = 11
) (
  input                          avmm_clk,
  input                          avmm_reset,
  
  // AVMM signals to the transceiver
  output reg                     odi_read,
  output reg                     odi_write,
  output reg [ADDR_WIDTH-1:0]    odi_address,
  output reg [DATA_WIDTH-1:0]    odi_writedata,
  input      [7:0]               odi_readdata,
  input                          odi_waitrequest,

  // Control signals from CSR
  input                          odi_count_en,
  input                          odi_snap,
  input                          odi_reset,

  // Status signals from ODI
  output                         odi_done,
  output reg [49:0]              odi_bit_count,
  output reg [49:0]              odi_err_count
);

/**********************************************************************/
// States for the Statemachine
// General Sequence: idle > odi_start_0 > odi_rstn_1 > odi_rst_0 > odi_start_1 > odi_start_0 > chck_done > read_bits > read_errs
/**********************************************************************/
localparam SM_ODI_ACCEL_IDLE            = 5'd0;
localparam SM_ODI_ACCEL_RD_OFST_169     = 5'd1;
localparam SM_ODI_ACCEL_WR_START_0      = 5'd2;
localparam SM_ODI_ACCEL_WR_RESET_1      = 5'd3;
localparam SM_ODI_ACCEL_WR_RESET_0      = 5'd4;
localparam SM_ODI_ACCEL_WR_START_1      = 5'd5;
localparam SM_ODI_ACCEL_WR_START_DISABLE= 5'd6;
localparam SM_ODI_ACCEL_WAIT            = 5'd7;
localparam SM_ODI_ACCEL_RD_ADPT_STAT_BUS= 5'd8;
localparam SM_ODI_ACCEL_RD_ADPT_STATUS  = 5'd9;
localparam SM_ODI_ACCEL_RD_ADPT_ERR_1   = 5'd10;
localparam SM_ODI_ACCEL_RD_ADPT_ERR_2   = 5'd11;
localparam SM_ODI_ACCEL_RD_ADPT_BIT_1   = 5'd12;
localparam SM_ODI_ACCEL_RD_ADPT_BIT_2   = 5'd13;
localparam SM_ODI_ACCEL_FINAL_ACCUM     = 5'd14;


/**********************************************************************/
// Local wires and registers
/**********************************************************************/
reg [4:0]       sm_odi_state;
reg [4:0]       sm_odi_next;
reg [5:0]       timeout;
reg [7:0]       lcl_odi_read;
reg [15:0]      adpt_bits;
reg [15:0]      adpt_errs;
reg [50:0]      odi_bit_accumulator;
reg [50:0]      odi_err_accumulator;


/**********************************************************************/
// Statemachine
/**********************************************************************/
always@(posedge avmm_clk or posedge avmm_reset) begin
  if(avmm_reset) begin
    sm_odi_state      <= SM_ODI_ACCEL_IDLE;
    odi_read          <= 1'b0;
    odi_write         <= 1'b0;
    odi_address       <= {ADDR_WIDTH{1'b0}};
    odi_writedata     <= {DATA_WIDTH{1'b0}};
    adpt_bits         <= 16'b0;
    adpt_errs         <= 16'b0;
  end else if(odi_reset) begin
    sm_odi_state      <= SM_ODI_ACCEL_IDLE;
    odi_read          <= 1'b0;
    odi_write         <= 1'b0;
    odi_address       <= {ADDR_WIDTH{1'b0}};
    odi_writedata     <= {DATA_WIDTH{1'b0}};
    adpt_bits         <= 16'b0;
    adpt_errs         <= 16'b0;
  end else begin
    odi_read          <= 1'b0;
    odi_write         <= 1'b0;
    odi_address       <= {ADDR_WIDTH{1'b0}};
    odi_writedata     <= {DATA_WIDTH{1'b0}};
    case(sm_odi_state)
      SM_ODI_ACCEL_IDLE:  
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b0;
                            adpt_bits         <= 16'b0;
                            adpt_errs         <= 16'b0;

                            if(odi_count_en == 1'b1) begin
                              sm_odi_state    <= SM_ODI_ACCEL_RD_OFST_169;
                            end
                          end

      SM_ODI_ACCEL_RD_OFST_169:  
                          begin
                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin
                              adpt_bits         <= 16'b0;
                              adpt_errs         <= 16'b0;

                              odi_read          <= 1'b0;
                              odi_write         <= 1'b1;
                              odi_address       <= 10'h169;
                              odi_writedata     <= {odi_readdata[7:1],1'b0};
                              lcl_odi_read      <= odi_readdata;

                              sm_odi_state    <= SM_ODI_ACCEL_WR_RESET_0;
                            end else begin

                              odi_read          <= 1'b1;
                              odi_write         <= 1'b0;
                              odi_address       <= 10'h169;

                              sm_odi_state    <= SM_ODI_ACCEL_RD_OFST_169;
                            end
                          end

      SM_ODI_ACCEL_WR_RESET_0:  
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b1;
                            odi_address       <= 10'h169;
                            odi_writedata     <= {lcl_odi_read[7:2],2'b00};

                            sm_odi_state      <= SM_ODI_ACCEL_WR_RESET_1;
                          end

      SM_ODI_ACCEL_WR_RESET_1:  
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b1;
                            odi_address       <= 10'h169;
                            odi_writedata     <= {lcl_odi_read[7:2],2'b10};

                            sm_odi_state      <= SM_ODI_ACCEL_WR_START_1;
                          end

      SM_ODI_ACCEL_WR_START_1:  
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b1;
                            odi_address       <= 10'h169;
                            odi_writedata     <= {lcl_odi_read[7:2],2'b11};

                            sm_odi_state      <= SM_ODI_ACCEL_WR_START_DISABLE;
                          end

      SM_ODI_ACCEL_WR_START_DISABLE:  
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b1;
                            odi_address       <= 10'h169;
                            odi_writedata     <= {lcl_odi_read[7:2],2'b10};

                            sm_odi_state      <= SM_ODI_ACCEL_WAIT;
                            sm_odi_next       <= SM_ODI_ACCEL_RD_ADPT_STAT_BUS;
                          end
      SM_ODI_ACCEL_WAIT:
                          begin
                            odi_write         <= 1'b0;
                            odi_read          <= 1'b0;
                            odi_address       <= odi_address;
                            odi_writedata     <= odi_writedata;
                            if(timeout[4] & timeout[3]) begin
                              sm_odi_state    <= sm_odi_next;
                            end else begin
                              sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_STAT_BUS:
                          begin

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin // TODO
                              odi_read        <= 1'b0;
                              odi_write       <= 1'b1;
                              odi_address     <= 10'h14c;
                              odi_writedata   <= {odi_readdata[7],7'h2D}; // TODO - mask
                              lcl_odi_read    <= odi_readdata;

                              sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                              sm_odi_next     <= SM_ODI_ACCEL_RD_ADPT_STATUS;
                            end else begin
                              odi_read        <= 1'b1;
                              odi_write       <= 1'b0;
                              odi_address     <= 10'h14c;
                              odi_writedata   <= 8'h00;

                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_STAT_BUS;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_STATUS:
                          begin

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin // TODO
                              if(odi_readdata[1] == 1'b1) begin
                                odi_read      <= 1'b0;
                                odi_write     <= 1'b1;
                                odi_address   <= 10'h14c;
                                odi_writedata <= {lcl_odi_read[7],7'h2C};

                                sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                                sm_odi_next   <= SM_ODI_ACCEL_RD_ADPT_ERR_1;
                              end else begin
                                sm_odi_state  <= SM_ODI_ACCEL_WAIT;
                              end
                            end else begin
                              odi_read        <= 1'b1;
                              odi_write       <= 1'b0;
                              odi_address     <= 10'h177;
                              odi_writedata   <= 8'h0;
                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_STATUS;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_ERR_1:
                          begin

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin
                              odi_read        <= 1'b0;
                              odi_write       <= 1'b1;
                              odi_address     <= 10'h14c;
                              odi_writedata   <= {lcl_odi_read[7],7'h2B};

                              sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                              sm_odi_next     <= SM_ODI_ACCEL_RD_ADPT_ERR_2;

                              adpt_errs[15:8] <= odi_readdata;
                            end else begin
                              odi_read        <= 1'b1;
                              odi_write       <= 1'b0;
                              odi_address     <= 10'h177;
                              odi_writedata   <= 8'h0;
                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_ERR_1;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_ERR_2:
                          begin

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin
                              odi_read        <= 1'b0;
                              odi_write       <= 1'b1;
                              odi_address     <= 10'h14c;
                              odi_writedata   <= {lcl_odi_read[7],7'h2A};

                              sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                              sm_odi_next     <= SM_ODI_ACCEL_RD_ADPT_BIT_1;

                              adpt_errs[7:0] <= odi_readdata;
                            end else begin
                              odi_read        <= 1'b1;
                              odi_write       <= 1'b0;
                              odi_address     <= 10'h177;
                              odi_writedata   <= 8'h0;
                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_ERR_2;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_BIT_1:
                          begin

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin
                              odi_read        <= 1'b0;
                              odi_write       <= 1'b1;
                              odi_address     <= 10'h14c;
                              odi_writedata   <= {lcl_odi_read[7],7'h29};

                              sm_odi_state    <= SM_ODI_ACCEL_WAIT;
                              sm_odi_next     <= SM_ODI_ACCEL_RD_ADPT_BIT_2;
                              
                              adpt_bits[15:8] <= odi_readdata;
                            end else begin
                              odi_read        <= 1'b1;
                              odi_write       <= 1'b0;
                              odi_address     <= 10'h177;
                              odi_writedata   <= 8'h0;
                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_BIT_1;
                            end
                          end

      SM_ODI_ACCEL_RD_ADPT_BIT_2:
                          begin
                            odi_write         <= 1'b0;
                            odi_address       <= 10'h177;
                            odi_writedata     <= 8'h0;

                            if(odi_waitrequest == 1'b0 && odi_read == 1'b1) begin
                              odi_read        <= 1'b0;
                              sm_odi_state    <= SM_ODI_ACCEL_FINAL_ACCUM;
                              adpt_bits[7:0]  <= odi_readdata;
                            end else begin
                              odi_read        <= 1'b1;
                              sm_odi_state    <= SM_ODI_ACCEL_RD_ADPT_BIT_2;
                            end
                          end

      SM_ODI_ACCEL_FINAL_ACCUM:
                          begin
                            if(odi_count_en == 1'b1) begin
                              sm_odi_state    <= SM_ODI_ACCEL_RD_OFST_169;
                            end else begin
                              sm_odi_state    <= SM_ODI_ACCEL_IDLE;
                            end
                          end

      default:
                          begin
                            odi_read          <= 1'b0;
                            odi_write         <= 1'b0;
                            odi_address       <= 10'b0;
                            odi_writedata     <= {DATA_WIDTH{1'b0}};
                          end
    endcase
  end
end

// Time between polling the odi_done bit to read out the accumualted read/write
always@(posedge avmm_clk) begin
  if(sm_odi_state == SM_ODI_ACCEL_WAIT) begin
    timeout         <= timeout + 1'b1;
  end else begin
    timeout         <= 5'b0;
  end
end


/**********************************************************************/
// Accumulate bit and error count!
/**********************************************************************/
assign odi_done = odi_bit_accumulator[50];
always@(posedge avmm_clk or posedge avmm_reset) begin
  if(avmm_reset == 1'b1) begin
    odi_bit_count           <= 50'b0;
    odi_err_count           <= 50'b0;
    odi_bit_accumulator     <= 51'b0;
    odi_err_accumulator     <= 51'b0;
  end else if(odi_reset == 1'b1) begin
    odi_bit_count           <= 50'b0;
    odi_err_count           <= 50'b0;
    odi_bit_accumulator     <= 51'b0;
    odi_err_accumulator     <= 51'b0;
  end else begin

    if(odi_snap) begin
      odi_bit_count         <= odi_bit_accumulator[49:0];
      odi_err_count         <= odi_err_accumulator[49:0];
    end

    if(sm_odi_state == SM_ODI_ACCEL_FINAL_ACCUM) begin
      if(odi_done == 1'b1) begin
        odi_bit_accumulator <= odi_bit_accumulator;
        odi_err_accumulator <= odi_err_accumulator;
      end else begin
        odi_bit_accumulator <= odi_bit_accumulator + adpt_bits;
        odi_err_accumulator <= odi_err_accumulator + adpt_errs;
      end
    end
  end
end

endmodule
