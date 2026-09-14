// SPDX-FileCopyrightText: 2026 Amina Tankovic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`resetall
`timescale 1ns / 1ps
`default_nettype none

// axis_async_fifo wrapped with Avalon-ST input/output interfaces.
module avalon_async_fifo (
    // Input: RX signals from altera_ethernet_100g
    input wire asi_clk,
    input wire asi_rst,
    input wire [511:0] asi_data,
    input wire asi_valid,
    input wire asi_eop,
    input wire asi_sop,
    input wire [5:0] asi_empty,
    output wire asi_ready, // Unconnected signal

    // Output: TX signals to altera_ethernet_100g
    input wire aso_clk,
    input wire aso_rst,
    output wire [511:0] aso_data,
    output wire aso_valid,
    output wire aso_eop,
    output wire aso_sop,
    output wire [5:0] aso_empty,
    input wire aso_ready
);

    axis_async_fifo #(
        .DEPTH(32768),
        .DATA_WIDTH(512),
        .USER_WIDTH(7), // sop(1) + empty(6)
        .FRAME_FIFO(1),
        .DROP_WHEN_FULL(1)
    ) u_axis_async_fifo (
        .s_clk(asi_clk),
        .s_rst(asi_rst),
        .s_axis_tdata(asi_data),
        .s_axis_tkeep({64{1'b1}}), // KEEP_WIDTH = (DATA_WIDTH + 7) / 8 = 64
        .s_axis_tvalid(asi_valid),
        .s_axis_tready(asi_ready),
        .s_axis_tlast(asi_eop),
        .s_axis_tid({8{1'b0}}), // ID_WIDTH = 8
        .s_axis_tdest({8{1'b0}}), // DEST_WIDTH = 8
        .s_axis_tuser({asi_sop, asi_empty}),

        .m_clk(aso_clk),
        .m_rst(aso_rst),
        .m_axis_tdata(aso_data),
        .m_axis_tkeep(),
        .m_axis_tvalid(aso_valid),
        .m_axis_tready(aso_ready),
        .m_axis_tlast(aso_eop),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser({aso_sop, aso_empty}),

        .s_pause_req(1'b0),
        .s_pause_ack(),
        .m_pause_req(1'b0),
        .m_pause_ack(),

        .s_status_depth(),
        .s_status_depth_commit(),
        .s_status_overflow(),
        .s_status_bad_frame(),
        .s_status_good_frame(),
        .m_status_depth(),
        .m_status_depth_commit(),
        .m_status_overflow(),
        .m_status_bad_frame(),
        .m_status_good_frame()
    );

endmodule

`resetall
