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

module alt_xcvr_native_rcfg_opt_logic_qufrg4q #(
  // Parameters for the embedded reconfiguration logic
  parameter                                 dbg_user_identifier         = 0,
  parameter                                 duplex_mode                 = "duplex",
  parameter                                 dbg_embedded_debug_enable   = 0,
  parameter                                 dbg_capability_reg_enable   = 0,
  parameter                                 dbg_prbs_soft_logic_enable  = 0,
  parameter                                 dbg_odi_soft_logic_enable   = 0,
  parameter                                 dbg_stat_soft_logic_enable  = 0,
  parameter                                 dbg_ctrl_soft_logic_enable  = 0,

  // Parameters for the AVMM masters and split interface
  parameter                                 CHANNELS                    = 1,
  parameter                                 RECONFIG_SHARED             = 0,
  parameter                                 JTAG_ENABLED                = 0,    // Can only be enabled when using a shared reconfig interface
  parameter                                 ADME_SLAVE_MAP              = "altera_xcvr_native_s10",
  parameter                                 ADME_ASSGN_MAP              = " ",
  parameter                                 RCFG_EMB_STRM_ENABLED       = 0,    // Enable the embedded reconfiguration streamer logic
  parameter                                 RCFG_PROFILE_CNT            = 2,    // Number of configuration profiles for embedded streamer

  // The following are not intended to be directly set
  parameter                                 IFACES                      = RECONFIG_SHARED ? 1 : CHANNELS,
  parameter                                 ADDR_BITS                   = 11,
  parameter                                 SEL_BITS                    = (RECONFIG_SHARED ? altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(CHANNELS-1) : 0),
  parameter                                 DATA_WIDTH                  = 32,
  parameter                                 enable_eios_rx_protect      = 0,
  parameter                                 pcs_aib_bonding_master      = 0,
  parameter				                    enable_background_cal       = 0

) (
  // User reconfig interface ports
  input  [IFACES-1:0]                          reconfig_clk,
  input  [IFACES-1:0]                          reconfig_reset,
  input  [IFACES-1:0]                          reconfig_write,
  input  [IFACES-1:0]                          reconfig_read,
  input  [IFACES*(ADDR_BITS+SEL_BITS)-1:0]     reconfig_address,
  input  [IFACES*DATA_WIDTH-1:0]               reconfig_writedata,
  output [IFACES*DATA_WIDTH-1:0]               reconfig_readdata,
  output [IFACES-1:0]                          reconfig_waitrequest,

  // AVMM ports to transceiver Split bychannel
  output [CHANNELS-1:0]                        avmm_clk,
  output [CHANNELS-1:0]                        avmm_reset,
  output [CHANNELS-1:0]                        avmm_write,
  output [CHANNELS-1:0]                        avmm_read,
  output [CHANNELS*ADDR_BITS-1:0]              avmm_address,
  output [CHANNELS*8-1:0]                      avmm_writedata,
  input  [CHANNELS*8-1:0]                      avmm_readdata,
  input  [CHANNELS-1:0]                        avmm_waitrequest,

  // input signals from the PHY for PRBSerror accumulation
  input  [CHANNELS-1:0]                        prbs_err_signal,
  input  [CHANNELS-1:0]                        prbs_done_signal,

  // input rx_clkout
  input  [CHANNELS-1:0]                        in_rx_clkout,

  // pipe and mac interface
  input                                        pipe_clk,   // pipe clock
  input                                        pipe_rstn,  // active low reset
  input  [1:0]                                 pipe_rate, 
  input                                        eios_rx_prot_req,
  input  [CHANNELS-1:0]                        pld_pmaif_mask_tx_pll,    //signals from PHY
  input  [CHANNELS-1:0]                        pcie_ctrl_testbus_b10,    

  // input status signals
  input  [CHANNELS-1:0]                        in_rx_is_lockedtoref,
  input  [CHANNELS-1:0]                        in_rx_is_lockedtodata,
  input  [CHANNELS-1:0]                        in_tx_cal_busy,
  input  [CHANNELS-1:0]                        in_rx_cal_busy,
  input  [CHANNELS-1:0]                        in_avmm_busy,
  input  [CHANNELS-1:0]                        in_tx_transfer_ready,
  input  [CHANNELS-1:0]                        in_rx_transfer_ready,

  // input control signals
  input  [CHANNELS-1:0]                        in_rx_prbs_err_clr,
  input  [CHANNELS-1:0]                        in_set_rx_locktoref,
  input  [CHANNELS-1:0]                        in_set_rx_locktodata,
  input  [CHANNELS-1:0]                        in_en_serial_lpbk,
  input  [CHANNELS-1:0]                        in_rx_analogreset,
  input  [CHANNELS-1:0]                        in_rx_digitalreset,  
  input  [CHANNELS-1:0]                        in_tx_analogreset,
  input  [CHANNELS-1:0]                        in_tx_digitalreset,
    
  // output control signals to the phy
  output [CHANNELS-1:0]                        out_prbs_err_clr,
  output [CHANNELS-1:0]                        out_set_rx_locktoref,
  output [CHANNELS-1:0]                        out_set_rx_locktodata,
  output [CHANNELS-1:0]                        out_en_serial_lpbk,
  output [CHANNELS-1:0]                        out_rx_analogreset,
  output [CHANNELS-1:0]                        out_rx_digitalreset,  
  output [CHANNELS-1:0]                        out_tx_analogreset,
  output [CHANNELS-1:0]                        out_tx_digitalreset,  
  output [CHANNELS-1:0]                        out_tx_cal_busy_mask,
  output [CHANNELS-1:0]                        out_rx_cal_busy_mask,
  //output control signal for background calibration module
  output [CHANNELS-1:0] 			bg_cal_en
);

