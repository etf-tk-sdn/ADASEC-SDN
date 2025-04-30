// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ns / 1ns
// This module takes the stats vector from the MAC and
// produces and extended stats vector which is derived
// from the MAC stats. Data from the extended stats
// vector is counted and accessable through an Avalon
// Interface

/*
                                                                                        avalon interface <--------
                                                                                                                 |
                                                                                                                 |
                      |---------------------------|                |----------------------|                      V
           valid ---->|                           |-----valid----->|                      |              |----------------|
MAC stats vector ---->| extended stats vector gen |---ext stats--->| invalid stats filter |--ext stats-->| stats counters |
   error signals ---->|                           |                |                      |              |----------------|
                      |---------------------------|                |----------------------|
*/



module alt_e100s10_stats_counters #(
    parameter WIDTH         = 64,
    parameter WIDTH_ERR     = 32,
    parameter SIM_EMULATE   = 1'b0,
    parameter TARGET_CHIP   = 5
) (
    input               aclr,			// csr_rst_n; async hardware reset from pin;
    //input               cfg_sys_rst,		// cfg_sys_rst from config register; stats_clk domain;
    // AVMM bus
    input               stats_clk,
    input      [7:0]    addr,
    output reg [31:0]   readdata,
    input               read,
    input               write,
    input      [31:0]   writedata,
    output reg          data_valid,
    
    input               mac_clk,
    input		mac_clk_locked,
    input               crc_error,
    input               undersized_frame,
    input               oversized_frame_in,
    input               payload_len_error,
    input               valid_in,
    input      [41:0]   status_data_vector
);
    // Synchronize aclr to status clock domain
    alt_e100s10_synchronizer #(.WIDTH (1)) aclr_stats_sync (
        .clk    (stats_clk),
        .din    (aclr),
        .dout   (aclr_sync_stats)
    );

    // Get extended stats vector and valid signal
    wire fragmented_frame;
    wire jabbered_frame;
    wire crc_errored_frame;
    wire fcs_errored_frame;
    wire frame_len_64b;
    wire frame_len_65to127b;
    wire frame_len_128to255b;
    wire frame_len_256to511b;
    wire frame_len_512to1023b;
    wire frame_len_1024to1518b;
    wire frame_len_1519tomax;
    wire frame_oversized;
    wire mcast_data_err;
    wire bcast_data_err;
    wire ucast_data_err;
    wire mcast_ctrl_err;
    wire bcast_ctrl_err;
    wire ucast_ctrl_err;
    wire pause_err;
    wire mcast_data_ok;
    wire bcast_data_ok;
    wire ucast_data_ok;
    wire mcast_ctrl_ok;
    wire bcast_ctrl_ok;
    wire ucast_ctrl_ok;
    wire pause_ok;
    wire runt;
    wire valid_out;
    wire [15:0] octets_ok_payload;
    wire [15:0] octets_ok_frame;

    wire	invalid_sop, invalid_eop;

    // Module to derive extended stats vector from
    // MAC stats vector.
    alt_e100s10_extended_stats_vector vec (
        .clk                    (mac_clk),

        // Inputs from MAC
        .status_data_vector     (status_data_vector),
        .crc_error              (crc_error),
        .undersized_frame       (undersized_frame),
        .oversized_frame_in     (oversized_frame_in),
        .payload_len_error      (payload_len_error),
        .valid_in               (valid_in),

        // Extended stats outputs
        .fragmented_frame       (fragmented_frame),
        .jabbered_frame         (jabbered_frame),
        .crc_errored_frame      (crc_errored_frame),
        .fcs_errored_frame      (fcs_errored_frame),
        .invalid_sop		(invalid_sop),
        .invalid_eop		(invalid_eop),
        .frame_len_64b          (frame_len_64b),
        .frame_len_65to127b     (frame_len_65to127b),
        .frame_len_128to255b    (frame_len_128to255b),
        .frame_len_256to511b    (frame_len_256to511b),
        .frame_len_512to1023b   (frame_len_512to1023b),
        .frame_len_1024to1518b  (frame_len_1024to1518b),
        .frame_len_1519tomax    (frame_len_1519tomax),
        .frame_oversized        (frame_oversized),
        .mcast_data_err         (mcast_data_err),
        .bcast_data_err         (bcast_data_err),
        .ucast_data_err         (ucast_data_err),
        .mcast_ctrl_err         (mcast_ctrl_err),
        .bcast_ctrl_err         (bcast_ctrl_err),
        .ucast_ctrl_err         (ucast_ctrl_err),
        .pause_err              (pause_err),
        .mcast_data_ok          (mcast_data_ok),
        .bcast_data_ok          (bcast_data_ok),
        .ucast_data_ok          (ucast_data_ok),
        .mcast_ctrl_ok          (mcast_ctrl_ok),
        .bcast_ctrl_ok          (bcast_ctrl_ok),
        .ucast_ctrl_ok          (ucast_ctrl_ok),
        .pause_ok               (pause_ok),
        .runt                   (runt),
        .error                  (),
        .valid_out              (valid_out),
        .octetsOK_payload       (octets_ok_payload),
        .octetsOK_frame         (octets_ok_frame)
    );

    // Filter invalid signals by setting them to zero
    // Create signals that only register non-zero when valid is high
    reg pulse_fragmented_frame;
    reg pulse_jabbered_frame;
    reg pulse_crc_errored_frame;
    reg pulse_fcs_errored_frame;
    reg pulse_frame_len_64b;
    reg pulse_frame_len_65to127b;
    reg pulse_frame_len_128to255b;
    reg pulse_frame_len_256to511b;
    reg pulse_frame_len_512to1023b;
    reg pulse_frame_len_1024to1518b;
    reg pulse_frame_len_1519tomax;
    reg pulse_frame_oversized;
    reg pulse_mcast_data_err;
    reg pulse_bcast_data_err;
    reg pulse_ucast_data_err;
    reg pulse_mcast_ctrl_err;
    reg pulse_bcast_ctrl_err;
    reg pulse_ucast_ctrl_err;
    reg pulse_pause_err;
    reg pulse_mcast_data_ok;
    reg pulse_bcast_data_ok;
    reg pulse_ucast_data_ok;
    reg pulse_mcast_ctrl_ok;
    reg pulse_bcast_ctrl_ok;
    reg pulse_ucast_ctrl_ok;
    reg pulse_pause_ok;
    reg pulse_runt;
    reg pulse_invalid_sop;
    reg pulse_invalid_eop;
    //reg pulse_error;
    reg [15:0] pulse_octets_ok_payload;
    reg [15:0] pulse_octets_ok_frame;

    always @(posedge mac_clk) begin
        pulse_fragmented_frame       <= valid_out ? fragmented_frame      : 1'b0;
        pulse_jabbered_frame         <= valid_out ? jabbered_frame        : 1'b0;
        pulse_crc_errored_frame      <= valid_out ? crc_errored_frame     : 1'b0;
        pulse_fcs_errored_frame      <= valid_out ? fcs_errored_frame     : 1'b0;
        pulse_frame_len_64b          <= valid_out ? frame_len_64b         : 1'b0;
        pulse_frame_len_65to127b     <= valid_out ? frame_len_65to127b    : 1'b0;
        pulse_frame_len_128to255b    <= valid_out ? frame_len_128to255b   : 1'b0;
        pulse_frame_len_256to511b    <= valid_out ? frame_len_256to511b   : 1'b0;
        pulse_frame_len_512to1023b   <= valid_out ? frame_len_512to1023b  : 1'b0;
        pulse_frame_len_1024to1518b  <= valid_out ? frame_len_1024to1518b : 1'b0;
        pulse_frame_len_1519tomax    <= valid_out ? frame_len_1519tomax   : 1'b0;
        pulse_frame_oversized        <= valid_out ? frame_oversized       : 1'b0;
        pulse_mcast_data_err         <= valid_out ? mcast_data_err        : 1'b0;
        pulse_bcast_data_err         <= valid_out ? bcast_data_err        : 1'b0;
        pulse_ucast_data_err         <= valid_out ? ucast_data_err        : 1'b0;
        pulse_mcast_ctrl_err         <= valid_out ? mcast_ctrl_err        : 1'b0;
        pulse_bcast_ctrl_err         <= valid_out ? bcast_ctrl_err        : 1'b0;
        pulse_ucast_ctrl_err         <= valid_out ? ucast_ctrl_err        : 1'b0;
        pulse_pause_err              <= valid_out ? pause_err             : 1'b0;
        pulse_mcast_data_ok          <= valid_out ? mcast_data_ok         : 1'b0;
        pulse_bcast_data_ok          <= valid_out ? bcast_data_ok         : 1'b0;
        pulse_ucast_data_ok          <= valid_out ? ucast_data_ok         : 1'b0;
        pulse_mcast_ctrl_ok          <= valid_out ? mcast_ctrl_ok         : 1'b0;
        pulse_bcast_ctrl_ok          <= valid_out ? bcast_ctrl_ok         : 1'b0;
        pulse_ucast_ctrl_ok          <= valid_out ? ucast_ctrl_ok         : 1'b0;
        pulse_pause_ok               <= valid_out ? pause_ok              : 1'b0;
        pulse_runt                   <= valid_out ? runt                  : 1'b0;
        pulse_invalid_sop	     <= valid_out ? invalid_sop           : 1'b0;
        pulse_invalid_eop	     <= valid_out ? invalid_eop           : 1'b0;
        pulse_octets_ok_payload      <= valid_out ? octets_ok_payload     : 16'd0;
        pulse_octets_ok_frame        <= valid_out ? octets_ok_frame       : 16'd0;
    end

    // --------------------- CSR ----------------------------
    wire [63:0] incr_signals;

    // Config and status registers
    wire            parity_err_0_15;
    wire            parity_err_16_31;
    wire            parity_err_oo;
    reg             parity_error;

    wire            shadow_grant_0_15;
    wire            shadow_grant_16_31;
    wire            shadow_grant_oo;
    reg             shadow_grant;

    // Register before syncing to avoid glitches
    always @(posedge mac_clk) parity_error <= parity_err_0_15 || parity_err_16_31 || parity_err_oo;
    always @(posedge mac_clk) shadow_grant <= shadow_grant_0_15 || shadow_grant_16_31 || shadow_grant_oo;

    wire    parity_error_sync;
    alt_e100s10_synchronizer #(.WIDTH (1)) sync_pe (
        .clk    (stats_clk),
        .din    (parity_error),
        .dout   (parity_error_sync)
    );

    wire    shadow_grant_sync;
    alt_e100s10_synchronizer #(.WIDTH (1)) sync_sg (
        .clk    (stats_clk),
        .din    (shadow_grant),
        .dout   (shadow_grant_sync)
    );

    reg     [2:0]   cntr_config;
    wire    [1:0]   cntr_status = {shadow_grant_sync, parity_error_sync};

    wire            clear_counters      = cntr_config[0];
    wire            clear_parity_err    = cntr_config[1];
    wire            shadow_request      = cntr_config[2];

    // CSR writes
    always @(posedge stats_clk) begin
        cntr_config[1:0]    <= 2'b00;           // Self clearing
        cntr_config[2]      <= cntr_config[2];  // Hold value

        if (aclr_sync_stats) begin
        //if (aclr_sync_stats | cfg_sys_rst) begin
            cntr_config <= 3'b000;
        end else begin
            if (write) begin
                case (addr)
                    8'h45   : cntr_config <= writedata[2:0];
                endcase
            end
        end
    end

    // CSR reads
    reg [31:0]  readdata_csr;
    reg         data_valid_csr;

    wire        cs_csr = ((addr >= 8'h45) && (addr <= 8'h46));
    wire        csr_read = (cs_csr && read);

    always @(posedge stats_clk) begin
        case (addr)
            8'h45   : readdata_csr <= {29'd0, cntr_config};
            8'h46   : readdata_csr <= {30'd0, cntr_status};
            default : readdata_csr <= 32'h5B6C5615;
        endcase
    end

    always @(posedge stats_clk) data_valid_csr <= csr_read;

    // Synchronize shadow request to mac clock domain
    wire shadow_request_sync;
    alt_e100s10_synchronizer #(.WIDTH (1)) sync_sr (
        .clk    (mac_clk),
        .din    (shadow_request),
        .dout   (shadow_request_sync)
    );

