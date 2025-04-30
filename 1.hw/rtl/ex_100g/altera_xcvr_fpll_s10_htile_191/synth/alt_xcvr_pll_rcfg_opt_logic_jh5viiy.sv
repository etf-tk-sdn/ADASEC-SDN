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

module alt_xcvr_pll_rcfg_opt_logic_jh5viiy #(
  // Parameters for the embedded reconfiguration logic
  parameter                                 dbg_user_identifier         = 0,
  parameter                                 dbg_embedded_debug_enable   = 0,
  parameter                                 dbg_capability_reg_enable   = 0,
  parameter                                 dbg_stat_soft_logic_enable  = 0,
  parameter                                 dbg_ctrl_soft_logic_enable  = 0,
  parameter                                 en_master_cgb               = 0,

  // Parameters for the AVMM masters and split interface
  parameter                                 INTERFACES                  = 1,
  parameter                                 RECONFIG_SHARED             = 0,
  parameter                                 JTAG_ENABLED                = 0,    // Can only be enabled when using a shared reconfig interface
  parameter                                 ADME_SLAVE_MAP              = "altera_xcvr_cdr_pll_s10",
  parameter                                 ADME_ASSGN_MAP              = " ",
  parameter                                 RCFG_EMB_STRM_ENABLED       = 0,    // Enable the embedded reconfiguration streamer logic
  parameter                                 RCFG_PROFILE_CNT            = 2,    // Number of configuration profiles for embedded streamer

  // The following are not intended to be directly set
  parameter                                 IFACES                      = RECONFIG_SHARED ? 1 : INTERFACES,
  parameter                                 ADDR_BITS                   = 11,
  parameter                                 SEL_BITS                    = (RECONFIG_SHARED ? altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(INTERFACES-1) : 0),
  parameter                                 DATA_WIDTH                  = 32

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

  // AVMM ports to transceiver Split by interface
  output [INTERFACES-1:0]                        avmm_clk,
  output [INTERFACES-1:0]                        avmm_reset,
  output [INTERFACES-1:0]                        avmm_write,
  output [INTERFACES-1:0]                        avmm_read,
  output [INTERFACES*ADDR_BITS-1:0]              avmm_address,
  output [INTERFACES*8-1:0]                      avmm_writedata,
  input  [INTERFACES*8-1:0]                      avmm_readdata,
  input  [INTERFACES-1:0]                        avmm_waitrequest,

  // input signals from the core
  input         in_pll_powerdown,
  input         in_pll_locked,
  input         in_pll_cal_busy,
  input         in_avmm_busy,
  
  // output signals to the ip
  output        out_pll_powerdown

);

/**********************************************************************/
// Per Instance instantiations and assignments
/**********************************************************************/
localparam INTERFACE_SEL_WIDTH = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(INTERFACES-1);
localparam ENABLED_JTAG_MASTERS = 1 + JTAG_ENABLED + RCFG_EMB_STRM_ENABLED;
localparam RCFG_EMB_STRM_CFG_SEL_WIDTH = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(RCFG_PROFILE_CNT-1);


// Raw rmbedded reconfig signals (always independent)
wire [INTERFACES-1:0]             rcfg_emb_strm_write;
wire [INTERFACES-1:0]             rcfg_emb_strm_read;
wire [INTERFACES*ADDR_BITS-1:0]   rcfg_emb_strm_address;
wire [INTERFACES*DATA_WIDTH-1:0]  rcfg_emb_strm_writedata;
wire [INTERFACES-1:0]             rcfg_emb_strm_waitrequest;

// User AVMM signals expanded to independent interfaces
wire [INTERFACES-1:0]             split_user_write;
wire [INTERFACES-1:0]             split_user_read;
wire [INTERFACES*ADDR_BITS-1:0]   split_user_address;
wire [INTERFACES*DATA_WIDTH-1:0]  split_user_writedata;
wire [INTERFACES-1:0]             split_user_waitrequest;

// JTAG signals expanded to independent interfaces
wire [INTERFACES-1:0]             split_jtag_write;
wire [INTERFACES-1:0]             split_jtag_read;
wire [INTERFACES*ADDR_BITS-1:0]   split_jtag_address;
wire [INTERFACES*DATA_WIDTH-1:0]  split_jtag_writedata;
wire [INTERFACES-1:0]             split_jtag_waitrequest;