/**********************************************************************/
// Per Instance instantiations and assignments
/**********************************************************************/
localparam AVMM_OFFSET = ADDR_BITS - 1;
localparam CHANNEL_SEL_WIDTH = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(CHANNELS-1);
localparam ENABLED_JTAG_MASTERS = 1 + enable_eios_rx_protect + JTAG_ENABLED + RCFG_EMB_STRM_ENABLED;
localparam RCFG_EMB_STRM_CFG_SEL_WIDTH = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(RCFG_PROFILE_CNT-1);


// Raw rmbedded reconfig signals (always independent)
wire [CHANNELS-1:0]             rcfg_emb_strm_write;
wire [CHANNELS-1:0]             rcfg_emb_strm_read;
wire [CHANNELS*ADDR_BITS-1:0]   rcfg_emb_strm_address;
wire [CHANNELS*DATA_WIDTH-1:0]  rcfg_emb_strm_writedata;
wire [CHANNELS-1:0]             rcfg_emb_strm_waitrequest;

// User AVMM signals expanded to independent channels
wire [CHANNELS-1:0]             split_user_write;
wire [CHANNELS-1:0]             split_user_read;
wire [CHANNELS*ADDR_BITS-1:0]   split_user_address;
wire [CHANNELS*DATA_WIDTH-1:0]  split_user_writedata;
wire [CHANNELS-1:0]             split_user_waitrequest;

// ODI AVMM signals, repurposed to be spilt_eios_rp signals 
wire [CHANNELS-1:0]             odi_write;
wire [CHANNELS-1:0]             odi_read;
wire [CHANNELS*ADDR_BITS-1:0]   odi_address;
wire [CHANNELS*DATA_WIDTH-1:0]  odi_writedata;
wire [CHANNELS-1:0]             odi_waitrequest;

// JTAG signals expanded to independent channels
wire [CHANNELS-1:0]             split_jtag_write;
wire [CHANNELS-1:0]             split_jtag_read;
wire [CHANNELS*ADDR_BITS-1:0]   split_jtag_address;
wire [CHANNELS*DATA_WIDTH-1:0]  split_jtag_writedata;
wire [CHANNELS-1:0]             split_jtag_waitrequest;

// Additional arbitration signals for soft CSR
wire [CHANNELS-1:0]             chnl_write;
wire [CHANNELS-1:0]             chnl_read;
wire [CHANNELS-1:0]             chnl_busy;
wire [CHANNELS-1:0]             chnl_waitrequest;
wire [CHANNELS*8-1:0]           chnl_readdata;

// embedded reconfig signals
wire [CHANNELS-1:0]             rcfg_emb_strm_busy;
wire [CHANNELS-1:0]             rcfg_emb_strm_chan_sel;
wire [CHANNELS*RCFG_EMB_STRM_CFG_SEL_WIDTH-1:0]   rcfg_emb_strm_cfg_sel;
wire [CHANNELS-1:0]             rcfg_emb_strm_bcast_en;
wire [CHANNELS-1:0]             rcfg_emb_strm_cfg_load;

// Read_write signals to assist with prioritizing arbitrarion
wire [CHANNELS-1:0]             user_read_write;
wire [CHANNELS-1:0]             odi_read_write;
wire [CHANNELS-1:0]             jtag_read_write;
wire [CHANNELS-1:0]             rcfg_emb_strm_read_write;

// Wires for converting between data widths
wire [CHANNELS*DATA_WIDTH-1:0]  expanded_avmm_readdata;
wire [CHANNELS*DATA_WIDTH-1:0]  expanded_avmm_writedata;

// Wires for control and status signals between the various masters
wire [CHANNELS-1:0]             odi_done;
wire [CHANNELS-1:0]             prbs_done_sync;
wire [CHANNELS*50-1:0]          prbs_err_count;
wire [CHANNELS*50-1:0]          prbs_bit_count;
wire [CHANNELS*50-1:0]          odi_err_count;
wire [CHANNELS*50-1:0]          odi_bit_count;


// Wires for qmap cleanup
wire lcl_g_arbiter_dis;
wire lcl_g_avmm_csr_dis;
wire lcl_ground;

// Warning Removal
assign lcl_g_avmm_csr_dis   = &{1'b0,
                                rcfg_emb_strm_busy,
                                prbs_done_sync,
                                odi_done,
                                prbs_err_count,
                                prbs_bit_count,
                                odi_bit_count,
                                odi_err_count};
