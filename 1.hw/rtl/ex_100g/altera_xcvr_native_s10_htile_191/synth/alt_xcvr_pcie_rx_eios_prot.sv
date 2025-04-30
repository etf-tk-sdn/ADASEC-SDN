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


// Altera or its authorized distributors.  Please refer to the applicable
// agreement for further details.


// synthesis translate_off
`timescale 1ns / 1ps
`define ALTERA_RTL_MODE
`define ALTERA_SIMPLE_MEM
`define SIM_ONLY_ACDS
// synthesis translate_on

module alt_xcvr_pcie_rx_eios_prot # (
   parameter LANES = 16, 
   parameter BONDED_MASTER_CHANNEL = 8,
   parameter ADDR_BITS = 11,
   parameter SEL_BITS = altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(LANES-1)
  )
  (
  // clock and active low reset
   input         clk, nreset,
   input         eios_rx_prot_req, 
   input [1:0]   current_rate,
   //exported from PHY
   input [LANES-1:0]     pld_pmaif_mask_tx_pll,
   input [LANES-1:0]     pcie_ctrl_testbus_b10,  
   //PHY reconfig interface
   input          xcvr_reconfig_clk ,
   input          xcvr_reconfig_reset ,
   output reg [ADDR_BITS+SEL_BITS-1:0] xcvr_reconfig_address,
   output [31:0] xcvr_reconfig_writedata, 
   input  [31:0] xcvr_reconfig_readdata,
   output reg xcvr_reconfig_write, 
   output reg xcvr_reconfig_read,
   input         xcvr_reconfig_waitrequest
  );

//==============================================================================================
   //logic below is to implement workaround for the revB si G3->G2 speed change issue in PCS
//==============================================================================================

   localparam TX_PLL_MASK_DLY_CYCLE = 32;
   localparam RX_WORKAROUND_EN = 1'b1;

   integer   i;

