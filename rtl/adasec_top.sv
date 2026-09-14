// SPDX-FileCopyrightText: 2026 Amina Tankovic
// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

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
    // ---------------------------------------------------------------------
    // Avalon-MM adapter for the encryption-instruction RAM
    // ---------------------------------------------------------------------
    // Address map (byte addresses):
    //   0x0000_0000          test/status register
    //   0x0001_0000-0001_FFFF encryption instruction RAM
    //
    // Each of the 1024 instruction rows occupies a 64-byte stride. Words
    // 0-11 contain position_vector[383:0]. Word 12 contains count[6:0] in
    // bits [6:0]. Words 13-15 are reserved and read as zero.
    localparam logic [15:0] INSTRUCTION_WINDOW = 16'h0001;
    localparam logic [3:0] INSTRUCTION_LAST_WORD = 4'd12;

    typedef enum logic [2:0] {
        MM_IDLE,
        MM_READ_WAIT,
        MM_WRITE_READ,
        MM_WRITE_COMMIT
    } mm_state_t;

    mm_state_t mm_state_reg;
    logic [31:0] test_output_reg;
    logic [31:0] avalon_readdata_reg;
    logic avalon_readdatavalid_reg;
    logic avalon_writeresponsevalid_reg;

    logic [9:0] mm_instruction_addr_reg;
    logic [3:0] mm_instruction_word_reg;
    logic [31:0] mm_writedata_reg;
    logic [3:0] mm_byteenable_reg;
    logic [390:0] instruction_rddata_b;
    logic [390:0] instruction_wrdata_b_reg;
    logic [9:0] instruction_rdaddr_b;
    logic instruction_wr_b;

    wire mm_instruction_select =
        (avalon_address[31:16] == INSTRUCTION_WINDOW);
    wire mm_instruction_word_valid =
        (avalon_address[5:2] <= INSTRUCTION_LAST_WORD);
    wire mm_test_select = (avalon_address[31:2] == 30'b0);

    function automatic logic [31:0] merge_byteenable(
        input logic [31:0] old_data,
        input logic [31:0] new_data,
        input logic [3:0] byteenable
    );
        logic [31:0] merged_data;
        begin
            merged_data = old_data;
            for (int byte_index = 0; byte_index < 4; byte_index++) begin
                if (byteenable[byte_index]) begin
                    merged_data[byte_index*8 +: 8] =
                        new_data[byte_index*8 +: 8];
                end
            end
            return merged_data;
        end
    endfunction

    function automatic logic [31:0] select_instruction_word(
        input logic [390:0] row_data,
        input logic [3:0] word_index
    );
        logic [415:0] padded_row;
        begin
            padded_row = '0;
            padded_row[390:0] = row_data;
            if (word_index <= INSTRUCTION_LAST_WORD) begin
                return padded_row[word_index*32 +: 32];
            end
            return 32'b0;
        end
    endfunction

    function automatic logic [390:0] merge_instruction_word(
        input logic [390:0] row_data,
        input logic [3:0] word_index,
        input logic [31:0] write_data,
        input logic [3:0] byteenable
    );
        logic [415:0] padded_row;
        begin
            padded_row = '0;
            padded_row[390:0] = row_data;
            if (word_index <= INSTRUCTION_LAST_WORD) begin
                for (int byte_index = 0; byte_index < 4; byte_index++) begin
                    if (byteenable[byte_index]) begin
                        padded_row[word_index*32 + byte_index*8 +: 8] =
                            write_data[byte_index*8 +: 8];
                    end
                end
            end
            return padded_row[390:0];
        end
    endfunction

    always_comb begin
        if ((mm_state_reg == MM_IDLE) && mm_instruction_select) begin
            instruction_rdaddr_b = avalon_address[15:6];
        end else begin
            instruction_rdaddr_b = mm_instruction_addr_reg;
        end
        instruction_wr_b = (mm_state_reg == MM_WRITE_COMMIT);
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            mm_state_reg <= MM_IDLE;
            test_output_reg <= 32'b0;
            avalon_readdata_reg <= 32'b0;
            avalon_readdatavalid_reg <= 1'b0;
            avalon_writeresponsevalid_reg <= 1'b0;
            mm_instruction_addr_reg <= '0;
            mm_instruction_word_reg <= '0;
            mm_writedata_reg <= '0;
            mm_byteenable_reg <= '0;
            instruction_wrdata_b_reg <= '0;
        end else begin
            avalon_readdatavalid_reg <= 1'b0;
            avalon_writeresponsevalid_reg <= 1'b0;

            case (mm_state_reg)
                MM_IDLE: begin
                    if (avalon_write) begin
                        if (mm_instruction_select &&
                                mm_instruction_word_valid) begin
                            mm_instruction_addr_reg <= avalon_address[15:6];
                            mm_instruction_word_reg <= avalon_address[5:2];
                            mm_writedata_reg <= avalon_writedata;
                            mm_byteenable_reg <= avalon_byteenable;
                            mm_state_reg <= MM_WRITE_READ;
                        end else begin
                            if (mm_test_select) begin
                                test_output_reg <= merge_byteenable(
                                    test_output_reg,
                                    avalon_writedata,
                                    avalon_byteenable
                                );
                            end
                            avalon_writeresponsevalid_reg <= 1'b1;
                        end
                    end else if (avalon_read) begin
                        if (mm_instruction_select &&
                                mm_instruction_word_valid) begin
                            mm_instruction_addr_reg <= avalon_address[15:6];
                            mm_instruction_word_reg <= avalon_address[5:2];
                            mm_state_reg <= MM_READ_WAIT;
                        end else begin
                            if (mm_test_select) begin
                                avalon_readdata_reg <= test_input;
                            end else begin
                                avalon_readdata_reg <= 32'b0;
                            end
                            avalon_readdatavalid_reg <= 1'b1;
                        end
                    end
                end

                MM_READ_WAIT: begin
                    avalon_readdata_reg <= select_instruction_word(
                        instruction_rddata_b,
                        mm_instruction_word_reg
                    );
                    avalon_readdatavalid_reg <= 1'b1;
                    mm_state_reg <= MM_IDLE;
                end

                MM_WRITE_READ: begin
                    instruction_wrdata_b_reg <= merge_instruction_word(
                        instruction_rddata_b,
                        mm_instruction_word_reg,
                        mm_writedata_reg,
                        mm_byteenable_reg
                    );
                    mm_state_reg <= MM_WRITE_COMMIT;
                end

                MM_WRITE_COMMIT: begin
                    // The RAM samples instruction_wr_b and the assembled row
                    // on this edge.
                    avalon_writeresponsevalid_reg <= 1'b1;
                    mm_state_reg <= MM_IDLE;
                end

                default: mm_state_reg <= MM_IDLE;
            endcase
        end
    end

    assign test_output = test_output_reg;
    assign avalon_readdata = avalon_readdata_reg;
    assign avalon_readdatavalid = avalon_readdatavalid_reg;
    assign avalon_writeresponsevalid = avalon_writeresponsevalid_reg;
    assign avalon_waitrequest = (mm_state_reg != MM_IDLE);
    assign avalon_response = 2'b00;

    // ---------------------------------------------------------------------
    // Encryption datapath
    // ---------------------------------------------------------------------
    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(13)
    ) key_material_if (
        .clk(clk),
        .rst(rst)
    );

    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(13)
    ) payload_request_if (
        .clk(clk),
        .rst(rst)
    );

    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(455)
    ) key_vector_if (
        .clk(clk),
        .rst(rst)
    );

    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(455)
    ) scheduled_key_if (
        .clk(clk),
        .rst(rst)
    );

    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(13)
    ) payload_to_encryptor_if (
        .clk(clk),
        .rst(rst)
    );

    avalon_if #(
        .DATA_WIDTH(512),
        .CHANNEL_WIDTH(13)
    ) encrypted_if (
        .clk(clk),
        .rst(rst)
    );

    logic [4:0] payload_packet_index_reg;
    logic [4:0] payload_segment_index_reg;
    logic [9:0] instruction_rdaddr_a;
    logic payload_pipeline_ready;
    logic payload_pipeline_valid;
    logic [511:0] payload_pipeline_data;
    logic payload_pipeline_sop;
    logic payload_pipeline_eop;
    logic [5:0] payload_pipeline_empty;
    wire payload_accept = asi_eth_1_valid && asi_eth_1_ready;

    always_comb begin
        if (asi_eth_1_sop) begin
            instruction_rdaddr_a = {payload_packet_index_reg, 5'b0};
        end else begin
            instruction_rdaddr_a = {
                payload_packet_index_reg,
                payload_segment_index_reg
            };
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            payload_packet_index_reg <= '0;
            payload_segment_index_reg <= '0;
        end else if (payload_accept) begin
            if (asi_eth_1_eop) begin
                payload_packet_index_reg <= payload_packet_index_reg + 1'b1;
                payload_segment_index_reg <= '0;
            end else if (asi_eth_1_sop) begin
                payload_segment_index_reg <= 5'd1;
            end else begin
                payload_segment_index_reg <= payload_segment_index_reg + 1'b1;
            end
        end
    end

    // Fork eth1 atomically: one branch requests a key while the other enters
    // an elastic delay line. Both branches advance on the same input beat.
    assign payload_request_if.data = asi_eth_1_data;
    assign payload_request_if.valid = asi_eth_1_valid &&
        payload_pipeline_ready;
    assign payload_request_if.sop = asi_eth_1_sop;
    assign payload_request_if.eop = asi_eth_1_eop;
    assign payload_request_if.empty = asi_eth_1_empty;
    assign payload_request_if.channel = {3'b0, instruction_rdaddr_a};
    assign asi_eth_1_ready = payload_pipeline_ready &&
        payload_request_if.ready;

    axis_pipeline_register #(
        .DATA_WIDTH(512),
        .KEEP_ENABLE(1),
        .KEEP_WIDTH(64),
        .LAST_ENABLE(1),
        .USER_ENABLE(1),
        .USER_WIDTH(7),
        .REG_TYPE(2),
        .LENGTH(8)
    ) u_payload_delay (
        .clk(clk),
        .rst(rst),
        .s_axis_tdata(asi_eth_1_data),
        .s_axis_tkeep({64{1'b1}}),
        .s_axis_tvalid(asi_eth_1_valid && payload_request_if.ready),
        .s_axis_tready(payload_pipeline_ready),
        .s_axis_tlast(asi_eth_1_eop),
        .s_axis_tid('0),
        .s_axis_tdest('0),
        .s_axis_tuser({asi_eth_1_sop, asi_eth_1_empty}),
        .m_axis_tdata(payload_pipeline_data),
        .m_axis_tkeep(),
        .m_axis_tvalid(payload_pipeline_valid),
        .m_axis_tready(payload_to_encryptor_if.ready),
        .m_axis_tlast(payload_pipeline_eop),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser({payload_pipeline_sop, payload_pipeline_empty})
    );

    assign payload_to_encryptor_if.data = payload_pipeline_data;
    assign payload_to_encryptor_if.valid = payload_pipeline_valid;
    assign payload_to_encryptor_if.sop = payload_pipeline_sop;
    assign payload_to_encryptor_if.eop = payload_pipeline_eop;
    assign payload_to_encryptor_if.empty = payload_pipeline_empty;
    assign payload_to_encryptor_if.channel = '0;

    // Channel 3 remains directly cross-connected to channel 4. Accepted
    // eth3 words are also sampled as key material whenever the key buffer has
    // room; this tap never adds backpressure to the eth3<->eth4 path.
    assign key_material_if.data = asi_eth_3_data;
    assign key_material_if.valid = asi_eth_3_valid && aso_eth_4_ready &&
        key_material_if.ready;
    assign key_material_if.sop = asi_eth_3_sop;
    assign key_material_if.eop = asi_eth_3_eop;
    assign key_material_if.empty = asi_eth_3_empty;
    assign key_material_if.channel = '0;

    key_provider u_key_provider (
        .clk(clk),
        .rst(rst),
        .rdaddrA(instruction_rdaddr_a),
        .addrB(instruction_rdaddr_b),
        .wrdataB(instruction_wrdata_b_reg),
        .wrB(instruction_wr_b),
        .rddataB(instruction_rddata_b),
        .from_pcap_reader(payload_request_if),
        .from_key_generator(key_material_if),
        .to_key_scheduler(key_vector_if)
    );

    key_scheduler u_key_scheduler (
        .clk(clk),
        .rst(rst),
        .from_key_provider(key_vector_if),
        .from_distributor(scheduled_key_if)
    );

    encryption_block u_encryption_block (
        .clk(clk),
        .rst(rst),
        .from_key_scheduler(scheduled_key_if),
        .from_reader_register(payload_to_encryptor_if),
        .encrypted(encrypted_if)
    );

    // eth2 -> eth1 remains a direct cross-connect.
    assign aso_eth_1_data = asi_eth_2_data;
    assign aso_eth_1_valid = asi_eth_2_valid;
    assign aso_eth_1_sop = asi_eth_2_sop;
    assign aso_eth_1_eop = asi_eth_2_eop;
    assign aso_eth_1_empty = asi_eth_2_empty;
    assign asi_eth_2_ready = aso_eth_1_ready;

    // eth1 -> encryptor -> eth2.
    assign aso_eth_2_data = encrypted_if.data;
    assign aso_eth_2_valid = encrypted_if.valid;
    assign aso_eth_2_sop = encrypted_if.sop;
    assign aso_eth_2_eop = encrypted_if.eop;
    assign aso_eth_2_empty = encrypted_if.empty;
    assign encrypted_if.ready = aso_eth_2_ready;

    // eth3 <-> eth4 remains cross-connected in both directions.
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