//------------------------------------
wire cnt_clear, cnt_clear_sync, par_err_clear_sync;
assign cnt_clear = aclr_sync_stats | clear_counters;	// | cfg_sys_rst;
alt_e100s10_stats_sync u_cnt_clear_sync (
	.aclk		(stats_clk),
	.din		(cnt_clear),
	.bclk		(mac_clk),
	.bclk_vld	(mac_clk_locked),
	.dout		(cnt_clear_sync)
);

alt_e100s10_stats_sync u_clr_parity_sync (
	.aclk		(stats_clk),
	.din		(clear_parity_err),
	.bclk		(mac_clk),
	.bclk_vld	(mac_clk_locked),
	.dout		(par_err_clear_sync)
);

//--------------------------------------------------
    // Stretch clear pulse to 32 cycles as required by
    // stats_ram blocks
    wire stretched_clear_cnt;
    alt_e100s10_pulse_stretcher #(
        .CYCLES     (36)
    ) ps_clr (
        .clk        (mac_clk),
        .pulse_in   (cnt_clear_sync),
        .pulse_out  (stretched_clear_cnt)
    );

    wire stretched_clear_par_err;
    alt_e100s10_pulse_stretcher #(
        .CYCLES     (36)
    ) ps_pe_clr (
        .clk        (mac_clk),
        .pulse_in   (par_err_clear_sync),
        .pulse_out  (stretched_clear_par_err)
    );

