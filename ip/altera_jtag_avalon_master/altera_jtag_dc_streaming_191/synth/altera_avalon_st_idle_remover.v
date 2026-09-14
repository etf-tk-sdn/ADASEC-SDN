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


// --------------------------------------------------------------------------------
//| Avalon ST Idle Remover 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_remover (

      // Interface: clk
      input              clk,
      input              reset_n,
      // Interface: ST in
      output reg         in_ready,
      input              in_valid,
      input      [7: 0]  in_data,

      // Interface: ST out 
      input              out_ready,
      output reg         out_valid,
      output reg [7: 0]  out_data
);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------

   reg  received_esc;
   wire escape_char, idle_char;

   // ---------------------------------------------------------------------
   //| Thingofamagick
   // ---------------------------------------------------------------------

   assign idle_char = (in_data == 8'h4a);
   assign escape_char = (in_data == 8'h4d);

   always @(posedge clk or negedge reset_n) begin
      if (!reset_n) begin
         received_esc <= 0; 
      end else begin
         if (in_valid & in_ready) begin
            if (escape_char & ~received_esc) begin
                 received_esc <= 1;
            end else if (out_valid) begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      in_ready = out_ready;
      //out valid when in_valid.  Except when we get idle or escape
      //however, if we have received an escape character, then we are valid
      out_valid = in_valid & ~idle_char & (received_esc | ~escape_char);
      out_data = received_esc ? (in_data ^ 8'h20) : in_data;
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OraYGnqZAGf5M3WGiRIUztRR2XPfDUWtSPZUayeiSjFSmrTPINcfoCe/2a8UnQ2IC7jZaYSgYXZKXilBbr8NDXIXu9io8f7PC+p4+oQf/uerp1rLLS7PivmzhjlGjSNWPE+7KYfnsL2S3nAzUxUd2zNZBKOBEGfZToff5axnXurFANpNl/fuHMpgeS08IiPY21928m0zINQukBxVZxQw+UgJrul+Kw3td6vC1MD9KfwGgaexYwJ1+fFEFBfARoWllAUcqm0SmvE2rKzpDzE44aIlRy213g9+8LzjANFBJ2UiI1+Q6tZtHR3FBkuJBEnF27l+/42S0es9PYJFdI6sH95aJQ9RcpmgWxbzO6f6a3BfoQ7cZRadzIctH0a6tJR72TE+zCjdZEpE55Mwo0W9E9uEru43nwlPQWMPIxFcUDT54qL33Nix6BHT2ZFrif4MDkZugCLJou19MfjVsRyzXlzIailxM9m2uURYdWwZeCMzaWYP3r1k4VIfYkXVbi7vdLzNTFSwIObH9QpT6lHkZapEXZOGzFtMGVWguUkX1tNg/gxkfwcY9GWsnqy4qWovlF3KY+rWYqk+cpJCmGhhXlDlLyqc7zoy0wqnJ7e8JmXKTkKQp+9d0Vha1/MSU4ucaRELNFfZjOQzAeAY8VamK52r9h+pkIPemZSZUCTyZFd77/5llQ0GwJeWG62xe8r0txMcMLbeJLwIGnkQLe+0mK2yi1WBBStL1neC19ts2qTya87azdj1S2YGWcU5iQNc/8UnPniJPubnHB8VbcDmTAdqHAhNcFRUhLxhMlXaGWokJ4Gakj1Fqgi5jK57UWC/8S6JpMulqrl3/oxNC29OzeY/EG7izz73y6tH6i/to6McOAq7GejiJPgv9SkVkva6Awhozw/Pe1pvvIF0T7oJETIVpf5OIZCML3g9/sqP9GCV1SsFA5CqKKLRnF1t3q95XBAW3XU7ARER3pVi3aQNSiq99QnevJ20/2QKhM7jniUuY5yJQKRQAR4XuBJQ78b1"
`endif