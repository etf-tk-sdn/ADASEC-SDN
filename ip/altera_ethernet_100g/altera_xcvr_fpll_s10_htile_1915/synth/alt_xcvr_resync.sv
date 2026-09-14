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


// Module: alt_xcvr_resync
//
// Description:
//  A general purpose resynchronization module.
//  
//  Parameters:
//    SYNC_CHAIN_LENGTH
//      - Specifies the length of the synchronizer chain for metastability
//        retiming.
//    WIDTH
//      - Specifies the number of bits you want to synchronize. Controls the width of the
//        d and q ports.
//    SLOW_CLOCK - USE WITH CAUTION. 
//      - Leaving this setting at its default will create a standard resynch circuit that
//        merely passes the input data through a chain of flip-flops. This setting assumes
//        that the input data has a pulse width longer than one clock cycle sufficient to
//        satisfy setup and hold requirements on at least one clock edge.
//      - By setting this to 1 (USE CAUTION) you are creating an asynchronous
//        circuit that will capture the input data regardless of the pulse width and 
//        its relationship to the clock. However it is more difficult to apply static
//        timing constraints as it ties the data input to the clock input of the flop.
//        This implementation assumes the data rate is slow enough
//    INIT_VALUE
//      - Specifies the initial values of the synchronization registers.
//
// Apply embedded false path timing constraint
(* altera_attribute  = "-name SDC_STATEMENT \"set regs [get_registers -nowarn *alt_xcvr_resync*sync_r[0]]; if {[llength [query_collection -report -all $regs]] > 0} {set_false_path -to $regs}\"" *)

`timescale 1ps/1ps 

module alt_xcvr_resync #(
    parameter SYNC_CHAIN_LENGTH = 2,  // Number of flip-flops for retiming. Must be >1
    parameter WIDTH             = 1,  // Number of bits to resync
    parameter SLOW_CLOCK        = 0,  // See description above
    parameter INIT_VALUE        = 0
  ) (
  input   wire              clk,
  input   wire              reset,
  input   wire  [WIDTH-1:0] d,
  output  wire  [WIDTH-1:0] q
  );

localparam  INT_LEN       = (SYNC_CHAIN_LENGTH > 1) ? SYNC_CHAIN_LENGTH : 2;
localparam  [INT_LEN-1:0] L_INIT_VALUE = (INIT_VALUE == 1) ? {INT_LEN{1'b1}} : {INT_LEN{1'b0}};

genvar ig;

// Generate a synchronizer chain for each bit
generate for(ig=0;ig<WIDTH;ig=ig+1) begin : resync_chains
    wire                d_in;   // Input to sychronization chain.
    (* altera_attribute  = "disable_da_rule=D103" *)
    reg   [INT_LEN-1:0] sync_r = L_INIT_VALUE;

    assign  q[ig]   = sync_r[INT_LEN-1]; // Output signal

    always @(posedge clk or posedge reset)
      if(reset)
        sync_r  <= L_INIT_VALUE;
      else
        sync_r  <= {sync_r[INT_LEN-2:0],d_in};

    // Generate asynchronous capture circuit if specified.
    if(SLOW_CLOCK == 0) begin
      assign  d_in = d[ig];
    end else begin
      wire  d_clk;
      reg   d_r = L_INIT_VALUE[0];
      wire  clr_n;

      assign  d_clk = d[ig];
      assign  d_in  = d_r;
      assign  clr_n = ~q[ig] | d_clk; // Clear when output is logic 1 and input is logic 0

      // Asynchronously latch the input signal.
      always @(posedge d_clk or negedge clr_n)
        if(!clr_n)      d_r <= 1'b0;
        else if(d_clk)  d_r <= 1'b1;
    end // SLOW_CLOCK
  end // for loop
endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "/RDp5nbdJI/I+mTEYq1BvrygziL3298XeYthiYFQQqg/2/Ylikra3AL5fYFj21YJTqSTeuced4Tn4OFvdQyfj5RXz9f6Xk6oB7vATPK9ELh2mwnhQJa3ipyfhFCPOvL+61RNdd+D1i/J5PgDzu1txNYj0taJ0uwH1coeSCaN+PlpO1BEGKISBNXOT1TAMV4pB7/0nOVCBGL902T5gpagi0SJY6mw2Vr4SnRd4TmXIL42YdocZcDqTXKFWzlSPl6TOSlsKeGJzcjIt1YHcxRuNqm1nf6GvdHvkjFUuZHZWo17tHs9oBPDSNzD+MzGbRCqzSzS6sBJA/tGo/AEd7ynG/BBpHQoxXrIMEMUNLvX7p3LRUWCU5P9wMF9/7h3o4YyetAaj7kmu1alFfn3C/hBeTomh2aOGi6LHrZ64yyN0ovUxB6+38Uv2QaMB9DAmpzpYqAZ8oqtryknXDNA7i9doIYTmE5+Xoio6wEioyzMXgH6FoY2VDiZYYhRVCfgQC90Ufh7+TJcWRk8DQEmLaStGlePQ8jcBJuSWcEertY2AlD67JZ7lq3XKdqAWn0eKoFl8cJwcmBQ/v0ZCx1ORQ3r/WXAgwvlSFYmwl4gl6ciNOzhvuR7XZLkjf15a/ylqR9hquDR1i+zuPbXkBj+hjh+czhUctyaebYSB8+oRILe6nX6BJcWWZKl5nKrkxYSZcf08a294HWYIt3YVywulpBO/hpT/oQZSiGYoEwwB6e4fqD/qbpViNzu/+oZkpCHF/cRDiqh3nrvmZv8FNTYuAPsb9uuvTR9fyhjoIWDhlTQHERTshypbqlJqJUHKW5GfH5AK/zTlcJpm8q/dnpv6/v/l+5tA1mBBLJweriQJaYUdEzeM3VpzB8YuyjWKEZ8VxUW9p3HoOmsyW4RtnR43P5NRp1yz/wZrR5AHqRT/HwxRB6Z5hVv/4okHzvndjw1cp2irDtVgEkhNcDFTkA4VV4aEuchcyDr5a/JQngDyyYCv2XgMqVgHkNCx1q0WnbmaPvp"
`endif