// Author: Amina Tankovic
// Description: AXI4-Stream FIFO by Alex Forencich wrapped with Avalon-ST interface

module avalon_fifo#(
    parameter DEPTH = 32768,
    parameter DATA_WIDTH = 512,
    parameter USER_WIDTH = 20,   //1(sop) + 6(empty) + 13(channel)
    parameter FRAME_FIFO = 0,
    parameter DROP_OVERSIZE_FRAME = FRAME_FIFO,
    parameter DROP_WHEN_FULL = 0,
    parameter RAM_PIPELINE = 1
) (
    input logic clk,
    input logic rst,
    avalon_if.in input_avalon,
    avalon_if.out output_avalon,
    output logic [$clog2(DEPTH):0] depth_signal,
    output logic [$clog2(DEPTH):0] depth_signal2
);

axis_fifo #(
     .DEPTH(DEPTH),
     .DATA_WIDTH(DATA_WIDTH),
     .USER_WIDTH(USER_WIDTH),
     //.RAM_PIPELINE(0),                        //BILO ZAKOMENTARISANO U VERZIJI KOJA RADI
     .FRAME_FIFO(FRAME_FIFO),
     .OUTPUT_FIFO_ENABLE(1)
    ) fifo (
     .clk(clk),
     .rst(rst),
     .s_axis_tdata(input_avalon.data),
     .s_axis_tkeep('1),
     .s_axis_tvalid(input_avalon.valid),
     .s_axis_tready(input_avalon.ready),
     .s_axis_tlast(input_avalon.eop),
     .s_axis_tid('0),
     .s_axis_tdest('0),
     .s_axis_tuser({input_avalon.sop, input_avalon.empty, input_avalon.channel}),

     .m_axis_tdata(output_avalon.data),
     .m_axis_tkeep(),
     .m_axis_tvalid(output_avalon.valid),
     .m_axis_tready(output_avalon.ready),
     .m_axis_tlast(output_avalon.eop),
     .m_axis_tid(),
     .m_axis_tdest(),
     .m_axis_tuser({output_avalon.sop, output_avalon.empty, output_avalon.channel}),

     .pause_req(0),
     .pause_ack(),

     .status_depth(depth_signal),
     .status_depth_commit(depth_signal2),
     .status_overflow(),
     .status_bad_frame(),
     .status_good_frame()
);

endmodule