// Additional arbitration signals for soft CSR
wire [INTERFACES-1:0]             chnl_write;
wire [INTERFACES-1:0]             chnl_read;
wire [INTERFACES-1:0]             chnl_busy;
wire [INTERFACES-1:0]             chnl_waitrequest;
wire [INTERFACES*8-1:0]           chnl_readdata;

// embedded reconfig signals
wire [INTERFACES-1:0]             rcfg_emb_strm_busy;
wire [INTERFACES-1:0]             rcfg_emb_strm_chan_sel;
wire [INTERFACES*RCFG_EMB_STRM_CFG_SEL_WIDTH-1:0]   rcfg_emb_strm_cfg_sel;
wire [INTERFACES-1:0]             rcfg_emb_strm_bcast_en;
wire [INTERFACES-1:0]             rcfg_emb_strm_cfg_load;

// Read_write signals to assist with prioritizing arbitrarion
wire [INTERFACES-1:0]             user_read_write;
wire [INTERFACES-1:0]             jtag_read_write;
wire [INTERFACES-1:0]             rcfg_emb_strm_read_write;

// Wires for converting between data widths
wire [INTERFACES*DATA_WIDTH-1:0]  expanded_avmm_readdata;
wire [INTERFACES*DATA_WIDTH-1:0]  expanded_avmm_writedata;


// Wires for qmap cleanup
wire lcl_g_arbiter_dis;
wire lcl_g_avmm_csr_dis;
wire lcl_ground;

// Warning Removal
assign lcl_g_avmm_csr_dis   = &{1'b0,
                                rcfg_emb_strm_busy};
assign lcl_g_arbiter_dis    = &{1'b0, 
                                rcfg_emb_strm_address, 
                                rcfg_emb_strm_writedata,
                                split_jtag_address, 
                                split_jtag_writedata,
                                user_read_write,
                                jtag_read_write,
                                rcfg_emb_strm_read_write};
assign lcl_ground           = &{1'b0,
                                lcl_g_avmm_csr_dis,
                                lcl_g_arbiter_dis};

// Generate variable for interface numbers
genvar ig;


