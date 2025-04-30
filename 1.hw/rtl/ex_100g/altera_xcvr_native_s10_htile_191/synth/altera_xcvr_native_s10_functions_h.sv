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


//
// Common functions for Stratix 10 Native PHY IP
//
`timescale 1 ps/1 ps
  
package altera_xcvr_native_s10_functions_h;

    localparam  MAX_CONVERSION_SIZE_ALT_XCVR_NATIVE_S10 = 128;
    localparam  MAX_STRING_CHARS_ALT_XCVR_NATIVE_S10  = 64;
	  localparam integer MAX_CHARS_ALT_XCVR_NATIVE_S10 = 86; // To accomodate LONG parameter lists.
   
    ////////////////////////////////////////////////////////////////////
    // Return the number of bits required to represent an integer
    // E.g. 0->1; 1->1; 2->2; 3->2 ... 31->5; 32->6
    //
    function integer clogb2_alt_xcvr_native_s10;
      input integer input_num;
      begin
        for (clogb2_alt_xcvr_native_s10=0; input_num>0; clogb2_alt_xcvr_native_s10=clogb2_alt_xcvr_native_s10+1)
          input_num = input_num >> 1;
        if(clogb2_alt_xcvr_native_s10 == 0)
          clogb2_alt_xcvr_native_s10 = 1;
      end
    endfunction

    ////////////////////////////////////////////////////////////////////
    // Return the number of binary addr bits required to select an instance 
    // out of an integer number of items 
    // E.g. 1 or smaller->0; 2->1; 3,4->2; 5,6,7,8->3; ... 17..32->5;
    //
    function integer sel_bits_alt_xcvr_native;
      input integer input_num;
      begin
        sel_bits_alt_xcvr_native=0;
        for (input_num = input_num -1; input_num>0; input_num = input_num >> 1 )
          sel_bits_alt_xcvr_native = sel_bits_alt_xcvr_native + 1;
      end
    endfunction

    ////////////////////////////////////////////////////////////////////
    // Used to calculate the value of the "hssi_10g_tx_pcs_comp_cnt"
    // parameter for a given channel in a bonded configuration
    //
    // @param channels - Number of channels in the interface
    // @param pcs_bonding_master - PCS master channel index
    // @param channel_index - Index of channel within interface to determine
    //                        parameter value for.
    //
    // @return An integer value for the parameter "hssi_10g_tx_pcs_comp_cnt".
    function [7:0] get_comp_cnt_alt_xcvr_native_s10;
      input integer channels;
      input integer pcs_bonding_master;
      input integer channel_index;

      integer max_index;
      integer comp_cnt;
      begin
        // Determine the index of the master
        max_index = (pcs_bonding_master > (channels - pcs_bonding_master)) ? pcs_bonding_master
          : (channels-pcs_bonding_master);
        // Determine the index of this channel
        if (channel_index == pcs_bonding_master)
          comp_cnt  = max_index;
        else if (channel_index < pcs_bonding_master)
          comp_cnt  = max_index - (pcs_bonding_master - channel_index);
        else
          comp_cnt  = max_index - (channel_index - pcs_bonding_master);
        // Convert index to count value
        comp_cnt = comp_cnt * 2;
        get_comp_cnt_alt_xcvr_native_s10 = comp_cnt[7:0];
      end
    endfunction

    ////////////////////////////////////////////////////////////////////
    // Used to calculate the value of the distance of current channel to mcgb
    //
    // @param pcs_bonding_master - PCS master channel index
    // @param channel_index - Index of channel within interface to determine
    //                        parameter value for.
    //
    // @return An 4 bits value for the parameter lower 3 showing distance, if MSB 1 then the current channel is above the mcgb 
    function [4:0] get_mcgb_location_alt_xcvr_native_s10(
      input integer pcs_bonding_master,
      input integer channel_index
    );
      integer distance;
      begin
        if (channel_index < pcs_bonding_master) begin
           distance = pcs_bonding_master-channel_index;
           get_mcgb_location_alt_xcvr_native_s10 = {1'b1,distance[3:0]};
        end else begin
           distance = channel_index-pcs_bonding_master;
           get_mcgb_location_alt_xcvr_native_s10 = {1'b0,distance[3:0]};
        end
      end
    endfunction


    function automatic [MAX_CONVERSION_SIZE_ALT_XCVR_NATIVE_S10-1:0] str_2_bin_alt_xcvr_native_s10;
      input [MAX_STRING_CHARS_ALT_XCVR_NATIVE_S10*8-1:0] instring;

      integer this_char;
      integer i;
      begin
        // Initialize accumulator
        str_2_bin_alt_xcvr_native_s10 = {MAX_CONVERSION_SIZE_ALT_XCVR_NATIVE_S10{1'b0}};
        for(i=MAX_STRING_CHARS_ALT_XCVR_NATIVE_S10-1;i>=0;i=i-1) begin
          this_char = instring[i*8+:8];
          // Add value of this digit
          if(this_char >= 48 && this_char <= 57)
            str_2_bin_alt_xcvr_native_s10 = (str_2_bin_alt_xcvr_native_s10 * 10) + (this_char - 48);
        end
      end
    endfunction

    ////////////////////////////////////////////////////////////////////
    // Adds an offets to 'scrambler seed' per channel for interlaken as:
    // (58'h123456789abcde + user_seed + (24'h826a3*lane_number)) 
    // see FB 138336 for details
    //
    // @param protocol_hint - only interlaken matters
    // @param user_seed     - 58 bit base seed to be modified per channel
    // @param lane_number   - Index of channel within interface to determine
    //                        parameter value for.
    //
    // @return 58 bits scrambler seed for the channel
    function [57:0] set_10g_scrm_seed_user_alt_xcvr_native_s10 (
      input [8*MAX_STRING_CHARS_ALT_XCVR_NATIVE_S10:1] protocol_hint,
      input [57:0]                 user_seed,
      input integer                lane_number
    );
      set_10g_scrm_seed_user_alt_xcvr_native_s10 = (protocol_hint == "interlaken_mode") ? (58'h123456789abcde + user_seed + (24'h826a3*lane_number)) : user_seed;
    endfunction

  ////////////////////////////////////////////////////////////////////
  // Convert an integer to a string
  function [MAX_CHARS_ALT_XCVR_NATIVE_S10*8-1:0] int2str_alt_xcvr_native_s10(
    input integer in_int
  );
    integer i;
    integer this_char;
    i = 0;
    int2str_alt_xcvr_native_s10 = "";
    do
    begin
      this_char = (in_int % 10) + 48;
      int2str_alt_xcvr_native_s10[i*8+:8] = this_char[7:0];
      i=i+1;
      in_int = in_int / 10; 
    end
    while(in_int > 0);
  endfunction

   
endpackage
