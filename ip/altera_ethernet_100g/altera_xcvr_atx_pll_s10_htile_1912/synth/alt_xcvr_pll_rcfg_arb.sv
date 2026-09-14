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


`timescale 1 ps/1 ps

module alt_xcvr_pll_rcfg_arb #(
  parameter total_masters   = 3,
  parameter interfaces      = 1,
  parameter address_width   = 10,
  parameter data_width      = 32
) (
  // Basic AVMM inputs
  input  [interfaces-1:0]              reconfig_clk,
  input  [interfaces-1:0]              reconfig_reset,

  // User AVMM input
  input  [interfaces-1:0]               user_read,
  input  [interfaces-1:0]               user_write,
  input  [interfaces*address_width-1:0] user_address,
  input  [interfaces*data_width-1:0]    user_writedata,
  input  [interfaces-1:0]               user_read_write,
  output [interfaces-1:0]               user_waitrequest,

  // Reconfig Steamer AVMM input
  input  [interfaces-1:0]               strm_read,
  input  [interfaces-1:0]               strm_write,
  input  [interfaces*address_width-1:0] strm_address,
  input  [interfaces*data_width-1:0]    strm_writedata,
  input  [interfaces-1:0]               strm_read_write,
  output [interfaces-1:0]               strm_waitrequest,

  // ADME AVMM input
  input  [interfaces-1:0]               jtag_read,
  input  [interfaces-1:0]               jtag_write,
  input  [interfaces*address_width-1:0] jtag_address,
  input  [interfaces*data_width-1:0]    jtag_writedata,
  input  [interfaces-1:0]               jtag_read_write,
  output [interfaces-1:0]               jtag_waitrequest,

  // AVMM output the interface and the CSR
  input  [interfaces-1:0]               avmm_waitrequest,
  output [interfaces-1:0]               avmm_read,
  output [interfaces-1:0]               avmm_write,
  output [interfaces*address_width-1:0] avmm_address,
  output [interfaces*data_width-1:0]    avmm_writedata
);

// General wires
wire [interfaces*total_masters-1:0] grant;
wire [interfaces-1:0]               strm_grants;
wire [interfaces-1:0]               user_read_write_lcl;

// Variables for the generate loops 
genvar ig; // For bus widths
genvar jg; // For interfaces
generate for(jg=0;jg<interfaces;jg=jg+1) begin: g_arb

    /*********************************************************************/
    // case: 309705
    // Simulation fix.  When the user inputs drive x at the beginning of simulation,
    // then even after a reset, the grant will have been assigned a value of x.
    // since there is a loopback in the RTL, the value will continue to be x,
    // and gets reflected on avmm_readdata and avmm_waitrequest.  once an avmm master
    // requests a read or write, the x value for grant will correct itself.
    /**********************************************************************/
    assign user_read_write_lcl[jg] = 
                                     // synthesis translate_off
                                       (user_read_write[jg] === 1'bx) ? 1'b0 : 
                                     // synthesis translate_on
                                       user_read_write[jg];
    


    /**********************************************************************/
    // Per Instance instantiations and assignments
    // Priority in decreasing order is embedded reconfig -> user AVMM -> JTAG
    /**********************************************************************/
    alt_xcvr_arbiter #(
          .width (total_masters)
    ) arbiter_inst (
          .clock (reconfig_clk[jg]),
          .req   ({jtag_read_write[jg], user_read_write_lcl[jg], strm_read_write[jg]}),
          .grant (grant[jg*total_masters+:total_masters])
    );
   
    // Assign the grant signal
    assign strm_grants[jg] = grant[jg*total_masters];
    
    // Use the grant as a mask for the various read and writes signals
    // if you OR them all together, it will generate the read/write request if any are high
    // For streamer write/read condition - if broadcasting, wait for all interfaces to receive grant before asserting write/read
    assign avmm_write[jg] =  |(grant[jg*total_masters+:total_masters] & {jtag_write[jg], user_write[jg], ((~&strm_write | &strm_grants) & strm_write[jg])});
    assign avmm_read[jg]  =  |(grant[jg*total_masters+:total_masters] & {jtag_read[jg],  user_read[jg],  ((~&strm_read  | &strm_grants) & strm_read[jg])});
    
    // Split the wait request, and if the grant is asserted to any one master, assert wait request to all others
    assign {jtag_waitrequest[jg], user_waitrequest[jg], strm_waitrequest[jg]} = (~grant[jg*total_masters+:total_masters] | {total_masters{avmm_waitrequest[jg]}});
    
    // Since these are buses, the logic must be done in a bit-wise fashion; hence the for loop
    // Generate the address for the bus width 
    for(ig=0; ig<address_width;ig=ig+1) begin: g_avmm_address
      assign avmm_address[jg*address_width + ig] = |(grant[jg*total_masters+:total_masters] & {jtag_address[jg*address_width + ig], user_address[jg*address_width + ig], strm_address[jg*address_width + ig]});
    end // End g_avmm_address
    
    // Generate the write data for the bus width
    for(ig=0; ig<data_width;ig=ig+1) begin: g_avmm_writdata
      assign avmm_writedata[jg*data_width+ ig] = |(grant[jg*total_masters+:total_masters] & {jtag_writedata[jg*data_width + ig], user_writedata[jg*data_width + ig], strm_writedata[jg*data_width + ig]});
    end // End g_avmm_writedata
  
  end //End for interface-wise for loop
endgenerate // End generate 
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "Qpn6yaCwI1RZ4kkjNzbswjNc69/0GAZZyecmVdhUvEMoYEgWRIuls/pJRRXQfHGxbpEXL0l6XzyyJ/EO56CgfTYjPV77KmSwoSxJu/rMVhwBKNHSxF2Vc0bGstlAMtUPBb1Xnw1be8xPNCHJJE0CnuJ9PdCUrwn51F5fXrRKAdoaMEfnhz/B/+vNvmfaZvjsSPyRAae0ZHr3kVsU1YayXGZFgjBuRtAA9OOJdu9Ras3mKy93qGPqffE3e8+2bAGVIit4ba1m52reWdGKMYNalYnbYqK3CM1qK2iuJbCiMZW/IcOXf4x+O3O1+ZC5NQx3oy4sqFlnZbIej081mw4DjHZc2NJsbrn3Exvi52vE2PuqTcVgybq0QjRDD9EH3fpsEm4vUZ30zm6wICO/+RCixufkGULVXQQjFIrAIe0AeV3Trl9QOtfjE1pyuDut315XXc0FhG9BSiOK22H42VeIv/LsgjiabZQRevOfIyhCM1JE3L3Y6AcGYD12Yj6PW7546R4lw32hhQjtV2s03gZkHPhKVmPqdwMZj9e9toSUI674s8114A0J8WAwszby+OIxqoErKJ3DKSHiojA3ZwjFBUkECrqqXxOBG6YIShSfu4F0It2FmQooRPwY5A7IsPAAa5ncj02FeR4X6SlUDTl9KSdeAZGgNxACM1bcogHGSuDQIXDY+1I37/ow6frZEkCUVdssVlD3otrlsH9AIsrmbX2oWjSt7wt+Mb4BZjRhDEtzuUnlTOVyqVP1/4AzdPr2qmWgfVf3xodUMHUKjobyXWuGK+Ek2F0oQmeOJ7L1Xv+lDoNLz0UfnYizCuCTYl1JlfkVbw/Pb2hv8taF4pU5D8t86+Sl0pW9+Oi57c0O4RQGWEkylME/IzD/37G5fqoqGVnEIybTx0YoQPHs7Nnqz28l4B3B721dk9tdEpggNvUxglHTq4FPRHMj+kL/p6lJlJU5blEr0mokF5jhoa+07CeoFiyICTpIJ2StZVMtyHAPveLfL2SKllwkuo2jQKql"
`endif