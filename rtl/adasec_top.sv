`resetall
`timescale 1ns / 1ps
`default_nettype none

module adasec_top #(
    parameter int unsigned DATA_W = 8,
    parameter int unsigned EMPTY_W = (DATA_W > 8) ?
        $clog2(DATA_W / 8) : 1
) (
    input  wire logic               clk,
    input  wire logic               rst,

    // Avalon-MM interface for CSR access.
    input  wire logic               avalon_read,
    input  wire logic               avalon_write,
    output wire logic               avalon_waitrequest,
    input  wire logic [31:0]        avalon_address,
    input  wire logic [31:0]        avalon_writedata,
    input  wire logic [3:0]         avalon_byteenable,
    output wire logic               avalon_readdatavalid,
    output wire logic               avalon_writeresponsevalid,
    output wire logic [31:0]        avalon_readdata,
    output wire logic [1:0]         avalon_response,

    // Avalon-ST sink and source for Ethernet channel 1.
    input  wire logic [DATA_W-1:0]  asi_eth_1_data,
    input  wire logic               asi_eth_1_valid,
    input  wire logic               asi_eth_1_sop,
    input  wire logic               asi_eth_1_eop,
    input  wire logic [EMPTY_W-1:0] asi_eth_1_empty,
    output wire logic               asi_eth_1_ready,

    output wire logic [DATA_W-1:0]  aso_eth_1_data,
    output wire logic               aso_eth_1_valid,
    output wire logic               aso_eth_1_sop,
    output wire logic               aso_eth_1_eop,
    output wire logic [EMPTY_W-1:0] aso_eth_1_empty,
    input  wire logic               aso_eth_1_ready,

    // Avalon-ST sink and source for Ethernet channel 2.
    input  wire logic [DATA_W-1:0]  asi_eth_2_data,
    input  wire logic               asi_eth_2_valid,
    input  wire logic               asi_eth_2_sop,
    input  wire logic               asi_eth_2_eop,
    input  wire logic [EMPTY_W-1:0] asi_eth_2_empty,
    output wire logic               asi_eth_2_ready,

    output wire logic [DATA_W-1:0]  aso_eth_2_data,
    output wire logic               aso_eth_2_valid,
    output wire logic               aso_eth_2_sop,
    output wire logic               aso_eth_2_eop,
    output wire logic [EMPTY_W-1:0] aso_eth_2_empty,
    input  wire logic               aso_eth_2_ready,

    // Avalon-ST sink and source for Ethernet channel 3.
    input  wire logic [DATA_W-1:0]  asi_eth_3_data,
    input  wire logic               asi_eth_3_valid,
    input  wire logic               asi_eth_3_sop,
    input  wire logic               asi_eth_3_eop,
    input  wire logic [EMPTY_W-1:0] asi_eth_3_empty,
    output wire logic               asi_eth_3_ready,

    output wire logic [DATA_W-1:0]  aso_eth_3_data,
    output wire logic               aso_eth_3_valid,
    output wire logic               aso_eth_3_sop,
    output wire logic               aso_eth_3_eop,
    output wire logic [EMPTY_W-1:0] aso_eth_3_empty,
    input  wire logic               aso_eth_3_ready,

    // Avalon-ST sink and source for Ethernet channel 4.
    input  wire logic [DATA_W-1:0]  asi_eth_4_data,
    input  wire logic               asi_eth_4_valid,
    input  wire logic               asi_eth_4_sop,
    input  wire logic               asi_eth_4_eop,
    input  wire logic [EMPTY_W-1:0] asi_eth_4_empty,
    output wire logic               asi_eth_4_ready,

    output wire logic [DATA_W-1:0]  aso_eth_4_data,
    output wire logic               aso_eth_4_valid,
    output wire logic               aso_eth_4_sop,
    output wire logic               aso_eth_4_eop,
    output wire logic [EMPTY_W-1:0] aso_eth_4_empty,
    input  wire logic               aso_eth_4_ready,

    // Test input and output.
    input  wire logic [31:0]        test_input,
    output wire logic [31:0]        test_output
);
    // CSR - temporary test register.
	 logic [31:0] test_output_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            test_output_reg <= 32'b0;
        end else if (avalon_write) begin
            test_output_reg <= avalon_writedata;
        end
    end

    assign test_output = test_output_reg;
	 
	 assign avalon_readdata = test_input;
	 assign avalon_readdatavalid = 1'b1;
	 assign avalon_waitrequest = 1'b0;
	 
	 // Preserve currently unused inputs at the Reserved Core boundary.
    (* noprune *) logic        unused_avalon_read_reg;
    (* noprune *) logic [31:0] unused_avalon_address_reg;
    (* noprune *) logic [3:0]  unused_avalon_byteenable_reg;

    always_ff @(posedge clk) begin
        unused_avalon_read_reg       <= avalon_read;
        unused_avalon_address_reg    <= avalon_address;
        unused_avalon_byteenable_reg <= avalon_byteenable;
    end

    // Cross-connect Ethernet channels 1 and 2.
    assign aso_eth_1_data = asi_eth_2_data;
    assign aso_eth_1_valid = asi_eth_2_valid;
    assign aso_eth_1_sop = asi_eth_2_sop;
    assign aso_eth_1_eop = asi_eth_2_eop;
    assign aso_eth_1_empty = asi_eth_2_empty;
    assign asi_eth_2_ready = aso_eth_1_ready;

    assign aso_eth_2_data = asi_eth_1_data;
    assign aso_eth_2_valid = asi_eth_1_valid;
    assign aso_eth_2_sop = asi_eth_1_sop;
    assign aso_eth_2_eop = asi_eth_1_eop;
    assign aso_eth_2_empty = asi_eth_1_empty;
    assign asi_eth_1_ready = aso_eth_2_ready;

    // Cross-connect Ethernet channels 3 and 4.
    assign aso_eth_3_data = asi_eth_4_data;
    assign aso_eth_3_valid = asi_eth_4_valid;
    assign aso_eth_3_sop = asi_eth_4_sop;
    assign aso_eth_3_eop = asi_eth_4_eop;
    assign aso_eth_3_empty = asi_eth_4_empty;
    assign asi_eth_4_ready = aso_eth_3_ready;

    assign aso_eth_4_data = asi_eth_3_data;
    assign aso_eth_4_valid = asi_eth_3_valid;
    assign aso_eth_4_sop = asi_eth_3_sop;
    assign aso_eth_4_eop = asi_eth_3_eop;
    assign aso_eth_4_empty = asi_eth_3_empty;
    assign asi_eth_3_ready = aso_eth_4_ready;

endmodule

`resetall
