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

//`define ENABLE_DDR4A
//`define ENABLE_DDR4B
//`define ENABLE_DDR4C
//`define ENABLE_DDR4D
//`define ENABLE_PCIE
`define ENABLE_QSFP28A
`define ENABLE_QSFP28B
`define ENABLE_QSFP28C
`define ENABLE_QSFP28D
//`define ENABLE_HPS

`timescale 1 ps / 1 ps

module alt_e100s10 (
      ///////// CLOCK /////////
      input              CLK_100_B3I,
      input              CLK_50_B2C,
      input              CLK_50_B2L,
      input              CLK_50_B3C,
      input              CLK_50_B3I,
      input              CLK_50_B3L,

      ///////// Buttons /////////
      input              CPU_RESET_n,
      input    [ 1: 0]   BUTTON,

      ///////// Swtiches /////////
      input    [ 1: 0]   SW,

      ///////// LED /////////
      output   [ 3: 0]   LED, //LED is Low-Active

      ///////// FLASH /////////
      output             FLASH_CLK,
      output   [27: 1]   FLASH_A,
      inout    [15: 0]   FLASH_D,
      output             FLASH_CE_n,
      output             FLASH_WE_n,
      output             FLASH_OE_n,
      output             FLASH_ADV_n,
      output             FLASH_RESET_n,
      input              FLASH_RDY_BSY_n,

`ifdef ENABLE_DDR4A
      ///////// DDR4A /////////
      input              DDR4A_REFCLK_p,
      output   [16: 0]   DDR4A_A,
      output   [ 1: 0]   DDR4A_BA,
      output   [ 1: 0]   DDR4A_BG,
      output             DDR4A_CK,
      output             DDR4A_CK_n,
      output             DDR4A_CKE,
      inout    [ 8: 0]   DDR4A_DQS,
      inout    [ 8: 0]   DDR4A_DQS_n,
      inout    [71: 0]   DDR4A_DQ,
      inout    [ 8: 0]   DDR4A_DBI_n,
      output             DDR4A_CS_n,
      output             DDR4A_RESET_n,
      output             DDR4A_ODT,
      output             DDR4A_PAR,
      input              DDR4A_ALERT_n,
      output             DDR4A_ACT_n,
      input              DDR4A_EVENT_n,
      inout              DDR4A_SCL,
      inout              DDR4A_SDA,
      input              DDR4A_RZQ,
`endif /*ENABLE_DDR4A*/

`ifdef ENABLE_DDR4B
      ///////// DDR4B /////////
      input              DDR4B_REFCLK_p,
      output   [16: 0]   DDR4B_A,
      output   [ 1: 0]   DDR4B_BA,
      output   [ 1: 0]   DDR4B_BG,
      output             DDR4B_CK,
      output             DDR4B_CK_n,
      output             DDR4B_CKE,
      inout    [ 8: 0]   DDR4B_DQS,
      inout    [ 8: 0]   DDR4B_DQS_n,
      inout    [71: 0]   DDR4B_DQ,
      inout    [ 8: 0]   DDR4B_DBI_n,
      output             DDR4B_CS_n,
      output             DDR4B_RESET_n,
      output             DDR4B_ODT,
      output             DDR4B_PAR,
      input              DDR4B_ALERT_n,
      output             DDR4B_ACT_n,
      input              DDR4B_EVENT_n,
      inout              DDR4B_SCL,
      inout              DDR4B_SDA,
      input              DDR4B_RZQ,
`endif /*ENABLE_DDR4B*/

`ifdef ENABLE_DDR4C
      ///////// DDR4C /////////
      input              DDR4C_REFCLK_p,
      output   [16: 0]   DDR4C_A,
      output   [ 1: 0]   DDR4C_BA,
      output   [ 1: 0]   DDR4C_BG,
      output             DDR4C_CK,
      output             DDR4C_CK_n,
      output             DDR4C_CKE,
      inout    [ 8: 0]   DDR4C_DQS,
      inout    [ 8: 0]   DDR4C_DQS_n,
      inout    [71: 0]   DDR4C_DQ,
      inout    [ 8: 0]   DDR4C_DBI_n,
      output             DDR4C_CS_n,
      output             DDR4C_RESET_n,
      output             DDR4C_ODT,
      output             DDR4C_PAR,
      input              DDR4C_ALERT_n,
      output             DDR4C_ACT_n,
      input              DDR4C_EVENT_n,
      inout              DDR4C_SCL,
      inout              DDR4C_SDA,
      input              DDR4C_RZQ,