//--------------------------------------------------
    wire clk_locked_sync;
    alt_e100s10_synchronizer #(.WIDTH (1)) sync_lock (
        .clk    (stats_clk),
        .din    (mac_clk_locked),
        .dout   (clk_locked_sync)
    );

    // --------------------- Feed stats vectors to MLAB counters ----------------------------

    // Stats 0-15
    // Each stats_ram block can count 16 vector signals
    assign incr_signals[ 0] = pulse_fragmented_frame;
    assign incr_signals[ 1] = pulse_jabbered_frame;
    assign incr_signals[ 2] = pulse_fcs_errored_frame;
    assign incr_signals[ 3] = pulse_crc_errored_frame;
    assign incr_signals[ 4] = pulse_mcast_data_err;
    assign incr_signals[ 5] = pulse_bcast_data_err;
    assign incr_signals[ 6] = pulse_ucast_data_err;
    assign incr_signals[ 7] = pulse_mcast_ctrl_err;
    assign incr_signals[ 8] = pulse_bcast_ctrl_err;
    assign incr_signals[ 9] = pulse_ucast_ctrl_err;
    assign incr_signals[10] = pulse_pause_err;
    assign incr_signals[11] = pulse_frame_len_64b;
    assign incr_signals[12] = pulse_frame_len_65to127b;
    assign incr_signals[13] = pulse_frame_len_128to255b;
    assign incr_signals[14] = pulse_frame_len_256to511b;
    assign incr_signals[15] = pulse_frame_len_512to1023b;

    // stats_ram block counts events on the "incs" input.
    // Counts are accessed through the rd_addr and rd_value
    // ports.
    // Data is presented on the rd_value port 1 cycle after
    // an address is presented on the rd_addr port.
    wire [31:0] data_0_15;
    alt_e100s10_stat_ram_16x64b #(
        .INC_WIDTH          (1),
        .ACCUM_WIDTH        (16),
        .SIM_EMULATE        (SIM_EMULATE),
        .TARGET_CHIP        (TARGET_CHIP)
    ) stats_ram_0_15 (
        .clk                (mac_clk),
        .sclr               (stretched_clear_cnt),
        .sclr_addr          (cnt_clear_sync),
        .incs               (incr_signals[15:0]) ,
        .rd_addr            (addr[4:0]),
        .rd_value           (data_0_15),
        .shadow_req         (shadow_request_sync),
        .shadow_grant       (shadow_grant_0_15),
        .sclr_parity_err    (stretched_clear_par_err),
        .parity_err         (parity_err_0_15)
    );

    // The sync_read block is used to perform avalon bus accesses
    // accross clock domains.
    // Present a valid address on addr_req and pulse the read_req signal.
    // The requsted data is later presented on the data_req bus and the
    // data_valid signal is pulsed to indicate the data is valid.
    wire data_valid_0_15;
    wire [31:0] readdata_0_15;
    wire cs_0_15   = (addr[7:5] == 3'b000);
    wire read_0_15 = (cs_0_15 && read);
    alt_e100s10_sync_read #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(5)
    ) sr0 (
    .master_rst       (aclr_sync_stats  ),
    .master_clk       (stats_clk        ),
    .master_address   (addr[4:0]        ),
    .master_read      (read_0_15    ),
    .master_data      (readdata_0_15    ),
    .master_wait      (waitreq_0_15     ),
    .master_valid     ( data_valid_0_15 ),

    .slave_clk        (mac_clk ),
    .clk_locked_sync (clk_locked_sync ),
    //.slave_clk_locked (mac_clk_locked ),
    .slave_address    (),
    .slave_data       (data_0_15)
    );

    // Stats 16-31
    assign incr_signals[16] = pulse_frame_len_1024to1518b;
    assign incr_signals[17] = pulse_frame_len_1519tomax;
    assign incr_signals[18] = pulse_frame_oversized;
    assign incr_signals[19] = pulse_mcast_data_ok;
    assign incr_signals[20] = pulse_bcast_data_ok;
    assign incr_signals[21] = pulse_ucast_data_ok;
    assign incr_signals[22] = pulse_mcast_ctrl_ok;
    assign incr_signals[23] = pulse_bcast_ctrl_ok;
    assign incr_signals[24] = pulse_ucast_ctrl_ok;
    assign incr_signals[25] = pulse_pause_ok;
    assign incr_signals[26] = pulse_runt;
    assign incr_signals[27] = pulse_invalid_sop;	//hua; 1'b0;
    assign incr_signals[28] = pulse_invalid_eop;	//hua; 1'b0;
    assign incr_signals[29] = valid_out;		//hua; 1'b0;
    assign incr_signals[30] = 1'b0;
    assign incr_signals[31] = 1'b0;

    //wire [31:0] read_data_16_31;
    wire [31:0] data_16_31;
    alt_e100s10_stat_ram_16x64b #(
        .INC_WIDTH          (1),
        .ACCUM_WIDTH        (16),
        .SIM_EMULATE        (SIM_EMULATE),
        .TARGET_CHIP        (TARGET_CHIP)
    ) stats_ram_16_31 (
        .clk                (mac_clk),
        .sclr               (stretched_clear_cnt),
        .sclr_addr          (cnt_clear_sync),
        .incs               (incr_signals[31:16]) ,
        .rd_addr            (addr[4:0]),
        .rd_value           (data_16_31),
        .shadow_req         (shadow_request_sync),
        .shadow_grant       (shadow_grant_16_31),
        .sclr_parity_err    (stretched_clear_par_err),
        .parity_err         (parity_err_16_31)
    );

    wire  data_valid_16_31;
    wire [31:0] readdata_16_31;
    wire cs_16_31   = (addr[7:5] == 3'b001);
    wire read_16_31 = (cs_16_31 && read);
    alt_e100s10_sync_read #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(5)
    ) sr1 (
    .master_rst       (aclr_sync_stats  ),
    .master_clk       (stats_clk        ),
    .master_address   (addr[4:0]        ),
    .master_read      (read_16_31    ),
    .master_data      (readdata_16_31    ),
    .master_wait      (waitreq_16_31     ),
    .master_valid     ( data_valid_16_31 ),

    .slave_clk        (mac_clk ),
    .clk_locked_sync (clk_locked_sync ),
    //.slave_clk_locked (mac_clk_locked ),
    .slave_address    (),
    .slave_data       (data_16_31)
    );

    // Stats  0-31
    // Stats  32-63
    // Stats  64-95
    // Stats  96-127

    // octets OK counter
    assign incr_signals[47:32] = pulse_octets_ok_payload;
    assign incr_signals[63:48] = pulse_octets_ok_frame;

    //wire [31:0] read_data_oo;
    wire [31:0] data_oo;
    alt_e100s10_stat_ram_16x64b #(
        .INC_WIDTH          (16),
        .ACCUM_WIDTH        (16),
        .SIM_EMULATE        (SIM_EMULATE),
        .TARGET_CHIP        (TARGET_CHIP)
    ) stats_ram_oo (
        .clk                (mac_clk),
        .sclr               (stretched_clear_cnt),
        .sclr_addr          (cnt_clear_sync),
        .incs               ({224'd0, incr_signals[63:48], incr_signals[47:32]}) ,
        .rd_addr            (addr[4:0]),
        .rd_value           (data_oo),
        .shadow_req         (shadow_request_sync),
        .shadow_grant       (shadow_grant_oo),
        .sclr_parity_err    (stretched_clear_par_err),
        .parity_err         (parity_err_oo)
    );

    wire  data_valid_oo;
    wire [31:0] readdata_oo;
    wire cs_oo   = (addr[7:5] == 3'b011);
    wire read_oo = (cs_oo && read);
    alt_e100s10_sync_read #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(5)
    ) sr2 (
    .master_rst       (aclr_sync_stats  ),
    .master_clk       (stats_clk        ),
    .master_address   (addr[4:0]        ),
    .master_read      (read_oo    ),
    .master_data      (readdata_oo    ),
    .master_wait      (waitreq_oo     ),
    .master_valid     ( data_valid_oo ),

    .slave_clk        (mac_clk ),
    .clk_locked_sync (clk_locked_sync ),
    //.slave_clk_locked (mac_clk_locked ),
    .slave_address    (),
    .slave_data       (data_oo)
    );

    // Dummy module for returning read valids
    wire cs_dummy   = !(cs_0_15 || cs_16_31 || cs_oo || cs_csr);  // When nobody else is selected
    wire read_dummy = (cs_dummy && read);
    wire    [31:0]  readdata_dummy;
    wire            data_valid_dummy;
    alt_e100s10_dummy_csr #(
        .WIDTH      (32)
    ) dummy_csr (
        .clk        (stats_clk),
        .read       (read_dummy),
        .readdata   (readdata_dummy),
        .datavalid  (data_valid_dummy)
    );

    // Output decoding
    // Pick the appropriate output from one of the multiple stats_ram blocks
reg data_valid_t;
reg [31:0] readdata_t;
always @(posedge stats_clk) data_valid_t <= data_valid_0_15 || data_valid_16_31 || data_valid_oo || data_valid_csr || data_valid_dummy;
always @(posedge stats_clk) data_valid <= data_valid_t;
    //assign data_valid = data_valid_0_15 || data_valid_16_31 || data_valid_oo || data_valid_csr || data_valid_dummy;

always @(posedge stats_clk) begin
        if      (data_valid_0_15)  readdata_t <= readdata_0_15;
        else if (data_valid_16_31) readdata_t <= readdata_16_31;
        else if (data_valid_oo)    readdata_t <= readdata_oo;
        else if (data_valid_dummy) readdata_t <= readdata_dummy;
        else if (data_valid_csr)   readdata_t <= readdata_csr;
        else                       readdata_t <= 32'hdeadc0de;
end
always @(posedge stats_clk) readdata <= readdata_t;
/*
    always @(*) begin
        if      (data_valid_0_15)  readdata = readdata_0_15;
        else if (data_valid_16_31) readdata = readdata_16_31;
        else if (data_valid_oo)    readdata = readdata_oo;
        else if (data_valid_dummy) readdata = readdata_dummy;
        else if (data_valid_csr)   readdata = readdata_csr;
        else                       readdata = 32'hdeadc0de;
    end
*/
endmodule

// A dummy module for the purpose of responding
// to read which are not covered by other modules
module alt_e100s10_dummy_csr #(
    parameter           WIDTH = 32
) (
    input               clk,
    input               read,
    output  [WIDTH-1:0] readdata,
    output  reg         datavalid
);

    always @(posedge clk) datavalid <= read;
    assign readdata = 'hdeadc0de;
endmodule

//------------------------------------
module alt_e100s10_stats_sync (
	input	aclk,
	input	din,
	input	bclk,
	input	bclk_vld,
	output	dout
);

reg	din_r;
reg	bvld_combine;
wire	din_ack;

always @ (posedge aclk)
  if (din)			din_r <= 1'b1;
  else if (din_ack)		din_r <= 1'b0;

always @ (posedge bclk)		bvld_combine <= dout & bclk_vld;

alt_e100s10_synchronizer #(.WIDTH (1)) u_din_sync 
	(.clk(bclk), .din(din_r), .dout(dout));

alt_e100s10_synchronizer #(.WIDTH (1)) u_din_ack_sync 
	(.clk(aclk), .din(bvld_combine), .dout(din_ack));

endmodule
//------------------------------------