/**********************************************************************/
// Generate Statement for the Shared vs Split user interface
/**********************************************************************/
generate
  // Expand the AVMM signals from the interface to the 32-bit interface of the user
  for(ig=0;ig<INTERFACES;ig=ig+1) begin: g_expanded_avmm_signals
    assign  expanded_avmm_readdata [ig*DATA_WIDTH +: DATA_WIDTH] = {24'd0,chnl_readdata [ig*8 +: 8]};
    assign  avmm_writedata [ig*8 +: 8]                           = expanded_avmm_writedata   [ig*DATA_WIDTH +: 8];
  end


  /**********************************************************************/
  // Split the reconfig interface to the independent interface when using shared reconfig
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
    assign reconfig_waitrequest                                 = ({INTERFACES{lcl_ground}} | split_user_waitrequest);

  // If we are using a shared interface
  end else begin : g_shared
    wire [INTERFACE_SEL_WIDTH-1:0]                                 rcfg_if_sel;

    // Generate interface select based on upper address bits
    assign rcfg_if_sel                                          = reconfig_address[ADDR_BITS+:INTERFACE_SEL_WIDTH];
    assign reconfig_readdata                                    = expanded_avmm_readdata[rcfg_if_sel*DATA_WIDTH +: DATA_WIDTH];
    assign reconfig_waitrequest                                 = split_user_waitrequest[rcfg_if_sel];

    for(ig=0;ig<INTERFACES;ig=ig+1) begin : g_shared
      // Split shared signals to independent interfaces
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
    localparam set_slave_span = altera_xcvr_native_s10_functions_h::int2str_alt_xcvr_native_s10(2**(ADDR_BITS+INTERFACE_SEL_WIDTH+2));
    localparam set_slave_map  = {"{typeName ",ADME_SLAVE_MAP," address 0x0 span ",set_slave_span," hpath {}",ADME_ASSGN_MAP,"}"};

    // Raw JTAG signals
    wire                                     jtag_write;
    wire                                     jtag_read;
    wire [(ADDR_BITS+INTERFACE_SEL_WIDTH)-1:0] jtag_address;
    wire [DATA_WIDTH-1:0]                    jtag_writedata;
    wire [DATA_WIDTH-1:0]                    jtag_readdata;
    wire                                     jtag_waitrequest;
    wire [INTERFACE_SEL_WIDTH-1:0]             jtag_if_sel;

    // Generate interface select based on upper address bits
    assign jtag_if_sel                                          = jtag_address[ADDR_BITS+:INTERFACE_SEL_WIDTH];
    assign jtag_readdata                                        = expanded_avmm_readdata[jtag_if_sel*DATA_WIDTH +: DATA_WIDTH];
    assign jtag_waitrequest                                     = split_jtag_waitrequest[jtag_if_sel];

    // Split shared signals to independent interface
    for(ig=0;ig<INTERFACES;ig=ig+1) begin: g_expanded_avmm_signals
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
        .ADDR_WIDTH                            ( (ADDR_BITS+INTERFACE_SEL_WIDTH) ),
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
      assign jtag_address                       = {(ADDR_BITS+INTERFACE_SEL_WIDTH){1'b0}};
      assign jtag_writedata                     = {DATA_WIDTH{1'b0}};
    `endif

  // If we have not enabled the ADME
  end else begin : g_jtag_disable
    assign split_jtag_write                     = {INTERFACES{1'b0}};
    assign split_jtag_read                      = {INTERFACES{1'b0}};
    assign split_jtag_address                   = {(INTERFACES*ADDR_BITS){1'b0}};
    assign split_jtag_writedata                 = {(INTERFACES*DATA_WIDTH){1'b0}};
  end 
endgenerate // End g_jtag


/**********************************************************************/
// Embedded Reconfig Streamer
/**********************************************************************/
generate if(RCFG_EMB_STRM_ENABLED) begin : g_rcfg_strm_enable //TODO check to see if there is parameter redundancy

      alt_xcvr_native_rcfg_strm_top_jh5viiy #(
        .xcvr_rcfg_interfaces                  ( INTERFACES                      ),
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
      assign  rcfg_emb_strm_write               = {INTERFACES{1'b0}};
      assign  rcfg_emb_strm_read                = {INTERFACES{1'b0}};
      assign  rcfg_emb_strm_address             = {(INTERFACES*ADDR_BITS){1'b0}};
      assign  rcfg_emb_strm_writedata           = {INTERFACES{32'b0}};
      assign  rcfg_emb_strm_chan_sel            = {INTERFACES{1'b0}};
      assign  rcfg_emb_strm_busy                = {INTERFACES{1'b0}};
  end
endgenerate // End g_rcfg_strm_enable


/**********************************************************************/
// AVMM Master read/write signals.
/**********************************************************************/
assign user_read_write          = split_user_read    | split_user_write;       // Bits asserted for corresponding interfaces from/to which user avmm is currently reading/writing
assign jtag_read_write          = split_jtag_read    | split_jtag_write;       // Bits asserted for corresponding interfaces from/to which jtag is currently reading/writing
assign rcfg_emb_strm_read_write = rcfg_emb_strm_read | rcfg_emb_strm_write; // Bits asserted for corresponding interfaces from/to which embedded streamer is currently reading/writing


/**********************************************************************/
// AVMM Arbiter.  Instantiated once per interface, however to handle streaming
// broadcast, the interface-wise instantiation is handled within the arbiter.
/**********************************************************************/
generate if (ENABLED_JTAG_MASTERS > 1) begin: g_arbiter_enable
    alt_xcvr_pll_rcfg_arb #(
      .total_masters                                 ( 3                         ),
      .interfaces                                    ( INTERFACES                ),
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
     
      // ADME AVMM input
      .jtag_read                                     ( split_jtag_read           ),
      .jtag_write                                    ( split_jtag_write          ),
      .jtag_address                                  ( split_jtag_address        ),
      .jtag_writedata                                ( split_jtag_writedata      ),
      .jtag_read_write                               ( jtag_read_write           ),
      .jtag_waitrequest                              ( split_jtag_waitrequest    ),
     
      // AVMM output to the interface and the CSR
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
// Per interface instantiations and assignments
/**********************************************************************/
//This local parameter differentiates potential usage of different widths
// for AVMM1 vs. AVMM2 interfaces
localparam CSR_DECODE_BIT = (ADDR_BITS == 11) ? 10 : 9;

generate for(ig=0;ig<INTERFACES;ig=ig+1) begin: g_optional_chnl_reconfig_logic

    /**********************************************************************/
    // Instantiate the Soft CSR
    /**********************************************************************/
    if(dbg_embedded_debug_enable) begin: g_avmm_csr_enabled

      // Instantiate wires as part of generate to avoid warnings about unused wires.
      // AVMM reconfiguration signals for embedded debug
      wire [INTERFACES-1:0]             debug_write;
      wire [INTERFACES-1:0]             debug_read;
      wire [INTERFACES-1:0]             debug_waitrequest;
      wire [INTERFACES*8-1:0]           debug_readdata;
      
      // avmm arbitration for soft csr and interface
      assign debug_read       [ig]      = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? chnl_read          [ig]      : 1'b0;
      assign debug_write      [ig]      = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? chnl_write         [ig]      : 1'b0;
      assign avmm_read        [ig]      = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? 1'b0                         : chnl_read         [ig];
      assign avmm_write       [ig]      = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? 1'b0                         : chnl_write        [ig];
      assign chnl_waitrequest [ig]      = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? debug_waitrequest  [ig]      : avmm_waitrequest  [ig];
      assign chnl_readdata    [ig*8+:8] = (avmm_address[ig*ADDR_BITS+CSR_DECODE_BIT]) ? debug_readdata     [ig*8+:8] : avmm_readdata     [ig*8+:8];


      alt_xcvr_pll_avmm_csr #(
        .dbg_capability_reg_enable           ( dbg_capability_reg_enable           ),
        .dbg_user_identifier                 ( dbg_user_identifier                 ),
        .dbg_stat_soft_logic_enable          ( dbg_stat_soft_logic_enable          ),
        .dbg_ctrl_soft_logic_enable          ( dbg_ctrl_soft_logic_enable          ),
        .en_master_cgb                       ( en_master_cgb                       ),
        .rcfg_emb_strm_enable                ( RCFG_EMB_STRM_ENABLED               ),
        .rcfg_emb_strm_cfg_sel_width         ( RCFG_EMB_STRM_CFG_SEL_WIDTH         )
      ) embedded_debug_soft_csr (
        // avmm signals
        .avmm_clk                            ( avmm_clk                 [ig]       ),
        .avmm_reset                          ( avmm_reset               [ig]       ),
        .avmm_address                        ( avmm_address      [ig*ADDR_BITS+:9] ),
        .avmm_writedata                      ( avmm_writedata           [ig*8+:8]  ),
        .avmm_write                          ( debug_write              [ig]       ),
        .avmm_read                           ( debug_read               [ig]       ),
        .avmm_readdata                       ( debug_readdata           [ig*8+:8]  ),
        .avmm_waitrequest                    ( debug_waitrequest        [ig]       ),

        // input status signals from the interface
        .pll_powerdown                       (in_pll_powerdown),
        .pll_locked                          (in_pll_locked),
        .pll_cal_busy                        (in_pll_cal_busy),
        .avmm_busy                           (in_avmm_busy),

        // embedded reconfig signals
        .rcfg_emb_strm_busy                  ( rcfg_emb_strm_busy       [ig]       ),
        .rcfg_emb_strm_chan_sel              ( rcfg_emb_strm_chan_sel   [ig]       ),
        .rcfg_emb_strm_cfg_sel               ( rcfg_emb_strm_cfg_sel    [ig*RCFG_EMB_STRM_CFG_SEL_WIDTH+:RCFG_EMB_STRM_CFG_SEL_WIDTH]),
        .rcfg_emb_strm_bcast_en              ( rcfg_emb_strm_bcast_en   [ig]       ),
        .rcfg_emb_strm_cfg_load              ( rcfg_emb_strm_cfg_load   [ig]       ),


         // output control signals
         .csr_pll_powerdown                   (out_pll_powerdown)
      );

    end else begin: g_avmm_csr_disable
      // do a pass though for control signals when no embedded debug
      assign out_pll_powerdown = in_pll_powerdown;

      // assign these signals to ground when no embedded debug
      assign avmm_read        [ig]        = chnl_read              [ig];
      assign avmm_write       [ig]        = chnl_write             [ig];
      assign chnl_waitrequest [ig]        = avmm_waitrequest       [ig];  
      assign chnl_readdata    [ig*8+:8]   = avmm_readdata          [ig*8+:8];
    end

  end // End for Loop for interfaces
endgenerate

endmodule