`endif /*ENABLE_DDR4C*/

`ifdef ENABLE_DDR4D
      ///////// DDR4D /////////
      input              DDR4D_REFCLK_p,
      output   [16: 0]   DDR4D_A,
      output   [ 1: 0]   DDR4D_BA,
      output   [ 1: 0]   DDR4D_BG,
      output             DDR4D_CK,
      output             DDR4D_CK_n,
      output             DDR4D_CKE,
      inout    [ 8: 0]   DDR4D_DQS,
      inout    [ 8: 0]   DDR4D_DQS_n,
      inout    [71: 0]   DDR4D_DQ,
      inout    [ 8: 0]   DDR4D_DBI_n,
      output             DDR4D_CS_n,
      output             DDR4D_RESET_n,
      output             DDR4D_ODT,
      output             DDR4D_PAR,
      input              DDR4D_ALERT_n,
      output             DDR4D_ACT_n,
      input              DDR4D_EVENT_n,
      inout              DDR4D_SCL,
      inout              DDR4D_SDA,
      input              DDR4D_RZQ,
`endif /*ENABLE_DDR4D*/

      ///////// SI5340A0 /////////
      inout              SI5340A0_I2C_SCL,
      inout              SI5340A0_I2C_SDA,
      input              SI5340A0_INTR,
      output             SI5340A0_OE_n,
      output             SI5340A0_RST_n,

      ///////// SI5340A1 /////////
      inout              SI5340A1_I2C_SCL,
      inout              SI5340A1_I2C_SDA,
      input              SI5340A1_INTR,
      output             SI5340A1_OE_n,
      output             SI5340A1_RST_n,

      ///////// I2Cs /////////
      inout              FAN_I2C_SCL,
      inout              FAN_I2C_SDA,
      input              FAN_ALERT_n,
      inout              POWER_MONITOR_I2C_SCL,
      inout              POWER_MONITOR_I2C_SDA,
      input              POWER_MONITOR_ALERT_n,
      inout              TEMP_I2C_SCL,
      inout              TEMP_I2C_SDA,

      ///////// GPIO /////////
      inout    [ 1: 0]   GPIO_CLK,
      inout    [ 3: 0]   GPIO_P,

`ifdef ENABLE_PCIE
      ///////// PCIE /////////
      inout              PCIE_SMBCLK,
      inout              PCIE_SMBDAT,
      input              PCIE_REFCLK_p,
      output   [15: 0]   PCIE_TX_p,
      input    [15: 0]   PCIE_RX_p,
      input              PCIE_PERST_n,
      output             PCIE_WAKE_n,
`endif /*ENABLE_PCIE*/

`ifdef ENABLE_QSFP28A
      ///////// QSFP28A /////////
      input              QSFP28A_REFCLK_p,
      output   [ 3: 0]   QSFP28A_TX_p,
      input    [ 3: 0]   QSFP28A_RX_p,
      input              QSFP28A_INTERRUPT_n,
      output             QSFP28A_LP_MODE,
      input              QSFP28A_MOD_PRS_n,
      output             QSFP28A_MOD_SEL_n,
      output             QSFP28A_RST_n,
      inout              QSFP28A_SCL,
      inout              QSFP28A_SDA,
`endif /*ENABLE_QSFP28A*/

`ifdef ENABLE_QSFP28B
      ///////// QSFP28B /////////
      input              QSFP28B_REFCLK_p,
      output   [ 3: 0]   QSFP28B_TX_p,
      input    [ 3: 0]   QSFP28B_RX_p,
      input              QSFP28B_INTERRUPT_n,
      output             QSFP28B_LP_MODE,
      input              QSFP28B_MOD_PRS_n,
      output             QSFP28B_MOD_SEL_n,
      output             QSFP28B_RST_n,
      inout              QSFP28B_SCL,
      inout              QSFP28B_SDA,
`endif /*ENABLE_QSFP28B*/

`ifdef ENABLE_QSFP28C
      ///////// QSFP28C /////////
      input              QSFP28C_REFCLK_p,
      output   [ 3: 0]   QSFP28C_TX_p,
      input    [ 3: 0]   QSFP28C_RX_p,
      input              QSFP28C_INTERRUPT_n,
      output             QSFP28C_LP_MODE,
      input              QSFP28C_MOD_PRS_n,
      output             QSFP28C_MOD_SEL_n,
      output             QSFP28C_RST_n,
      inout              QSFP28C_SCL,
      inout              QSFP28C_SDA,
