// Author: Amina Tankovic
// Description: Key scheduler - distributes the key material prepared by key provider through 6 stages (64x64 network) in order to 
//              get the final key and perform selective encryption.

module key_scheduler#(                                     
) (
    input logic clk,
    input logic rst,   
    avalon_if.in from_key_provider,
    avalon_if.out from_distributor 
);

avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp1(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp2(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp3(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp4(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp5(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp6(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp7(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp8(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp9(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp10(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp11(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512), .CHANNEL_WIDTH(455)) outp12(.clk(clk),.rst(rst));

//Omega network 64x64: 6 stages separated by avalon pipeline registers

stage #(
         .stage_order(0)
        ) stage0(
            .input_to_stage(from_key_provider),
            .output_from_stage(outp1)
        );

avalon_pipeline_register first_reg(
            .clk(clk),
            .rst(rst),
            .input_avalon(outp1),
            .output_avalon(outp2)
);

stage #(
         .stage_order(1)
        ) stage1(
            .input_to_stage(outp2),
            .output_from_stage(outp3)
        );

avalon_pipeline_register second_reg(
            .clk(clk),
            .rst(rst),
            .input_avalon(outp3),
            .output_avalon(outp4)
);

stage #(
         .stage_order(2)
        ) stage2(
            .input_to_stage(outp4),
            .output_from_stage(outp5)
        );

avalon_pipeline_register third_reg(
            .clk(clk),
            .rst(rst),
            .input_avalon(outp5),
            .output_avalon(outp6)
);

stage #(
         .stage_order(3)
        ) stage3(
            .input_to_stage(outp6),
            .output_from_stage(outp7)
        );

avalon_pipeline_register fourth_reg(
            .clk(clk),
            .rst(rst),
            .input_avalon(outp7),
            .output_avalon(outp8)
);

stage #(
         .stage_order(4)
        ) stage4(
            .input_to_stage(outp8),
            .output_from_stage(outp9)
        );

avalon_pipeline_register fifth_reg(
            .clk(clk),
            .rst(rst),
            .input_avalon(outp9),
            .output_avalon(outp10)
);

stage #(
         .stage_order(5)
        ) stage5(
            .input_to_stage(outp10),
            .output_from_stage(from_distributor)
        );

endmodule 