assign lcl_g_arbiter_dis    = &{1'b0, 
                                rcfg_emb_strm_address, 
                                rcfg_emb_strm_writedata, 
                                odi_address, 
                                odi_writedata, 
                                split_jtag_address, 
                                split_jtag_writedata,
                                user_read_write,
                                odi_read_write,
                                jtag_read_write,
                                rcfg_emb_strm_read_write};
assign lcl_ground           = &{1'b0,
                                lcl_g_avmm_csr_dis,
                                lcl_g_arbiter_dis};

// Generate variable for channel numbers
genvar ig;


/**********************************************************************/
// Generate Statement for the Shared vs Split user interface
/**********************************************************************/
generate
  // Expand the AVMM signals from the channel to the 32-bit interface of the user
  for(ig=0;ig<CHANNELS;ig=ig+1) begin: g_expanded_avmm_signals
    assign  expanded_avmm_readdata [ig*DATA_WIDTH +: DATA_WIDTH] = {24'd0,chnl_readdata [ig*8 +: 8]};
    assign  avmm_writedata [ig*8 +: 8]                           = expanded_avmm_writedata   [ig*DATA_WIDTH +: 8];
  end


  /**********************************************************************/
  // Split the reconfig interface to the independent channel when using shared reconfig
  /**********************************************************************/
  if(!RECONFIG_SHARED) begin : g_not_shared
    // Signals are already split, so wire straight through
    assign avmm_clk                                             = reconfig_clk;
    assign avmm_reset                                           = reconfig_reset;

    assign split_user_write                                     = reconfig_write;
    assign split_user_read                                      = reconfig_read;
    assign split_user_address                                   = reconfig_address;
    assign split_user_writedata                                 = reconfig_writedata;
    assign reconfig_readdata                                    = expanded_avmm_readdata;
    assign reconfig_waitrequest                                 = ({CHANNELS{lcl_ground}} | split_user_waitrequest);

  // If we are using a shared interface
  end else begin : g_shared
    wire [CHANNEL_SEL_WIDTH-1:0]                                 rcfg_if_sel;

    // Generate interface select based on upper address bits
    assign rcfg_if_sel                                          = reconfig_address[ADDR_BITS+:CHANNEL_SEL_WIDTH];
    assign reconfig_readdata                                    = expanded_avmm_readdata[rcfg_if_sel*DATA_WIDTH +: DATA_WIDTH];
    assign reconfig_waitrequest                                 = split_user_waitrequest[rcfg_if_sel];

    for(ig=0;ig<CHANNELS;ig=ig+1) begin : g_shared
      // Split shared signals to independent channels
      assign avmm_clk             [ig]                          = reconfig_clk;
      assign avmm_reset           [ig]                          = reconfig_reset;

      assign split_user_write     [ig]                          = reconfig_write & (rcfg_if_sel == ig) | lcl_ground;
      assign split_user_read      [ig]                          = reconfig_read  & (rcfg_if_sel == ig);
      assign split_user_address   [ig*ADDR_BITS +: ADDR_BITS]   = reconfig_address[0+:ADDR_BITS];
      assign split_user_writedata [ig*DATA_WIDTH +: DATA_WIDTH] = reconfig_writedata;
    end
  end //End g_not_shared
endgenerate


/**********************************************************************/
// Embedded JTAG Debug Master (ADME)
/**********************************************************************/
generate if(JTAG_ENABLED) begin : g_jtag

    // Set the slave type for the ADME.  Since the span needs to be a string, 2^(total addr_bits) will
    // give the max value, however since the adme uses byte alignment, shift the span by two bits.
    localparam set_slave_span = altera_xcvr_native_s10_functions_h::int2str_alt_xcvr_native_s10(2**(ADDR_BITS+CHANNEL_SEL_WIDTH+2));
    localparam set_slave_map  = {"{typeName ",ADME_SLAVE_MAP," address 0x0 span ",set_slave_span," hpath {}",ADME_ASSGN_MAP,"}"};

    // Raw JTAG signals
    wire                                     jtag_write;
    wire                                     jtag_read;
    wire [(ADDR_BITS+CHANNEL_SEL_WIDTH)-1:0] jtag_address;
    wire [DATA_WIDTH-1:0]                    jtag_writedata;
    wire [DATA_WIDTH-1:0]                    jtag_readdata;
    wire                                     jtag_waitrequest;
    wire [CHANNEL_SEL_WIDTH-1:0]             jtag_if_sel;

    // Generate channel select based on upper address bits
    assign jtag_if_sel                                          = jtag_address[ADDR_BITS+:CHANNEL_SEL_WIDTH];
    assign jtag_readdata                                        = expanded_avmm_readdata[jtag_if_sel*DATA_WIDTH +: DATA_WIDTH];
    assign jtag_waitrequest                                     = split_jtag_waitrequest[jtag_if_sel];

    // Split shared signals to independent channels
    for(ig=0;ig<CHANNELS;ig=ig+1) begin: g_expanded_avmm_signals
      assign split_jtag_write     [ig]                          = jtag_write & (jtag_if_sel == ig);
      assign split_jtag_read      [ig]                          = jtag_read  & (jtag_if_sel == ig);
      assign split_jtag_address   [ig*ADDR_BITS +: ADDR_BITS]   = jtag_address[0+:ADDR_BITS];
      assign split_jtag_writedata [ig*DATA_WIDTH +: DATA_WIDTH] = jtag_writedata[DATA_WIDTH-1:0];
    end

    // When doing RTL sims, remove the altera_debug_master_endpoint, as 
    // there is no RTL simulation model.  Pre and Post Fit sims are ok.
    `ifdef ALTERA_RESERVED_QIS
      altera_debug_master_endpoint
      #(
        .ADDR_WIDTH                            ( (ADDR_BITS+CHANNEL_SEL_WIDTH) ),
        .DATA_WIDTH                            ( DATA_WIDTH                    ),
        .HAS_RDV                               ( 0                             ),
        .SLAVE_MAP                             ( set_slave_map                 ),
        .PREFER_HOST                           ( " "                           ),
        .CLOCK_RATE_CLK                        ( 0                             )
      ) adme (
        .clk                                   ( reconfig_clk                  ),
        .reset                                 ( reconfig_reset                ),
        .master_write                          ( jtag_write                    ),
        .master_read                           ( jtag_read                     ),
        .master_address                        ( jtag_address                  ),
        .master_writedata                      ( jtag_writedata                ),
        .master_waitrequest                    ( jtag_waitrequest              ),
        .master_readdatavalid                  ( 1'b0                          ),
        .master_readdata                       ( jtag_readdata                 )
      );
    `else
      assign jtag_write                         = 1'b0;
      assign jtag_read                          = 1'b0;
      assign jtag_address                       = {(ADDR_BITS+CHANNEL_SEL_WIDTH){1'b0}};
      assign jtag_writedata                     = {DATA_WIDTH{1'b0}};
    `endif

  // If we have not enabled the ADME
  end else begin : g_jtag_disable
    assign split_jtag_write                     = {CHANNELS{1'b0}};
    assign split_jtag_read                      = {CHANNELS{1'b0}};
    assign split_jtag_address                   = {(CHANNELS*ADDR_BITS){1'b0}};
    assign split_jtag_writedata                 = {(CHANNELS*DATA_WIDTH){1'b0}};
  end 
endgenerate // End g_jtag


/**********************************************************************/
// Embedded Reconfig Streamer
/**********************************************************************/
generate if(RCFG_EMB_STRM_ENABLED) begin : g_rcfg_strm_enable //TODO check to see if there is parameter redundancy

      alt_xcvr_native_rcfg_strm_top_qufrg4q #(
        .xcvr_rcfg_interfaces                  ( CHANNELS                        ),
        .xcvr_rcfg_addr_width                  ( ADDR_BITS                       ),
        .xcvr_rcfg_data_width                  ( DATA_WIDTH                      ),
        .rcfg_profile_cnt                      ( RCFG_PROFILE_CNT                )
      )rcfg_strm_top_inst(
        .clk                                   ( reconfig_clk[0]                 ), // All clock bits should be driven by the same source if using independent interface
        .reset                                 ( |reconfig_reset                 ), // Any reset bit will reset the reconfig streamer
        .cfg_sel                               ( rcfg_emb_strm_cfg_sel           ),
        .bcast_en                              ( rcfg_emb_strm_bcast_en          ),
        .cfg_load                              ( rcfg_emb_strm_cfg_load          ),
        .chan_sel                              ( rcfg_emb_strm_chan_sel          ),
        .stream_busy                           ( rcfg_emb_strm_busy              ),
        .xcvr_reconfig_write                   ( rcfg_emb_strm_write             ),
        .xcvr_reconfig_read                    ( rcfg_emb_strm_read              ),
        .xcvr_reconfig_address                 ( rcfg_emb_strm_address           ),
        .xcvr_reconfig_writedata               ( rcfg_emb_strm_writedata         ),
        .xcvr_reconfig_readdata                ( expanded_avmm_readdata          ),
        .xcvr_reconfig_waitrequest             ( rcfg_emb_strm_waitrequest       )
      );

    // If we disable the reconfig streamer
    end else begin: g_rcfg_strm_disable
      assign  rcfg_emb_strm_write               = {CHANNELS{1'b0}};
      assign  rcfg_emb_strm_read                = {CHANNELS{1'b0}};
      assign  rcfg_emb_strm_address             = {(CHANNELS*ADDR_BITS){1'b0}};
      assign  rcfg_emb_strm_writedata           = {CHANNELS{32'b0}};
      assign  rcfg_emb_strm_chan_sel            = {CHANNELS{1'b0}};
      assign  rcfg_emb_strm_busy                = {CHANNELS{1'b0}};
  end
endgenerate // End g_rcfg_strm_enable


/**********************************************************************/
//  PIPE EIOS RX Protection Soft IP; 
/**********************************************************************/
generate if (enable_eios_rx_protect) begin: g_eios_rp_enable

  // Raw PIPE EIOS Rx Protect signals
  wire [ADDR_BITS+CHANNEL_SEL_WIDTH-1:0]   eios_rp_address;
  wire [CHANNEL_SEL_WIDTH-1:0]             eios_rp_if_sel;
  wire [DATA_WIDTH-1:0]                    eios_rp_writedata;
  wire [DATA_WIDTH-1:0]                    eios_rp_readdata;   
  wire                                     eios_rp_write;
  wire                                     eios_rp_read;
  wire                                     eios_rp_waitrequest;

    // Generate channel select based on upper address bits
    assign eios_rp_if_sel                                       = eios_rp_address[ADDR_BITS+:CHANNEL_SEL_WIDTH];
    assign eios_rp_readdata                                     = expanded_avmm_readdata[eios_rp_if_sel*DATA_WIDTH +: DATA_WIDTH];
    assign eios_rp_waitrequest                                  = odi_waitrequest[eios_rp_if_sel];

    // Split shared signals to independent channels
    for(ig=0;ig<CHANNELS;ig=ig+1) begin: g_expanded_avmm_signals
      assign odi_write     [ig]                          = eios_rp_write & (eios_rp_if_sel == ig);
      assign odi_read      [ig]                          = eios_rp_read  & (eios_rp_if_sel == ig);
      assign odi_address   [ig*ADDR_BITS +: ADDR_BITS]   = eios_rp_address[0+:ADDR_BITS];
      assign odi_writedata [ig*DATA_WIDTH +: DATA_WIDTH] = eios_rp_writedata[DATA_WIDTH-1:0];
    end

  alt_xcvr_pcie_rx_eios_prot # (
    .BONDED_MASTER_CHANNEL               (  pcs_aib_bonding_master ),
    .LANES                               (  CHANNELS  ) 
    )  pcie_rx_eios_prot_inst   ( 
    .clk                                  (  pipe_clk ),  // pipe and mac interface, clock
    .nreset                               (  pipe_rstn ), // active low reset
    .current_rate						  (  pipe_rate ),
    .eios_rx_prot_req                     (  eios_rx_prot_req ),

    .pld_pmaif_mask_tx_pll                (  pld_pmaif_mask_tx_pll  ),  //exported from PHY
    .pcie_ctrl_testbus_b10                (  pcie_ctrl_testbus_b10  ),  

    .xcvr_reconfig_clk                    (  reconfig_clk[0]  ),  //user and phy reconfig interface
    .xcvr_reconfig_reset                  (  reconfig_reset[0]  ),
    .xcvr_reconfig_address                (  eios_rp_address   ),   
    .xcvr_reconfig_writedata              (  eios_rp_writedata ),    
    .xcvr_reconfig_readdata               (  eios_rp_readdata  ),     
    .xcvr_reconfig_write                  (  eios_rp_write ), 
    .xcvr_reconfig_read                   (  eios_rp_read ),
    .xcvr_reconfig_waitrequest            (  eios_rp_waitrequest )
  );
  end else begin: g_eios_rp_disable
    assign  odi_address           = {  (CHANNELS*ADDR_BITS){1'b0} };
    assign  odi_writedata         = {  (CHANNELS*DATA_WIDTH){1'b0}  };
    assign  odi_write             = {  CHANNELS{1'b0}  };
    assign  odi_read              = {  CHANNELS{1'b0}  };
  end
endgenerate // End g_eios_rp




/**********************************************************************/
// AVMM Master read/write signals.
/**********************************************************************/
assign user_read_write          = split_user_read    | split_user_write;       // Bits asserted for corresponding channels from/to which user avmm is currently reading/writing
assign jtag_read_write          = split_jtag_read    | split_jtag_write;       // Bits asserted for corresponding channels from/to which jtag is currently reading/writing
assign rcfg_emb_strm_read_write = rcfg_emb_strm_read | rcfg_emb_strm_write; // Bits asserted for corresponding channels from/to which embedded streamer is currently reading/writing
assign odi_read_write           = odi_read           | odi_write;

/**********************************************************************/
// AVMM Arbiter.  Instantiated once per channel, however to handle streaming
// broadcast, the channel-wise instantiation is handled within the arbiter.
/**********************************************************************/
generate if (ENABLED_JTAG_MASTERS > 1) begin: g_arbiber_enable
    alt_xcvr_native_rcfg_arb #(
      .total_masters                                 ( 4                         ),
      .channels                                      ( CHANNELS                  ),
      .address_width                                 ( ADDR_BITS                 ),
      .data_width                                    ( DATA_WIDTH                )
    ) alt_xcvr_rcfg_arb (
      // Basic AVMM inputs 
      .reconfig_clk                                  ( avmm_clk                  ), 
      .reconfig_reset                                ( avmm_reset                ), 

      // User AVMM input
      .user_read                                     ( split_user_read           ),
      .user_write                                    ( split_user_write          ),
      .user_address                                  ( split_user_address        ),
      .user_writedata                                ( split_user_writedata      ),
      .user_read_write                               ( user_read_write           ),
      .user_waitrequest                              ( split_user_waitrequest    ),
     
      // Reconfig Steamer AVMM input
      .strm_read                                     ( rcfg_emb_strm_read        ),
      .strm_write                                    ( rcfg_emb_strm_write       ),
      .strm_address                                  ( rcfg_emb_strm_address     ),
      .strm_writedata                                ( rcfg_emb_strm_writedata   ),
      .strm_read_write                               ( rcfg_emb_strm_read_write  ),
      .strm_waitrequest                              ( rcfg_emb_strm_waitrequest ),
     
      // ODI AVMM input
      .odi_read                                      ( odi_read                  ),
      .odi_write                                     ( odi_write                 ),
      .odi_address                                   ( odi_address               ),
      .odi_writedata                                 ( odi_writedata             ),
      .odi_read_write                                ( odi_read_write            ),
      .odi_waitrequest                               ( odi_waitrequest           ),
     
      // ADME AVMM input
      .jtag_read                                     ( split_jtag_read           ),
      .jtag_write                                    ( split_jtag_write          ),
      .jtag_address                                  ( split_jtag_address        ),
      .jtag_writedata                                ( split_jtag_writedata      ),
      .jtag_read_write                               ( jtag_read_write           ),
      .jtag_waitrequest                              ( split_jtag_waitrequest    ),
     
      // AVMM output the channel and the CSR
      .avmm_waitrequest                              ( chnl_waitrequest          ),
      .avmm_read                                     ( chnl_read                 ),
      .avmm_write                                    ( chnl_write                ),
      .avmm_address                                  ( avmm_address              ),
      .avmm_writedata                                ( expanded_avmm_writedata   )
    );
  end else begin: g_arbiter_disable
    // Pass through signals
    assign split_user_waitrequest                    = chnl_waitrequest;
    assign chnl_read                                 = split_user_read;
    assign chnl_write                                = split_user_write;
    assign expanded_avmm_writedata                   = split_user_writedata;
    assign avmm_address                              = split_user_address;

  end
endgenerate // End g_arbiter


/**********************************************************************/
// Per Channel instantiations and assignments
/**********************************************************************/
generate for(ig=0;ig<CHANNELS;ig=ig+1) begin: g_optional_chnl_reconfig_logic

wire [CHANNELS-1:0]             csr_prbs_snapshot;
wire [CHANNELS-1:0]             csr_prbs_count_en;
wire [CHANNELS-1:0]             csr_odi_count_en;
wire [CHANNELS-1:0]             csr_odi_snap;
wire [CHANNELS-1:0]             csr_odi_reset;

    /**********************************************************************/
    // Instantiate the Soft CSR
    /**********************************************************************/
    if(dbg_embedded_debug_enable) begin: g_avmm_csr_enabled

      // Instantiate wires as part of generate to avoid warnings about unused wires.
      // AVMM reconfiguration signals for embedded debug
      wire [CHANNELS-1:0]             debug_write;
      wire [CHANNELS-1:0]             debug_read;
      wire [CHANNELS-1:0]             debug_waitrequest;
      wire [CHANNELS*8-1:0]           debug_readdata;
      
      // avmm arbitration for soft csr and channel
      assign debug_read       [ig]      = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? chnl_read          [ig]      : 1'b0;
      assign debug_write      [ig]      = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? chnl_write         [ig]      : 1'b0;
      assign avmm_read        [ig]      = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? 1'b0                         : chnl_read         [ig];
      assign avmm_write       [ig]      = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? 1'b0                         : chnl_write        [ig];
      assign chnl_waitrequest [ig]      = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? debug_waitrequest  [ig]      : avmm_waitrequest  [ig];
      assign chnl_readdata    [ig*8+:8] = (avmm_address[ig*ADDR_BITS+AVMM_OFFSET]) ? debug_readdata     [ig*8+:8] : avmm_readdata     [ig*8+:8];


      alt_xcvr_native_avmm_csr #(
        .channels                            ( CHANNELS                            ),
        .channel_num                         ( ig                                  ),
	.addr_width		             ( AVMM_OFFSET			   ),
        .dbg_user_identifier                 ( dbg_user_identifier                 ),
        .duplex_mode                         ( duplex_mode                         ),
        .dbg_capability_reg_enable           ( dbg_capability_reg_enable           ),
        .dbg_prbs_soft_logic_enable          ( dbg_prbs_soft_logic_enable          ),
        .dbg_odi_soft_logic_enable           ( dbg_odi_soft_logic_enable           ),
        .dbg_stat_soft_logic_enable          ( dbg_stat_soft_logic_enable          ),
        .dbg_ctrl_soft_logic_enable          ( dbg_ctrl_soft_logic_enable          ),
        .rcfg_emb_strm_enable                ( RCFG_EMB_STRM_ENABLED               ),
        .rcfg_emb_strm_cfg_sel_width         ( RCFG_EMB_STRM_CFG_SEL_WIDTH         ),
	.enable_background_cal               ( enable_background_cal)
      ) embedded_debug_soft_csr (
        // avmm signals
        .avmm_clk                            ( avmm_clk                 [ig]       ),
        .avmm_reset                          ( avmm_reset               [ig]       ),
        .avmm_address                        ( avmm_address				[ig*ADDR_BITS+:AVMM_OFFSET] ),
        .avmm_writedata                      ( avmm_writedata           [ig*8+:8]  ),
        .avmm_write                          ( debug_write              [ig]       ),
        .avmm_read                           ( debug_read               [ig]       ),
        .avmm_readdata                       ( debug_readdata           [ig*8+:8]  ),
        .avmm_waitrequest                    ( debug_waitrequest        [ig]       ),

        // prbs control signals
        .prbs_err                            ( prbs_err_count           [ig*50+:50]),
        .prbs_bit                            ( prbs_bit_count           [ig*50+:50]),
        .prbs_done                           ( prbs_done_sync           [ig]       ),
        .prbs_snap                           ( csr_prbs_snapshot        [ig]       ),
        .prbs_count_en                       ( csr_prbs_count_en        [ig]       ),
        .prbs_reset                          ( out_prbs_err_clr         [ig]       ),

        // odi ctrl signals
        .odi_bit                             ( odi_bit_count            [ig*50+:50]),
        .odi_err                             ( odi_err_count            [ig*50+:50]),
        .odi_done                            ( odi_done                 [ig]       ),
        .odi_count_en                        ( csr_odi_count_en         [ig]       ),
        .odi_reset                           ( csr_odi_reset            [ig]       ),               
        .odi_snap                            ( csr_odi_snap             [ig]       ),

        // input status signals from the channel
        .rx_is_lockedtodata                  ( in_rx_is_lockedtodata    [ig]       ),
        .rx_is_lockedtoref                   ( in_rx_is_lockedtoref     [ig]       ),
        .tx_cal_busy                         ( in_tx_cal_busy           [ig]       ),
        .rx_cal_busy                         ( in_rx_cal_busy           [ig]       ),
        .avmm_busy                           ( in_avmm_busy             [ig]       ),
		.tx_transfer_ready					 ( in_tx_transfer_ready 	[ig]	   ),
		.rx_transfer_ready					 ( in_rx_transfer_ready 	[ig]	   ),

        // input control signals
        .rx_prbs_err_clr                     ( in_rx_prbs_err_clr       [ig]       ),
        .set_rx_locktoref                    ( in_set_rx_locktoref      [ig]       ),
        .set_rx_locktodata                   ( in_set_rx_locktodata     [ig]       ),
        .serial_loopback                     ( in_en_serial_lpbk        [ig]       ),
        .rx_analogreset                      ( in_rx_analogreset        [ig]       ),
        .rx_digitalreset                     ( in_rx_digitalreset       [ig]       ),		
        .tx_analogreset                      ( in_tx_analogreset        [ig]       ),
        .tx_digitalreset                     ( in_tx_digitalreset       [ig]       ),
		        
        // embedded reconfig signals
        .rcfg_emb_strm_busy                  ( rcfg_emb_strm_busy       [ig]       ),
        .rcfg_emb_strm_chan_sel              ( rcfg_emb_strm_chan_sel   [ig]       ),
        .rcfg_emb_strm_cfg_sel               ( rcfg_emb_strm_cfg_sel    [ig*RCFG_EMB_STRM_CFG_SEL_WIDTH+:RCFG_EMB_STRM_CFG_SEL_WIDTH]),
        .rcfg_emb_strm_bcast_en              ( rcfg_emb_strm_bcast_en   [ig]       ),
        .rcfg_emb_strm_cfg_load              ( rcfg_emb_strm_cfg_load   [ig]       ),


        // output control signals to the channel
        .csr_set_lock_to_data                ( out_set_rx_locktodata    [ig]       ),
        .csr_set_lock_to_ref                 ( out_set_rx_locktoref     [ig]       ),
        .csr_en_loopback                     ( out_en_serial_lpbk       [ig]       ),
        .csr_rx_analogreset                  ( out_rx_analogreset       [ig]       ),
        .csr_rx_digitalreset                 ( out_rx_digitalreset      [ig]       ),		
        .csr_tx_analogreset                  ( out_tx_analogreset       [ig]       ),
        .csr_tx_digitalreset                 ( out_tx_digitalreset      [ig]       ),		
        .csr_tx_cal_busy_mask                ( out_tx_cal_busy_mask     [ig]       ),
        .csr_rx_cal_busy_mask                ( out_rx_cal_busy_mask     [ig]       ),
	// output controls background calibration module
	.bg_cal_en				(bg_cal_en[ig])
      );

    end else begin: g_avmm_csr_disable
      // do a pass though for control signals when no embedded debug
      assign out_prbs_err_clr       [ig]  = in_rx_prbs_err_clr     [ig];
      assign out_set_rx_locktoref   [ig]  = in_set_rx_locktoref    [ig];
      assign out_set_rx_locktodata  [ig]  = in_set_rx_locktodata   [ig];
      assign out_en_serial_lpbk     [ig]  = in_en_serial_lpbk      [ig];
      assign out_rx_analogreset     [ig]  = in_rx_analogreset      [ig];
      assign out_rx_digitalreset    [ig]  = in_rx_digitalreset     [ig];	  
      assign out_tx_analogreset     [ig]  = in_tx_analogreset      [ig];
      assign out_tx_digitalreset    [ig]  = in_tx_digitalreset     [ig];	  
      assign out_tx_cal_busy_mask   [ig]  = 1'b1;
      assign out_rx_cal_busy_mask   [ig]  = 1'b1;

      // assign these signals to ground when no embedded debug
      assign avmm_read        [ig]        = chnl_read              [ig];
      assign avmm_write       [ig]        = chnl_write             [ig];
      assign chnl_waitrequest [ig]        = avmm_waitrequest       [ig];  
      assign chnl_readdata    [ig*8+:8]   = avmm_readdata          [ig*8+:8];
	// assing bg_cal_en to 1
      assign bg_cal_en 		[ig] 	= 1'b1;
    end


    /**********************************************************************/
    // Instantiate the PRBS accumulators
    /**********************************************************************/
    if(dbg_prbs_soft_logic_enable == 1) begin: g_prbs_accumulators_enable
      alt_xcvr_native_prbs_accum prbs_soft_accumulators (
        .avmm_clk                            ( avmm_clk           [ig]             ),
        .avmm_reset                          ( avmm_reset         [ig]             ),

        // Control signals from CSR
        .prbs_reset                          ( out_prbs_err_clr   [ig]             ),
        .prbs_snapshot                       ( csr_prbs_snapshot  [ig]             ),
        .prbs_counter_en                     ( csr_prbs_count_en  [ig]             ),

        // Status signals from PRBS
        .prbs_done_sync                      ( prbs_done_sync     [ig]             ),
        .prbs_err_count                      ( prbs_err_count     [ig*50+:50]      ),
        .prbs_bit_count                      ( prbs_bit_count     [ig*50+:50]      ),

        // Signals from the transceiver
        .rx_clkout                           ( in_rx_clkout       [ig]             ),
        .prbs_err_signal                     ( prbs_err_signal    [ig]             ),
        .prbs_done_signal                    ( prbs_done_signal   [ig]             )
      );

    // If PRBS is not enabled
    end else begin: g_prbs_accumulators_disable
      assign prbs_err_count[ig*50+:50]   = 50'b0;
      assign prbs_bit_count[ig*50+:50]   = 50'b0;
      assign prbs_done_sync[ig]          = 1'b0;
    end // End g_prbs_accumulators


    /**********************************************************************/
    // ODI accumulators feature dropped; the IP level avmm port is used for 
    // PCIe eios rx protection
    /**********************************************************************/
    if( 0 ) begin: g_odi_accelerator_enable
      alt_xcvr_native_odi_accel #(
        .DATA_WIDTH                          ( DATA_WIDTH                          ),
		.ADDR_WIDTH							 ( ADDR_BITS						   )
      ) odi_soft_accelerator (
        .avmm_clk                            ( avmm_clk          [ig]              ),
        .avmm_reset                          ( avmm_reset        [ig]              ),
        
        // AVMM signals to the transceiver
        .odi_read                            ( odi_read          [ig]              ),
        .odi_write                           ( odi_write         [ig]              ),
        .odi_address                         ( odi_address       [ig*ADDR_BITS+:ADDR_BITS] ),
        .odi_writedata                       ( odi_writedata     [ig*DATA_WIDTH+:DATA_WIDTH]),
        .odi_readdata                        ( avmm_readdata     [ig*8+:8]         ),
        .odi_waitrequest                     ( odi_waitrequest   [ig]              ),

        // Control signals from CSR
        .odi_count_en                        ( csr_odi_count_en  [ig]              ),
        .odi_snap                            ( csr_odi_snap      [ig]              ),
        .odi_reset                           ( csr_odi_reset     [ig]              ),

        // Status signals from ODI
        .odi_done                            ( odi_done          [ig]              ),
        .odi_bit_count                       ( odi_bit_count     [ig*50+:50]       ),
        .odi_err_count                       ( odi_err_count     [ig*50+:50]       )
      );

    end else begin: g_odi_accelerator_disable
//      assign odi_read[ig]                             = 1'b0;
//      assign odi_write[ig]                            = 1'b0;
      assign odi_done[ig]                             = 1'b0;
      assign odi_bit_count[ig*50+:50]                 = 50'b0;
      assign odi_err_count[ig*50+:50]                 = 50'b0;
//      assign odi_address[ig*ADDR_BITS+:ADDR_BITS]     = {ADDR_BITS{1'b0}};
//      assign odi_writedata[ig*DATA_WIDTH+:DATA_WIDTH] = {DATA_WIDTH{1'b0}};
    end // End g_odi_accelerator

  end // End for Loop for channels
endgenerate

endmodule

