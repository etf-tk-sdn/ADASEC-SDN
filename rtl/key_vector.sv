// SPDX-FileCopyrightText: 2026 Amina Tankovic
// SPDX-FileCopyrightText: 2026 Enio Kaljic
// SPDX-License-Identifier: CERN-OHL-S-2.0

`timescale 1ps / 1ps

// Key material provider. Incoming 512-bit words are buffered and consumed
// according to the byte count stored in the instruction RAM. The selected
// key bytes and their destination positions are passed to the Omega network.
module key_vector #(
    parameter PACKET_LENGTH = 512,
    parameter CHANNEL_WIDTH = 391,
    parameter GRANULARITY = 1,
    parameter BIT_VECTOR_WIDTH = 64
) (
    input logic clk,
    input logic rst,

    avalon_if.in  from_generator,
    input logic [390:0] readdata,
    avalon_if.in  from_pcap_reader,
    avalon_if.out key_vector_next
);

    localparam int KEY_BUFFER_WIDTH = 2048;
    localparam int KEY_WORD_WIDTH = 512;

    logic [KEY_BUFFER_WIDTH-1:0] key_buffer_reg;
    logic [11:0] key_bits_reg;

    logic request_pending_reg;
    logic request_sop_reg;
    logic request_eop_reg;
    logic [5:0] request_empty_reg;

    logic [6:0] selected_byte_count;
    logic [9:0] selected_bit_count;
    logic output_available;
    logic request_accept;
    logic generator_accept;
    logic consume_key;

    always_comb begin
        if (readdata[390:384] > 7'd64) begin
            selected_byte_count = 7'd64;
        end else begin
            selected_byte_count = readdata[390:384];
        end
    end

    assign selected_bit_count = {selected_byte_count, 3'b000};
    assign output_available = !key_vector_next.valid ||
        key_vector_next.ready;

    // A full 512-bit key word covers the largest possible instruction.
    // Keep one request pending while the synchronous RAM read completes.
    assign from_pcap_reader.ready = !rst && !request_pending_reg &&
        output_available && (key_bits_reg >= KEY_WORD_WIDTH);

    // Four words fit in the key buffer. Backpressure Ethernet channel 3 when
    // accepting another complete word could overflow it.
    assign from_generator.ready = !rst &&
        (key_bits_reg <= KEY_BUFFER_WIDTH-KEY_WORD_WIDTH);

    assign request_accept = from_pcap_reader.valid &&
        from_pcap_reader.ready;
    assign generator_accept = from_generator.valid &&
        from_generator.ready;
    assign consume_key = request_pending_reg && output_available &&
        (selected_byte_count != 0);

    always_ff @(posedge clk) begin : key_buffer
        logic [KEY_BUFFER_WIDTH-1:0] shifted_buffer;
        logic [11:0] shifted_count;

        if (rst) begin
            key_buffer_reg <= '0;
            key_bits_reg <= '0;
            request_pending_reg <= 1'b0;
            request_sop_reg <= 1'b0;
            request_eop_reg <= 1'b0;
            request_empty_reg <= '0;
            key_vector_next.data <= '0;
            key_vector_next.valid <= 1'b0;
            key_vector_next.sop <= 1'b0;
            key_vector_next.eop <= 1'b0;
            key_vector_next.empty <= '0;
            key_vector_next.channel <= '0;
        end else begin
            // Defaults preserve the key pool. Consumption is applied first,
            // then a simultaneously accepted word is appended behind it.
            shifted_buffer = key_buffer_reg;
            shifted_count = key_bits_reg;

            if (consume_key) begin
                shifted_buffer = key_buffer_reg << selected_bit_count;
                shifted_count = key_bits_reg - selected_bit_count;
            end

            if (generator_accept) begin
                shifted_buffer = shifted_buffer ^
                    ({from_generator.data, {1536{1'b0}}} >> shifted_count);
                shifted_count = shifted_count + 12'd512;
            end

            key_buffer_reg <= shifted_buffer;
            key_bits_reg <= shifted_count;

            if (key_vector_next.ready) begin
                key_vector_next.valid <= 1'b0;
            end

            if (request_accept) begin
                request_pending_reg <= 1'b1;
                request_sop_reg <= from_pcap_reader.sop;
                request_eop_reg <= from_pcap_reader.eop;
                request_empty_reg <= from_pcap_reader.empty;
            end

            // The RAM output now belongs to the request captured one cycle
            // earlier. Hold this output until the scheduler accepts it.
            if (request_pending_reg && output_available) begin
                request_pending_reg <= 1'b0;
                key_vector_next.valid <= 1'b1;
                key_vector_next.sop <= request_sop_reg;
                key_vector_next.eop <= request_eop_reg;
                key_vector_next.empty <= request_empty_reg;
                key_vector_next.channel <= {
                    64'b0, selected_byte_count, readdata[383:0]
                };

                if (selected_byte_count == 0) begin
                    key_vector_next.data <= '0;
                end else begin
                    key_vector_next.data <= key_buffer_reg[2047:1536];
                end
            end
        end
    end

endmodule
