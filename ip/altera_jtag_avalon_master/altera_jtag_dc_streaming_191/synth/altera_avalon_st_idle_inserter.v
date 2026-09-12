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
//| Avalon ST Idle Inserter 
// --------------------------------------------------------------------------------

`timescale 1ns / 100ps
module altera_avalon_st_idle_inserter (

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
         if (in_valid & out_ready) begin
            if ((idle_char | escape_char) & ~received_esc & out_ready) begin
                 received_esc <= 1;
            end else begin
                 received_esc <= 0;
            end
         end
      end
   end

   always @* begin
      //we are always valid
      out_valid = 1'b1;
      in_ready = out_ready & (~in_valid | ((~idle_char & ~escape_char) | received_esc));
      out_data = (~in_valid) ? 8'h4a :    //if input is not valid, insert idle
                 (received_esc) ? in_data ^ 8'h20 : //escaped once, send data XOR'd
                 (idle_char | escape_char) ? 8'h4d : //input needs escaping, send escape_char
                 in_data; //send data
   end
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "OraYGnqZAGf5M3WGiRIUztRR2XPfDUWtSPZUayeiSjFSmrTPINcfoCe/2a8UnQ2IC7jZaYSgYXZKXilBbr8NDXIXu9io8f7PC+p4+oQf/uerp1rLLS7PivmzhjlGjSNWPE+7KYfnsL2S3nAzUxUd2zNZBKOBEGfZToff5axnXurFANpNl/fuHMpgeS08IiPY21928m0zINQukBxVZxQw+UgJrul+Kw3td6vC1MD9KfyrLkJ7UfKv+Y5fEPs/+nkitQMplwP9ZHirkcgjoMe35vwobmdghNwc9SK/AublKnMOEZnnoflia60BQANDdT9TRaBiWxRycLsm4fj5grv8bfld13UoJn3w9GDEl+qxuVLP2+YvU7i50J2dy4+wWFCBCmEo9Q8KgGstgpEAbTwHXXlx/5LOxzSYxTNU7O0QpYxCW/71Huef7ZD5HhjGBXnHRSnX3Wribx2K3HV8EnBOHzN2TT14JI/xBVK9bcG8i+gGEH5dpti7L8vTECG3EUKS6tv4U75rm8bnr47ln8X/U3T53Cj5KkvdZDAF/FLHil2/zFgAaR3wU9OItnEXISjPzxxWOH/aLyWZkKQDMlKOZgWkRZ65lntNF+bEwzeLdsJsy1gAcasGe1Imn1zzy89iohwjn7iazkKd1pdQNDrzZdA1aRWXuaxGGPFs1ftuFTgR/F42o0xvMB2AHI7+X/Pu2KALP73wnJh8l9T45BY8GocBeEryfuSSalkWQCRCBT6j8v8ATU57N4cxmiXMhxPwkPwUf4QQ0xH1lh2M8tv3SDS/wfCwTtcc90aCZFVJz5C0J58Zn6qVrqvxMp18SneDix6cLW6Z5X8T3ftH/nuwqcN98HCnQxxEYmCLDFgOSHTM7r5T7+cptOcn6u7aBtTYgRIfCrj4ZtrBtwMp/kJ4EG26Avdl+FDZtdiOVAQFNpUphHXzwTTVodlE/5CoRS4bc7akLNXqYD8pHCm470/JhadZDcTZD0RklfBWhnMOGRLLMs2sY6eJmTR//FH3qgQr"
`endif