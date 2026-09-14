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


// Clocked priority encoder with state
//
// On each clock cycle, updates state to show which request is granted.
// Most recent grant holder is always the highest priority.
// If current grant holder is not making a request, while others are, 
// then new grant holder is always the requester with lowest bit number.
// If no requests, current grant holder retains grant state

// $Header$

`timescale 1 ns / 1 ns
//altera message_off 16753
module alt_xcvr_arbiter #(
	parameter width = 2
) (
	input  wire clock,
	input  wire [width-1:0] req,	// req[n] requests for this cycle
	output reg  [width-1:0] grant	// grant[n] means requester n is grantee in this cycle
);

	wire idle;	// idle when no requests
	wire [width-1:0] keep;	// keep[n] means requester n is requesting, and already has the grant
							// Note: current grantee is always highest priority for next grant
	wire [width-1:0] take;	// take[n] means requester n is requesting, and there are no higher-priority requests

	assign keep = req & grant;	// current grantee is always highest priority for next grant
	assign idle = ~| req;		// idle when no requests

	initial begin
		grant = 0;
	end

	// grant next state depends on current grant and take priority
	always @(posedge clock) begin
		grant <= 
// synthesis translate_off
                    (grant === {width{1'bx}})? {width{1'b0}} :
// synthesis translate_on
				keep				// if current grantee is requesting, gets to keep grant
				 | ({width{idle}} & grant)	// if no requests, grant state remains unchanged
				 | take;			// take applies only if current grantee is not requesting
	end

	// 'take' bus encodes priority.  Request with lowest bit number wins when current grantee not requesting
	assign take[0] = req[0]
					 & (~| (keep & ({width{1'b1}} << 1)));	// no 'keep' from lower-priority inputs
	genvar i;
	generate
	for (i=1; i < width; i = i + 1) begin : arb
		assign take[i] = req[i]
						 & (~| (keep & ({width{1'b1}} << (i+1))))	// no 'keep' from lower-priority inputs
						 & (~| (req & {i{1'b1}}));	// no 'req' from higher-priority inputs
	end
	endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "/RDp5nbdJI/I+mTEYq1BvrygziL3298XeYthiYFQQqg/2/Ylikra3AL5fYFj21YJTqSTeuced4Tn4OFvdQyfj5RXz9f6Xk6oB7vATPK9ELh2mwnhQJa3ipyfhFCPOvL+61RNdd+D1i/J5PgDzu1txNYj0taJ0uwH1coeSCaN+PlpO1BEGKISBNXOT1TAMV4pB7/0nOVCBGL902T5gpagi0SJY6mw2Vr4SnRd4TmXIL7/1gSp3dzzn2hFgz+sVinIiltxyhkKHYZjUn9Oyc6ibbw/kofV+DgnujBTl/8VNTWgfF4jK8fymCdB6TAXu8nWBj7BiVRSN/Ce5a0gP3MSvCJgcKnqo0tV1M5AtBhy24igOkYMPaquDrNZRR6M9qL0tteS0L7rdJ/BYq6bxnbxbXG1vBl7kiNJ7eJ5iJ25oOenYXuo87oJ9R0hH02HwVzllpuZzTFRXPW9fDZxgjnJ6oKkox/6XJomyuj+SZGRqjlULmucIyAE+tR5/3SRYQ1/ar026+bRQjvvUITF/Um8uqiXNHj29zHHXGbVZ/6LdjSGP1xzWteIk2H30MC9Jd7iLNauFxEAui0QSVLyZ88rRZ5l47FW9aWYtPFduVNQUlKoOdvrl/G7MxK1xbQHyCk9fIw4riuGp4eGfvUVG15xDFu4pEZX53/yUYEIAigO51Cd1vdxkozq2/GWQr8SeqnuFFph1vhZT8tJv7VK3Yd3WsyZgfuRTCh5AhY0wFteqRT0CtVXBCdT6TzMSj1MEB6GJ5yfVJeR6+gmFqrxHmj1o0yE4upADHNBblJJUxOhPvOyR7goGtpvHuwft1uZ7fBnrWP5a0jUjREdpqBi5wqrbGcaoK97zHronltGurB+Q4F3E/MkIUZy5CwfJYSXRa7SBgceoyUMVkfiFSB6GKjJ2j4Di05PbQMRC/C9bTkiMzgGa+eVgo2OBnxUZqCvJ/KAAulzqSFtC1l8MglTAhMFdmU9N78TBupOgJMjzaF+DZAXUS4MySplOv9io7oTifqC"
`endif