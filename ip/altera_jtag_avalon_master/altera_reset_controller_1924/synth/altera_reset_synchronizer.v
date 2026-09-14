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
`pragma questa_oem_00 "LX4fNUqnOK9YZXada7z4XBduZSVIzRiCZMV68Nw5pi3jGBzEJ7k/q3e2pe2d5ih5hQ+ItbTsv85ur7WT52QvsISuFabvVGM2dFC3XgapA19E935fa4wOMN7g1FoVOeA23o/bx9lzQi1KwtrGAT3WnWAHbOPjvJVj7gDzuux6BsOeHiRy+Hf4CH1XhQbVVKIHvO4RIGSV91Lrvssmc61f/rmN/00diyYUtd7BjtnlFtP3IcyvE2Lx56JH5/zygnIWjGbp8hf0E0IV0WSvdImlp2y5ZSvXbcG59hqsF3YLaD+HeulEjpVWxGoN/HrpuS+ByJBgoPfbdrVooqQaoolJq4ctRUGBh6lcdniRzeb2DnzaVknmm9yfLXNYVdexc98S9Fu6mN3axQ9ULdEAXPVQZ5bEkEbA2j2xnwJlITGp+sfvm5Dv/uPf8DBlkeYpjZi+fTVCrL62dv5HLfrGdtpZubkEuAYePC2MmjNkOzs28K5hmdKBKVnZmmx4lIFtLooznQfPjdKTBumPNEX8+6LEBBCe7CK12lk5UcIJWHiNeuAuVVW0jhYVLvXVjQroufV387E1tve7qgMERimu+x12VDfYTi34Vg4DiC7m0gW6CgoCSQ+ZfZzCWxyxuWtD74Q7PFHwlB+votC2MwO4QgqjPee3PUhXaX+OB+ieKE7+sLd0yRfQsKWXO8/n3skxzGHAUYE3mqYel2BBgrKOWVb4FueLrXqj395RgLUiU2Mj/B0tAZ4OZzUgjry7rCm3NJE/GRaLhO27d1ohHpCx9St9vsnrMNcEn9S56nLDPir/tJ024kqYHxTFQRGyCJVYuqR54OgVK2pqP7e1Hb2/vhYFYZDL0zTZ7XcWVk+hYF48aLvRxjnCNy5E3XbD8rFSlvQjJ1aZSXqJfBLdjP7VsfBbjRaz2d0MvLj5mvS1bZj9FSg/6M9csmt9U4Pmyv992SzuCimAYkXD+HpU6pL0UFkWzj0+JuRa+lHMvBQcFbIyXIVT+l1X9XWfSUV6ZYHxf95A"
`endif