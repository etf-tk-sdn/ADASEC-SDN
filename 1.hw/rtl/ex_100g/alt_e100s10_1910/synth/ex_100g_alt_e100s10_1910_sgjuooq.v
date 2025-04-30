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


`timescale 1ps/1ps

// top level file for S10 100G Ethernet IP

module ex_100g_alt_e100s10_1910_sgjuooq #( 
parameter   device_revision       = "14nm5bcr2eb",             // Stratix 10
parameter   TARGET_CHIP           = 2,             // Stratix 10
parameter   SIM_EMULATE           = 1'b0,
parameter   SIM_SHORT_AM          = 1'b0,
parameter   EXT_TX_PLL            = 1'b1,           // unused
parameter   RX_PLL_TYPE           = "FPLL",
parameter   TX_PLL_TYPE           = "FPLL",
parameter   TX_IOPLL_REFCLK       = 1,
parameter   TX_PLL_LOCAT          = 0,
parameter   PHY_REFCLK            = 1,            // unused 
parameter   SYNOPT_FLOW_CONTROL   = 0,
parameter   SYNOPT_NUMPRIORITY    = 1,
parameter   SYNOPT_PREAMBLE_PASS  = 1, 
parameter   SYNOPT_MAC_STATS_COUNTERS = 1,
parameter   SYNOPT_TXCRC_INS      = 1,
parameter   SYNOPT_READY_LATENCY  = 0,          // undecided?
parameter   SYNOPT_STRICT_SOP     = 0,
parameter   STATUS_CLK_KHZ        = 100000,     // clock status rate in KHz
// PARAMETER ENABLE_ADME          = 0           // undecided
parameter   ELI_ENABLE            = 0,
parameter   SYNOPT_C4_RSFEC       = 1,
parameter   SYNOPT_AVALON         = 1,
parameter   SYNOPT_ALIGN_FCSEOP   = 0,      // ?? 
parameter   REVID                 = 32'h08092017,
parameter   BASE_PHY              = 1,
parameter   BASE_TXMAC            = 4,
parameter   BASE_RXMAC            = 5,
parameter   BASE_TXFEC            = 12,
parameter   BASE_RXFEC            = 13,
parameter   SYNOPT_LINK_FAULT     = 1,	//0,
parameter   SYNOPT_AVG_IPG        = 12,
parameter   SYNOPT_MAC_DIC        = 1,
parameter   SYNOPT_PTP            = 0,
parameter   SYNOPT_TOD_FMT        = 0,
parameter   PTP_LATENCY           = 52,
parameter   PTP_FP_WIDTH          = 16,   //   width   of   fingerprint,   ptp   parameter
parameter   PMA_WORD_SIZE         = 66,
parameter   FEC_AM_BITS           = 14,   //for simulation purpose, to make am bit space short 
parameter   ADDRSIZE              = 8,   
parameter   WORDS                 = 4,
// AN/LT Parameters
parameter  ENABLE_ANLT            = 0,
parameter  SYNTH_AN               = 1,
parameter  LINK_TIMER_KR          = 504,
parameter  AN_TECH                = 0,
parameter  E25_TECH               = 256,
parameter  AN_CHAN                = 1,
parameter  AN_PAUSE               = 2,
parameter  SYNTH_LT               = 1,
parameter  VMAXRULE               = 30,
parameter  VMINRULE               = 6,
parameter  VODMINRULE             = 14,
parameter  VPOSTRULE              = 25,
parameter  VPRERULE               = 16,
parameter  PREMAINVAL             = 30,
parameter  PREPOSTVAL             = 0,
parameter  PREPREVAL              = 0,
parameter  INITMAINVAL            = 25,
parameter  INITPOSTVAL            = 13,
parameter  INITPREVAL             = 3,
parameter  TRNWTWIDTH             = 7,
parameter  CL72_PRBS              = 0,
parameter  SYNOPT_C4_RSFEC_DYN    = 0,
parameter  USE_DEBUG_CPU          = 0
) (

//  clock and resets

output              clk_txmac,
output              clk_rxmac,
input               clk_ref,
input   [1:0]       tx_serial_clk,
input               tx_rst_n,
input               rx_rst_n,
input               csr_rst_n,

input   [1:0]       tx_pll_locked,
output              tx_lanes_stable,
output              rx_pcs_ready,
output              rx_block_lock,      
output              rx_am_lock,     

// avalon tx interface
input               l8_tx_startofpacket,
input               l8_tx_endofpacket,
input               l8_tx_valid,
output              l8_tx_ready,
input   [5:0]       l8_tx_empty,
input   [8*64-1:0]  l8_tx_data,
input               l8_tx_error,

output              l8_txstatus_valid,
output  [39:0]      l8_txstatus_data,
output  [6:0]       l8_txstatus_error,

// avalon rx interface
output              l8_rx_startofpacket,
output              l8_rx_endofpacket,
output              l8_rx_valid,
output  [5:0]       l8_rx_empty,   
output[ 8*64-1:0]   l8_rx_data,

output              l8_rxstatus_valid,
output  [39:0]      l8_rxstatus_data,
output  [5:0]       l8_rx_error,

// Flow control interface
input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx0,
input  [SYNOPT_NUMPRIORITY-1:0] pause_insert_tx1,
output [SYNOPT_NUMPRIORITY-1:0] pause_receive_rx,

// Link fault interface
output			remote_fault_status,
output			local_fault_status,

// CSR interface
input               clk_status,
input   [15:0]      status_addr,
input               status_read,
input               status_write,
output  [31:0]      status_readdata,
output              status_readdata_valid,
input   [31:0]      status_writedata,
output              status_waitrequest,

// reconfig interface

input               reconfig_clk,                // reconfig_clk.clk
input               reconfig_reset,              // reconfig_reset.reset
input               reconfig_write,              // reconfig_avmm.write
input               reconfig_read,               // .read
input  wire [12:0]  reconfig_address,           // .address
input  wire [31:0]  reconfig_writedata,         // .writedata
output wire [31:0]  reconfig_readdata,          // .readdata
output              reconfig_waitrequest,       // .waitrequest

// HSSI Interface
output  [3:0]       tx_serial,
input   [3:0]       rx_serial,

// PCS
output tx_clk_locked,
output rx_clk_locked,


// MII TX
output                 tx_mii_stall,
input  [WORDS*8-1:0]   tx_mii_c,
input  [WORDS*64-1:0]  tx_mii_d,
input                  tx_mii_valid,
output                 clk_txmac_mii,
// MII RX
output                 rx_mii_valid,
output [4*64-1:0]      rx_mii_d,
output [4*8-1:0]       rx_mii_c,
output                 clk_rxmac_mii,
//MAC TESTING    
output                 tx_am_pcs,
output                 rxpcs_fully_aligned,
output                 tx_mac_sclr,
output                 rx_mac_sclr,
output                 o_csr_reset,

output [7:0]           avmm_addr,
output [32-1:0]        avmm_din,

input  [32-1:0]        avmm_mac_rx_dout,
input                  avmm_mac_rx_dval,
output                 avmm_mac_rx_write,
output                 avmm_mac_rx_read,

input  [32-1:0]        avmm_mac_tx_dout,
input                  avmm_mac_tx_dval,
output                 avmm_mac_tx_write,
output                 avmm_mac_tx_read,    
input  [32-1:0]        avmm_fc_tx_dout,
input                  avmm_fc_tx_dval,
output                 avmm_fc_tx_write,
output                 avmm_fc_tx_read,

input  [32-1:0]        avmm_fc_rx_dout,
input                  avmm_fc_rx_dval,
output                 avmm_fc_rx_write,
output                 avmm_fc_rx_read,

input  [32-1:0]        avmm_mac_tx_stats_dout,
input                  avmm_mac_tx_stats_dval,
output                 avmm_mac_tx_stats_write,
output                 avmm_mac_tx_stats_read,
input  [32-1:0]        avmm_mac_rx_stats_dout,
input                  avmm_mac_rx_stats_dval,
output                 avmm_mac_rx_stats_write,
output                 avmm_mac_rx_stats_read

);

localparam DEVREV = "REVB";

wire    [4*66-1:0]  tx_parallel_data_e100s10; 
wire    [4*66-1:0]  tx_parallel_data;
wire    [4*66-1:0]  tx_parallel_data_kr;
wire    [4*66-1:0]  rx_parallel_data;
wire    [3:0]       rx_div_clk;
wire    [3:0]       tx_div_clk;
wire    [3:0]       tx_clkout;
wire    [3:0]       rx_clkout;
wire                tx_clk = tx_div_clk[1];
wire                rx_clk = rx_div_clk[1];

assign                clk_txmac = tx_clk;
assign                clk_rxmac = rx_clk;

wire                clk_tx_rs_frompll = 1'b0;
wire                txfec_pll_locked_frompll = 1'b0;

wire    [3:0]       tx_analogreset;         
wire    [3:0]       rx_analogreset;         
wire    [3:0]       tx_digitalreset;        
wire    [3:0]       rx_digitalreset;        
wire    [3:0]       tx_analogreset_stat;    
wire    [3:0]       tx_digitalreset_stat;   
wire    [3:0]       rx_analogreset_stat;    
wire    [3:0]       rx_digitalreset_stat;   
wire    [3:0]       rx_digitalreset_stat_pma;   
wire    [3:0]       rx_digitalreset_stat_trs_kr;
wire    [3:0]       tx_cal_busy;            
wire    [3:0]       rx_cal_busy;            
wire    [3:0]       freq_lock;                  
wire    [3:0]       rx_is_lockedtodata;

wire    [3:0]       tx_pempty;
wire    [3:0]       tx_pfull;
wire    [3:0]       tx_empty;
wire    [3:0]       tx_full;
wire    [3:0]       rx_pempty;
wire    [3:0]       rx_pfull;
wire    [3:0]       rx_empty;
wire    [3:0]       rx_full;
wire    [3:0]       sloop;
wire    [3:0]       rx_bitslip;
wire    [3:0]       tx_dll_lock;

reg    [3:0]       rx_read_en;
wire    [3:0]       rx_data_valid;

wire                avmm_write;              
wire                avmm_read;               
wire [ADDRSIZE-1:0] avmm_address;            
wire        [31:0]  avmm_writedata;          
wire        [31:0]  avmm_fecpll_readdata;           
wire                avmm_fecpll_waitrequest;       

wire                fec_tx_pll_locked, fec_rx_pll_locked;
wire   [3:0]        rx_pma_ready, tx_pma_ready;
wire                rx_digitalreset_req;
wire                pma_reset;
wire                rx_set_locktoref, rx_set_locktodata, rx_set_locktoref_e100;
wire                clk_rx_rs, clk_tx_rs;
// KR Signals
wire                rx_set_locktodata_e100s10;
wire [3:0]          rx_is_lockedtodata_kr;
wire [3:0]          rx_bitslip_hssi;
wire [3:0]          rx_bitslip_kr;
wire                inhibit_slip;
wire                inhibit_rx_reset;
wire [3:0]          rx_bitslip_xcvr = inhibit_slip? 4'b0000 : rx_bitslip_kr;
wire [3:0]          rx_set_locktoref_kr;
wire [3:0]          rx_set_locktodata_kr;
wire [3:0]          rx_pma_ready_kr, tx_pma_ready_kr;
wire                tx_data_valid_kr;
wire [3:0]          tx_data_valid_e100s10;
wire                soft_txp_rst, soft_rxp_rst;
wire                kr_mode;
wire                start_reset_ctrl;

//XCVR Reconfig Interface
wire        xcvr_reconfig_write;
wire        xcvr_reconfig_read;
wire [12:0] xcvr_reconfig_address;
wire [31:0] xcvr_reconfig_writedata;
wire [31:0] xcvr_reconfig_readdata;
wire        xcvr_reconfig_waitrequest;

wire [31:0]  status_readdata_e100s10;
wire         status_readdata_valid_e100s10;
wire         status_waitrequest_e100s10;

wire [31:0]  status_readdata_kr;
wire         status_readdata_valid_kr;
wire         status_waitrequest_kr;

wire         reconfig_waitrequest_kr;

wire         hi_ber_raw;
// Core Module 
wire         enable_rsfec;
wire enable_rsfec_csr;


assign enable_rsfec = enable_rsfec_csr;
wire  [4*2-1:0]  tx_control;
wire   [4*2-1:0]  tx_control_phy;
wire   [3:0]      tx_data_valid_phy;
wire  [64*4-1:0] tx_data;
wire   [64*4-1:0] tx_data_phy;

wire   [4*2-1:0]  rx_control;
wire  [4*2-1:0]  rx_control_phy;
wire  [3:0]      rx_data_valid_phy;
wire   [64*4-1:0] rx_data;
wire  [64*4-1:0] rx_data_phy;

wire [3:0] rx_transfer_ready,rx_aib_reset, rx_pcs_reset; 
wire [3:0] tx_transfer_ready,tx_aib_reset, tx_pcs_reset; 
wire       reset_aib_ack,reset_pcs_ack;
wire       start_reset_ctrl_tx_aib,start_reset_ctrl_tx_pcs;
wire       start_reset_ctrl_rx;

// ELI Combined CSR Interface
wire    [15:0]  status_addr_eli;
wire            status_read_eli;
wire            status_write_eli;
wire    [31:0]  status_readdata_eli;
wire            status_readdata_valid_eli;
wire    [31:0]  status_writedata_eli;
wire            status_waitrequest_eli;

// ELI Combined Reconfig Interface
wire            reconfig_write_eli;
wire            reconfig_read_eli;
wire    [12:0]  reconfig_address_eli;
wire    [31:0]  reconfig_writedata_eli;
wire    [31:0]  reconfig_readdata_eli;
wire            reconfig_waitrequest_eli;


alt_e100s10_eth_4  #(

        .SIM_SHORT_AM         (SIM_SHORT_AM),      // shorten the AM interval to lock faster
        .SIM_EMULATE          (SIM_EMULATE),
        .PHY_REFCLK           (PHY_REFCLK)          ,
        .SYNOPT_FLOW_CONTROL  (SYNOPT_FLOW_CONTROL),
        .SYNOPT_NUMPRIORITY   (SYNOPT_NUMPRIORITY),
        .SYNOPT_PREAMBLE_PASS (SYNOPT_PREAMBLE_PASS ),
        .SYNOPT_TXCRC_INS     (SYNOPT_TXCRC_INS   ),
	    .SYNOPT_STRICT_SOP    (SYNOPT_STRICT_SOP),
        .WORDS                (WORDS),
        .SYNOPT_MAC_STATS_COUNTERS   (SYNOPT_MAC_STATS_COUNTERS),
        .SYNOPT_AVALON        (SYNOPT_AVALON),
        .SYNOPT_ALIGN_FCSEOP  (SYNOPT_ALIGN_FCSEOP),
        .REVID                (REVID),
        .BASE_PHY             (BASE_PHY),
        .BASE_TXMAC           (BASE_TXMAC),
        .BASE_RXMAC           (BASE_RXMAC),
        .BASE_TXFEC           (BASE_TXFEC),
        .BASE_RXFEC           (BASE_RXFEC),
        .SYNOPT_LINK_FAULT    (SYNOPT_LINK_FAULT),
        .SYNOPT_AVG_IPG       (SYNOPT_AVG_IPG),
        .SYNOPT_MAC_DIC       (SYNOPT_MAC_DIC),
        .SYNOPT_PTP           (SYNOPT_PTP),
        .SYNOPT_TOD_FMT       (SYNOPT_TOD_FMT),
        .PTP_LATENCY          (PTP_LATENCY),
        .PTP_FP_WIDTH         (PTP_FP_WIDTH), // width of fingerprint, ptp parameter

        .PMA_WORD_SIZE        (PMA_WORD_SIZE),
        .FEC_AM_BITS          (FEC_AM_BITS),  //for simulation purpose
        .EXT_TX_PLL           (EXT_TX_PLL),
        .RX_PLL_TYPE          (RX_PLL_TYPE),
        .TX_PLL_TYPE          (TX_PLL_TYPE),
        .SYNOPT_C4_RSFEC      (SYNOPT_C4_RSFEC),
        .SYNOPT_C4_RSFEC_DYN  (SYNOPT_C4_RSFEC_DYN),
        .ENABLE_ANLT          (ENABLE_ANLT)


) alt_s100 (        // clean up the clocks at core level

    // clocks and reset
    .rx_clk                 (rx_clk),
    .tx_clk                 (tx_clk),
    .clk_rx_rs              (clk_rx_rs),
    .clk_tx_rs              (clk_tx_rs),
    .clk_ref                (clk_ref),      
    .enable_rsfec           (enable_rsfec_csr), 
    .tx_data_kr             (tx_parallel_data_kr),
    .kr_mode                (kr_mode),
    .csr_rst_n              (csr_rst_n),
    .rx_rst                 (~rx_rst_n),
    .tx_rst                 (~tx_rst_n),
    .rx_pma_ready           (rx_pma_ready_kr),
    .tx_pma_ready           (tx_pma_ready_kr),
    .rx_digitalreset_req    (rx_digitalreset_req),
    .native_phy_reset       (pma_reset),
    .tx_dll_lock            (tx_dll_lock),
    .tx_digitalreset_stat   (tx_digitalreset_stat),
    .inhibit_rx_reset       (inhibit_rx_reset),
    .inhibit_slip           (inhibit_slip),

    // PLL and TX status
    .fec_tx_pll_locked      (fec_tx_pll_locked),
    .fec_rx_pll_locked      (fec_rx_pll_locked),
    .tx_lanes_stable        (tx_lanes_stable),

    // PMA signals
    .rx_data_in             (rx_parallel_data),
    .rx_bitslip             (rx_bitslip),
    .rx_data_valid          (rx_data_valid),
    .tx_data_out            (tx_parallel_data),
    .tx_data_valid          (tx_data_valid_e100s10),

    // AVMM Interface
    .avmm_clk               (clk_status), //CSR clk
    .avmm_reset             (~csr_rst_n), 
    .status_addr            (status_addr_eli),
    .status_read            (status_read_eli),
    .status_write           (status_write_eli),
    .status_readdata        (status_readdata_e100s10),
    .status_readdata_valid  (status_readdata_valid_e100s10),
    .status_writedata       (status_writedata_eli),
    .status_waitrequest     (status_waitrequest_e100s10),

     // PHY Control & Status
    .tx_pempty              (tx_pempty),
    .tx_pfull               (tx_pfull),
    .tx_empty               (tx_empty),
    .tx_full                (tx_full),
    .tx_pll_locked          (tx_pll_locked),
    .rx_pempty              (rx_pempty),
    .rx_pfull               (rx_pfull),
    .rx_empty               (rx_empty),
    .rx_full                (rx_full),
    .rx_is_lockedtodata     (rx_is_lockedtodata_kr&~{4{kr_mode}}),
    .rx_seriallpbken        (sloop),
    .rx_set_locktoref       (rx_set_locktoref),
    .rx_set_locktodata      (rx_set_locktodata_e100s10),
    .rx_pcs_ready           (rx_pcs_ready),
    .rx_block_lock          (rx_block_lock),
    .rx_am_lock             (rx_am_lock),
    // Avalon TX Interface
    .l8_tx_startofpacket          (l8_tx_startofpacket),
    .l8_tx_endofpacket            (l8_tx_endofpacket),
    .l8_tx_valid                  (l8_tx_valid),
    .l8_tx_ready                  (l8_tx_ready),
    .l8_tx_empty                  (l8_tx_empty),
    .l8_tx_data                   (l8_tx_data),
    .l8_tx_error                  (l8_tx_error ),
    .l8_txstatus_valid            (l8_txstatus_valid),
    .l8_txstatus_data             (l8_txstatus_data),
    .l8_txstatus_error            (l8_txstatus_error),

     // Avalon RX Interface
    .l8_rx_startofpacket          (l8_rx_startofpacket),
    .l8_rx_endofpacket            (l8_rx_endofpacket ),
    .l8_rx_valid                  (l8_rx_valid),
    .l8_rx_empty                  (l8_rx_empty ),
    .l8_rx_data                   (l8_rx_data),
    .l8_rxstatus_valid            (l8_rxstatus_valid),
    .l8_rxstatus_data             (l8_rxstatus_data),
    .l8_rx_error                  (l8_rx_error),
    // Link Fault
    .unidirectional_en      (), // LF; not used
    .link_fault_gen_en      (), // LF; not used
    .remote_fault_status    (remote_fault_status),
    .local_fault_status     (local_fault_status),

    // Flow Control
    .pause_insert_tx0      (pause_insert_tx0),
    .pause_insert_tx1      (pause_insert_tx1),
    .pause_receive_rx      (pause_receive_rx),
    .o_hi_ber                     (hi_ber_raw) //KR Support
    
);

//------------------------------------------------------------------//
// JTAG Master and Arbiter for Ethernet Link Inspector

generate
if (ELI_ENABLE) begin: GEN_ELI_JTAG
    alt_e100s10_eli_jtag eli_jtag(

        // Clock and Resets
        .clk_status                 (clk_status),
        .csr_rst_n                  (csr_rst_n),

        // CSR Interface
        .status_addr                (status_addr),
        .status_read                (status_read),
        .status_write               (status_write),
        .status_readdata            (status_readdata),
        .status_readdata_valid      (status_readdata_valid),
        .status_writedata           (status_writedata),
        .status_waitrequest         (status_waitrequest),

        // Reconfig Interface
        .reconfig_write             (reconfig_write),
        .reconfig_read              (reconfig_read),
        .reconfig_address           (reconfig_address),
        .reconfig_writedata         (reconfig_writedata),
        .reconfig_readdata          (reconfig_readdata),
        .reconfig_waitrequest       (reconfig_waitrequest),

        // Combined CSR Interface
        .status_addr_eli            (status_addr_eli),
        .status_read_eli            (status_read_eli),
        .status_write_eli           (status_write_eli),
        .status_readdata_eli        (status_readdata_eli),
        .status_readdata_valid_eli  (status_readdata_valid_eli),
        .status_writedata_eli       (status_writedata_eli),
        .status_waitrequest_eli     (status_waitrequest_eli),

        // Combined Reconfig Interface
        .reconfig_write_eli         (reconfig_write_eli),
        .reconfig_read_eli          (reconfig_read_eli),
        .reconfig_address_eli       (reconfig_address_eli),
        .reconfig_writedata_eli     (reconfig_writedata_eli),
        .reconfig_readdata_eli      (reconfig_readdata_eli),
        .reconfig_waitrequest_eli   (reconfig_waitrequest_eli)
    );
end
else begin: NO_ELI_JTAG
    assign  status_addr_eli             =    status_addr;
    assign  status_read_eli             =    status_read;
    assign  status_write_eli            =    status_write;
    assign  status_readdata             =    status_readdata_eli;
    assign  status_readdata_valid       =    status_readdata_valid_eli;
    assign  status_writedata_eli        =    status_writedata;
    assign  status_waitrequest          =    status_waitrequest_eli;

    assign  reconfig_write_eli          =    reconfig_write;
    assign  reconfig_read_eli           =    reconfig_read;
    assign  reconfig_address_eli        =    reconfig_address;
    assign  reconfig_writedata_eli      =    reconfig_writedata;
    assign  reconfig_readdata           =    reconfig_readdata_eli;
    assign  reconfig_waitrequest        =    reconfig_waitrequest_eli;
end
endgenerate

//------------------------------------------------------------------//
// ADAPTATION

wire reconfig_write_mx;
wire reconfig_read_mx;
wire [12:0] reconfig_address_mx;
wire [31:0] reconfig_writedata_mx;
wire adapt_write;
wire adapt_read;
wire [12:0] adapt_address;
wire [31:0] adapt_writedata;
wire adapting;
wire reconfig_waitrequest_xcvr;

generate
if (ENABLE_ANLT==0) begin

    alt_e100s10_adapt_pma #(
        .DEVREV(DEVREV)
    ) adapt (
      .mgmt_clk          (reconfig_clk),       // managemnt/reconfig clock
      .mgmt_reset        (reconfig_reset),     // managemnt/reconfig reset

      .rx_is_lockedtodata(rx_is_lockedtodata_kr),//.rx_is_lockedtodata(rx_is_lockedtodata[3:0]), // PLL rx_is_lockedtodata
      .adapting          (adapting), // Programming adaption mode

      .rcfg_write        (adapt_write),    // AVMM write
      .rcfg_read         (adapt_read),     // AVMM read
      .rcfg_address      (adapt_address),  // AVMM address
      .rcfg_wrdata       (adapt_writedata),   // AVMM write data
      .rcfg_rddata       (reconfig_readdata_eli),   // AVMM read data
      .rcfg_wtrqst       (adapt_waitrequest)    // AVMM wait request
    );

alt_e100s10_rcfg_arb #(
  .total_masters  (2),
  .channels       (1),
  .address_width  (13),
  .data_width     (32)
) rca(
  // Basic AVMM inputs
  .reconfig_clk         (reconfig_clk),
  .reconfig_reset       (reconfig_reset),

  // User AVMM input
  .user_read            (reconfig_read_eli),
  .user_write           (reconfig_write_eli),
  .user_address         (reconfig_address_eli),
  .user_writedata       (reconfig_writedata_eli),
  .user_read_write      (reconfig_read_eli || reconfig_write_eli),
  .user_waitrequest     (reconfig_waitrequest_eli),

  // Reconfig Steamer AVMM input
  .adapt_read            (adapt_read),
  .adapt_write           (adapt_write),
  .adapt_address         (adapt_address),
  .adapt_writedata       (adapt_writedata),
  .adapt_read_write      (adapt_read || adapt_write),
  .adapt_waitrequest     (adapt_waitrequest),

  // AVMM output the channel and the CSR
  .avmm_waitrequest     (reconfig_waitrequest_kr),
  .avmm_read            (reconfig_read_mx),
  .avmm_write           (reconfig_write_mx),
  .avmm_address         (reconfig_address_mx),
  .avmm_writedata       (reconfig_writedata_mx)
);

end
else begin
    assign reconfig_waitrequest_eli   = reconfig_waitrequest_kr;
    assign reconfig_write_mx      = reconfig_write_eli;
    assign reconfig_read_mx       = reconfig_read_eli;
    assign reconfig_address_mx    = reconfig_address_eli;
    assign reconfig_writedata_mx  = reconfig_writedata_eli;
end
endgenerate

//------------------------------------------------------------------//


genvar   i;
generate

  for (i=0; i<4; i=i+1) begin : asn
    assign  tx_control[2*i+:2] = tx_parallel_data[66*i+64+:2];
    assign  tx_data[64*i+:64] = tx_parallel_data[66*i+:64];
    assign  rx_parallel_data[66*i+:64] = rx_data[64*i+:64];
    assign  rx_parallel_data[66*i+64+:2] = rx_control[2*i+:2];
  end
endgenerate
    
assign tx_control_phy    = tx_control;
assign tx_data_phy       = tx_data;
assign tx_data_valid_phy = tx_data_valid_e100s10;//(kr_mode == 1'b1) ? {4{tx_data_valid_kr}} : tx_data_valid_e100s10;

assign rx_data       = rx_data_phy;
assign rx_control    = rx_control_phy;
assign rx_data_valid = rx_data_valid_phy;

wire  [3:0]  tx_xcvr_clk = {tx_serial_clk[1], tx_serial_clk[1], tx_serial_clk[0], tx_serial_clk[0]};

// Auto-generated PMA

ex_100g_alt_e100s10_1910_msocaki xcvr (
    
    // Reset
    .tx_analogreset         (tx_analogreset), 
    .rx_analogreset         (rx_analogreset), 
    .tx_analogreset_stat    (tx_analogreset_stat),
    .rx_analogreset_stat    (rx_analogreset_stat),
    .tx_digitalreset        (tx_digitalreset),    
    .rx_digitalreset        (rx_digitalreset),     
    .tx_digitalreset_stat   (tx_digitalreset_stat),    
    .rx_digitalreset_stat   (rx_digitalreset_stat_pma),
    .tx_cal_busy            (tx_cal_busy), 
    .rx_cal_busy            (rx_cal_busy), 
    .tx_dll_lock            (tx_dll_lock),      

    // serial
    .tx_serial_clk0         (tx_xcvr_clk), 
    .rx_cdr_refclk0         (clk_ref), 
    .tx_serial_data         (tx_serial), 
    .rx_serial_data         (rx_serial), 
    .rx_seriallpbken        (sloop),
    .rx_is_lockedtoref      (freq_lock),        
    .rx_is_lockedtodata     (rx_is_lockedtodata),

    // parallel clocks
    .tx_coreclkin           ({4{tx_clk}}),          
    .rx_coreclkin           ({4{rx_clk}}),
    .tx_clkout              (tx_clkout),                 
    .tx_clkout2             (tx_div_clk),                
    .rx_clkout              (rx_clkout),                  
    .rx_clkout2             (rx_div_clk),

    // data
    .tx_parallel_data       (tx_data_phy), 
    .unused_tx_parallel_data(48'h0),
    .tx_control             (tx_control_phy),
    .rx_parallel_data       (rx_data_phy), 
    .unused_rx_parallel_data (),
    .rx_control             (rx_control_phy),

    // control & status
    .rx_fifo_rd_en          (rx_read_en),               
    .rx_data_valid          (rx_data_valid_phy),          
    .tx_enh_data_valid      (tx_data_valid_phy),    // control signal to allow PMA out of reset
    .tx_fifo_wr_en          (tx_data_valid_phy),    
    .rx_bitslip             (rx_bitslip_xcvr),
    
    // FIFO status
    .tx_fifo_full           (tx_full),       
    .tx_fifo_empty          (tx_empty),      
    .tx_fifo_pfull          (tx_pfull),      
    .tx_fifo_pempty         (tx_pempty),     
    .rx_fifo_full           (rx_full),       
    .rx_fifo_empty          (rx_empty),      
    .rx_fifo_pfull          (rx_pfull),      
    .rx_fifo_pempty         (rx_pempty),        

    // reconfig interface
    .reconfig_clk           (reconfig_clk), 
    .reconfig_reset         (reconfig_reset), 
    .reconfig_write         (xcvr_reconfig_write),       
    .reconfig_read          (xcvr_reconfig_read),       
    .reconfig_address       (xcvr_reconfig_address),   
    .reconfig_writedata     (xcvr_reconfig_writedata),  
    .reconfig_readdata      (xcvr_reconfig_readdata),   
    .reconfig_waitrequest   (xcvr_reconfig_waitrequest),

    .rx_set_locktoref       (rx_set_locktoref_kr & {4{~inhibit_rx_reset}}),
    .rx_set_locktodata      (rx_set_locktodata_kr & {4{~inhibit_rx_reset}})
);

// Temporary connections
//assign rx_read_en   = ~rx_pempty;       // rev-A Bug - will need to update for rev-B

//CDC crossing
wire [3:0] rx_digitalreset_sync_rxclk;

alt_e100s10_syncnr2 #(
  .WIDTH(4)
) rx_digitalreset_sync_inst(
  .din_clk (reconfig_clk),
  .din     (rx_digitalreset),
  .dout_clk(rx_clk),
  .dout    (rx_digitalreset_sync_rxclk)
);

always @(posedge rx_clk) begin
    if (rx_digitalreset_sync_rxclk) begin
        rx_read_en  <= 4'b0000;
    end else begin
        rx_read_en  <= rx_read_en | ~rx_pempty;
    end
end

// Auto-generated PHY Reset Controller 

// will be generating tx_data_valid and using tx_data_valid_e1
wire [3:0]  digital_rx_ready;

assign digital_rx_ready     = inhibit_rx_reset ? 4'hF : (rx_digitalreset_req & ~kr_mode ? 4'b0000 : rx_is_lockedtodata_kr); 

s10_xcvr_reset_controller reset_controller (

        .clock                  (reconfig_clk),      
        .reset                  (pma_reset | start_reset_ctrl),
        .tx_analogreset         (tx_analogreset),    
        .tx_digitalreset        (tx_digitalreset),   
        .tx_ready               (tx_pma_ready),      
        .pll_locked             (&tx_pll_locked),    
        .pll_select             (1'b0),
        .tx_cal_busy            (tx_cal_busy),          
        .tx_analogreset_stat    (tx_analogreset_stat),  
        .tx_digitalreset_stat   (tx_digitalreset_stat), 
        .rx_analogreset         (rx_analogreset),       
        .rx_digitalreset        (rx_digitalreset),      
        .rx_ready               (rx_pma_ready),         
        .rx_is_lockedtodata     (digital_rx_ready),    
        .rx_cal_busy            (rx_cal_busy | {4{start_reset_ctrl_rx}}),          
        .rx_analogreset_stat    (rx_analogreset_stat),  
        .rx_digitalreset_stat   (rx_digitalreset_stat)  

);

generate
if (SYNOPT_C4_RSFEC==1) begin : WITH_FEC

wire fec_tx_pll_locked_rsfec;
wire fec_rx_pll_locked_rsfec;
wire clk_rx_rs_rsfec;
wire clk_tx_rs_rsfec;
wire rx_set_locktoref_e100_rsfec;

alt_e100s10_fecpll_sgjuooq
      #(
        .RX_PLL_TYPE(RX_PLL_TYPE),
        .TX_PLL_TYPE(TX_PLL_TYPE),
        .TX_IOPLL_REFCLK(TX_IOPLL_REFCLK),
        .TX_PLL_LOCAT(TX_PLL_LOCAT)
       ) fecpll (
        .clk_ref(clk_ref),                           // in, 644/322 mhz
        .avmm_clk(clk_status),                       //

        .clk_rx(rx_clk),                             // in, from xcvr -- 390.625mhz
        .clk_tx(tx_clk),                             // in, from xcvr -- 390.625mhz
        .clk_rx_rs(clk_rx_rs_rsfec),                       // out, rx pll output clock -- 312.5mhz
        .clk_tx_rs(clk_tx_rs_rsfec),                       // out, tx pll output clock -- 312.5mhz

        .rxfec_pll_locked(fec_rx_pll_locked_rsfec),        // out, rxfec fpll lock
        .txfec_pll_locked(fec_tx_pll_locked_rsfec),        // out, txfec fpll lock

        .pma_reset(pma_reset),              // in, based on the rx's digital reset
        .tx_pll_reset(tx_analogreset[1]),            // in, based on the tx's analog reset.


        .txfec_pll_locked_frompll(txfec_pll_locked_frompll), //in, from outsiee of IP
        .clk_tx_rs_frompll(clk_tx_rs_frompll),               //in, from outsiee of IP

        .pll_recal_done(pll_recal_done),             //out. 40G: this one AND with rx_pcs_pll_locked then send to Pcs rx_set_locktoref

        .rx_set_locktoref_e100 (rx_set_locktoref_e100_rsfec), // out, 40G send to pma's rx_set_locktoref
        .rx_set_locktoref(rx_set_locktoref),        // in, from csr's output
        .rx_is_lockedtoref(freq_lock[3:0]),          // in
        .rx_is_lockedtodata(rx_is_lockedtodata_kr)//.rx_is_lockedtodata(rx_is_lockedtodata[3:0]) // in

 );

    assign  fec_tx_pll_locked     = (enable_rsfec == 1) ? fec_tx_pll_locked_rsfec     : 1'b1;
    assign  fec_rx_pll_locked     = (enable_rsfec == 1) ? fec_rx_pll_locked_rsfec     : 1'b1;
    assign  clk_rx_rs             = (enable_rsfec == 1) ? clk_rx_rs_rsfec             : 1'b0;
    assign  clk_tx_rs             = (enable_rsfec == 1) ? clk_tx_rs_rsfec             : 1'b0;
    assign  rx_set_locktoref_e100 = (enable_rsfec == 1) ? rx_set_locktoref_e100_rsfec : 1'b0;

end
else begin
    assign  fec_tx_pll_locked   = 1'b1;
    assign  fec_rx_pll_locked   = 1'b1;
    assign  clk_rx_rs           = 1'b0;
    assign  clk_tx_rs           = 1'b0;
    assign  rx_set_locktoref_e100           = 1'b0;
end
endgenerate 

generate
    if(ENABLE_ANLT) begin : GENKR
        // AN/LT logic
        assign status_readdata_eli        = (status_addr_eli[11:8] == 4'b0000) ? status_readdata_kr       : status_readdata_e100s10;
        assign status_readdata_valid_eli  = (status_addr_eli[11:8] == 4'b0000) ? status_readdata_valid_kr : status_readdata_valid_e100s10;
        assign status_waitrequest_eli     = (status_addr_eli[11:8] == 4'b0000) ? status_waitrequest_kr    : status_waitrequest_e100s10;

        alt_e100s10_kr_reset_sequencer_top alt_e100s10_kr4_reset_sequencer_top_inst
        (	
          .clk_in             (reconfig_clk     ), // used for CDC
          .reset              ( pma_reset       ),
          .release_aib_first  (1'b1             ),
          .reset_in_tx        (tx_digitalreset  ),
          .reset_in_rx        (rx_digitalreset  ),
          .start_reset_aib    (start_reset_ctrl_tx_aib&~start_reset_ctrl_tx_pcs),
          .start_reset_pcs    (start_reset_ctrl_tx_pcs&~start_reset_ctrl_tx_aib),
          .reset_aib_ack      (reset_aib_ack    ),
          .reset_pcs_ack      (reset_pcs_ack    ),
          .rx_transfer_ready  (rx_transfer_ready),
          .tx_transfer_ready  (tx_transfer_ready),
          .rx_aib_reset       (rx_aib_reset     ),
          .rx_pcs_reset       (rx_pcs_reset     ),
          .tx_aib_reset       (tx_aib_reset     ),
          .tx_pcs_reset       (tx_pcs_reset     ),
          .rx_reset_out       (rx_digitalreset_stat_trs_kr),
          .tx_reset_out       (tx_digitalreset_stat)

        );

       assign rx_digitalreset_stat = rx_digitalreset_stat_trs_kr ;  
 
 
       alt_e100s10_kr #(
            .DEVREV(DEVREV),
            .LANES(4),
            .STATUS_CLK_KHZ(STATUS_CLK_KHZ),
            .SYNTH_AN(SYNTH_AN),
            .LINK_TIMER_KR(LINK_TIMER_KR),
            .AN_TECH(AN_TECH),
            .E25_TECH(E25_TECH),
            .AN_CHAN(AN_CHAN),
            .AN_PAUSE(AN_PAUSE),
            .SYNTH_LT(SYNTH_LT),
            .VMAXRULE(VMAXRULE),
            .VMINRULE(VMINRULE),
            .VODMINRULE(VODMINRULE),
            .VPOSTRULE(VPOSTRULE),
            .VPRERULE(VPRERULE),
            .PREMAINVAL(PREMAINVAL),
            .PREPOSTVAL(PREPOSTVAL),
            .PREPREVAL(PREPREVAL),
            .INITMAINVAL(INITMAINVAL),
            .INITPOSTVAL(INITPOSTVAL),
            .INITPREVAL(INITPREVAL),
            .TRNWTWIDTH(TRNWTWIDTH),
            .CL72_PRBS(CL72_PRBS),
            .USE_DEBUG_CPU(USE_DEBUG_CPU)
        ) alt_e100s10_kr_inst (
            .start_reset_ctrl_rx    (start_reset_ctrl_rx),
            .start_reset_ctrl_tx_aib(start_reset_ctrl_tx_aib),
            .start_reset_ctrl_tx_pcs(start_reset_ctrl_tx_pcs),
            .reset_aib_ack          (reset_aib_ack),
            .reset_pcs_ack          (reset_pcs_ack),
    
            .start_reset_ctrl (start_reset_ctrl),
            .i_reconfig_clk   (reconfig_clk),
            .i_reconfig_reset (reconfig_reset),
            .i_csr_rst_in     (~csr_rst_n),     
            .i_tx_clk         (tx_clk),  
            .i_rx_clk         (rx_clk),  

            .rx_digitalreset_stat (rx_digitalreset_stat),
            .tx_digitalreset_stat (tx_digitalreset_stat),
            .rx_analogreset_stat (rx_analogreset_stat),
            .tx_analogreset_stat (tx_analogreset_stat),
            .rx_cal_busy (rx_cal_busy),
            .tx_cal_busy (tx_cal_busy),

            // Seperate XCVR reconfig Interfaces for each xcvr lane
            // User-facing side
            .i_xcvr_reconfig_address     (reconfig_address_mx),
            .i_xcvr_reconfig_read        (reconfig_read_mx),
            .i_xcvr_reconfig_write       (reconfig_write_mx),
            .i_xcvr_reconfig_writedata   (reconfig_writedata_mx),
            .o_xcvr_reconfig_readdata    (reconfig_readdata_eli),
            .o_xcvr_reconfig_waitrequest (reconfig_waitrequest_kr),

            // XCVR reconfig, hssi-facing side
            .xcvr_reconfig_write       (xcvr_reconfig_write),
            .xcvr_reconfig_read        (xcvr_reconfig_read),
            .xcvr_reconfig_address     (xcvr_reconfig_address),
            .xcvr_reconfig_writedata   (xcvr_reconfig_writedata),
            .xcvr_reconfig_readdata    (xcvr_reconfig_readdata),
            .xcvr_reconfig_waitrequest (xcvr_reconfig_waitrequest),

            // KR Soft CSR Interface
            .status_read           (status_read_eli),
            .status_write          (status_write_eli),
            .status_addr           (status_addr_eli), 
            .status_readdata       (status_readdata_kr),
            .status_writedata      (status_writedata_eli),
            .status_readdata_valid (status_readdata_valid_kr),
            .status_waitrequest    (status_waitrequest_kr),

            // HSSI Interface
            .rx_parallel_data    (rx_parallel_data),
            .tx_parallel_data    (tx_parallel_data_kr),
            .rx_data_valid       ({4{1'b1}}), 
            .tx_data_valid       (tx_data_valid_kr),
            .o_rx_bitslip        (rx_bitslip_kr),
            .i_rx_bitslip        (rx_bitslip),
            .o_rx_set_locktodata (rx_set_locktodata_kr),
            .o_rx_set_locktoref  (rx_set_locktoref_kr),

            .i_rx_is_lockedtodata(rx_is_lockedtodata),
            .i_rx_is_lockedtoref (freq_lock),

            // From User CSRs
            .i_rx_set_locktodata ({4{rx_set_locktodata_e100s10}}), 
            .i_rx_set_locktoref  ({4{rx_set_locktoref_e100}}),

            // Link Status Signals
            .i_am_lock           (rx_pcs_ready),
            .i_hi_ber            (hi_ber_raw),

            // Reset controller interface
            .kr_mode             (kr_mode),
            
            .o_rx_is_lockedtodata(rx_is_lockedtodata_kr),
            // tx/rx clock ready from reset controller
            .i_tx_ready          (tx_pma_ready),
            .i_rx_ready          (rx_pma_ready),
            // tx/rx clock ready to user logic
            .o_tx_ready          (tx_pma_ready_kr),  
            .o_rx_ready          (rx_pma_ready_kr)  
        );
    end else begin : NOKR
    	  assign start_reset_ctrl_rx       = 1'b0;
        assign rx_digitalreset_stat      = rx_digitalreset_stat_pma ;  

        assign kr_mode                      = 1'b0;       //Disable KR
        assign rx_set_locktodata_kr         = 4'b0; 
        assign rx_set_locktoref_kr          = {4{rx_set_locktoref_e100}};

        assign tx_pma_ready_kr              = tx_pma_ready;
        assign rx_pma_ready_kr              = rx_pma_ready;
        
        assign xcvr_reconfig_write          = reconfig_write_mx;
        assign xcvr_reconfig_writedata      = reconfig_writedata_mx;
        assign xcvr_reconfig_read           = reconfig_read_mx;
        assign xcvr_reconfig_address        = reconfig_address_mx;   
        assign reconfig_readdata_eli        = xcvr_reconfig_readdata;
        assign reconfig_waitrequest_kr      = xcvr_reconfig_waitrequest;
         
        assign status_readdata_eli          = status_readdata_e100s10;
        assign status_readdata_valid_eli    = status_readdata_valid_e100s10;
        assign status_waitrequest_eli       = status_waitrequest_e100s10;

        assign rx_is_lockedtodata_kr        = rx_is_lockedtodata;

        assign tx_parallel_data_kr          = 264'b0;
        assign tx_data_valid_kr             = 1'b0;
        assign rx_bitslip_kr                = rx_bitslip;
        assign start_reset_ctrl             = 1'b0;

    end
endgenerate

endmodule

