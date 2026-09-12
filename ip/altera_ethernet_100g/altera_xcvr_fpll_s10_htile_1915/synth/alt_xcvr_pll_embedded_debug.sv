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


`timescale 1ps/1ps

module alt_xcvr_pll_embedded_debug #(
  parameter dbg_capability_reg_enable   = 0,
  parameter dbg_user_identifier         = 0,
  parameter dbg_stat_soft_logic_enable  = 0,
  parameter dbg_ctrl_soft_logic_enable  = 0,
  parameter en_master_cgb               = 0
) (
  // avmm signals
  input         avmm_clk,
  input         avmm_reset,
  input  [8:0]  avmm_address,
  input  [7:0]  avmm_writedata,
  input         avmm_write,
  input         avmm_read,
  output [7:0]  avmm_readdata,
  output        avmm_waitrequest,

  // input signals from the core
  input         in_pll_powerdown,
  input         in_pll_locked,
  input         in_pll_cal_busy,
  input         in_avmm_busy,

  // output signals to the ip
  output        out_pll_powerdown
);

wire        prbs_done_sync;
wire        csr_prbs_snapshot;
wire        csr_prbs_count_en;
wire        csr_prbs_reset;
wire [47:0] prbs_err_count;
wire [47:0] prbs_bit_count;

alt_xcvr_pll_avmm_csr #(
  .dbg_capability_reg_enable   ( dbg_capability_reg_enable ),
  .dbg_user_identifier         ( dbg_user_identifier ),
  .dbg_stat_soft_logic_enable  ( dbg_stat_soft_logic_enable ),
  .dbg_ctrl_soft_logic_enable  ( dbg_ctrl_soft_logic_enable ),
  .en_master_cgb               ( en_master_cgb)
) embedded_debug_soft_csr (
  // avmm signals
  .avmm_clk                            (avmm_clk),
  .avmm_reset                          (avmm_reset),
  .avmm_address                        (avmm_address),
  .avmm_writedata                      (avmm_writedata),
  .avmm_write                          (avmm_write),
  .avmm_read                           (avmm_read),
  .avmm_readdata                       (avmm_readdata),
  .avmm_waitrequest                    (avmm_waitrequest),

  // input status signals from the channel
  .pll_powerdown                       (in_pll_powerdown),
  .pll_locked                          (in_pll_locked),
  .pll_cal_busy                        (in_pll_cal_busy),
  .avmm_busy                           (in_avmm_busy),

  // output control signals
  .csr_pll_powerdown                   (out_pll_powerdown)
);

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "Qpn6yaCwI1RZ4kkjNzbswjNc69/0GAZZyecmVdhUvEMoYEgWRIuls/pJRRXQfHGxbpEXL0l6XzyyJ/EO56CgfTYjPV77KmSwoSxJu/rMVhwBKNHSxF2Vc0bGstlAMtUPBb1Xnw1be8xPNCHJJE0CnuJ9PdCUrwn51F5fXrRKAdoaMEfnhz/B/+vNvmfaZvjsSPyRAae0ZHr3kVsU1YayXGZFgjBuRtAA9OOJdu9Ras0meQCBTzCizSnpAcYVl8we2FeRKsWMWEw81qz+0Fek1b6+KhBZbAd1kwHubuVmmS8T+aNS6zCRrYZZes79OcD2OtDEHgD04wKStIOPPoARRyMZhQnSMCVMg/AgS0B6SL8d/aqhc4Fk7XxFXtcbzTZTH4LLB9II+avWo4hikn/madPOmJEfEXPfcUgEg34b8Rb5JXzQGF6A35RP8XcwFdVqN0rDa+835vAKLQWVXgwYh4lVvTX7TY2ss8cSm0ucaJswCK2OoRsjh+Wi39s85lhaHpwEQbXLnebzOfzSmgWV6oITRNENF9DV2NjDXxKdfqtZYdRCokyhlKoa+KQsS5dEmTbfAX7LqWHAibvx3Haa7qf/5iHDNfXfI6vW6j0znNn35VBcp7jIBmtPZ1K/T1j4zivJICXh0+q3J3j8vzx9SKAy4aBHPbBso/Ix7uU9aYMfhAjBpVN2q8N5tolM2Moc5eIdIG1Joqz3tbLamzJZQ6rEiHJmF6nxSIrr4SOewgZFaaLziLnHAI+HXM0G1fX2O7zsLAhO/M/xSNsIBL/YLOXTUuCGenC9jAm4t2qTEY7I5aYdMTrK7MPYFM860fqsJjgJGOTK003/KYwPCm8Ey/lIJC990MpYDh9wYCzjAvhhNqeS0RyFMziZTUafrukulde41DveCYQrOmMOpNJ4fnBhSwzu3hWO+qoyn+JtXryJff6tWaBgzVeMc6lWYBZEKgVA4OkH60AgePH/gCwhOtvlxA2hxEbWnJ9KzpTLORSzCfluAusLa3A8CTpZ5gbD"
`endif