// Logic running @ pld_clk domain
   reg pcs_bypass_clr, pcs_bypass_clr_dly;
   reg l1_entry_workaround_needed,
       l1_entry_workaround_needed_dly;

   reg       eios_rx_prot_req_dly;
   reg [3:0] rx_stretch_counter; 
   wire      nreset_sync2;

   reg [3:0] reconfig_rx_chnl; //for 16-lane coeff value access

    //following are the RX workaround implementation
   wire tx_pll_mask;
   wire tx_pll_mask_sync;  // sync to xcvr_reconfig_clk first
   wire [LANES-1:0] inferred_rxvalid, inferred_rxvalid_sync;
   wire l1_entry_workaround_needed_sync;
   reg l1_entry_workaround_needed_sync_dly;

    assign inferred_rxvalid = pcie_ctrl_testbus_b10[LANES-1:0];
    assign tx_pll_mask =      pld_pmaif_mask_tx_pll[BONDED_MASTER_CHANNEL];
        
   reg  tx_pll_mask_dly;  //delay the signal for one cycle
   reg  tx_pll_mask_dly_in_progress;
   reg [6:0]  tx_pll_mask_dly_count;

   reg [LANES-1:0] rx_workaround_needed;  //when asserted, indicating the RX work around need be implemented
   reg [LANES-1:0] rx_workaround_done;
   reg [LANES-1:0] rx_workaround_clr; 
   reg [LANES-1:0] inferred_rxvalid_sync_dly;
   reg [LANES-1:0] inferred_rxvalid_fall_hold;
   
   //reset sync cell
   altera_std_synchronizer_nocut  u_sync_nreset  (.clk (clk), .reset_n (nreset), .din (1'b1), .dout (nreset_sync2));
    
   always @ (posedge clk or negedge nreset_sync2)
      if (~nreset_sync2) 
        begin
            
            rx_stretch_counter <= 4'h0;
            eios_rx_prot_req_dly <= 1'b0;
            l1_entry_workaround_needed <= 1'b0;
            l1_entry_workaround_needed_dly <= 1'b0;           

        end
      else 
        begin
            eios_rx_prot_req_dly <= eios_rx_prot_req;       

            if (RX_WORKAROUND_EN) begin
               l1_entry_workaround_needed <= ((!eios_rx_prot_req_dly  && eios_rx_prot_req) & ((current_rate == 2'h2) | (current_rate == 2'h1)))? 1'b1 : 
                               (rx_stretch_counter == 4'hf) ? 1'b0 : l1_entry_workaround_needed;
               rx_stretch_counter <= (rx_stretch_counter == 4'hf) ? 4'h0:
                                     l1_entry_workaround_needed ? rx_stretch_counter + 1'b1 : rx_stretch_counter;
               l1_entry_workaround_needed_dly <= l1_entry_workaround_needed;                      
            end
                        
        end


   //==================================================
   //Logic running @ xcvr_reconfig_clk domain
   //Logic transferred to xcvr_reconfig_clk domain, using ******_dly version to ensure the hip_coeff_value latched stable when launching in another domain
  
   altera_std_synchronizer_nocut u_tx_pll_mask_sync (.clk (xcvr_reconfig_clk), .reset_n (~xcvr_reconfig_reset), .din (tx_pll_mask), .dout (tx_pll_mask_sync));
   altera_std_synchronizer_nocut u_l1_entry_workaround_needed_sync (.clk (xcvr_reconfig_clk), .reset_n (~xcvr_reconfig_reset), .din (l1_entry_workaround_needed), .dout (l1_entry_workaround_needed_sync));
  
   genvar k;
   generate 
    for (k=0; k<LANES; k=k+1) begin: sync_logic
       altera_std_synchronizer_nocut u_inferred_rxvalid_sync (.clk (xcvr_reconfig_clk), .reset_n (~xcvr_reconfig_reset), .din (inferred_rxvalid[k]), .dout (inferred_rxvalid_sync[k]));
    end
   endgenerate

   wire xcvr_reg1e_write_accepted,
        xcvr_reg1e_read_accepted;

   reg [6:0]  pcs_reg1e_latch [0:LANES-1];
        
    


   //==============================================================================     
   //workaround on RX side     
   assign xcvr_reconfig_ovr_reg1e = (xcvr_reconfig_address[10:0] == 'h1E);
   // reg1E is for RX side workaround
   assign xcvr_reg1e_write_accepted = xcvr_reconfig_write & ~xcvr_reconfig_waitrequest & xcvr_reconfig_ovr_reg1e;
   assign xcvr_reg1e_read_accepted  = xcvr_reconfig_read  & ~xcvr_reconfig_waitrequest & xcvr_reconfig_ovr_reg1e;
   assign xcvr_reconfig_writedata = {|rx_workaround_needed, pcs_reg1e_latch[reconfig_rx_chnl]};

   always_comb begin
     xcvr_reconfig_address[ADDR_BITS-1:0] = 'h1e;
     if (SEL_BITS>=1)  xcvr_reconfig_address[ADDR_BITS+:SEL_BITS] = reconfig_rx_chnl[0+:SEL_BITS];
   end 

   always @ (posedge xcvr_reconfig_clk or posedge xcvr_reconfig_reset)
      if (xcvr_reconfig_reset)
      begin
         xcvr_reconfig_write <= 1'b0;
         xcvr_reconfig_read  <= 1'b0;
         reconfig_rx_chnl    <= 4'h0;
      end
      else
      begin
        xcvr_reconfig_write  <= (xcvr_reconfig_write & ~xcvr_reconfig_waitrequest)? 1'b0: 
                                  ((|rx_workaround_needed & xcvr_reg1e_read_accepted) | (|rx_workaround_clr)) ? 1'b1 : xcvr_reconfig_write;
      if (LANES == 16) begin                          
        reconfig_rx_chnl  <= (rx_workaround_needed[0] | (~(&rx_workaround_needed) & rx_workaround_clr[0]))? 4'h0 : 
         (rx_workaround_needed[1] | (~(&rx_workaround_needed) & rx_workaround_clr[1]))? 4'h1 : 
         (rx_workaround_needed[2] | (~(&rx_workaround_needed) & rx_workaround_clr[2]))? 4'h2 : 
         (rx_workaround_needed[3] | (~(&rx_workaround_needed) & rx_workaround_clr[3]))? 4'h3 : 
         (rx_workaround_needed[4] | (~(&rx_workaround_needed) & rx_workaround_clr[4]))? 4'h4 : 
         (rx_workaround_needed[5] | (~(&rx_workaround_needed) & rx_workaround_clr[5]))? 4'h5 : 
         (rx_workaround_needed[6] | (~(&rx_workaround_needed) & rx_workaround_clr[6]))? 4'h6 : 
         (rx_workaround_needed[7] | (~(&rx_workaround_needed) & rx_workaround_clr[7]))? 4'h7 : 
         (rx_workaround_needed[8] | (~(&rx_workaround_needed) & rx_workaround_clr[8]))? 4'h8 : 
         (rx_workaround_needed[9] | (~(&rx_workaround_needed) & rx_workaround_clr[9]))? 4'h9 : 
         (rx_workaround_needed[10] | (~(&rx_workaround_needed) & rx_workaround_clr[10]))? 4'ha : 
         (rx_workaround_needed[11] | (~(&rx_workaround_needed) & rx_workaround_clr[11]))? 4'hb : 
         (rx_workaround_needed[12] | (~(&rx_workaround_needed) & rx_workaround_clr[12]))? 4'hc : 
         (rx_workaround_needed[13] | (~(&rx_workaround_needed) & rx_workaround_clr[13]))? 4'hd : 
         (rx_workaround_needed[14] | (~(&rx_workaround_needed) & rx_workaround_clr[14]))? 4'he : 
         (rx_workaround_needed[15] | (~(&rx_workaround_needed) & rx_workaround_clr[15]))? 4'hf : 
                             'h0;
      end
      else if (LANES == 8) begin
         reconfig_rx_chnl  <= (rx_workaround_needed[0] | (~(&rx_workaround_needed) & rx_workaround_clr[0]))? 4'h0 : 
         (rx_workaround_needed[1] | (~(&rx_workaround_needed) & rx_workaround_clr[1]))? 4'h1 : 
         (rx_workaround_needed[2] | (~(&rx_workaround_needed) & rx_workaround_clr[2]))? 4'h2 : 
         (rx_workaround_needed[3] | (~(&rx_workaround_needed) & rx_workaround_clr[3]))? 4'h3 : 
         (rx_workaround_needed[4] | (~(&rx_workaround_needed) & rx_workaround_clr[4]))? 4'h4 : 
         (rx_workaround_needed[5] | (~(&rx_workaround_needed) & rx_workaround_clr[5]))? 4'h5 : 
         (rx_workaround_needed[6] | (~(&rx_workaround_needed) & rx_workaround_clr[6]))? 4'h6 : 
         (rx_workaround_needed[7] | (~(&rx_workaround_needed) & rx_workaround_clr[7]))? 4'h7 : 4'h0;
      end
      else if (LANES == 4) begin
         reconfig_rx_chnl  <= (rx_workaround_needed[0] | (~(&rx_workaround_needed) & rx_workaround_clr[0]))? 4'h0 : 
         (rx_workaround_needed[1] | (~(&rx_workaround_needed) & rx_workaround_clr[1]))? 4'h1 : 
         (rx_workaround_needed[2] | (~(&rx_workaround_needed) & rx_workaround_clr[2]))? 4'h2 : 
         (rx_workaround_needed[3] | (~(&rx_workaround_needed) & rx_workaround_clr[3]))? 4'h3 : 4'h0;
      end
      else if (LANES == 2) begin
         reconfig_rx_chnl  <= (rx_workaround_needed[0] | (~(&rx_workaround_needed) & rx_workaround_clr[0]))? 4'h0 : 
         (rx_workaround_needed[1] | (~(&rx_workaround_needed) & rx_workaround_clr[1]))? 4'h1 : 4'h0;
      end
      else reconfig_rx_chnl  <= 4'h0;
      xcvr_reconfig_read <= (xcvr_reconfig_read & ~xcvr_reconfig_waitrequest) ? 1'b0:
                               (|rx_workaround_needed & ~xcvr_reconfig_write) ? 1'b1 :
                               xcvr_reconfig_read;                     
      end
   
   assign tx_pll_mask_chk = (tx_pll_mask_dly_count== TX_PLL_MASK_DLY_CYCLE) | (l1_entry_workaround_needed_sync & ~l1_entry_workaround_needed_sync_dly);

   always @ (posedge xcvr_reconfig_clk or posedge xcvr_reconfig_reset)
      if (xcvr_reconfig_reset)
      begin
         tx_pll_mask_dly <= 1'b0;
         tx_pll_mask_dly_in_progress <= 1'b0;
         tx_pll_mask_dly_count <= 7'h0; 
         l1_entry_workaround_needed_sync_dly <= 1'b0;
         for (i=0; i<LANES; i=i+1) begin
             rx_workaround_needed[i] <= 1'b0;
             rx_workaround_done[i]   <= 1'b0;
             rx_workaround_clr[i]    <= 1'b0;
             pcs_reg1e_latch[i]      <= 7'h0;
             inferred_rxvalid_sync_dly[i] <=1'b0;
             inferred_rxvalid_fall_hold[i] <= 1'b0;
         end
      end
      else
      begin
         tx_pll_mask_dly <= tx_pll_mask_sync;
         l1_entry_workaround_needed_sync_dly <= l1_entry_workaround_needed_sync;
          inferred_rxvalid_sync_dly <= inferred_rxvalid_sync;
          tx_pll_mask_dly_in_progress <= tx_pll_mask_chk ? 1'b0 :
                                         (~tx_pll_mask_dly & tx_pll_mask_sync) ? 1'b1: tx_pll_mask_dly_in_progress;

          tx_pll_mask_dly_count <= tx_pll_mask_chk ? 'h1:
                                   tx_pll_mask_dly_in_progress ? tx_pll_mask_dly_count + 1'b1: 
                                   tx_pll_mask_dly_count;

         //if tx_mask_pll transition low-to-high, & inferred_rxvalid_sync is high then EIOS is not detected
         if (RX_WORKAROUND_EN) begin
            for (i=0; i<LANES; i=i+1) begin   
                inferred_rxvalid_fall_hold[i] <= (inferred_rxvalid_sync_dly[i] & ~inferred_rxvalid_sync[i])? 1'b1 :
                                                 (inferred_rxvalid_sync[i])? 1'b0 :
                                                 (rx_workaround_clr[i] & (reconfig_rx_chnl==i) & xcvr_reg1e_write_accepted)? 1'b0 :
                                                 inferred_rxvalid_fall_hold[i];
                rx_workaround_needed[i] <= (rx_workaround_needed[i] & (reconfig_rx_chnl==i) & xcvr_reg1e_write_accepted) ? 1'b0 : 
                                           (tx_pll_mask_chk & inferred_rxvalid_sync[i]) ? 1'b1 : 
                                           rx_workaround_needed[i];
                rx_workaround_done[i]   <= (rx_workaround_clr[i]   & (reconfig_rx_chnl==i) & xcvr_reg1e_write_accepted) ? 1'b0 : 
                                           (rx_workaround_needed[i] & (reconfig_rx_chnl==i) & xcvr_reg1e_write_accepted) ? 1'b1 : 
                                           rx_workaround_done[i];
                rx_workaround_clr[i]    <=  (rx_workaround_clr[i] & (reconfig_rx_chnl==i) & xcvr_reg1e_write_accepted) ? 1'b0 :
                                            (inferred_rxvalid_fall_hold[i] & rx_workaround_done[i]) ? 1'b1 : 
                                            rx_workaround_clr[i];
                
               pcs_reg1e_latch[i]      <= rx_workaround_needed[i] & (reconfig_rx_chnl==i) & xcvr_reg1e_read_accepted ? xcvr_reconfig_readdata[6:0] : pcs_reg1e_latch[i];                           
            end   
         end
   end   

endmodule // alt_xcvr_pcie_rx_eios_prot