`endif /*ENABLE_QSFP28C*/

`ifdef ENABLE_QSFP28D
      ///////// QSFP28D /////////
      input              QSFP28D_REFCLK_p,
      output   [ 3: 0]   QSFP28D_TX_p,
      input    [ 3: 0]   QSFP28D_RX_p,
      input              QSFP28D_INTERRUPT_n,
      output             QSFP28D_LP_MODE,
      input              QSFP28D_MOD_PRS_n,
      output             QSFP28D_MOD_SEL_n,
      output             QSFP28D_RST_n,
      inout              QSFP28D_SCL,
      inout              QSFP28D_SDA,
`endif /*ENABLE_QSFP28D*/

`ifdef ENABLE_HPS
      ///////// HPS /////////

      // USB
      input              HPS_USB0_CLK,
      output             HPS_USB0_STP,
      input              HPS_USB0_DIR,
      inout    [ 7: 0]   HPS_USB0_DATA,
      input              HPS_USB0_NXT,

      // Ethernet
      output             HPS_EMAC0_TX_CLK,
      output             HPS_EMAC0_TX_CTL,
      input              HPS_EMAC0_RX_CLK,
      input              HPS_EMAC0_RX_CTL,
      output   [ 3: 0]   HPS_EMAC0_TXD,
      input    [ 3: 0]   HPS_EMAC0_RXD,
      inout              HPS_EMAC0_MDIO,
      output             HPS_EMAC0_MDC,

      // uart
      output             HPS_UART0_TX,
      input              HPS_UART0_RX,
      output             HPS_FPGA_UART1_TX,
      input              HPS_FPGA_UART1_RX,

      // sdcard
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout    [ 3: 0]   HPS_SD_DATA,
      input              HPS_OSC_CLK,

      // user io
      inout              HPS_LED,
      inout              HPS_KEY,

      // card detection
      inout              HPS_CARD_PRSNT_n,

`endif /*ENABLE_HPS*/



       ///////// EXP /////////
      input              EXP_EN,

      ///////// UFL /////////
      inout              UFL_CLKIN_p,
      inout              UFL_CLKIN_n

/*
    input clk50,
    input cpu_resetn,

    // QSFP
    output wire  qsfp_lowpwr,   // LPMode
    output wire  qsfp_rstn,   // ResetL

    // 10G IO
    input wire clk_ref_r,
    input wire [3:0] rx_serial,
    output wire [3:0] tx_serial,
    output wire [9:0]             user_io,
    output wire [7:0]             user_led
*/

);

  ///////////////////////////
// pin connection
wire 			clk50;  
wire 			cpu_resetn;

wire	      qsfp_rstn;
wire		   qsfp_lowpwr;
wire		   ethA_clk_ref_r;
wire		   ethB_clk_ref_r;
wire		   ethC_clk_ref_r;
wire		   ethD_clk_ref_r;
wire	[3:0] ethA_rx_serial;
wire	[3:0] ethB_rx_serial;
wire	[3:0] ethC_rx_serial;
wire	[3:0] ethD_rx_serial;
wire  [3:0] ethA_tx_serial;
wire  [3:0] ethB_tx_serial;
wire  [3:0] ethC_tx_serial;
wire  [3:0] ethD_tx_serial;

assign clk50 = CLK_50_B2C;
assign cpu_resetn = CPU_RESET_n;
assign LED = 4'b0000;

  
`ifdef ENABLE_QSFP28A
	assign QSFP28A_RST_n = qsfp_rstn;
	assign QSFP28A_LP_MODE = qsfp_lowpwr;
	assign ethA_clk_ref_r = QSFP28A_REFCLK_p;
	assign QSFP28A_TX_p = ethA_tx_serial;
	assign ethA_rx_serial = QSFP28A_RX_p;
`endif // ENABLE_QSFP28A  

`ifdef ENABLE_QSFP28B
	assign QSFP28B_RST_n = qsfp_rstn;
	assign QSFP28B_LP_MODE = qsfp_lowpwr;
	assign ethB_clk_ref_r = QSFP28B_REFCLK_p;
	assign QSFP28B_TX_p = ethB_tx_serial;
	assign ethB_rx_serial = QSFP28B_RX_p;
`endif // ENABLE_QSFP28B  

`ifdef ENABLE_QSFP28C
	assign QSFP28C_RST_n = qsfp_rstn;
	assign QSFP28C_LP_MODE = qsfp_lowpwr;
	assign ethC_clk_ref_r = QSFP28C_REFCLK_p;
	assign QSFP28C_TX_p = ethC_tx_serial;
	assign ethC_rx_serial = QSFP28C_RX_p;
