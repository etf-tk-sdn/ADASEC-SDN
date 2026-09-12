`resetall
`timescale 1ns / 1ps
`default_nettype none

module reset_synchronizer #(
    parameter int unsigned NUM_OUTPUTS = 1
) (
    input  wire                   clk,
    input  wire                   reset,
    output wire [NUM_OUTPUTS-1:0] reset_sync
);

    // Shared stage: asynchronous assertion,
    // synchronous deassertion in the clk domain.
    (* preserve_syn_only *)
    logic reset_pre, reset_pre_2;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reset_pre   <= 1'b1;
            reset_pre_2 <= 1'b1;
        end else begin
            reset_pre   <= 1'b0;
            reset_pre_2 <= reset_pre;
        end
    end

    // Separate reset branch for each consumer.
    generate
        for (genvar g = 0; g < NUM_OUTPUTS; g++) begin : gen_branch

            (* dont_merge, preserve_syn_only *)
            logic [1:0] reset_pipe;

            always_ff @(posedge clk or posedge reset_pre_2) begin
                if (reset_pre_2)
                    reset_pipe <= 2'b11;
                else
                    reset_pipe <= {reset_pipe[0], 1'b0};
            end

            assign reset_sync[g] = reset_pipe[1];
        end
    endgenerate

endmodule

`resetall
