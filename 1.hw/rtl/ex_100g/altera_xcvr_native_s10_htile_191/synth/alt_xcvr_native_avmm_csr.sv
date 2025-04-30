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


// (C) 2001-2018 Intel Corporation. All rights reserved.
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

module alt_xcvr_native_avmm_csr #(
  parameter                               dbg_capability_reg_enable        = 0,
  parameter                               dbg_user_identifier              = 0,
  parameter                               dbg_stat_soft_logic_enable       = 0,
  parameter                               dbg_ctrl_soft_logic_enable       = 0,
  parameter                               channels                         = 1,
  parameter                               channel_num                      = 1,
  parameter								  addr_width					   = 10,
  parameter                               duplex_mode                      = 3,
  parameter                               dbg_prbs_soft_logic_enable       = 0,
  parameter                               dbg_odi_soft_logic_enable        = 0,
  parameter                               rcfg_emb_strm_enable             = 0,
  parameter                               rcfg_emb_strm_cfg_sel_width      = 2,
  parameter                               enable_background_cal      = 1  
) (
  // avmm signals
  input                                   avmm_clk,
  input                                   avmm_reset,
  input  [addr_width-1:0]                 avmm_address,
  input  [7:0]                            avmm_writedata,
  input                                   avmm_write,
  input                                   avmm_read,
  output reg [7:0]                        avmm_readdata,
  output                                  avmm_waitrequest,

  // prbs ctrl signal
  input  [49:0]                           prbs_err,
  input  [49:0]                           prbs_bit,
  input                                   prbs_done,
  output                                  prbs_count_en,
  output                                  prbs_snap,
  output                                  prbs_reset,
  
  // odi ctrl signals
  input  [49:0]                           odi_bit,
  input  [49:0]                           odi_err,
  input                                   odi_done,
  output                                  odi_count_en,
  output                                  odi_reset,               
  output                                  odi_snap,

  // input status signals from the channel
  input                                   rx_is_lockedtodata,
  input                                   rx_is_lockedtoref,
  input                                   tx_cal_busy,
  input                                   rx_cal_busy,
  input                                   avmm_busy,
  // <TODO: case:335703>
  input                                   tx_transfer_ready,
  input                                   rx_transfer_ready,
  
  // input control signals
  input                                   rx_prbs_err_clr,
  input                                   set_rx_locktoref,
  input                                   set_rx_locktodata,
  input                                   serial_loopback,
  input                                   rx_analogreset,
  input                                   rx_digitalreset,
  input                                   tx_analogreset,
  input                                   tx_digitalreset,  

  // embedded reconfigsignals
  input                                   rcfg_emb_strm_busy,
  input                                   rcfg_emb_strm_chan_sel,
  output [rcfg_emb_strm_cfg_sel_width-1:0] rcfg_emb_strm_cfg_sel,
  output                                  rcfg_emb_strm_bcast_en,
  output                                  rcfg_emb_strm_cfg_load,

  // output control signals to the channel
  output                                  csr_set_lock_to_data,
  output                                  csr_set_lock_to_ref,
  output                                  csr_en_loopback,
  output                                  csr_rx_analogreset,
  output                                  csr_rx_digitalreset,  
  output                                  csr_tx_analogreset,
  output                                  csr_tx_digitalreset,  
  output                                  csr_tx_cal_busy_mask,
  output                                  csr_rx_cal_busy_mask,
  output				  bg_cal_en
);

// Import package with parameters for the soft addresses and offsets
import      s10_avmm_h::*;


// Reg for generating waitrequest and data valid
reg         avmm_valid;

/**********************************************************************/
// wires and bus declaration
/**********************************************************************/
wire [7:0]  rd_channel;
wire [7:0]  rd_channel_num;
wire [7:0]  rd_duplex;
wire [7:0]  rd_system_id;
wire [7:0]  rd_prbs_en;
wire [7:0]  rd_odi_en;
wire [7:0]  rd_status_en;
wire [7:0]  rd_control_en;
wire [7:0]  rd_prbs_ctrl;
wire [7:0]  rd_odi_ctrl;
wire [7:0]  rd_ltr_status;
wire [7:0]  rd_set_ltr;
wire [7:0]  rd_loopback;
wire [7:0]  rd_cal_busy;
wire [7:0]  rd_chnl_reset;
wire [7:0]  rd_rcfg_emb_ctrl;
wire [7:0]  rd_rcfg_emb_status;
wire [49:0] rd_prbs_err;
wire [49:0] rd_prbs_bit;
wire [49:0] rd_odi_err;
wire [49:0] rd_odi_bit;
wire [7:0]  rd_bg_cal;
/**********************************************************************/
//generate waitrequest
/**********************************************************************/
assign avmm_waitrequest = (~avmm_valid & avmm_read);


