// SPDX-FileCopyrightText: 2026 Amina Tankovic
// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps

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

module de10_pro_top (
    ///////// CLOCK /////////
    input CLK_100_B3I,
    input CLK_50_B2C,
    input CLK_50_B2L,
    input CLK_50_B3C,
    input CLK_50_B3I,
    input CLK_50_B3L,

    ///////// Buttons /////////
    input CPU_RESET_n,
    input [1:0] BUTTON,

    ///////// Switches /////////
    input [1:0] SW,

    ///////// LED /////////
    output [3:0] LED, // LED is active-low

    ///////// FLASH /////////
    output FLASH_CLK,
    output [27:1] FLASH_A,
    inout [15:0] FLASH_D,
    output FLASH_CE_n,
    output FLASH_WE_n,
    output FLASH_OE_n,
    output FLASH_ADV_n,
    output FLASH_RESET_n,
    input FLASH_RDY_BSY_n,

`ifdef ENABLE_DDR4A
    ///////// DDR4A /////////
    input DDR4A_REFCLK_p,
    output [16:0] DDR4A_A,
    output [1:0] DDR4A_BA,
    output [1:0] DDR4A_BG,
    output DDR4A_CK,
    output DDR4A_CK_n,
    output DDR4A_CKE,
    inout [8:0] DDR4A_DQS,
    inout [8:0] DDR4A_DQS_n,
    inout [71:0] DDR4A_DQ,
    inout [8:0] DDR4A_DBI_n,
    output DDR4A_CS_n,
    output DDR4A_RESET_n,
    output DDR4A_ODT,
    output DDR4A_PAR,
    input DDR4A_ALERT_n,
    output DDR4A_ACT_n,
    input DDR4A_EVENT_n,
    inout DDR4A_SCL,
    inout DDR4A_SDA,
    input DDR4A_RZQ,
`endif // ENABLE_DDR4A

`ifdef ENABLE_DDR4B
    ///////// DDR4B /////////
    input DDR4B_REFCLK_p,
    output [16:0] DDR4B_A,
    output [1:0] DDR4B_BA,
    output [1:0] DDR4B_BG,
    output DDR4B_CK,
    output DDR4B_CK_n,
    output DDR4B_CKE,
    inout [8:0] DDR4B_DQS,
    inout [8:0] DDR4B_DQS_n,
    inout [71:0] DDR4B_DQ,
    inout [8:0] DDR4B_DBI_n,
    output DDR4B_CS_n,
    output DDR4B_RESET_n,
    output DDR4B_ODT,
    output DDR4B_PAR,
    input DDR4B_ALERT_n,
    output DDR4B_ACT_n,
    input DDR4B_EVENT_n,
    inout DDR4B_SCL,
    inout DDR4B_SDA,
    input DDR4B_RZQ,
`endif // ENABLE_DDR4B

`ifdef ENABLE_DDR4C
    ///////// DDR4C /////////
    input DDR4C_REFCLK_p,
    output [16:0] DDR4C_A,
    output [1:0] DDR4C_BA,
    output [1:0] DDR4C_BG,
    output DDR4C_CK,
    output DDR4C_CK_n,
    output DDR4C_CKE,
    inout [8:0] DDR4C_DQS,
    inout [8:0] DDR4C_DQS_n,
    inout [71:0] DDR4C_DQ,
    inout [8:0] DDR4C_DBI_n,
    output DDR4C_CS_n,
    output DDR4C_RESET_n,
    output DDR4C_ODT,
    output DDR4C_PAR,
    input DDR4C_ALERT_n,
    output DDR4C_ACT_n,
    input DDR4C_EVENT_n,
    inout DDR4C_SCL,
    inout DDR4C_SDA,
    input DDR4C_RZQ,
`endif // ENABLE_DDR4C

`ifdef ENABLE_DDR4D
    ///////// DDR4D /////////
    input DDR4D_REFCLK_p,
    output [16:0] DDR4D_A,
    output [1:0] DDR4D_BA,
    output [1:0] DDR4D_BG,
    output DDR4D_CK,
    output DDR4D_CK_n,
    output DDR4D_CKE,
    inout [8:0] DDR4D_DQS,
    inout [8:0] DDR4D_DQS_n,
    inout [71:0] DDR4D_DQ,
    inout [8:0] DDR4D_DBI_n,
    output DDR4D_CS_n,
    output DDR4D_RESET_n,
    output DDR4D_ODT,
    output DDR4D_PAR,
    input DDR4D_ALERT_n,
    output DDR4D_ACT_n,
    input DDR4D_EVENT_n,
    inout DDR4D_SCL,
    inout DDR4D_SDA,
    input DDR4D_RZQ,
`endif // ENABLE_DDR4D

    ///////// SI5340A0 /////////
    inout SI5340A0_I2C_SCL,
    inout SI5340A0_I2C_SDA,
    input SI5340A0_INTR,
    output SI5340A0_OE_n,
    output SI5340A0_RST_n,

    ///////// SI5340A1 /////////
    inout SI5340A1_I2C_SCL,
    inout SI5340A1_I2C_SDA,
    input SI5340A1_INTR,
    output SI5340A1_OE_n,
    output SI5340A1_RST_n,

    ///////// I2Cs /////////
    inout FAN_I2C_SCL,
    inout FAN_I2C_SDA,
    input FAN_ALERT_n,
    inout POWER_MONITOR_I2C_SCL,
    inout POWER_MONITOR_I2C_SDA,
    input POWER_MONITOR_ALERT_n,
    inout TEMP_I2C_SCL,
    inout TEMP_I2C_SDA,

    ///////// GPIO /////////
    inout [1:0] GPIO_CLK,
    inout [3:0] GPIO_P,

`ifdef ENABLE_PCIE
    ///////// PCIE /////////
    inout PCIE_SMBCLK,
    inout PCIE_SMBDAT,
    input PCIE_REFCLK_p,
    output [15:0] PCIE_TX_p,
    input [15:0] PCIE_RX_p,
    input PCIE_PERST_n,
    output PCIE_WAKE_n,
`endif // ENABLE_PCIE

`ifdef ENABLE_QSFP28A
    ///////// QSFP28A /////////
    input QSFP28A_REFCLK_p,
    output [3:0] QSFP28A_TX_p,
    input [3:0] QSFP28A_RX_p,
    input QSFP28A_INTERRUPT_n,
    output QSFP28A_LP_MODE,
    input QSFP28A_MOD_PRS_n,
    output QSFP28A_MOD_SEL_n,
    output QSFP28A_RST_n,
    inout QSFP28A_SCL,
    inout QSFP28A_SDA,
`endif // ENABLE_QSFP28A

`ifdef ENABLE_QSFP28B
    ///////// QSFP28B /////////
    input QSFP28B_REFCLK_p,
    output [3:0] QSFP28B_TX_p,
    input [3:0] QSFP28B_RX_p,
    input QSFP28B_INTERRUPT_n,
    output QSFP28B_LP_MODE,
    input QSFP28B_MOD_PRS_n,
    output QSFP28B_MOD_SEL_n,
    output QSFP28B_RST_n,
    inout QSFP28B_SCL,
    inout QSFP28B_SDA,
`endif // ENABLE_QSFP28B

`ifdef ENABLE_QSFP28C
    ///////// QSFP28C /////////
    input QSFP28C_REFCLK_p,
    output [3:0] QSFP28C_TX_p,
    input [3:0] QSFP28C_RX_p,
    input QSFP28C_INTERRUPT_n,
    output QSFP28C_LP_MODE,
    input QSFP28C_MOD_PRS_n,
    output QSFP28C_MOD_SEL_n,
    output QSFP28C_RST_n,
    inout QSFP28C_SCL,
    inout QSFP28C_SDA,
`endif // ENABLE_QSFP28C

`ifdef ENABLE_QSFP28D
    ///////// QSFP28D /////////
    input QSFP28D_REFCLK_p,
    output [3:0] QSFP28D_TX_p,
    input [3:0] QSFP28D_RX_p,
    input QSFP28D_INTERRUPT_n,
    output QSFP28D_LP_MODE,
    input QSFP28D_MOD_PRS_n,
    output QSFP28D_MOD_SEL_n,
    output QSFP28D_RST_n,
    inout QSFP28D_SCL,
    inout QSFP28D_SDA,
`endif // ENABLE_QSFP28D

`ifdef ENABLE_HPS
    ///////// HPS /////////

    // USB
    input HPS_USB0_CLK,
    output HPS_USB0_STP,
    input HPS_USB0_DIR,
    inout [7:0] HPS_USB0_DATA,
    input HPS_USB0_NXT,

    // Ethernet
    output HPS_EMAC0_TX_CLK,
    output HPS_EMAC0_TX_CTL,
    input HPS_EMAC0_RX_CLK,
    input HPS_EMAC0_RX_CTL,
    output [3:0] HPS_EMAC0_TXD,
    input [3:0] HPS_EMAC0_RXD,
    inout HPS_EMAC0_MDIO,
    output HPS_EMAC0_MDC,

    // uart
    output HPS_UART0_TX,
    input HPS_UART0_RX,
    output HPS_FPGA_UART1_TX,
    input HPS_FPGA_UART1_RX,

    // sdcard
    output HPS_SD_CLK,
    inout HPS_SD_CMD,
    inout [3:0] HPS_SD_DATA,
    input HPS_OSC_CLK,

    // user io
    inout HPS_LED,
    inout HPS_KEY,

    // card detection
    inout HPS_CARD_PRSNT_n,

`endif // ENABLE_HPS

    ///////// EXP /////////
    input EXP_EN,

    ///////// UFL /////////
    inout UFL_CLKIN_p,
    inout UFL_CLKIN_n
);
    // Pin connections
    wire clk_50;
    wire cpu_reset_n;

    wire qsfp_rst_n;
    wire qsfp_low_pwr;
    wire eth_1_clk_ref_r;
    wire eth_2_clk_ref_r;
    wire eth_3_clk_ref_r;
    wire eth_4_clk_ref_r;
    wire [3:0] eth_1_rx_serial;
    wire [3:0] eth_2_rx_serial;
    wire [3:0] eth_3_rx_serial;
    wire [3:0] eth_4_rx_serial;
    wire [3:0] eth_1_tx_serial;
    wire [3:0] eth_2_tx_serial;
    wire [3:0] eth_3_tx_serial;
    wire [3:0] eth_4_tx_serial;

    assign clk_50 = CLK_50_B2C;
    assign cpu_reset_n = CPU_RESET_n;

    `ifdef ENABLE_QSFP28A
        assign QSFP28A_RST_n = qsfp_rst_n;
        assign QSFP28A_LP_MODE = qsfp_low_pwr;
        assign eth_1_clk_ref_r = QSFP28A_REFCLK_p;
        assign QSFP28A_TX_p = eth_1_tx_serial;
        assign eth_1_rx_serial = QSFP28A_RX_p;
    `endif // ENABLE_QSFP28A

    `ifdef ENABLE_QSFP28B
        assign QSFP28B_RST_n = qsfp_rst_n;
        assign QSFP28B_LP_MODE = qsfp_low_pwr;
        assign eth_2_clk_ref_r = QSFP28B_REFCLK_p;
        assign QSFP28B_TX_p = eth_2_tx_serial;
        assign eth_2_rx_serial = QSFP28B_RX_p;
    `endif // ENABLE_QSFP28B

    `ifdef ENABLE_QSFP28C
        assign QSFP28C_RST_n = qsfp_rst_n;
        assign QSFP28C_LP_MODE = qsfp_low_pwr;
        assign eth_3_clk_ref_r = QSFP28C_REFCLK_p;
        assign QSFP28C_TX_p = eth_3_tx_serial;
        assign eth_3_rx_serial = QSFP28C_RX_p;
    `endif // ENABLE_QSFP28C

    `ifdef ENABLE_QSFP28D
        assign QSFP28D_RST_n = qsfp_rst_n;
        assign QSFP28D_LP_MODE = qsfp_low_pwr;
        assign eth_4_clk_ref_r = QSFP28D_REFCLK_p;
        assign QSFP28D_TX_p = eth_4_tx_serial;
        assign eth_4_rx_serial = QSFP28D_RX_p;
    `endif // ENABLE_QSFP28D

    // SI5340A clock configuration for the transceivers
    assign SI5340A0_RST_n = 1'b1;
    assign SI5340A1_RST_n = 1'b1;
    assign SI5340A0_OE_n = 1'b0;
    assign SI5340A1_OE_n = 1'b0;

    assign qsfp_rst_n = 1'b1;
    assign qsfp_low_pwr = 1'b0;

    localparam DEVICE_FAMILY = "Stratix 10";
    localparam WORDS = 8;
    localparam WIDTH = 64;
    localparam SOP_ON_LANE0 = 1'b1;
    localparam SIM_NO_TEMP_SENSE = 1'b0;

    wire ninit_done, arst, io_pll_locked, clk_100, clk_300;
    wire [5:0] rst_300;

    altera_reset_release u_reset_release (
        .ninit_done(ninit_done)
    );

    altera_system_pll u_system_pll (
        .rst(~cpu_reset_n | ninit_done), // reset.reset
        .refclk(clk_50), // refclk.clk
        .locked(io_pll_locked), // locked.export
        .outclk_0(clk_100), // outclk0.clk
        .outclk_1(clk_300) // outclk1.clk
    );

    assign arst = ninit_done | ~cpu_reset_n | ~io_pll_locked;

    reset_synchronizer #(
        .NUM_OUTPUTS(6)
    ) u_reset_sync_clk_300 (
        .clk(clk_300),
        .reset(arst),
        .reset_sync(rst_300)
    );

    // Four Ethernet instances
    wire [511:0] asi_eth_1_data;
    wire asi_eth_1_valid;
    wire asi_eth_1_sop;
    wire asi_eth_1_eop;
    wire [5:0] asi_eth_1_empty;
    wire asi_eth_1_ready;
    wire [511:0] aso_eth_1_data;
    wire aso_eth_1_valid;
    wire aso_eth_1_sop;
    wire aso_eth_1_eop;
    wire [5:0] aso_eth_1_empty;
    wire aso_eth_1_ready;

    wire [511:0] asi_eth_2_data;
    wire asi_eth_2_valid;
    wire asi_eth_2_sop;
    wire asi_eth_2_eop;
    wire [5:0] asi_eth_2_empty;
    wire asi_eth_2_ready;
    wire [511:0] aso_eth_2_data;
    wire aso_eth_2_valid;
    wire aso_eth_2_sop;
    wire aso_eth_2_eop;
    wire [5:0] aso_eth_2_empty;
    wire aso_eth_2_ready;

    wire [511:0] asi_eth_3_data;
    wire asi_eth_3_valid;
    wire asi_eth_3_sop;
    wire asi_eth_3_eop;
    wire [5:0] asi_eth_3_empty;
    wire asi_eth_3_ready;
    wire [511:0] aso_eth_3_data;
    wire aso_eth_3_valid;
    wire aso_eth_3_sop;
    wire aso_eth_3_eop;
    wire [5:0] aso_eth_3_empty;
    wire aso_eth_3_ready;

    wire [511:0] asi_eth_4_data;
    wire asi_eth_4_valid;
    wire asi_eth_4_sop;
    wire asi_eth_4_eop;
    wire [5:0] asi_eth_4_empty;
    wire asi_eth_4_ready;
    wire [511:0] aso_eth_4_data;
    wire aso_eth_4_valid;
    wire aso_eth_4_sop;
    wire aso_eth_4_eop;
    wire [5:0] aso_eth_4_empty;
    wire aso_eth_4_ready;

    eth_100g u_eth_1 (
        .rx_serial(eth_1_rx_serial),
        .clk_ref_r(eth_1_clk_ref_r),
        .clk_100(clk_100),
        .rst(arst),
        .tx_serial(eth_1_tx_serial),

        .rst_avst(rst_300[0]),
        .clk_avst(clk_300),

        .aso_data(asi_eth_1_data),
        .aso_valid(asi_eth_1_valid),
        .aso_sop(asi_eth_1_sop),
        .aso_eop(asi_eth_1_eop),
        .aso_empty(asi_eth_1_empty),
        .aso_ready(asi_eth_1_ready),

        .asi_data(aso_eth_1_data),
        .asi_valid(aso_eth_1_valid),
        .asi_sop(aso_eth_1_sop),
        .asi_eop(aso_eth_1_eop),
        .asi_empty(aso_eth_1_empty),
        .asi_ready(aso_eth_1_ready)
    );

    eth_100g u_eth_2 (
        .rx_serial(eth_2_rx_serial),
        .clk_ref_r(eth_2_clk_ref_r),
        .clk_100(clk_100),
        .rst(arst),
        .tx_serial(eth_2_tx_serial),

        .rst_avst(rst_300[1]),
        .clk_avst(clk_300),

        .aso_data(asi_eth_2_data),
        .aso_valid(asi_eth_2_valid),
        .aso_sop(asi_eth_2_sop),
        .aso_eop(asi_eth_2_eop),
        .aso_empty(asi_eth_2_empty),
        .aso_ready(asi_eth_2_ready),

        .asi_data(aso_eth_2_data),
        .asi_valid(aso_eth_2_valid),
        .asi_sop(aso_eth_2_sop),
        .asi_eop(aso_eth_2_eop),
        .asi_empty(aso_eth_2_empty),
        .asi_ready(aso_eth_2_ready)
    );

    eth_100g u_eth_3 (
        .rx_serial(eth_3_rx_serial),
        .clk_ref_r(eth_3_clk_ref_r),
        .clk_100(clk_100),
        .rst(arst),
        .tx_serial(eth_3_tx_serial),

        .rst_avst(rst_300[2]),
        .clk_avst(clk_300),

        .aso_data(asi_eth_3_data),
        .aso_valid(asi_eth_3_valid),
        .aso_sop(asi_eth_3_sop),
        .aso_eop(asi_eth_3_eop),
        .aso_empty(asi_eth_3_empty),
        .aso_ready(asi_eth_3_ready),

        .asi_data(aso_eth_3_data),
        .asi_valid(aso_eth_3_valid),
        .asi_sop(aso_eth_3_sop),
        .asi_eop(aso_eth_3_eop),
        .asi_empty(aso_eth_3_empty),
        .asi_ready(aso_eth_3_ready)
    );

    eth_100g u_eth_4 (
        .rx_serial(eth_4_rx_serial),
        .clk_ref_r(eth_4_clk_ref_r),
        .clk_100(clk_100),
        .rst(arst),
        .tx_serial(eth_4_tx_serial),

        .rst_avst(rst_300[3]),
        .clk_avst(clk_300),

        .aso_data(asi_eth_4_data),
        .aso_valid(asi_eth_4_valid),
        .aso_sop(asi_eth_4_sop),
        .aso_eop(asi_eth_4_eop),
        .aso_empty(asi_eth_4_empty),
        .aso_ready(asi_eth_4_ready),

        .asi_data(aso_eth_4_data),
        .asi_valid(aso_eth_4_valid),
        .asi_sop(aso_eth_4_sop),
        .asi_eop(aso_eth_4_eop),
        .asi_empty(aso_eth_4_empty),
        .asi_ready(aso_eth_4_ready)
    );

    // ADASEC dataplane
    wire [31:0] avalon_address;       // Address output of Avalon Memory Mapped Host
    wire [31:0] avalon_readdata;      // Read Data input to Avalon Memory Mapped Host
    wire        avalon_read;          // Read command from Avalon Memory Mapped Host
    wire        avalon_write;         // Write command from Avalon Memory Mapped Host
    wire [31:0] avalon_writedata;     // Write Data from Avalon Memory Mapped Host
    wire        avalon_waitrequest;   // Wait request from Avalon Memory Mapped Agent, indicates agent is not ready
    wire        avalon_readdatavalid; // Valid read data indication from Avalon Memory Mapped Agent
    wire [3:0]  avalon_byteenable;    // Indicates valid write data/read data location

    wire [31:0] test_input;
    wire [31:0] test_output;

    adasec_top #(
        .DATA_W(512),
        .EMPTY_W(6)
    ) u_adasec_top (
        .clk(clk_300),
        .rst(rst_300[4]),

        .avalon_read(avalon_read),
        .avalon_write(avalon_write),
        .avalon_waitrequest(avalon_waitrequest),
        .avalon_address(avalon_address),
        .avalon_writedata(avalon_writedata),
        .avalon_byteenable(avalon_byteenable),
        .avalon_readdatavalid(avalon_readdatavalid),
        .avalon_writeresponsevalid(),
        .avalon_readdata(avalon_readdata),
        .avalon_response(),

        .asi_eth_1_data(asi_eth_1_data),
        .asi_eth_1_valid(asi_eth_1_valid),
        .asi_eth_1_sop(asi_eth_1_sop),
        .asi_eth_1_eop(asi_eth_1_eop),
        .asi_eth_1_empty(asi_eth_1_empty),
        .asi_eth_1_ready(asi_eth_1_ready),
        .aso_eth_1_data(aso_eth_1_data),
        .aso_eth_1_valid(aso_eth_1_valid),
        .aso_eth_1_sop(aso_eth_1_sop),
        .aso_eth_1_eop(aso_eth_1_eop),
        .aso_eth_1_empty(aso_eth_1_empty),
        .aso_eth_1_ready(aso_eth_1_ready),

        .asi_eth_2_data(asi_eth_2_data),
        .asi_eth_2_valid(asi_eth_2_valid),
        .asi_eth_2_sop(asi_eth_2_sop),
        .asi_eth_2_eop(asi_eth_2_eop),
        .asi_eth_2_empty(asi_eth_2_empty),
        .asi_eth_2_ready(asi_eth_2_ready),
        .aso_eth_2_data(aso_eth_2_data),
        .aso_eth_2_valid(aso_eth_2_valid),
        .aso_eth_2_sop(aso_eth_2_sop),
        .aso_eth_2_eop(aso_eth_2_eop),
        .aso_eth_2_empty(aso_eth_2_empty),
        .aso_eth_2_ready(aso_eth_2_ready),

        .asi_eth_3_data(asi_eth_3_data),
        .asi_eth_3_valid(asi_eth_3_valid),
        .asi_eth_3_sop(asi_eth_3_sop),
        .asi_eth_3_eop(asi_eth_3_eop),
        .asi_eth_3_empty(asi_eth_3_empty),
        .asi_eth_3_ready(asi_eth_3_ready),
        .aso_eth_3_data(aso_eth_3_data),
        .aso_eth_3_valid(aso_eth_3_valid),
        .aso_eth_3_sop(aso_eth_3_sop),
        .aso_eth_3_eop(aso_eth_3_eop),
        .aso_eth_3_empty(aso_eth_3_empty),
        .aso_eth_3_ready(aso_eth_3_ready),

        .asi_eth_4_data(asi_eth_4_data),
        .asi_eth_4_valid(asi_eth_4_valid),
        .asi_eth_4_sop(asi_eth_4_sop),
        .asi_eth_4_eop(asi_eth_4_eop),
        .asi_eth_4_empty(asi_eth_4_empty),
        .asi_eth_4_ready(asi_eth_4_ready),
        .aso_eth_4_data(aso_eth_4_data),
        .aso_eth_4_valid(aso_eth_4_valid),
        .aso_eth_4_sop(aso_eth_4_sop),
        .aso_eth_4_eop(aso_eth_4_eop),
        .aso_eth_4_empty(aso_eth_4_empty),
        .aso_eth_4_ready(aso_eth_4_ready),

        .test_input(test_input),
        .test_output(test_output)
    );

    assign test_input = {BUTTON, SW, test_output[27:0]};
    assign LED = ~test_output[3:0];

    altera_jtag_avalon_master u_jtag_avalon_master (
        .clk_clk(clk_300),
        .clk_reset_reset(rst_300[5]),
        .master_reset_reset(),
        .master_address(avalon_address),
        .master_readdata(avalon_readdata),
        .master_read(avalon_read),
        .master_write(avalon_write),
        .master_writedata(avalon_writedata),
        .master_waitrequest(avalon_waitrequest),
        .master_readdatavalid(avalon_readdatavalid),
        .master_byteenable(avalon_byteenable)
    );

endmodule

`resetall
