// SPDX-FileCopyrightText: 2026 Amina Tankovic
// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

module eth_100g (
    // Interface to/from QSFP
    input wire [3:0] rx_serial,
    input wire clk_ref_r,
    input wire clk_100,
    input wire rst,
    output wire [3:0] tx_serial,

    input wire rst_avst,
    input wire clk_avst,

    // Avalon-ST interface from FIFO buffer
    output wire [511:0] aso_data,
    output wire aso_valid,
    output wire aso_sop,
    output wire aso_eop,
    output wire [5:0] aso_empty,
    input wire aso_ready,

    // Avalon-ST interface to FIFO buffer
    input wire [511:0] asi_data,
    input wire asi_valid,
    input wire asi_sop,
    input wire asi_eop,
    input wire [5:0] asi_empty,
    output wire asi_ready
);

    localparam DEVICE_FAMILY = "Stratix 10";

    wire serial_clk_1;
    wire pll_locked_1;
    wire serial_clk_2;
    wire pll_locked_2;

    wire [1:0] pll_locked;
    wire [1:0] serial_clk;

    atx_pll_s100 u_atx_pll_1 (
        .pll_refclk0(clk_ref_r), // pll_refclk0.clk
        .tx_serial_clk_gxt(serial_clk_1),
        .pll_locked(pll_locked_1), // pll_locked.pll_locked
        .pll_cal_busy() // pll_cal_busy.pll_cal_busy
    );

    atx_pll_s100 u_atx_pll_2 (
        .pll_refclk0(clk_ref_r), // pll_refclk0.clk
        .tx_serial_clk_gxt(serial_clk_2),
        .pll_locked(pll_locked_2), // pll_locked.pll_locked
        .pll_cal_busy() // pll_cal_busy.pll_cal_busy
    );

    assign pll_locked = {pll_locked_1, pll_locked_2};
    assign serial_clk = {serial_clk_1, serial_clk_2};

    wire clk_tx_mac;
    wire clk_rx_mac;
    wire [511:0] asi_mac_tx_data;
    wire [5:0] asi_mac_tx_empty;
    wire asi_mac_tx_eop;
    wire asi_mac_tx_ready;
    wire asi_mac_tx_sop;
    wire asi_mac_tx_valid;
    wire [511:0] aso_mac_rx_data;
    wire [5:0] aso_mac_rx_empty;
    wire aso_mac_rx_eop;
    wire aso_mac_rx_sop;
    wire aso_mac_rx_valid;
    wire [5:0] aso_mac_rx_error;

    altera_ethernet_100g u_altera_ethernet_100g (
        .clk_ref(clk_ref_r),
        .csr_rst_n(~rst),
        .tx_rst_n(1'b1),
        .rx_rst_n(1'b1),
        .clk_status(clk_100),
        .status_write(1'b0),
        .status_read(1'b0),
        .status_addr({16{1'b0}}),
        .status_writedata({32{1'b0}}),
        .status_readdata(),
        .status_readdata_valid(),
        .status_waitrequest(),

        .clk_txmac(clk_tx_mac),
        .l8_tx_startofpacket(asi_mac_tx_sop),
        .l8_tx_endofpacket(asi_mac_tx_eop),
        .l8_tx_valid(asi_mac_tx_valid),
        .l8_tx_ready(asi_mac_tx_ready),
        .l8_tx_empty(asi_mac_tx_empty),
        .l8_tx_data(asi_mac_tx_data),
        .l8_tx_error(1'b0),
        .clk_rxmac(clk_rx_mac),
        .l8_rx_error(aso_mac_rx_error),
        .l8_rx_valid(aso_mac_rx_valid),
        .l8_rx_startofpacket(aso_mac_rx_sop),
        .l8_rx_endofpacket(aso_mac_rx_eop),
        .l8_rx_empty(aso_mac_rx_empty),
        .l8_rx_data(aso_mac_rx_data),

        .tx_serial(tx_serial),
        .rx_serial(rx_serial),

        .reconfig_clk(clk_100),
        .reconfig_reset(rst),
        .reconfig_write(1'b0),
        .reconfig_read(1'b0),
        .reconfig_address({13{1'b0}}), // 11:0 in top-level entity, 12:0 in documentation
        .reconfig_writedata({32{1'b0}}),
        .reconfig_readdata(),
        .reconfig_waitrequest(),

        .tx_lanes_stable(),
        .rx_pcs_ready(),
        .rx_block_lock(),
        .rx_am_lock(),
        .l8_txstatus_valid(),
        .l8_txstatus_data(),
        .l8_txstatus_error(),
        .l8_rxstatus_valid(),
        .l8_rxstatus_data(),
        .tx_serial_clk(serial_clk),
        .tx_pll_locked(pll_locked)
    );

    avalon_async_fifo u_rx_fifo (
        .asi_clk(clk_rx_mac),
        .asi_rst(1'b0),
        .asi_data(aso_mac_rx_data),
        .asi_valid(aso_mac_rx_valid),
        .asi_eop(aso_mac_rx_eop),
        .asi_sop(aso_mac_rx_sop),
        .asi_empty(aso_mac_rx_empty),
        .asi_ready(),

        .aso_clk(clk_avst),
        .aso_rst(rst_avst),
        .aso_data(aso_data),
        .aso_valid(aso_valid),
        .aso_eop(aso_eop),
        .aso_sop(aso_sop),
        .aso_empty(aso_empty),
        .aso_ready(aso_ready)
    );

    avalon_async_fifo u_tx_fifo (
        .asi_clk(clk_avst),
        .asi_rst(rst_avst),
        .asi_data(asi_data),
        .asi_valid(asi_valid),
        .asi_eop(asi_eop),
        .asi_sop(asi_sop),
        .asi_empty(asi_empty),
        .asi_ready(asi_ready),

        .aso_clk(clk_tx_mac),
        .aso_rst(1'b0),
        .aso_data(asi_mac_tx_data),
        .aso_valid(asi_mac_tx_valid),
        .aso_eop(asi_mac_tx_eop),
        .aso_sop(asi_mac_tx_sop),
        .aso_empty(asi_mac_tx_empty),
        .aso_ready(asi_mac_tx_ready)
    );

endmodule

`resetall