`endif // ENABLE_QSFP28C  

`ifdef ENABLE_QSFP28D
	assign QSFP28D_RST_n = qsfp_rstn;
	assign QSFP28D_LP_MODE = qsfp_lowpwr;
	assign ethD_clk_ref_r = QSFP28D_REFCLK_p;
	assign QSFP28D_TX_p = ethD_tx_serial;
	assign ethD_rx_serial = QSFP28D_RX_p;
`endif // ENABLE_QSFP28D  
  
  
//////////////////////////////
// SI5340A clock config for xcvr


assign SI5340A0_RST_n = 1'b1;
assign SI5340A1_RST_n = 1'b1;

assign SI5340A0_OE_n = 1'b0;
assign SI5340A1_OE_n = 1'b0; 

//////////////////////////////  

    assign qsfp_rstn = 1'b1;
    assign qsfp_lowpwr = 1'b0;

    localparam DEVICE_FAMILY = "Stratix 10";
    localparam WORDS = 8;
    localparam WIDTH = 64;
    localparam SOP_ON_LANE0 = 1'b1;
    localparam SIM_NO_TEMP_SENSE = 1'b0;


    /////////////////////////
    // dev_clr sync-reset
    /////////////////////////

    wire user_mode_sync, arst, iopll_locked, clk100;
    alt_aeuex_user_mode_det dev_clr( .ref_clk(clk100), .user_mode_sync(user_mode_sync));
	 
	 alt_e100s10_sys_pll u0 (
        .rst        (~cpu_resetn),  // reset.reset
        .refclk     (clk50),        // refclk.clk
        .locked     (iopll_locked), // locked.export
        .outclk_0   (clk100)        // outclk0.clk
    );


    assign arst = ~user_mode_sync | ~cpu_resetn | ~iopll_locked;
	 
	 
	 //Instanciranje cijelog eth (ex_100g+fifo_tx+fifo_rx+2*pll)
	 //1. Slucaj - loopback
	 
	 wire [511:0] ethA_fifo_data;
	 wire ethA_fifo_valid;
	 wire ethA_fifo_sop;
	 wire ethA_fifo_eop;
	 wire [5:0] ethA_fifo_empty;
	 wire ethA_fifo_ready;
	 
	 wire [511:0] ethB_fifo_data;
	 wire ethB_fifo_valid;
	 wire ethB_fifo_sop;
	 wire ethB_fifo_eop;
	 wire [5:0] ethB_fifo_empty;
	 wire ethB_fifo_ready;
	 
	 wire [511:0] ethC_fifo_data;
	 wire ethC_fifo_valid;
	 wire ethC_fifo_sop;
	 wire ethC_fifo_eop;
	 wire [5:0] ethC_fifo_empty;
	 wire ethC_fifo_ready;
	 
	 wire [511:0] ethD_fifo_data;
	 wire ethD_fifo_valid;
	 wire ethD_fifo_sop;
	 wire ethD_fifo_eop;
	 wire [5:0] ethD_fifo_empty;
	 wire ethD_fifo_ready;
	 
	 wire ethA_clk390;
	 wire ethB_clk390;
	 wire ethC_clk390;
	 wire ethD_clk390;
	 
	 eth_100g ethA(
	     .rx_serial(ethA_rx_serial),
		  .clk_ref_r(ethA_clk_ref_r),
		  .clk100(clk100),
		  .rst(arst),
		  .tx_serial(ethA_tx_serial),
		  .clk390(ethA_clk390),
		  
		  .fifo_rst(1'b0),
		  .fifo_clk(ethA_clk390),
		  
		  .fifo_out_data(ethA_fifo_data),
		  .fifo_out_valid(ethA_fifo_valid),
		  .fifo_out_sop(ethA_fifo_sop),
		  .fifo_out_eop(ethA_fifo_eop),
		  .fifo_out_empty(ethA_fifo_empty),
		  .fifo_out_ready(ethA_fifo_ready),
		  
		  .fifo_in_data(ethB_fifo_data),
		  .fifo_in_valid(ethB_fifo_valid),
		  .fifo_in_sop(ethB_fifo_sop),
		  .fifo_in_eop(ethB_fifo_eop),
		  .fifo_in_empty(ethB_fifo_empty),
		  .fifo_in_ready(ethB_fifo_ready)
	 );
	 	 
	 eth_100g ethB(
	     .rx_serial(ethB_rx_serial),
		  .clk_ref_r(ethB_clk_ref_r),
		  .clk100(clk100),
		  .rst(arst),
		  .tx_serial(ethB_tx_serial),
		  .clk390(ethB_clk390),
		  
		  .fifo_rst(1'b0),
		  .fifo_clk(ethA_clk390),
		  
		  .fifo_out_data(ethB_fifo_data),
		  .fifo_out_valid(ethB_fifo_valid),
		  .fifo_out_sop(ethB_fifo_sop),
		  .fifo_out_eop(ethB_fifo_eop),
		  .fifo_out_empty(ethB_fifo_empty),
		  .fifo_out_ready(ethB_fifo_ready),
		  
		  .fifo_in_data(ethA_fifo_data),
		  .fifo_in_valid(ethA_fifo_valid),
		  .fifo_in_sop(ethA_fifo_sop),
		  .fifo_in_eop(ethA_fifo_eop),
		  .fifo_in_empty(ethA_fifo_empty),
		  .fifo_in_ready(ethA_fifo_ready)
	 );
	 
	 eth_100g ethC(
	     .rx_serial(ethC_rx_serial),
		  .clk_ref_r(ethC_clk_ref_r),
		  .clk100(clk100),
		  .rst(arst),
		  .tx_serial(ethC_tx_serial),
		  .clk390(ethC_clk390),
		  
		  .fifo_rst(1'b0),
		  .fifo_clk(ethC_clk390),
		  
		  .fifo_out_data(ethC_fifo_data),
		  .fifo_out_valid(ethC_fifo_valid),
		  .fifo_out_sop(ethC_fifo_sop),
		  .fifo_out_eop(ethC_fifo_eop),
		  .fifo_out_empty(ethC_fifo_empty),
		  .fifo_out_ready(ethC_fifo_ready),
		  
		  .fifo_in_data(ethD_fifo_data),
		  .fifo_in_valid(ethD_fifo_valid),
		  .fifo_in_sop(ethD_fifo_sop),
		  .fifo_in_eop(ethD_fifo_eop),
		  .fifo_in_empty(ethD_fifo_empty),
		  .fifo_in_ready(ethD_fifo_ready)
	 );
	 
	 eth_100g ethD(
	     .rx_serial(ethD_rx_serial),
		  .clk_ref_r(ethD_clk_ref_r),
		  .clk100(clk100),
		  .rst(arst),
		  .tx_serial(ethD_tx_serial),
		  .clk390(ethD_clk390),
		  
		  .fifo_rst(1'b0),
		  .fifo_clk(ethC_clk390),
		  
		  .fifo_out_data(ethD_fifo_data),
		  .fifo_out_valid(ethD_fifo_valid),
		  .fifo_out_sop(ethD_fifo_sop),
		  .fifo_out_eop(ethD_fifo_eop),
		  .fifo_out_empty(ethD_fifo_empty),
		  .fifo_out_ready(ethD_fifo_ready),
		  
		  .fifo_in_data(ethC_fifo_data),
		  .fifo_in_valid(ethC_fifo_valid),
		  .fifo_in_sop(ethC_fifo_sop),
		  .fifo_in_eop(ethC_fifo_eop),
		  .fifo_in_empty(ethC_fifo_empty),
		  .fifo_in_ready(ethC_fifo_ready)
	 );
	 
	 	 
    // _____________________________________________________________
    // merge status bus
    // _____________________________________________________________

    /*wire [31:0] status_readdata;
    wire status_readdata_valid, status_waitrequest;

    alt_aeuex_avalon_mm_read_combine #(
        .NUM_CLIENTS         (2)

    ) arc (
        .clk            (clk_status),
        .arst           (arst),
        .host_read        (status_read),
        .host_readdata        (status_readdata),
        .host_readdata_valid    (status_readdata_valid),
        .host_waitrequest    (status_waitrequest),


        .client_readdata_valid    ({status_readdata_valid_eth, reco_readdata_valid}),
        .client_readdata    ({status_readdata_eth, reco_readdata})

    );*/

    // _______________________________________________________________________________________________________________ 
    // jtag_avalon 
    // _______________________________________________________________________________________________________________
  /*  wire [31:0] av_addr;
    assign status_addr = av_addr[17:2];
    wire [3:0] byteenable;

    alt_e100s10_jtag_avalon jtag_master (
        .clk_clk                (clk_status),
        .clk_reset_reset        (arst),
        .master_address         (av_addr),
        .master_readdata        (status_readdata),
        .master_read            (status_read),
        .master_write           (status_write),
        .master_writedata       (status_writedata),
        .master_waitrequest     (status_waitrequest),
        .master_readdatavalid   (status_readdata_valid),
        .master_byteenable      (byteenable),
        .master_reset_reset     ()
    );*/
    // ___________________________________________________________

 
endmodule