/**********************************************************************/
// soft CSRs for embedded debug
/**********************************************************************/
always@(posedge avmm_clk) begin
  if(~avmm_read) begin
    avmm_valid    <= 1'b0;
    avmm_readdata <= RD_UNUSED;
  end else begin
    avmm_valid    <= avmm_waitrequest;
    case(avmm_address)

      // Address for Capabilities
      S10_XR_ADDR_ID_0:           avmm_readdata <= rd_system_id;
      S10_XR_ADDR_STATUS_EN:      avmm_readdata <= rd_status_en;
      S10_XR_ADDR_CONTROL_EN:     avmm_readdata <= rd_control_en;
      S10_XR_ADDR_NAT_CHNLS:      avmm_readdata <= rd_channel;
      S10_XR_ADDR_NAT_CHNL_NUM:   avmm_readdata <= rd_channel_num;
      S10_XR_ADDR_NAT_DUPLEX:     avmm_readdata <= rd_duplex;
      S10_XR_ADDR_NAT_PRBS_EN:    avmm_readdata <= rd_prbs_en;
      S10_XR_ADDR_NAT_ODI_EN:     avmm_readdata <= rd_odi_en;

      // Addresses for PRBS
      S10_XR_ADDR_PRBS_CTRL:      avmm_readdata <= rd_prbs_ctrl;
      S10_XR_ADDR_PRBS_ERR_0:     avmm_readdata <= rd_prbs_err[7:0];
      S10_XR_ADDR_PRBS_ERR_1:     avmm_readdata <= rd_prbs_err[15:8];
      S10_XR_ADDR_PRBS_ERR_2:     avmm_readdata <= rd_prbs_err[23:16];
      S10_XR_ADDR_PRBS_ERR_3:     avmm_readdata <= rd_prbs_err[31:24];
      S10_XR_ADDR_PRBS_ERR_4:     avmm_readdata <= rd_prbs_err[39:32];
      S10_XR_ADDR_PRBS_ERR_5:     avmm_readdata <= rd_prbs_err[47:40];
      S10_XR_ADDR_PRBS_ERR_6:     avmm_readdata <= {6'b0, rd_prbs_err[49:48]};
      S10_XR_ADDR_PRBS_BIT_0:     avmm_readdata <= rd_prbs_bit[7:0];
      S10_XR_ADDR_PRBS_BIT_1:     avmm_readdata <= rd_prbs_bit[15:8];
      S10_XR_ADDR_PRBS_BIT_2:     avmm_readdata <= rd_prbs_bit[23:16];
      S10_XR_ADDR_PRBS_BIT_3:     avmm_readdata <= rd_prbs_bit[31:24];
      S10_XR_ADDR_PRBS_BIT_4:     avmm_readdata <= rd_prbs_bit[39:32];
      S10_XR_ADDR_PRBS_BIT_5:     avmm_readdata <= rd_prbs_bit[47:40];
      S10_XR_ADDR_PRBS_BIT_6:     avmm_readdata <= {6'b0, rd_prbs_bit[49:48]};

      // Address for ODI
      S10_XR_ADDR_ODI_CTRL:       avmm_readdata <= rd_odi_ctrl;
      S10_XR_ADDR_ODI_ERR_0:      avmm_readdata <= rd_odi_err[7:0];
      S10_XR_ADDR_ODI_ERR_1:      avmm_readdata <= rd_odi_err[15:8];
      S10_XR_ADDR_ODI_ERR_2:      avmm_readdata <= rd_odi_err[23:16];
      S10_XR_ADDR_ODI_ERR_3:      avmm_readdata <= rd_odi_err[31:24];
      S10_XR_ADDR_ODI_ERR_4:      avmm_readdata <= rd_odi_err[39:32];
      S10_XR_ADDR_ODI_ERR_5:      avmm_readdata <= rd_odi_err[47:40];
      S10_XR_ADDR_ODI_ERR_6:      avmm_readdata <= {6'b0, rd_odi_err[49:48]};
      S10_XR_ADDR_ODI_BIT_0:      avmm_readdata <= rd_odi_bit[7:0];
      S10_XR_ADDR_ODI_BIT_1:      avmm_readdata <= rd_odi_bit[15:8];
      S10_XR_ADDR_ODI_BIT_2:      avmm_readdata <= rd_odi_bit[23:16];
      S10_XR_ADDR_ODI_BIT_3:      avmm_readdata <= rd_odi_bit[31:24];
      S10_XR_ADDR_ODI_BIT_4:      avmm_readdata <= rd_odi_bit[39:32];
      S10_XR_ADDR_ODI_BIT_5:      avmm_readdata <= rd_odi_bit[47:40];
      S10_XR_ADDR_ODI_BIT_6:      avmm_readdata <= {6'b0, rd_odi_bit[49:48]};

      // Address for status registers
      S10_XR_ADDR_GP_RD_LTR:      avmm_readdata <= rd_ltr_status;
      S10_XR_ADDR_GP_CAL_BUSY:    avmm_readdata <= rd_cal_busy;

      // Addresses for control registers
      S10_XR_ADDR_GP_SET_LTR:     avmm_readdata <= rd_set_ltr;
      S10_XR_ADDR_GP_LPBK:        avmm_readdata <= rd_loopback;
      S10_XR_ADDR_CHNL_RESET:     avmm_readdata <= rd_chnl_reset;
      //Embedded reconfig
      S10_XR_ADDR_EMBED_RCFG_CTRL:   avmm_readdata <= rd_rcfg_emb_ctrl;
      S10_XR_ADDR_EMBED_RCFG_STATUS: avmm_readdata <= rd_rcfg_emb_status;

      //Background Calibration
      S10_XR_ADDR_BG_CAL: avmm_readdata <= rd_bg_cal;

      default:                    avmm_readdata <= RD_UNUSED;
    endcase
  end
end

/**********************************************************************/
// Generate Capability Registers
/**********************************************************************/
generate if(dbg_capability_reg_enable == 1) begin: g_capability_reg_en
    assign rd_channel     = channels[7:0];
    assign rd_channel_num = channel_num[7:0];
    assign rd_duplex      = (duplex_mode == "duplex") ? 8'h3 :
                            (duplex_mode == "tx")     ? 8'h2 : 8'h1;
    assign rd_system_id   = dbg_user_identifier[7:0];
    assign rd_prbs_en     = dbg_prbs_soft_logic_enable[7:0];
    assign rd_odi_en      = dbg_odi_soft_logic_enable[7:0];
    assign rd_status_en   = dbg_stat_soft_logic_enable[7:0];
    assign rd_control_en  = dbg_ctrl_soft_logic_enable[7:0];
  end else begin: g_capability_reg_dis 
    assign rd_channel     = RD_UNUSED;
    assign rd_channel_num = RD_UNUSED;
    assign rd_duplex      = RD_UNUSED;
    assign rd_system_id   = RD_UNUSED;
    assign rd_prbs_en     = RD_UNUSED;
    assign rd_odi_en      = RD_UNUSED;
    assign rd_status_en   = RD_UNUSED;
    assign rd_control_en  = RD_UNUSED;
  end
endgenerate // End generate for g_capability_reg

/**********************************************************************/
// Generate Capability Registers for Background Calibration
/**********************************************************************/
assign bg_cal_en = rd_bg_cal[0];
reg [7:0] bg_cal_reg;

initial begin
   bg_cal_reg = 8'h01;
end

generate if( enable_background_cal== 1) begin: g_capability_bg_cal_en
    assign rd_bg_cal     = bg_cal_reg;
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
          bg_cal_reg           <= 8'h01;
      end else if(avmm_write && (avmm_address == S10_XR_ADDR_BG_CAL)) begin
          bg_cal_reg         <= avmm_writedata;
      end
    end
  end else begin: g_capability_bg_cal_dis 
    assign rd_bg_cal     = RD_UNUSED;
  end
endgenerate // End generate for g_capability_reg


/**********************************************************************/
// Generate registers for status signals
/**********************************************************************/
generate if(dbg_stat_soft_logic_enable == 1) begin: g_status_reg_en

    /**********************************************************************/
    // Wires for status signal synchronizers inside generate to avoid un-used wires
    /**********************************************************************/
    wire rx_is_ltd_sync;
    wire rx_is_ltr_sync;
    wire tx_cal_busy_sync;
    wire rx_cal_busy_sync;


    /**********************************************************************/
    // Instantiate Synchronizers and read logic for rx_is_lockedtodata and rx_is_lockedtoref
    /**********************************************************************/
    alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH         ( 3 ),
      .WIDTH                     ( 2 )  // two bits, one for locktodata and one for locktoref
    ) rx_is_locked_sync (
      .clk                       (avmm_clk),
      .reset                     (avmm_reset),
      .d                         ({rx_is_lockedtodata, rx_is_lockedtoref}),
      .q                         ({rx_is_ltd_sync, rx_is_ltr_sync}) 
    );

    assign rd_ltr_status[S10_XR_OFFSET_RD_LTR] = rx_is_ltr_sync;
    assign rd_ltr_status[S10_XR_OFFSET_RD_LTD] = rx_is_ltd_sync;
    assign rd_ltr_status[S10_XR_OFFSET_LTR_UNUSED+:S10_XR_LTR_UNUSED_LEN] = {S10_XR_LTR_UNUSED_LEN{1'b0}};


    /**********************************************************************/
    // Instantiate Synchronizers and read logic for avmm busy, cal busy and their masks
    /**********************************************************************/
    reg r_set_tx_cal_mask;
    reg r_set_rx_cal_mask;
    reg r_avmm_busy;

    // Instantiate Synchronizers and read logic for cal busy and avmm busy
    alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH         ( 3 ),
      .WIDTH                     ( 2 )  // two bits, one for tx cal busy and one for rx cal busy
    ) cal_busy (
      .clk                       (avmm_clk),
      .reset                     (avmm_reset),
      .d                         ({rx_cal_busy, tx_cal_busy}),
      .q                         ({rx_cal_busy_sync, tx_cal_busy_sync}) 
    );

    assign csr_tx_cal_busy_mask                   = ~r_set_tx_cal_mask;
    assign csr_rx_cal_busy_mask                   = ~r_set_rx_cal_mask;
    assign rd_cal_busy[S10_XR_OFFSET_TX_CAL_BUSY] = tx_cal_busy_sync;
    assign rd_cal_busy[S10_XR_OFFSET_RX_CAL_BUSY] = rx_cal_busy_sync;
    assign rd_cal_busy[S10_XR_OFFSET_AVMM_BUSY]   = r_avmm_busy;
    assign rd_cal_busy[S10_XR_OFFSET_CAL_DUMMY]   = 1'b0;
    assign rd_cal_busy[S10_XR_OFFSET_TX_CAL_MASK] = ~r_set_tx_cal_mask;
    assign rd_cal_busy[S10_XR_OFFSET_RX_CAL_MASK] = ~r_set_rx_cal_mask;
    assign rd_cal_busy[S10_XR_OFFSET_CAL_UNUSED+:S10_XR_CAL_UNUSED_LEN] = {S10_XR_CAL_UNUSED_LEN{1'b0}};

    // Assure that the avmm_busy register always gets updated
    always@(posedge avmm_clk) begin
      // Register the avmm busy signal
      r_avmm_busy                 <= avmm_busy;
    end

    // write cal_busy masks
    // Due to synthesis option not-gate pushback being optionally enabled, We will hard code its behavior.
    // this ensures that with or without a reset, the design will behave the same irrespective of the synth
    // option being enabled in the design.
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_set_tx_cal_mask           <= 1'b0;
        r_set_rx_cal_mask           <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_GP_CAL_BUSY) begin
          r_set_tx_cal_mask         <= ~avmm_writedata[S10_XR_OFFSET_TX_CAL_MASK];
          r_set_rx_cal_mask         <= ~avmm_writedata[S10_XR_OFFSET_RX_CAL_MASK];
      end
    end

  end else begin: g_status_reg_dis
    assign rd_ltr_status                          = RD_UNUSED;
    assign rd_cal_busy                            = RD_UNUSED;
    assign csr_tx_cal_busy_mask                   = 1'b1;
    assign csr_rx_cal_busy_mask                   = 1'b1;
  end
endgenerate //End generate g_status_reg


/**********************************************************************/
// Generate registers for control signals
/**********************************************************************/
generate if(dbg_ctrl_soft_logic_enable == 1) begin: g_control_reg

    /**********************************************************************/
    // Registers for set Lock to ref and set Lock to Data
    /**********************************************************************/
    reg r_set_ltr;
    reg r_set_ltd;
    reg r_set_ltr_override;
    reg r_set_ltd_override;

    // readback control registers for set ltr and ltd
    assign rd_set_ltr[S10_XR_OFFSET_SET_LTR]     = r_set_ltr;
    assign rd_set_ltr[S10_XR_OFFSET_SET_LTD]     = r_set_ltd;
    assign rd_set_ltr[S10_XR_OFFSET_SET_LTR_OVR] = r_set_ltr_override;
    assign rd_set_ltr[S10_XR_OFFSET_SET_LTD_OVR] = r_set_ltd_override;
    assign rd_set_ltr[S10_XR_OFFSET_SET_LTR_UNUSED+:S10_XR_SET_LTR_UNUSED_LEN] = {S10_XR_SET_LTR_UNUSED_LEN{1'b0}};

    // assign the output signals to the channel.  Use the inputs signal with the control registers
    assign csr_set_lock_to_ref  = (rd_set_ltr[S10_XR_OFFSET_SET_LTR_OVR]) ? rd_set_ltr[S10_XR_OFFSET_SET_LTR] : set_rx_locktoref;
    assign csr_set_lock_to_data = (rd_set_ltr[S10_XR_OFFSET_SET_LTD_OVR]) ? rd_set_ltr[S10_XR_OFFSET_SET_LTD] : set_rx_locktodata;

    // write control registers for ltr and ltd
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_set_ltr               <= 1'b0;
        r_set_ltd               <= 1'b0;
        r_set_ltr_override      <= 1'b0;
        r_set_ltd_override      <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_GP_SET_LTR) begin
        r_set_ltr               <= avmm_writedata[S10_XR_OFFSET_SET_LTR];
        r_set_ltd               <= avmm_writedata[S10_XR_OFFSET_SET_LTD];
        r_set_ltr_override      <= avmm_writedata[S10_XR_OFFSET_SET_LTR_OVR];
        r_set_ltd_override      <= avmm_writedata[S10_XR_OFFSET_SET_LTD_OVR];
      end
    end


    /**********************************************************************/
    // Registers for loopback
    /**********************************************************************/
    reg r_loopback;

    // readback control register for enabling loopback
    assign rd_loopback[S10_XR_OFFSET_LPBK] = r_loopback;
    assign rd_loopback[S10_XR_OFFSET_LPBK_UNUSED+:S10_XR_LPBK_UNUSED_LEN] = {S10_XR_LPBK_UNUSED_LEN{1'b0}};

    // assign the output signals to the channel
    assign csr_en_loopback  = (rd_loopback[S10_XR_OFFSET_LPBK] || serial_loopback);

    // write control registers for loopback
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_loopback    <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_GP_LPBK) begin
        r_loopback    <= avmm_writedata[S10_XR_OFFSET_LPBK];
      end
    end


    /**********************************************************************/
    // Registers for Channel Resets and Overrides
    /**********************************************************************/
    reg r_rx_analogreset;
    reg r_rx_digitalreset;
    reg r_tx_analogreset;
    reg r_tx_digitalreset;
    reg r_rx_analogreset_override;
    reg r_rx_digitalreset_override;
    reg r_tx_analogreset_override;
    reg r_tx_digitalreset_override;

    // readback the control registers for the channel resets and overrides
    assign rd_chnl_reset[S10_XR_OFFSET_RX_ANA]     = r_rx_analogreset;
    assign rd_chnl_reset[S10_XR_OFFSET_RX_DIG]     = r_rx_digitalreset;
    assign rd_chnl_reset[S10_XR_OFFSET_TX_ANA]     = r_tx_analogreset;
    assign rd_chnl_reset[S10_XR_OFFSET_TX_DIG]     = r_tx_digitalreset;
    assign rd_chnl_reset[S10_XR_OFFSET_RX_ANA_OVR] = r_rx_analogreset_override;
    assign rd_chnl_reset[S10_XR_OFFSET_RX_DIG_OVR] = r_rx_digitalreset_override;
    assign rd_chnl_reset[S10_XR_OFFSET_TX_ANA_OVR] = r_tx_analogreset_override;
    assign rd_chnl_reset[S10_XR_OFFSET_TX_DIG_OVR] = r_tx_digitalreset_override;

    // assign the output signals to the channel
    assign csr_rx_analogreset         = (rd_chnl_reset[S10_XR_OFFSET_RX_ANA_OVR]) ? rd_chnl_reset[S10_XR_OFFSET_RX_ANA] : rx_analogreset;
    assign csr_rx_digitalreset        = (rd_chnl_reset[S10_XR_OFFSET_RX_DIG_OVR]) ? rd_chnl_reset[S10_XR_OFFSET_RX_DIG] : rx_digitalreset;
    assign csr_tx_analogreset         = (rd_chnl_reset[S10_XR_OFFSET_TX_ANA_OVR]) ? rd_chnl_reset[S10_XR_OFFSET_TX_ANA] : tx_analogreset;
    assign csr_tx_digitalreset        = (rd_chnl_reset[S10_XR_OFFSET_TX_DIG_OVR]) ? rd_chnl_reset[S10_XR_OFFSET_TX_DIG] : tx_digitalreset;

    // write reset and reset override registers
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_rx_analogreset              <= 1'b0;
        r_rx_digitalreset             <= 1'b0;
        r_tx_analogreset              <= 1'b0;
        r_tx_digitalreset             <= 1'b0;
        r_rx_analogreset_override     <= 1'b0;
        r_rx_digitalreset_override    <= 1'b0;
        r_tx_analogreset_override     <= 1'b0;
        r_tx_digitalreset_override    <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_CHNL_RESET) begin
        r_rx_analogreset              <= avmm_writedata[S10_XR_OFFSET_RX_ANA]; 
        r_rx_digitalreset             <= avmm_writedata[S10_XR_OFFSET_RX_DIG]; 
        r_tx_analogreset              <= avmm_writedata[S10_XR_OFFSET_TX_ANA]; 
        r_tx_digitalreset             <= avmm_writedata[S10_XR_OFFSET_TX_DIG]; 
        r_rx_analogreset_override     <= avmm_writedata[S10_XR_OFFSET_RX_ANA_OVR]; 
        r_rx_digitalreset_override    <= avmm_writedata[S10_XR_OFFSET_RX_DIG_OVR]; 
        r_tx_analogreset_override     <= avmm_writedata[S10_XR_OFFSET_TX_ANA_OVR]; 
        r_tx_digitalreset_override    <= avmm_writedata[S10_XR_OFFSET_TX_DIG_OVR]; 
      end
    end
        
  end else begin: g_control_reg_dis
    // assign LTR control signals when control registers are disabled
    assign rd_set_ltr                 = RD_UNUSED;
    assign rd_loopback                = RD_UNUSED;
    assign rd_chnl_reset              = RD_UNUSED;

    // pass through control signals
    assign csr_set_lock_to_ref        = (set_rx_locktoref);
    assign csr_set_lock_to_data       = (set_rx_locktodata);
    assign csr_en_loopback            = (serial_loopback);
    assign csr_rx_analogreset         = (rx_analogreset);
    assign csr_rx_digitalreset        = (rx_digitalreset);
    assign csr_tx_analogreset         = (tx_analogreset);
    assign csr_tx_digitalreset        = (tx_digitalreset);
  end
endgenerate // End generate g_control_reg

/**********************************************************************/
// Embedded reconfig registers
/**********************************************************************/
generate if(rcfg_emb_strm_enable) begin: en_rcfg_reg

    /**********************************************************************/
    // Generate registers and wires for the reconfig soft logic
    /**********************************************************************/
    reg [rcfg_emb_strm_cfg_sel_width-1:0] r_rcfg_emb_strm_cfg_sel;
    reg                                   r_rcfg_emb_strm_cfg_load;
    reg                                   r_rcfg_emb_strm_bcast_en;
    reg                                   rcfg_emb_strm_cfg_load_lock = 1'b0;
  
    // readback the embedded reconfig control
    assign rd_rcfg_emb_ctrl               = {r_rcfg_emb_strm_cfg_load, r_rcfg_emb_strm_bcast_en, {(S10_XR_EMBED_RCFG_CFG_SEL_LEN-rcfg_emb_strm_cfg_sel_width){1'b0}}, r_rcfg_emb_strm_cfg_sel};
    assign rd_rcfg_emb_status             = {7'b0, rcfg_emb_strm_busy};
  
    // assign the output signals to the channel
    assign rcfg_emb_strm_cfg_sel          = r_rcfg_emb_strm_cfg_sel;
    assign rcfg_emb_strm_cfg_load         = r_rcfg_emb_strm_cfg_load;
    assign rcfg_emb_strm_bcast_en         = r_rcfg_emb_strm_bcast_en;
  
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_rcfg_emb_strm_cfg_sel           <= {rcfg_emb_strm_cfg_sel_width{1'b0}};
        r_rcfg_emb_strm_cfg_load          <= 1'b0;
        r_rcfg_emb_strm_bcast_en          <= 1'b0;
        rcfg_emb_strm_cfg_load_lock       <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_EMBED_RCFG_CTRL) begin
        // Write to this register
        r_rcfg_emb_strm_cfg_sel           <= avmm_writedata[S10_XR_OFFSET_EMBED_RCFG_CFG_SEL +: rcfg_emb_strm_cfg_sel_width ]; 
        r_rcfg_emb_strm_cfg_load          <= avmm_writedata[S10_XR_OFFSET_EMBED_RCFG_CFG_LOAD]; 
        r_rcfg_emb_strm_bcast_en          <= avmm_writedata[S10_XR_OFFSET_EMBED_RCFG_BCAST_EN]; 
      end else if(rcfg_emb_strm_chan_sel & rcfg_emb_strm_busy & ~rcfg_emb_strm_cfg_load_lock) begin
        // Reset the cfg_load bit when the streaming has started
        r_rcfg_emb_strm_cfg_load          <= 1'b0;
        rcfg_emb_strm_cfg_load_lock       <= 1'b1;
      end else if(~rcfg_emb_strm_busy & rcfg_emb_strm_cfg_load_lock)
        rcfg_emb_strm_cfg_load_lock       <= 1'b0;
    end
  end else begin: g_rcfg_reg_dis
    assign rd_rcfg_emb_ctrl               = RD_UNUSED;
    assign rd_rcfg_emb_status             = RD_UNUSED;
    assign rcfg_emb_strm_cfg_sel          = 1'b0; 
    assign rcfg_emb_strm_bcast_en         = 1'b0; 
    assign rcfg_emb_strm_cfg_load         = 1'b0;
  end
endgenerate //End generate g_rcfg_reg

/**********************************************************************/
// PRBS Registers and logic
/**********************************************************************/
assign rd_prbs_err  = prbs_err;
assign rd_prbs_bit  = prbs_bit;
generate if(dbg_prbs_soft_logic_enable == 1) begin: g_prbs_reg_en

    /**********************************************************************/
    // wires for synchronizer and registers for control signals to the PRBS accumulation block
    /**********************************************************************/
    wire rx_prbs_err_clr_sync;
    reg r_prbs_reset;
    reg r_prbs_snap;
    reg r_prbs_en;

    /**********************************************************************/
    // Instantiate Synchronizers and read logic for rx_is_lockedtodata and rx_is_lockedtoref
    /**********************************************************************/
    alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH                         ( 3 ),
      .WIDTH                                     ( 1 )  // two bits, one for locktodata and one for locktoref
    ) prbs_err_clr_sync (
      .clk                                       (avmm_clk),
      .reset                                     (avmm_reset),
      .d                                         (rx_prbs_err_clr),
      .q                                         (rx_prbs_err_clr_sync) 
    );

    // assign control signals for the PRBS accumulation logic
    assign prbs_count_en                          = r_prbs_en;
    assign prbs_snap                              = r_prbs_snap;
    assign prbs_reset                             = r_prbs_reset || rx_prbs_err_clr_sync;

    // readback data
    assign rd_prbs_ctrl[S10_XR_OFFSET_PRBS_EN]    = r_prbs_en;
    assign rd_prbs_ctrl[S10_XR_OFFSET_PRBS_RESET] = r_prbs_reset;
    assign rd_prbs_ctrl[S10_XR_OFFSET_PRBS_SNAP]  = r_prbs_snap;
    assign rd_prbs_ctrl[S10_XR_OFFSET_PRBS_DONE]  = prbs_done;
    assign rd_prbs_ctrl[S10_XR_OFFSET_PRBS_UNUSED+:S10_XR_PRBS_UNUSED_LEN] = {S10_XR_PRBS_UNUSED_LEN{1'b0}};

    // write prbs ctrl reg
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_prbs_en                                 <= 1'b0;
        r_prbs_reset                              <= 1'b0;
        r_prbs_snap                               <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_PRBS_CTRL) begin
        r_prbs_en                                 <= avmm_writedata[S10_XR_OFFSET_PRBS_EN];
        r_prbs_reset                              <= avmm_writedata[S10_XR_OFFSET_PRBS_RESET];
        r_prbs_snap                               <= avmm_writedata[S10_XR_OFFSET_PRBS_SNAP];
      end
    end
  end else begin: g_prbs_reg_dis
    assign prbs_reset                             = (rx_prbs_err_clr);
    assign rd_prbs_ctrl                           = RD_UNUSED;
    assign prbs_count_en                          = 1'b0;
    assign prbs_snap                              = 1'b0;
  end
endgenerate //End generate g_prbs_reg

/**********************************************************************/
// ODI Registers and logic
/**********************************************************************/
assign rd_odi_bit = odi_bit;
assign rd_odi_err = odi_err;
generate if(dbg_odi_soft_logic_enable == 1) begin: g_odi_reg_en

    /**********************************************************************/
    // wires for synchronizer and registers for control signals to the odi accumulation block
    /**********************************************************************/
    reg r_odi_reset;
    reg r_odi_snap;
    reg r_odi_en;

    // assign control signals for the ODI accumulation logic
    assign odi_count_en                         = r_odi_en;
    assign odi_snap                             = r_odi_snap;
    assign odi_reset                            = r_odi_reset;

    // readback data
    assign rd_odi_ctrl[S10_XR_OFFSET_ODI_EN]    = r_odi_en;
    assign rd_odi_ctrl[S10_XR_OFFSET_ODI_RESET] = r_odi_reset;
    assign rd_odi_ctrl[S10_XR_OFFSET_ODI_SNAP]  = r_odi_snap;
    assign rd_odi_ctrl[S10_XR_OFFSET_ODI_DONE]  = odi_done;
    assign rd_odi_ctrl[S10_XR_OFFSET_ODI_UNUSED+:S10_XR_ODI_UNUSED_LEN] = {S10_XR_ODI_UNUSED_LEN{1'b0}};

    // write ODI ctrl reg
    always@(posedge avmm_clk or posedge avmm_reset) begin
      if(avmm_reset) begin
        r_odi_en                                <= 1'b0;
        r_odi_reset                             <= 1'b0;
        r_odi_snap                              <= 1'b0;
      end else if(avmm_write && avmm_address == S10_XR_ADDR_ODI_CTRL) begin
        r_odi_en                                <= avmm_writedata[S10_XR_OFFSET_ODI_EN];
        r_odi_reset                             <= avmm_writedata[S10_XR_OFFSET_ODI_RESET];
        r_odi_snap                              <= avmm_writedata[S10_XR_OFFSET_ODI_SNAP];
      end
    end
  end else begin: g_odi_reg_dis
    assign rd_odi_ctrl                          = RD_UNUSED;
    assign odi_reset                            = 1'b0;
    assign odi_count_en                         = 1'b0;
    assign odi_snap                             = 1'b0;
  end
endgenerate //End generate g_odi_reg

endmodule
