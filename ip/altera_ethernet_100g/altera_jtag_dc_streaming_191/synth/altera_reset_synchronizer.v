// (C) 2001-2026 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/26.1.1/ip/iconnect/merlin/altera_reset_controller/altera_reset_synchronizer.v#1 $
// $Revision: #1 $
// $Date: 2026/05/07 $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1 ns / 1 ns

module altera_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=R101" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    (*preserve*) reg [DEPTH-1:0] altera_reset_synchronizer_int_chain;
    reg altera_reset_synchronizer_int_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_reset_synchronizer_int_chain <= {DEPTH{1'b1}};
                altera_reset_synchronizer_int_chain_out <= 1'b1;
            end
            else begin
                altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
                altera_reset_synchronizer_int_chain[DEPTH-1] <= 0;
                altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
            end
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_reset_synchronizer_int_chain[DEPTH-2:0] <= altera_reset_synchronizer_int_chain[DEPTH-1:1];
            altera_reset_synchronizer_int_chain[DEPTH-1] <= reset_in;
            altera_reset_synchronizer_int_chain_out <= altera_reset_synchronizer_int_chain[0];
        end

        assign reset_out = altera_reset_synchronizer_int_chain_out;
 
    end
    endgenerate

endmodule

`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OraYGnqZAGf5M3WGiRIUztRR2XPfDUWtSPZUayeiSjFSmrTPINcfoCe/2a8UnQ2IC7jZaYSgYXZKXilBbr8NDXIXu9io8f7PC+p4+oQf/uerp1rLLS7PivmzhjlGjSNWPE+7KYfnsL2S3nAzUxUd2zNZBKOBEGfZToff5axnXurFANpNl/fuHMpgeS08IiPY21928m0zINQukBxVZxQw+UgJrul+Kw3td6vC1MD9Kfwvuer9PJVtLMpcga1fYQKnuhvJdMA57JPcksizrxLRmZq/RvDtof/CWqA+p8GvjWQf7p53RU5DrgoZww1J/fR3oTbtB1nmqWVUrBpDQi/EvXNb0QnNHiCy55kAsJp+rqhFKKePt9ZyhCxlQB42US6jp2s93WNTWxYSGevfwwIFXtYdp6dxauinTJxkWsGqI+CfvpScn3Jt/3q662tr49gi5duTx1w61n1K0SE9qy9+vx41YfrV6rSy3cm1HlNh9qRPAk35qi7IzKUNJ/RkOeJiHw4sxdE4osPp5pcgOsPN9M7iAcKLozzrlpsFiVyJJ9JjTby2HJAgL/ksrplEaN9BNtEOGP/RyVFHC+U5bpZ9hZVB9k7LY9z0khNzWo2W+lwTXdXUhyBSHuMJPc5KwuqRf3NUatQWgC8jIO4y+yp6NSAI61I81fQ2b0U8nhCvihmfBeA7NvAyHkPCMcIXrKk2C7DheLrpt5Z7URv2iaPRGrBnP/wvdixWAXHxpMHzaUUm7JZttn+lwa6HIW+ulQdnD+3JfWvuYHupARzoVCfX+90Jge40m21EQmAvAe3xLvHe7n47tJUaDnmow5lmFCiM3mMANQnJ0tMFKq59YRwddFq70FKg5bxW0W3L/2xti39KAqyBGNIp46/135P4NoHh/DForp2wgkjuM8fxuprwde/zi/wYc61wylPtBplspVCy6xZpZA2zZ7vqR3qYJK/yW74tuewABSflBvBI90kgQ3j/iXZgfiP7iI7rssA+UygSpVZ0ebHPNzCt9CzDhlCD"
`endif