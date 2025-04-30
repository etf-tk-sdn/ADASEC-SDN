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


`timescale 1 ps/1 ps

package s10_avmm_h;

  // localparam to define unused bus
  localparam RD_UNUSED                  = 8'h0;

  // localparams for common capability registers
  localparam S10_XR_ADDR_ID_0           = 10'h0;
  localparam S10_XR_ADDR_ID_1           = 10'h1;
  localparam S10_XR_ADDR_ID_2           = 10'h2;
  localparam S10_XR_ADDR_ID_3           = 10'h3;
  localparam S10_XR_ADDR_STATUS_EN      = 10'h4;
  localparam S10_XR_ADDR_CONTROL_EN     = 10'h5;
  // Reserve Address 10'h6 to 10'hF for common capablities

  // native phy capability
  localparam S10_XR_ADDR_NAT_CHNLS      = 10'h10;
  localparam S10_XR_ADDR_NAT_CHNL_NUM   = 10'h11;
  localparam S10_XR_ADDR_NAT_DUPLEX     = 10'h12;
  localparam S10_XR_ADDR_NAT_PRBS_EN    = 10'h13;
  localparam S10_XR_ADDR_NAT_ODI_EN     = 10'h14;

  // pll ip capability
  localparam S10_XR_ADDR_PLL_MCGB_EN    = 10'h10;

  // localparams for csr for pll locked and cal busy
  localparam S10_XR_ADDR_GP_PLL_LOCK    = 10'h80;
  localparam S10_XR_OFFSET_GP_LOCK      = 0;
  localparam S10_XR_OFFSET_GP_CAL_BUSY  = 1;
  localparam S10_XR_OFFSET_GP_AVMM_BUSY = 2;
  localparam S10_XR_OFFSET_LOCK_UNUSED  = 3;
  localparam S10_XR_LOCK_UNUSED_LEN     = 5;

  // localparams for pll powerdown
  localparam S10_XR_ADDR_GP_PLL_RST     = 10'hE0;
  localparam S10_XR_OFFSET_PLL_RST      = 0;
  localparam S10_XR_OFFSET_PLL_RST_OVR  = 1;
  localparam S10_XR_OFFSET_PLL_RST_UNUSED = 2;
  localparam S10_XR_PLL_RST_UNUSED_LEN  = 6;

  // localparams for csr for lock to ref and lock to data
  localparam S10_XR_ADDR_GP_RD_LTR      = 10'h80;
  localparam S10_XR_OFFSET_RD_LTD       = 0;
  localparam S10_XR_OFFSET_RD_LTR       = 1;
  localparam S10_XR_OFFSET_LTR_UNUSED   = 2;
  localparam S10_XR_LTR_UNUSED_LEN      = 6;

  // localparams for csr for cal busy
  localparam S10_XR_ADDR_GP_CAL_BUSY    = 10'h81;
  localparam S10_XR_OFFSET_TX_CAL_BUSY  = 0;
  localparam S10_XR_OFFSET_RX_CAL_BUSY  = 1;
  localparam S10_XR_OFFSET_AVMM_BUSY    = 2;
  localparam S10_XR_OFFSET_CAL_DUMMY    = 3;
  localparam S10_XR_OFFSET_TX_CAL_MASK  = 4;
  localparam S10_XR_OFFSET_RX_CAL_MASK  = 5;
  localparam S10_XR_OFFSET_CAL_UNUSED   = 6;
  localparam S10_XR_CAL_UNUSED_LEN      = 2;

  // localparams for setting lock to ref and lock to data
  localparam S10_XR_ADDR_GP_SET_LTR     = 10'hE0;
  localparam S10_XR_OFFSET_SET_LTD      = 0;
  localparam S10_XR_OFFSET_SET_LTR      = 1;
  localparam S10_XR_OFFSET_SET_LTD_OVR  = 2;
  localparam S10_XR_OFFSET_SET_LTR_OVR  = 3;
  localparam S10_XR_OFFSET_SET_LTR_UNUSED = 4;
  localparam S10_XR_SET_LTR_UNUSED_LEN   = 4;

  // localparams for setting loopback
  localparam S10_XR_ADDR_GP_LPBK        = 10'hE1;
  localparam S10_XR_OFFSET_LPBK         = 0;
  localparam S10_XR_OFFSET_LPBK_UNUSED  = 1;
  localparam S10_XR_LPBK_UNUSED_LEN     = 7;

  // localparams for setting channel resets
  localparam S10_XR_ADDR_CHNL_RESET     = 10'hE2;
  localparam S10_XR_OFFSET_RX_ANA       = 0; 
  localparam S10_XR_OFFSET_RX_DIG       = 1; 
  localparam S10_XR_OFFSET_TX_ANA       = 2; 
  localparam S10_XR_OFFSET_TX_DIG       = 3; 
  localparam S10_XR_OFFSET_RX_ANA_OVR   = 4; 
  localparam S10_XR_OFFSET_RX_DIG_OVR   = 5; 
  localparam S10_XR_OFFSET_TX_ANA_OVR   = 6; 
  localparam S10_XR_OFFSET_TX_DIG_OVR   = 7; 

  // localparams for prbs addresses
  localparam S10_XR_ADDR_PRBS_CTRL      = 10'h100;
  localparam S10_XR_ADDR_PRBS_ERR_0     = 10'h101;
  localparam S10_XR_ADDR_PRBS_ERR_1     = 10'h102;
  localparam S10_XR_ADDR_PRBS_ERR_2     = 10'h103;
  localparam S10_XR_ADDR_PRBS_ERR_3     = 10'h104;
  localparam S10_XR_ADDR_PRBS_ERR_4     = 10'h105;
  localparam S10_XR_ADDR_PRBS_ERR_5     = 10'h106;
  localparam S10_XR_ADDR_PRBS_ERR_6     = 10'h107;
  localparam S10_XR_ADDR_PRBS_BIT_0     = 10'h10D;
  localparam S10_XR_ADDR_PRBS_BIT_1     = 10'h10E;
  localparam S10_XR_ADDR_PRBS_BIT_2     = 10'h10F;
  localparam S10_XR_ADDR_PRBS_BIT_3     = 10'h110;
  localparam S10_XR_ADDR_PRBS_BIT_4     = 10'h111;
  localparam S10_XR_ADDR_PRBS_BIT_5     = 10'h112;
  localparam S10_XR_ADDR_PRBS_BIT_6     = 10'h113;
  
  // localparams for prbs bit offsets
  localparam S10_XR_OFFSET_PRBS_EN      = 0;
  localparam S10_XR_OFFSET_PRBS_RESET   = 1;
  localparam S10_XR_OFFSET_PRBS_SNAP    = 2;
  localparam S10_XR_OFFSET_PRBS_DONE    = 3;
  localparam S10_XR_OFFSET_PRBS_UNUSED  = 4;
  localparam S10_XR_PRBS_UNUSED_LEN     = 4;

  // localparams for odi addresses
  localparam S10_XR_ADDR_ODI_CTRL       = 10'h120;
  localparam S10_XR_ADDR_ODI_ERR_0      = 10'h121;
  localparam S10_XR_ADDR_ODI_ERR_1      = 10'h122;
  localparam S10_XR_ADDR_ODI_ERR_2      = 10'h123;
  localparam S10_XR_ADDR_ODI_ERR_3      = 10'h124;
  localparam S10_XR_ADDR_ODI_ERR_4      = 10'h125;
  localparam S10_XR_ADDR_ODI_ERR_5      = 10'h126;
  localparam S10_XR_ADDR_ODI_ERR_6      = 10'h127;
  localparam S10_XR_ADDR_ODI_BIT_0      = 10'h12D;
  localparam S10_XR_ADDR_ODI_BIT_1      = 10'h12E;
  localparam S10_XR_ADDR_ODI_BIT_2      = 10'h12F;
  localparam S10_XR_ADDR_ODI_BIT_3      = 10'h130;
  localparam S10_XR_ADDR_ODI_BIT_4      = 10'h131;
  localparam S10_XR_ADDR_ODI_BIT_5      = 10'h132;
  localparam S10_XR_ADDR_ODI_BIT_6      = 10'h133;

  // localparams for odi bit offsets
  localparam S10_XR_OFFSET_ODI_EN       = 0;
  localparam S10_XR_OFFSET_ODI_RESET    = 1;
  localparam S10_XR_OFFSET_ODI_SNAP     = 2;
  localparam S10_XR_OFFSET_ODI_DONE     = 3;
  localparam S10_XR_OFFSET_ODI_UNUSED   = 4;
  localparam S10_XR_ODI_UNUSED_LEN      = 4;

  // localparams for embedded reconfig addresses
  // Control reg and offsets
  localparam S10_XR_ADDR_EMBED_RCFG_CTRL        = 10'h140;
  localparam S10_XR_OFFSET_EMBED_RCFG_CFG_SEL   = 0;
  localparam S10_XR_EMBED_RCFG_CFG_SEL_LEN      = 6; //bits [5:0] are alloted for cfg_sel even though GUI currently only supports upto 8 profiles.

  localparam S10_XR_OFFSET_EMBED_RCFG_BCAST_EN  = 6;
  localparam S10_XR_OFFSET_EMBED_RCFG_CFG_LOAD  = 7;

  // Status reg and offsets
  localparam S10_XR_ADDR_EMBED_RCFG_STATUS      = 10'h141;
  localparam S10_XR_OFFSET_EMBED_RCFG_STRM_BUSY = 0;

  // Background cal enable/disable
  localparam S10_XR_ADDR_BG_CAL      = 10'h142;
  localparam S10_XR_OFFSET_BG_CAL = 0;

endpackage
