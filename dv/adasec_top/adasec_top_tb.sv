`timescale 1ns/1ps

module adasec_top_tb;
    localparam int MAX_EXPECTED_BEATS = 32;

    localparam int POSITION_IDENTITY = 0;
    localparam int POSITION_SELECTIVE = 1;
    localparam int POSITION_MULTI_FIRST = 2;
    localparam int POSITION_MULTI_SECOND = 3;
    localparam int POSITION_REVERSE = 4;

    logic clk = 1'b0;
    logic rst = 1'b1;

    logic avalon_read = 1'b0;
    logic avalon_write = 1'b0;
    wire avalon_waitrequest;
    logic [31:0] avalon_address = '0;
    logic [31:0] avalon_writedata = '0;
    logic [3:0] avalon_byteenable = 4'hf;
    wire avalon_readdatavalid;
    wire avalon_writeresponsevalid;
    wire [31:0] avalon_readdata;
    wire [1:0] avalon_response;

    logic [511:0] asi_eth_1_data = '0;
    logic asi_eth_1_valid = 1'b0;
    logic asi_eth_1_sop = 1'b0;
    logic asi_eth_1_eop = 1'b0;
    logic [5:0] asi_eth_1_empty = '0;
    wire asi_eth_1_ready;
    wire [511:0] aso_eth_1_data;
    wire aso_eth_1_valid;
    wire aso_eth_1_sop;
    wire aso_eth_1_eop;
    wire [5:0] aso_eth_1_empty;
    logic aso_eth_1_ready = 1'b1;

    logic [511:0] asi_eth_2_data = '0;
    logic asi_eth_2_valid = 1'b0;
    logic asi_eth_2_sop = 1'b0;
    logic asi_eth_2_eop = 1'b0;
    logic [5:0] asi_eth_2_empty = '0;
    wire asi_eth_2_ready;
    wire [511:0] aso_eth_2_data;
    wire aso_eth_2_valid;
    wire aso_eth_2_sop;
    wire aso_eth_2_eop;
    wire [5:0] aso_eth_2_empty;
    logic aso_eth_2_ready = 1'b1;

    logic [511:0] asi_eth_3_data = '0;
    logic asi_eth_3_valid = 1'b0;
    logic asi_eth_3_sop = 1'b0;
    logic asi_eth_3_eop = 1'b0;
    logic [5:0] asi_eth_3_empty = '0;
    wire asi_eth_3_ready;
    wire [511:0] aso_eth_3_data;
    wire aso_eth_3_valid;
    wire aso_eth_3_sop;
    wire aso_eth_3_eop;
    wire [5:0] aso_eth_3_empty;
    logic aso_eth_3_ready = 1'b1;

    logic [511:0] asi_eth_4_data = '0;
    logic asi_eth_4_valid = 1'b0;
    logic asi_eth_4_sop = 1'b0;
    logic asi_eth_4_eop = 1'b0;
    logic [5:0] asi_eth_4_empty = '0;
    wire asi_eth_4_ready;
    wire [511:0] aso_eth_4_data;
    wire aso_eth_4_valid;
    wire aso_eth_4_sop;
    wire aso_eth_4_eop;
    wire [5:0] aso_eth_4_empty;
    logic aso_eth_4_ready = 1'b1;

    logic [31:0] test_input = 32'h1234_5678;
    wire [31:0] test_output;

    logic [2047:0] key_model;
    int key_model_bits;

    logic [511:0] expected_data [0:MAX_EXPECTED_BEATS-1];
    logic expected_sop [0:MAX_EXPECTED_BEATS-1];
    logic expected_eop [0:MAX_EXPECTED_BEATS-1];
    logic [5:0] expected_empty [0:MAX_EXPECTED_BEATS-1];
    int expected_write_count = 0;
    int expected_read_count = 0;
    int checked_at_test_start;

    always #5 clk = ~clk;

    adasec_top #(
        .DATA_W(512),
        .EMPTY_W(6)
    ) dut (
        .clk(clk),
        .rst(rst),
        .avalon_read(avalon_read),
        .avalon_write(avalon_write),
        .avalon_waitrequest(avalon_waitrequest),
        .avalon_address(avalon_address),
        .avalon_writedata(avalon_writedata),
        .avalon_byteenable(avalon_byteenable),
        .avalon_readdatavalid(avalon_readdatavalid),
        .avalon_writeresponsevalid(avalon_writeresponsevalid),
        .avalon_readdata(avalon_readdata),
        .avalon_response(avalon_response),
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

    function automatic logic [5:0] test_position(
        input int pattern,
        input int index
    );
        case (pattern)
            POSITION_IDENTITY: test_position = index[5:0];
            POSITION_SELECTIVE: begin
                case (index)
                    0: test_position = 6'd1;
                    1: test_position = 6'd7;
                    2: test_position = 6'd32;
                    default: test_position = 6'd63;
                endcase
            end
            POSITION_MULTI_FIRST: begin
                case (index)
                    0: test_position = 6'd63;
                    1: test_position = 6'd0;
                    default: test_position = 6'd31;
                endcase
            end
            POSITION_MULTI_SECOND: begin
                case (index)
                    0: test_position = 6'd2;
                    1: test_position = 6'd3;
                    2: test_position = 6'd5;
                    3: test_position = 6'd8;
                    4: test_position = 6'd13;
                    5: test_position = 6'd21;
                    6: test_position = 6'd34;
                    default: test_position = 6'd55;
                endcase
            end
            POSITION_REVERSE: test_position = 6'd63-index[5:0];
            default: test_position = '0;
        endcase
    endfunction

    function automatic logic [390:0] make_instruction(
        input int byte_count,
        input int pattern
    );
        logic [390:0] instruction;
        begin
            instruction = '0;
            instruction[390:384] = byte_count[6:0];
            for (int index = 0; index < byte_count; index++) begin
                instruction[383-index*6 -: 6] =
                    test_position(pattern, index);
            end
            return instruction;
        end
    endfunction

    function automatic logic [511:0] make_word(input logic [7:0] seed);
        logic [511:0] word;
        begin
            for (int index = 0; index < 64; index++) begin
                word[511-index*8 -: 8] = seed + index[7:0];
            end
            return word;
        end
    endfunction

    function automatic logic [511:0] expected_ciphertext(
        input logic [511:0] payload,
        input logic [390:0] instruction
    );
        logic [511:0] result;
        logic [5:0] position;
        int byte_count;
        begin
            result = payload;
            byte_count = instruction[390:384];
            if (byte_count > 64) begin
                byte_count = 64;
            end
            for (int index = 0; index < byte_count; index++) begin
                position = instruction[383-index*6 -: 6];
                result[511-position*8 -: 8] =
                    result[511-position*8 -: 8] ^
                    key_model[2047-index*8 -: 8];
            end
            return result;
        end
    endfunction

    task automatic mm_write_word(
        input logic [31:0] address,
        input logic [31:0] data,
        input logic [3:0] byteenable
    );
        int timeout;
        begin
            while (avalon_waitrequest) @(posedge clk);
            @(negedge clk);
            avalon_address = address;
            avalon_writedata = data;
            avalon_byteenable = byteenable;
            avalon_write = 1'b1;
            @(posedge clk);
            @(negedge clk);
            avalon_write = 1'b0;

            timeout = 0;
            while (!avalon_writeresponsevalid && timeout < 20) begin
                @(posedge clk);
                timeout++;
            end
            if (!avalon_writeresponsevalid) begin
                $fatal(1, "Avalon-MM write timeout at address %08h", address);
            end
            @(posedge clk);
        end
    endtask

    task automatic mm_read_word(
        input logic [31:0] address,
        output logic [31:0] data
    );
        int timeout;
        begin
            while (avalon_waitrequest) @(posedge clk);
            @(negedge clk);
            avalon_address = address;
            avalon_read = 1'b1;
            @(posedge clk);
            @(negedge clk);
            avalon_read = 1'b0;

            timeout = 0;
            while (!avalon_readdatavalid && timeout < 20) begin
                @(posedge clk);
                timeout++;
            end
            if (!avalon_readdatavalid) begin
                $fatal(1, "Avalon-MM read timeout at address %08h", address);
            end
            data = avalon_readdata;
            @(posedge clk);
        end
    endtask

    task automatic program_instruction(
        input int row_index,
        input logic [390:0] instruction
    );
        logic [415:0] padded_instruction;
        logic [31:0] readback;
        logic [31:0] word;
        logic [31:0] address;
        begin
            padded_instruction = '0;
            padded_instruction[390:0] = instruction;

            for (int word_index = 0; word_index <= 12; word_index++) begin
                address = 32'h0001_0000 + row_index*64 + word_index*4;
                word = padded_instruction[word_index*32 +: 32];
                mm_write_word(address, word, 4'hf);
            end

            for (int word_index = 0; word_index <= 12; word_index++) begin
                address = 32'h0001_0000 + row_index*64 + word_index*4;
                mm_read_word(address, readback);
                word = padded_instruction[word_index*32 +: 32];
                if (readback !== word) begin
                    $fatal(1,
                        "Instruction RAM mismatch row=%0d word=%0d got=%08h expected=%08h",
                        row_index, word_index, readback, word);
                end
            end
        end
    endtask

    task automatic reset_datapath;
        begin
            if (expected_read_count != expected_write_count) begin
                $fatal(1, "Reset requested with pending expected output");
            end
            @(negedge clk);
            rst = 1'b1;
            avalon_read = 1'b0;
            avalon_write = 1'b0;
            asi_eth_1_valid = 1'b0;
            asi_eth_2_valid = 1'b0;
            asi_eth_3_valid = 1'b0;
            asi_eth_4_valid = 1'b0;
            aso_eth_1_ready = 1'b1;
            aso_eth_2_ready = 1'b1;
            aso_eth_3_ready = 1'b1;
            aso_eth_4_ready = 1'b1;
            repeat (4) @(posedge clk);
            @(negedge clk);
            rst = 1'b0;
            key_model = '0;
            key_model_bits = 0;
            repeat (3) @(posedge clk);
        end
    endtask

    task automatic append_key_model(input logic [511:0] key_word);
        logic [2047:0] extended_word;
        begin
            if (key_model_bits > 1536) begin
                $fatal(1, "Test attempted to overflow the key model");
            end
            extended_word = {key_word, {1536{1'b0}}};
            key_model = key_model ^ (extended_word >> key_model_bits);
            key_model_bits = key_model_bits + 512;
        end
    endtask

    task automatic send_key_word(input logic [511:0] key_word);
        begin
            if (dut.key_material_if.ready !== 1'b1) begin
                $fatal(1, "Key buffer unexpectedly not ready");
            end
            @(negedge clk);
            asi_eth_3_data = key_word;
            asi_eth_3_valid = 1'b1;
            asi_eth_3_sop = 1'b1;
            asi_eth_3_eop = 1'b1;
            asi_eth_3_empty = '0;
            @(posedge clk);
            if (!asi_eth_3_ready || !aso_eth_4_valid ||
                    (aso_eth_4_data !== key_word)) begin
                $fatal(1, "eth3->eth4 cross-connect/key tap failed");
            end
            append_key_model(key_word);
            @(negedge clk);
            asi_eth_3_valid = 1'b0;
            asi_eth_3_sop = 1'b0;
            asi_eth_3_eop = 1'b0;
        end
    endtask

    task automatic queue_expected_output(
        input logic [511:0] payload,
        input logic [390:0] instruction,
        input logic sop,
        input logic eop,
        input logic [5:0] empty
    );
        int byte_count;
        begin
            if (expected_write_count >= MAX_EXPECTED_BEATS) begin
                $fatal(1, "Expected-output queue overflow");
            end
            if (key_model_bits < 512) begin
                $fatal(1, "Payload accepted without one complete key word");
            end

            expected_data[expected_write_count] =
                expected_ciphertext(payload, instruction);
            expected_sop[expected_write_count] = sop;
            expected_eop[expected_write_count] = eop;
            expected_empty[expected_write_count] = empty;
            expected_write_count++;

            byte_count = instruction[390:384];
            if (byte_count > 64) begin
                byte_count = 64;
            end
            key_model = key_model << (byte_count*8);
            key_model_bits = key_model_bits - byte_count*8;
        end
    endtask

    task automatic send_payload_beat(
        input logic [511:0] payload,
        input logic [390:0] instruction,
        input logic sop,
        input logic eop,
        input logic [5:0] empty
    );
        int timeout;
        begin
            @(negedge clk);
            asi_eth_1_data = payload;
            asi_eth_1_valid = 1'b1;
            asi_eth_1_sop = sop;
            asi_eth_1_eop = eop;
            asi_eth_1_empty = empty;

            timeout = 0;
            do begin
                @(posedge clk);
                timeout++;
                if (timeout >= 200) begin
                    $fatal(1, "Timeout waiting for eth1 ready");
                end
            end while (!asi_eth_1_ready);

            queue_expected_output(payload, instruction, sop, eop, empty);
            @(negedge clk);
            asi_eth_1_valid = 1'b0;
            asi_eth_1_sop = 1'b0;
            asi_eth_1_eop = 1'b0;
            asi_eth_1_empty = '0;
        end
    endtask

    task automatic wait_for_all_outputs;
        int timeout;
        begin
            timeout = 0;
            while ((expected_read_count < expected_write_count) &&
                    (timeout < 500)) begin
                @(posedge clk);
                timeout++;
            end
            if (expected_read_count != expected_write_count) begin
                $fatal(1,
                    "Timed out waiting for outputs: checked=%0d queued=%0d",
                    expected_read_count, expected_write_count);
            end
        end
    endtask

    task automatic check_other_cross_connects;
        logic [511:0] eth2_word;
        logic [511:0] eth4_word;
        begin
            eth2_word = make_word(8'h21);
            eth4_word = make_word(8'h91);
            @(negedge clk);
            asi_eth_2_data = eth2_word;
            asi_eth_2_valid = 1'b1;
            asi_eth_2_sop = 1'b1;
            asi_eth_2_eop = 1'b1;
            asi_eth_4_data = eth4_word;
            asi_eth_4_valid = 1'b1;
            asi_eth_4_sop = 1'b1;
            asi_eth_4_eop = 1'b1;
            #1;
            if (!aso_eth_1_valid || (aso_eth_1_data !== eth2_word) ||
                    !asi_eth_2_ready) begin
                $fatal(1, "eth2->eth1 cross-connect failed");
            end
            if (!aso_eth_3_valid || (aso_eth_3_data !== eth4_word) ||
                    !asi_eth_4_ready) begin
                $fatal(1, "eth4->eth3 cross-connect failed");
            end
            @(posedge clk);
            @(negedge clk);
            asi_eth_2_valid = 1'b0;
            asi_eth_4_valid = 1'b0;
        end
    endtask

    always @(posedge clk) begin
        if (!rst && aso_eth_2_valid && aso_eth_2_ready) begin
            if (expected_read_count >= expected_write_count) begin
                $fatal(1, "Unexpected encrypted eth2 output");
            end
            if (aso_eth_2_data !== expected_data[expected_read_count]) begin
                $fatal(1,
                    "Ciphertext mismatch at beat %0d\ngot      %h\nexpected %h",
                    expected_read_count,
                    aso_eth_2_data,
                    expected_data[expected_read_count]);
            end
            if ((aso_eth_2_sop !== expected_sop[expected_read_count]) ||
                    (aso_eth_2_eop !== expected_eop[expected_read_count]) ||
                    (aso_eth_2_empty !==
                        expected_empty[expected_read_count])) begin
                $fatal(1, "Avalon-ST sideband mismatch at beat %0d",
                    expected_read_count);
            end
            expected_read_count++;
        end
    end

    initial begin : test_sequence
        logic [390:0] instruction0;
        logic [390:0] instruction1;
        logic [390:0] instruction2;
        logic [511:0] held_data;
        logic held_sop;
        logic held_eop;
        logic [5:0] held_empty;
        logic [511:0] stalled_payload;
        logic [511:0] refill_key;
        int timeout;

        key_model = '0;
        key_model_bits = 0;

        // Basic full-width XOR and all unchanged cross-connects.
        reset_datapath();
        $display("TEST 1: full-block encryption");
        checked_at_test_start = expected_read_count;
        instruction0 = make_instruction(64, POSITION_IDENTITY);
        program_instruction(0, instruction0);
        check_other_cross_connects();
        send_key_word(make_word(8'h10));
        send_payload_beat(
            make_word(8'ha0), instruction0, 1'b1, 1'b1, 6'd0
        );
        wait_for_all_outputs();
        if (expected_read_count != checked_at_test_start+1) begin
            $fatal(1, "Full-block test did not check exactly one beat");
        end

        // Four key bytes placed at non-contiguous output byte positions.
        reset_datapath();
        $display("TEST 2: selective encryption");
        checked_at_test_start = expected_read_count;
        instruction0 = make_instruction(4, POSITION_SELECTIVE);
        program_instruction(0, instruction0);
        send_key_word(make_word(8'h40));
        send_payload_beat(
            make_word(8'hc0), instruction0, 1'b1, 1'b1, 6'd0
        );
        wait_for_all_outputs();
        if (expected_read_count != checked_at_test_start+1) begin
            $fatal(1, "Selective test did not check exactly one beat");
        end

        // Three segments use independent RAM rows.  The final segment has 17
        // empty bytes and a zero-byte instruction.
        reset_datapath();
        $display("TEST 3: multi-segment packet and empty");
        checked_at_test_start = expected_read_count;
        instruction0 = make_instruction(3, POSITION_MULTI_FIRST);
        instruction1 = make_instruction(8, POSITION_MULTI_SECOND);
        instruction2 = make_instruction(0, POSITION_IDENTITY);
        program_instruction(0, instruction0);
        program_instruction(1, instruction1);
        program_instruction(2, instruction2);
        send_key_word(make_word(8'h60));
        send_key_word(make_word(8'he0));
        send_payload_beat(
            make_word(8'h01), instruction0, 1'b1, 1'b0, 6'd0
        );
        send_payload_beat(
            make_word(8'h31), instruction1, 1'b0, 1'b0, 6'd0
        );
        send_payload_beat(
            make_word(8'h71), instruction2, 1'b0, 1'b1, 6'd17
        );
        wait_for_all_outputs();
        if (expected_read_count != checked_at_test_start+3) begin
            $fatal(1, "Multi-segment test did not check exactly three beats");
        end

        // Hold the encrypted output blocked across multiple cycles.  The first
        // result must remain stable while a second packet is already queued.
        reset_datapath();
        $display("TEST 4: output backpressure");
        checked_at_test_start = expected_read_count;
        instruction0 = make_instruction(64, POSITION_IDENTITY);
        instruction1 = make_instruction(64, POSITION_REVERSE);
        program_instruction(0, instruction0);
        program_instruction(32, instruction1);
        send_key_word(make_word(8'h20));
        send_key_word(make_word(8'h80));
        @(negedge clk);
        aso_eth_2_ready = 1'b0;
        send_payload_beat(
            make_word(8'h11), instruction0, 1'b1, 1'b1, 6'd0
        );
        send_payload_beat(
            make_word(8'h55), instruction1, 1'b1, 1'b1, 6'd0
        );

        timeout = 0;
        while (!aso_eth_2_valid && timeout < 200) begin
            @(posedge clk);
            timeout++;
        end
        if (!aso_eth_2_valid) begin
            $fatal(1, "Timed out waiting for blocked eth2 result");
        end
        held_data = aso_eth_2_data;
        held_sop = aso_eth_2_sop;
        held_eop = aso_eth_2_eop;
        held_empty = aso_eth_2_empty;
        repeat (6) begin
            @(posedge clk);
            if (!aso_eth_2_valid || (aso_eth_2_data !== held_data) ||
                    (aso_eth_2_sop !== held_sop) ||
                    (aso_eth_2_eop !== held_eop) ||
                    (aso_eth_2_empty !== held_empty)) begin
                $fatal(1, "Encrypted output changed under backpressure");
            end
        end
        @(negedge clk);
        aso_eth_2_ready = 1'b1;
        wait_for_all_outputs();
        if (expected_read_count != checked_at_test_start+2) begin
            $fatal(1, "Backpressure test did not check exactly two beats");
        end

        // Consume the only available key word, prove that eth1 stalls, then
        // refill from eth3 while the source keeps valid/data stable.
        reset_datapath();
        $display("TEST 5: key-buffer exhaustion and refill");
        checked_at_test_start = expected_read_count;
        instruction0 = make_instruction(64, POSITION_IDENTITY);
        instruction1 = make_instruction(4, POSITION_SELECTIVE);
        program_instruction(0, instruction0);
        program_instruction(32, instruction1);
        send_key_word(make_word(8'h33));
        send_payload_beat(
            make_word(8'h99), instruction0, 1'b1, 1'b1, 6'd0
        );
        wait_for_all_outputs();
        if (key_model_bits != 0) begin
            $fatal(1, "Key model was not exhausted");
        end

        stalled_payload = make_word(8'hb1);
        refill_key = make_word(8'hd0);
        @(negedge clk);
        asi_eth_1_data = stalled_payload;
        asi_eth_1_valid = 1'b1;
        asi_eth_1_sop = 1'b1;
        asi_eth_1_eop = 1'b1;
        asi_eth_1_empty = '0;
        repeat (5) begin
            @(posedge clk);
            if (asi_eth_1_ready) begin
                $fatal(1, "eth1 did not stall with an empty key buffer");
            end
        end

        if (dut.key_material_if.ready !== 1'b1) begin
            $fatal(1, "Empty key buffer did not request refill");
        end
        @(negedge clk);
        asi_eth_3_data = refill_key;
        asi_eth_3_valid = 1'b1;
        asi_eth_3_sop = 1'b1;
        asi_eth_3_eop = 1'b1;
        @(posedge clk);
        if (!aso_eth_4_valid || (aso_eth_4_data !== refill_key)) begin
            $fatal(1, "Refill key did not preserve eth3->eth4 traffic");
        end
        append_key_model(refill_key);
        @(negedge clk);
        asi_eth_3_valid = 1'b0;
        asi_eth_3_sop = 1'b0;
        asi_eth_3_eop = 1'b0;

        timeout = 0;
        do begin
            @(posedge clk);
            timeout++;
            if (timeout >= 50) begin
                $fatal(1, "eth1 did not resume after key refill");
            end
        end while (!asi_eth_1_ready);
        queue_expected_output(
            stalled_payload, instruction1, 1'b1, 1'b1, 6'd0
        );
        @(negedge clk);
        asi_eth_1_valid = 1'b0;
        asi_eth_1_sop = 1'b0;
        asi_eth_1_eop = 1'b0;
        wait_for_all_outputs();
        if (expected_read_count != checked_at_test_start+2) begin
            $fatal(1, "Refill test did not check exactly two beats");
        end

        $display(
            "PASS: all %0d encrypted beats and extended scenarios checked",
            expected_read_count
        );
        $finish;
    end

endmodule
