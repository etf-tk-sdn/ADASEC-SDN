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



//------------------------------------------------------------------
// filename: altera_xcvr_atx_pll_s10.sv.terp
//
// Description : instantiates avmm and lc-pll
//
// Limitation  : Intended for Nadder
//
// Copyright (c) Altera Corporation 1997-2012
// All rights reserved
//-------------------------------------------------------------------
//
// NOTEs
// - comments marked with OPEN means there is an issue that needs to be resolved but cannot be done due to lack of information.
// - comments marked with TODO means there is an issue that needs to be resolved and there is enough information already for the issue to be resolved.
//
//-------------------------------------------------------------------


// OPEN should we remove timescale?
`timescale 1 ns / 1 ns

module ex_100g_altera_xcvr_atx_pll_s10_htile_191_3kcg2aa
  #(  
      // H-Tile specific
      parameter atx_pll_bcm_silicon_rev = "rev_off" ,   // H-Tile Valid values: rev_off reva revb revc 
      parameter atx_pll_lcpll_gt_in_sel = "lc_gt_in_sel0" ,   // H-Tile Valid values: lc_gt_in_sel0 lc_gt_in_sel1 lc_gt_in_sel2 lc_gt_in_sel3 
      parameter atx_pll_lcpll_gt_out_left_enb = "lcpll_gt_out_left_en" ,    // H-Tile Valid values: lcpll_gt_out_left_dis lcpll_gt_out_left_en 
      parameter atx_pll_lcpll_gt_out_mid_enb = "lcpll_gt_out_mid_dis" ,   // H-TileValid values: lcpll_gt_out_mid_dis lcpll_gt_out_mid_en 
      parameter atx_pll_lcpll_gt_out_right_enb = "lcpll_gt_out_right_dis" ,   // H-Tile Valid values: lcpll_gt_out_right_dis lcpll_gt_out_right_en 
      parameter atx_pll_lcpll_lckdet_sel = "lc_lckdet_sel0" ,   // H-Tile Valid values: lc_lckdet_sel0 lc_lckdet_sel1 
      parameter atx_pll_direct_fb = "direct_fb" ,        //Valid values: iqtxrxclk_fb direct_fb 
      parameter atx_pll_lc_cal_reserved = "lc_cal_reserved_off" ,   //Valid values: lc_cal_reserved_off lc_cal_reserved_on 
      parameter atx_pll_lc_dyn_reconfig = "lc_dyn_reconfig_off" ,   //Valid values: lc_dyn_reconfig_off lc_dyn_reconfig_on 
      parameter atx_pll_enable_hclk = "false" ,   //Valid values: false true
      parameter atx_pll_powermode_ac_lc = "lc_ac_off" ,    
      parameter atx_pll_powermode_ac_lc_gtpath = "lc_gt_ac_off" ,    
      parameter atx_pll_powermode_dc_lc = "powerdown_lc" ,    
      parameter atx_pll_powermode_dc_lc_gtpath = "powerdown_lc_gt" ,    
      parameter atx_pll_pm_dprio_lc_dprio_status_select = "dprio_normal_status" ,		//Valid values: dprio_normal_status dsm_lsb_out dsm_msb_out dsm_dft_out 
		parameter hssi_refclk_divider_sel_pldclk = "iqclk_sel_pldclk",
      // End H-Tile specific
      parameter enable_debug_info = "true",                          // RANGE false|true      NOTE: this is simulation-only parameter, for debug purpose only

      parameter atx_pll_regulator_bypass = "reg_enable",
      parameter atx_pll_pfd_delay_compensation = "normal_delay",
      parameter atx_pll_cp_current_boost = "normal_setting",
      parameter atx_pll_pfd_pulse_width = "pulse_width_setting0",

      //    parameter atx_pll_l_counter_enable = "true",                   // RANGE true (false)
      parameter atx_pll_lcnt_off = "lcnt_off",      // RANGE lcnt_on, (lcnt_off)  
      parameter atx_pll_bonding = "cpri_bonding",               // RANGE (cpri_bonding) pll_bonding NOTE CPRI is for external feedback mode without feedback compensation bonding and PLL is for external feedback with feedback compensation bonding
      parameter atx_pll_prot_mode = "basic_tx",                      // RANGE "not_used" (basic_tx) "basic_kr_tx" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "cei_tx" "qpi_tx" "cpri_tx" "fc_tx" "srio_tx" "gpon_tx" "sdi_tx" "sata_tx" "xaui_tx" "obsai_tx" "gige_tx" "higig_tx" "sonet_tx" "sfp_tx" "xfp_tx" "sfi_tx"
      parameter atx_pll_silicon_rev = "e2",                     // RANGE (20nm5es) "20nm5es2" "20nm4" "20nm3" "20nm4qor" "20nm2" "20nm1"
      parameter atx_pll_bw_mode = "low_bw",                              // RANGE (low_bw) mid_bw high_bw
      parameter atx_pll_dsm_mode = "dsm_mode_integer",               // RANGE (dsm_mode_integer) dsm_mode_phase
      parameter atx_pll_reference_clock_frequency = "0",
      parameter atx_pll_out_freq = "0",
      parameter [7:0] atx_pll_mcnt_divide = 8'b00000001,                               // RANGE (1) 2 3 4 5 6 8 9 10 12 15 16 18 20 24 25 30 32 36 40 48 50 60 64 80 100
      parameter atx_pll_ref_clk_div = 1,                             // RANGE (1) 2 4 8
      parameter [4:0] atx_pll_l_counter = 5'b00001,                               // RANGE (1) 2 4 8 16
      parameter atx_pll_dsm_fractional_division = "1",               // This is a string value of a 32 bitvec      
      parameter atx_pll_lc_tank_band = "lc_band0",                      // RANGE (lc_band0) lc_band1 lc_band2 lc_band3 lc_band4 lc_band5 lc_band6 lc_band7
      parameter atx_pll_lc_sel_tank = "lctank0",                        // RANGE (lctank0) lctank1 lctank2
      //    parameter atx_pll_hclk_divide = 1,                             // RANGE (1) 40 50
      parameter [3:0] atx_pll_cgb_div = 4'b0001,                                 // RANGE (1) 2 4 8
      parameter [6:0] atx_pll_pma_width = 7'b0001000,                               // RANGE (8) 10 16 20 32 40 64

      parameter atx_pll_primary_use                = "hssi_x1",
      parameter atx_pll_lccmu_mode                    = "lccmu_normal",         // RANGE (lccmu_pd) lccmu_normal lccmu_reset
		parameter hssi_pma_lc_refclk_select_mux_xpll_lccmu_mode = "lccmu_normal",                      
      parameter atx_pll_xatb_lccmu_atb                     = "atb_selectdisable",    // RANGE (atb_selectdisable) atb_select0 atb_select1 atb_select2 atb_select3 atb_select4 atb_select5 atb_select6 atb_select7 atb_select8 atb_select9 atb_select10 atb_select11 atb_select12 atb_select13 atb_select14 atb_select15 atb_select16 atb_select17 atb_select18 atb_select19 atb_select20 atb_select21 atb_select22 atb_select23 atb_select24 atb_select25 atb_select26 atb_select27 atb_select28 atb_select29 atb_select30
      parameter atx_pll_chgpmp_compensation     = "cp_mode_enable",                 // RANGE cp_mode_disable (cp_mode_enable)
      parameter atx_pll_chgpmp_current_setting         = "cp_current_setting0",  // RANGE (cp_current_setting0) cp_current_setting1 cp_current_setting2 cp_current_setting3 cp_current_setting4 cp_current_setting5 cp_current_setting6 cp_current_setting7 cp_current_setting8 cp_current_setting9 cp_current_setting10 cp_current_setting11
      parameter atx_pll_chgpmp_testmode                = "cp_normal",            // RANGE (cp_normal) cp_test_up cp_test_dn cp_tristate
      parameter atx_pll_lf_3rd_pole_freq        = "lf_3rd_pole_setting0", // RANGE (lf_3rd_pole_setting0) lf_3rd_pole_setting1 lf_3rd_pole_setting2 lf_3rd_pole_setting3
      parameter atx_pll_lf_order                = "lf_2nd_order",         // RANGE (lf_2nd_order) lf_3rd_order lf_4th_order
      parameter atx_pll_lf_resistance              = "lf_setting0",          // RANGE (lf_setting0) lf_setting1 lf_setting2 lf_setting3
      parameter atx_pll_lf_ripplecap               = "lf_ripple_cap_0",      // RANGE lf_no_ripple (lf_ripple_cap_0) lf_ripple_cap_1
      parameter atx_pll_xd2a_lc_d2a_voltage                = "d2a_disable",          // RANGE d2a_setting_0 d2a_setting_1 d2a_setting_2 d2a_setting_3 d2a_setting_4 d2a_setting_5 d2a_setting_6 d2a_setting_7 (d2a_disable)
      parameter atx_pll_pll_dsm_out_sel                = "pll_dsm_disable",      // RANGE (pll_dsm_disable) pll_dsm_1st_order pll_dsm_2nd_order pll_dsm_3rd_order
      parameter atx_pll_pll_ecn_bypass             = "pll_ecn_bypass_disable",                // RANGE (pll_ecn_bypass_disable) pll_ecn_bypass_enable
      parameter atx_pll_pll_ecn_test_en            = "pll_ecn_test_disable",                // RANGE (pll_ecn_test_disable) pll_ecn_test_enable
      parameter atx_pll_pll_fractional_value_ready = "pll_k_ready",          // RANGE pll_k_not_ready (pll_k_ready)
      parameter atx_pll_lcnt_bypass          = "lcnt_no_bypass",                // RANGE (lcnt_no_bypass) lcnt_bypass 
      parameter atx_pll_cascadeclk_test            = "cascadetest_off",      // RANGE (cascadetest_off) cascadetest_on
      parameter atx_pll_lc_tank_voltage_coarse        = "vreg_setting_coarse1", // RANGE vreg_setting_coarse0 (vreg_setting_coarse1) vreg_setting_coarse2 vreg_setting_coarse3
      parameter atx_pll_lc_tank_voltage_fine          = "vreg_setting3",        // RANGE vreg_setting0 vreg_setting1 vreg_setting2 (vreg_setting3) vreg_setting4 vreg_setting5 vreg_setting6 vreg_setting7
      parameter atx_pll_output_regulator_supply    = "vreg1v_setting1",      // RANGE vreg1v_setting0 (vreg1v_setting1) vreg1v_setting2 vreg1v_setting3
      parameter atx_pll_overrange_voltage          = "over_setting3",        // RANGE over_setting0 over_setting1 over_setting2 (over_setting3) over_setting4 over_setting5 over_setting6 over_setting7
      parameter atx_pll_underrange_voltage         = "under_setting3",       // RANGE under_setting0 under_setting1 under_setting2 (under_setting3) under_setting4 under_setting5 under_setting6 under_setting7
      parameter atx_pll_is_cascaded_pll            = "false",                // RANGE (false) true
      parameter atx_pll_is_otn                     = "false",                // RANGE (false) true
      parameter atx_pll_is_sdi                     = "false",                // RANGE (false) true
      parameter atx_pll_lf_cbig_size             = "lf_cbig_setting0" ,   // RANGE (lf_cbig_setting0) , lf_cbig_setting1 , lf_cbig_setting2 , lf_cbig_setting3 , lf_cbig_setting4 
      parameter atx_pll_iqclk_sel                = "power_down" ,       // RANGE iqtxrxclk0 , iqtxrxclk1 , iqtxrxclk2 , iqtxrxclk3 , iqtxrxclk4 , iqtxrxclk5 , (power_down)
      parameter atx_pll_hclk_en              = "hclk_disabled" ,    // RANGE (hclk_disabled), hclk_enable 
      parameter atx_pll_calibration_mode         = "cal_off" ,            // RANGE (cal_off), uc_rst_pll , uc_rst_lf , uc_not_rst 
      parameter atx_pll_datarate_bps                 = "0" ,            // RANGE  
      parameter atx_pll_device_variant           = "device1" ,            // RANGE (device1), device2 , device3 , device4 , device5 
      parameter atx_pll_initial_settings         = "true" ,               // RANGE (false), true 
      parameter atx_pll_lcnt_divide  = 1 ,            // RANGE (5) 
      parameter [3:0] atx_pll_n_counter  = 4'b0001 ,                // RANGE (1, 2, 4, 8) 
      parameter atx_pll_powerdown_mode           = "powerup" ,            // RANGE (powerup) , powerdown 
      parameter atx_pll_sup_mode                 = "user_mode" ,        // RANGE (user_mode) , engineering_mode 
      parameter atx_pll_vco_freq                 = "0",               // RANGE  
      parameter atx_pll_fpll_refclk_selection    = "select_div_by_2",       // RANGE (select_div_by_2), select_vco_output
      parameter atx_pll_lc_to_fpll_l_counter     = "lcounter_setting0",     // RANGE (lcounter_setting0) .. lcounter_setting31
      parameter [4:0] atx_pll_lc_to_fpll_l_counter_scratch = 5'b00000,     // RANGE (5)

    //-----------------------------------------------------------------------------------------------
    // Adding the following parameters as an addendum following switching their
    // resolution stage to IPGEN.  IS mentioned that we are no longer concerned
    // about matching order or parameters in terp vs tcl so will simply collect
    // them here
    //-----------------------------------------------------------------------------------------------
      parameter atx_pll_analog_mode                     = "user_custom",
      parameter atx_pll_bandwidth_range_high                = "1",
      parameter atx_pll_bandwidth_range_low               = "1",
      parameter atx_pll_cal_status                      = "cal_done",
      parameter [11:0]  atx_pll_clk_high_perf_voltage         = 12'b0,
      parameter [11:0]  atx_pll_clk_low_power_voltage         = 12'b0,
      parameter [11:0]  atx_pll_clk_mid_power_voltage         = 12'b0,
      parameter [11:0]  atx_pll_clk_vreg_boost_expected_voltage = 12'b0,
      parameter [2:0] atx_pll_clk_vreg_boost_scratch        = 3'b0,
      parameter [4:0] atx_pll_clk_vreg_boost_step_size        = 4'b0,
      parameter [11:0]  atx_pll_lc_vreg1_boost_expected_voltage = 12'b0,
      parameter [2:0] atx_pll_lc_vreg1_boost_scratch        = 3'b0,
      parameter [11:0]  atx_pll_lc_vreg_boost_expected_voltage    = 12'b0,
      parameter [2:0] atx_pll_lc_vreg_boost_scratch         = 3'b0,
      parameter [11:0]  atx_pll_mcgb_vreg_boost_expected_voltage  = 12'b0,
      parameter [2:0] atx_pll_mcgb_vreg_boost_scratch       = 3'b0,
      parameter [4:0] atx_pll_mcgb_vreg_boost_step_size     = 5'b0,
      parameter [4:0] atx_pll_vreg1_boost_step_size         = 5'b0,
      parameter [4:0] atx_pll_vreg_boost_step_size              = 5'b0,
      parameter [11:0]  atx_pll_expected_lc_boost_voltage     = 12'b0,
      parameter atx_pll_f_max_lcnt_fpll_cascading           = "0",
      parameter atx_pll_f_max_pfd                               = "0",
      parameter atx_pll_f_max_pfd_fractional                    = "0",
      parameter atx_pll_f_max_ref                               = "0",
      parameter atx_pll_f_max_tank_0                            = "0",
      parameter atx_pll_f_max_tank_1                            = "0",
      parameter atx_pll_f_max_tank_2                            = "0",
      parameter atx_pll_f_max_vco                               = "0",
      parameter atx_pll_f_max_vco_fractional                    = "0",
      parameter atx_pll_f_max_x1                                = "0",
      parameter atx_pll_f_min_pfd                               = "0",
      parameter atx_pll_f_min_ref                               = "0",
      parameter atx_pll_f_min_tank_0                            = "0",
      parameter atx_pll_f_min_tank_1                            = "0",
      parameter atx_pll_f_min_tank_2                            = "0",
      parameter atx_pll_f_min_vco                               = "0",
      parameter atx_pll_lc_cal_status                           = "lc_status_notdone",
      parameter atx_pll_lc_calibration                          = "lc_cal_off",
      parameter atx_pll_lc_reg_status                           = "lc_reg_status_notdone",
      parameter atx_pll_lc_vreg1_boost                          = "lc_vreg1_no_voltage_boost",
      parameter atx_pll_lc_vreg_boost                           = "lc_vreg_no_voltage_boost",
      parameter [6:0] atx_pll_max_fractional_percentage           = 7'b0,
      parameter [6:0] atx_pll_min_fractional_percentage           = 7'b0,
      parameter atx_pll_power_mode                              = "low_power",
      parameter [11:0] atx_pll_power_rail_et                      = 12'b0,
      parameter atx_pll_side                                    = "side_unknown",
      parameter atx_pll_top_or_bottom                           = "tb_unknown",
      parameter atx_pll_vccdreg_clk                             = "vreg_clk0",
      parameter atx_pll_vccdreg_fb                              = "vreg_fb0",
      parameter atx_pll_vccdreg_fw                              = "vreg_fwk0",
    //-----------------------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------------------

      parameter hssi_pma_lc_refclk_select_mux_lc_scratch0_src      = "scratch0_src_lvpecl",
      parameter hssi_pma_lc_refclk_select_mux_lc_scratch1_src      = "scratch1_src_lvpecl",
      parameter hssi_pma_lc_refclk_select_mux_lc_scratch2_src      = "scratch2_src_lvpecl",
      parameter hssi_pma_lc_refclk_select_mux_lc_scratch3_src      = "scratch3_src_lvpecl",
      parameter hssi_pma_lc_refclk_select_mux_lc_scratch4_src      = "scratch4_src_lvpecl",
      parameter hssi_pma_lc_refclk_select_mux_lc_iq_scratch0_src   = "scratch0_power_down",
      parameter hssi_pma_lc_refclk_select_mux_lc_iq_scratch1_src   = "scratch1_power_down",
      parameter hssi_pma_lc_refclk_select_mux_lc_iq_scratch2_src   = "scratch2_power_down",
      parameter hssi_pma_lc_refclk_select_mux_lc_iq_scratch3_src   = "scratch3_power_down",
      parameter hssi_pma_lc_refclk_select_mux_lc_iq_scratch4_src   = "scratch4_power_down",

    //-----------------------------------------------------------------------------------------------
      parameter hssi_pma_lc_refclk_select_mux_powerdown_mode = "powerup",   // RANGE (powerup) powerdown     
      parameter hssi_pma_lc_refclk_select_mux_silicon_rev = "20nm5es",          // RANGE (20nm5es) "20nm5es2" "20nm4" "20nm3" "20nm4qor" "20nm2" "20nm1"
      parameter hssi_refclk_divider_silicon_rev = "20nm5es",          // RANGE (20nm5es) "20nm5es2" "20nm4" "20nm3" "20nm4qor" "20nm2" "20nm1"
      parameter hssi_pma_lc_refclk_select_mux_refclk_select = "ref_iqclk0",  // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down     

      parameter hssi_pma_lc_refclk_select_mux_inclk0_logical_to_physical_mapping = "ref_iqclk0",           // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
      parameter hssi_pma_lc_refclk_select_mux_inclk1_logical_to_physical_mapping = "ref_iqclk1",           // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
      parameter hssi_pma_lc_refclk_select_mux_inclk2_logical_to_physical_mapping = "ref_iqclk2",           // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
      parameter hssi_pma_lc_refclk_select_mux_inclk3_logical_to_physical_mapping = "ref_iqclk3",           // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down
      parameter hssi_pma_lc_refclk_select_mux_inclk4_logical_to_physical_mapping = "ref_iqclk4",           // RANGE (ref_iqclk0) ref_iqclk1 ref_iqclk2 ref_iqclk3 ref_iqclk4 ref_iqclk5 ref_iqclk6 ref_iqclk7 ref_iqclk8 ref_iqclk9 ref_iqclk10 ref_iqclk11 iqtxrxclk0 iqtxrxclk1 iqtxrxclk2 iqtxrxclk3 iqtxrxclk4 iqtxrxclk5 coreclk fixed_clk lvpecl adj_pll_clk power_down

    //-----------------------------------------------------------------------------------------------
      // Following are not getting auto_resolved,
    //-----------------------------------------------------------------------------------------------
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_lc_scratch0_src = "scratch0_src_lvpecl", // Range "scratch0_src_coreclk" "scratch0_src_iqclk" "scratch0_src_lvpecl"
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_lc_scratch1_src = "scratch1_src_lvpecl", // Range "scratch1_src_coreclk" "scratch1_src_iqclk" "scratch1_src_lvpecl"                                                                                  
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_lc_scratch2_src = "scratch2_src_lvpecl", // Range "scratch2_src_coreclk" "scratch2_src_iqclk" "scratch2_src_lvpecl"
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_lc_scratch3_src = "scratch3_src_lvpecl", // Range "scratch2_src_coreclk" "scratch2_src_iqclk" "scratch3_src_lvpecl"      
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_lc_scratch4_src = "scratch4_src_lvpecl", // Range "scratch2_src_coreclk" "scratch2_src_iqclk" "scratch4_src_lvpecl"
    //      parameter hssi_pma_lc_refclk_select_mux_xmux_refclk_src = "src_lvpecl",               // Range "src_coreclk" "src_iqclk" "src_lvpecl"
    //      parameter hssi_pma_lc_refclk_select_mux_xpm_iqref_mux_iqclk_sel             "ct1_atx_pll"  true     false          false    STRING   NOVAL  true                       true                   "power_down"                    {"iqtxrxclk0" "iqtxrxclk1" "iqtxrxclk2" "iqtxrxclk3" "iqtxrxclk4" "iqtxrxclk5" "power_down" "ref_iqclk0" "ref_iqclk1" "ref_iqclk10" "ref_iqclk11" "ref_iqclk2" "ref_iqclk3" "ref_iqclk4" "ref_iqclk5" "ref_iqclk6" "ref_iqclk7" "ref_iqclk8" "ref_iqclk9"}                                        


      parameter enable_mcgb = 0,                                             // RANGE (0) 1
      parameter enable_mcgb_reset = 0,
      parameter enable_mcgb_debug_ports_parameters = 0,                      // RANGE (0) 1

      parameter avmm_interfaces = ((enable_mcgb==1) && (enable_mcgb_debug_ports_parameters==1)) ? 2 : 1,

      
      parameter hssi_pma_cgb_master_silicon_rev = "20nm5es",                 // RANGE (20nm5es) "20nm5es2" "20nm4" "20nm3" "20nm4qor" "20nm2" "20nm1"
      parameter hssi_pma_cgb_master_prot_mode  = "basic_tx",                      // RANGE "not_used" (basic_tx) "basic_kr_tx" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "cei_tx" "qpi_tx" "cpri_tx" "fc_tx" "srio_tx" "gpon_tx" "sdi_tx" "sata_tx" "xaui_tx" "obsai_tx" "gige_tx" "higig_tx" "sonet_tx" "sfp_tx" "xfp_tx" "sfi_tx"
      parameter hssi_pma_cgb_master_cgb_enable_iqtxrxclk = "disable_iqtxrxclk",   // OPEN in atom default is enable in _hw.tcl default is disable // RANGE disable_iqtxrxclk (enable_iqtxrxclk) 
      parameter hssi_pma_cgb_master_x1_div_m_sel = "divbypass",                   // RANGE (divbypass) divby2 divby4 divby8
      parameter hssi_pma_cgb_master_ser_mode = "eight_bit",                       // RANGE (eight_bit) ten_bit sixteen_bit twenty_bit thirty_two_bit forty_bit sixty_four_bit
      parameter hssi_pma_cgb_master_datarate_bps = "0",

      parameter hssi_pma_cgb_master_cgb_power_down                     = "normal_cgb",                  // RANGE normal_cgb (power_down_cgb)                           
      parameter hssi_pma_cgb_master_bonding_reset_enable               = "allow_bonding_reset",         // RANGE disallow_bonding_reset (allow_bonding_reset) 
      parameter hssi_pma_cgb_master_observe_cgb_clocks                 = "observe_nothing",             // RANGE (observe_nothing) observe_x1mux_out   
      parameter hssi_pma_cgb_master_optimal                            = "true",                        // RANGE (true) false   
      //    parameter hssi_pma_cgb_master_op_mode                            = "enabled",                     // RANGE (enabled) pwr_down             
      parameter hssi_pma_cgb_master_tx_ucontrol_reset_pcie             = "pcscorehip_controls_mcgb",    // RANGE (pcscorehip_controls_mcgb) cgb_reset tx_pcie_gen1 tx_pcie_gen2 tx_pcie_gen3 tx_pcie_gen4  
      parameter hssi_pma_cgb_master_vccdreg_output                     = "vccdreg_nominal",             // RANGE (vccdreg_nominal) vccdreg_pos_setting0 vccdreg_pos_setting1 vccdreg_pos_setting2 vccdreg_pos_setting3 vccdreg_pos_setting4 vccdreg_pos_setting5 vccdreg_pos_setting6 vccdreg_pos_setting7 vccdreg_pos_setting8 vccdreg_pos_setting9 vccdreg_pos_setting10 vccdreg_pos_setting11 vccdreg_pos_setting12 vccdreg_pos_setting13 vccdreg_pos_setting14 vccdreg_pos_setting15 reserved1 reserved2 vccdreg_neg_setting0 vccdreg_neg_setting1 vccdreg_neg_setting2 vccdreg_neg_setting3 reserved3 reserved4 reserved5 reserved6 reserved7 reserved8 reserved9 reserved10 reserved11   
      parameter hssi_pma_cgb_master_input_select                       = "lcpll_top",                   // RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused)      
      parameter hssi_pma_cgb_master_input_select_gen3                  = "not_used" ,                     // RANGE lcpll_bot lcpll_top fpll_bot fpll_top (unused) 
      parameter hssi_pma_cgb_master_pcie_gen3_bitwidth                 = "pciegen3_wide" ,          // RANGE (pciegen3_wide) pciegen3_narrow parameter powerdown_mode = "powerup" ,    //Valid values: powerup , powerdown 
      parameter hssi_pma_cgb_master_powerdown_mode                     = "powerup" ,                  // RANGE (powerup) powerdown 
      parameter hssi_pma_cgb_master_sup_mode                           = "user_mode" ,              // RANGE (user_mode) engineering_mode 
      parameter hssi_pma_cgb_master_initial_settings                   = "true",                        // RANGE (false) true 
      parameter hssi_pma_cgb_master_power_rail_er                      = 12'b0,
      parameter hssi_pma_cgb_master_powermode_ac_cgb_master            = "cgb_master_ac_ls_1p0",
      parameter hssi_pma_cgb_master_powermode_dc_cgb_master            = "powerdown_cgb_master", 
      parameter hssi_pma_cgb_master_tx_ucontrol_en            			  = "disable", 
      parameter hip_cal_en                                             = "disable",                     // Indicates whether HIP is enabled or not. Valid values: disable, enable
        
      
      
    //-----------------------------------------------------------------------------------------------
      // NOTE following are constants, not meant to be changed in instantiations
    //-----------------------------------------------------------------------------------------------
      parameter SIZE_AVMM_RDDATA_BUS = 32,
      parameter SIZE_AVMM_WRDATA_BUS = 32,
      parameter SIZE_AVMM_ADDRESS_BUS = 11,      

    //-----------------------------------------------------------------------------------------------
      // instantiate paramters for embedded debug
    //-----------------------------------------------------------------------------------------------
      parameter rcfg_shared                 = 0,
      parameter rcfg_enable                 = 0,
      parameter rcfg_jtag_enable            = 0,
      parameter rcfg_emb_strm_enable        = 0,
      parameter rcfg_profile_cnt            = 2,
      parameter dbg_embedded_debug_enable   = 0,
      parameter dbg_capability_reg_enable   = 0,
      parameter dbg_user_identifier         = 0,
      parameter dbg_stat_soft_logic_enable  = 0,
      parameter dbg_ctrl_soft_logic_enable  = 0,
      parameter calibration_en              = "disable",
      parameter enable_analog_resets        = 0,      // (0,1)
      parameter enable_pcie_hip_connectivity                             = 0,
    //-----------------------------------------------------------------------------------------------
      // 0 - Disable pll_powerdown and mcgb_rst reset input connections. Still allows soft register override
      // 1 - Enable pll_powerdown and mcgb_rst reset input connections
    //-----------------------------------------------------------------------------------------------

      parameter rcfg_separate_avmm_busy     = 0,      // (0,1)
    //-----------------------------------------------------------------------------------------------
      // 0 - AVMM busy is reflected on the waitrequest
      // 1 - AVMM busy must be read from a soft CSR
    //-----------------------------------------------------------------------------------------------

      //AVMM2 parameters
    parameter          hssi_avmm2_if_silicon_rev                       = "14nm5"                       ,//"14nm5"
      parameter          hssi_avmm2_if_calibration_type                  = "one_time"                    ,//"continuous" "one_time"
    parameter          hssi_avmm2_if_pcs_calibration_feature_en        = "avmm2_pcs_calibration_dis"   ,//"avmm2_pcs_calibration_dis" "avmm2_pcs_calibration_en"
    parameter          hssi_avmm2_if_pcs_arbiter_ctrl                  = "avmm2_arbiter_uc_sel"        ,//"avmm2_arbiter_pld_sel" "avmm2_arbiter_uc_sel"
    parameter          hssi_avmm2_if_pcs_cal_done                      = "avmm2_cal_done_assert"       ,//"avmm2_cal_done_assert" "avmm2_cal_done_deassert"
    parameter          hssi_avmm2_if_pcs_hip_cal_en                    = "disable"                     ,//"disable" "enable"
    parameter [4:0]    hssi_avmm2_if_pcs_cal_reserved                  = 5'd0                          ,//0:31
    parameter          hssi_avmm2_if_hssiadapt_hip_mode                = "disable_hip"                 ,//"debug_chnl" "disable_hip" "user_chnl"
    parameter          hssi_avmm2_if_pldadapt_hip_mode                 = "disable_hip"                 ,//"debug_chnl" "disable_hip" "user_chnl"
    parameter          hssi_avmm2_if_hssiadapt_avmm_osc_clock_setting  = "osc_clk_div_by1"             ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
    parameter          hssi_avmm2_if_pldadapt_avmm_osc_clock_setting   = "osc_clk_div_by1"             ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
    parameter          hssi_avmm2_if_hssiadapt_avmm_testbus_sel        = "avmm1_transfer_testbus"      ,//"avmm1_cmn_intf_testbus" "avmm1_transfer_testbus" "avmm2_transfer_testbus" "avmm_clk_dcg_testbus"
    parameter          hssi_avmm2_if_pldadapt_avmm_testbus_sel         = "avmm1_transfer_testbus"      ,//"avmm1_cmn_intf_testbus" "avmm1_transfer_testbus" "avmm2_transfer_testbus" "unused_testbus"
    parameter          hssi_avmm2_if_pldadapt_gate_dis                 = "disable"                      //"disable" "enable"
   
      /// TODO all other pll parameters needs to be added
      ) (
   input           pll_powerdown, 
   input           pll_refclk0, 
   input           pll_refclk1, 
   input           pll_refclk2, 
   input           pll_refclk3, 
   input           pll_refclk4, 
   input           mcgb_aux_clk0, 
   input           mcgb_aux_clk1,
   input           mcgb_aux_clk2,
   input [1:0]         pcie_sw,

   output          tx_serial_clk, 

   output         tx_serial_clk_gxt,
	output			gxt_output_to_abv_atx,
	output			gxt_output_to_blw_atx,
	input				gxt_input_from_blw_atx,
	input				gxt_input_from_abv_atx,

   output          pll_locked, 
   output                            pll_locked_hip,
   output          pll_pcie_clk, 
   output          pll_cascade_clk, 
   output          atx_to_fpll_cascade_clk, 
  
   input           mcgb_rst,
   output                            mcgb_rst_stat,

   output [5:0]          tx_bonding_clocks, 
   output          mcgb_serial_clk, 
   output [1:0]          pcie_sw_done, 

   // NOTE: reconfig for PLL
   input           reconfig_clk0,
   input           reconfig_reset0,
   input           reconfig_write0,
   input           reconfig_read0,
//   input [9:0]         reconfig_address0, // OPEN [9:0] is bus size defined somewhere
   input [SIZE_AVMM_ADDRESS_BUS-1:0] reconfig_address0, // OPEN [9:0] is bus size defined somewhere   
   input [SIZE_AVMM_WRDATA_BUS-1:0]  reconfig_writedata0,
   output [SIZE_AVMM_RDDATA_BUS-1:0] reconfig_readdata0,
   output          avmm_busy0,
   output          reconfig_waitrequest0,
   output          pll_cal_busy,
   output          hip_cal_done,

   // NOTE: reconfig for CGB
   input           reconfig_clk1,
   input           reconfig_reset1,
   input           reconfig_write1,
   input           reconfig_read1,
//   input [9:0]         reconfig_address1,
   input [SIZE_AVMM_ADDRESS_BUS-1:0] reconfig_address1,  
   input [SIZE_AVMM_WRDATA_BUS-1:0]  reconfig_writedata1,
   output [SIZE_AVMM_RDDATA_BUS-1:0] reconfig_readdata1,
   output          avmm_busy1,
   output          reconfig_waitrequest1,
   output          mcgb_cal_busy, 
   output          mcgb_hip_cal_done, 
  
   // NOTE: Debug related not in hw.tcl
   output          clklow,
   output          fref, 
   output          overrange,
   output          underrange,
   output         wire pld_hssi_osc_transfer_en
   /// TODO include other any other ports for debugging?       
   );
   // Wires for PLD Adapt Atom
   wire            clklow_to_pa_atom;
   wire            fref_to_pa_atom;
   wire            pll_locked_to_pa_atom;
   wire            pll_powerdown_from_pa_atom;
   wire            mcgb_rst_from_pa_atom;
   
   
//   localparam avmm_interfaces = ((enable_mcgb==1) && (enable_mcgb_debug_ports_parameters==1)) ? 2 : 1;
   localparam RCFG_ADDR_BITS = 11;

   localparam  MAX_CONVERSION_SIZE_ALT_XCVR_ATX_S10 = 128;
   localparam  MAX_STRING_CHARS_ALT_XCVR_ATX_S10  = 64;

// Pll_powerdown removal change
//   localparam  lcl_enable_analog_resets = 
//`ifdef ALTERA_RESERVED_QIS
// `ifdef ALTERA_XCVR_S10_ENABLE_ANALOG_RESETS
//            1;  // MACRO override for quartus synthesis. Connect resets
// `else
//   enable_analog_resets; // parameter option for synthesis
// `endif // ALTERA_XCVR_S10_ENABLE_ANALOG_RESETS
//`else
//   1; // not synthesis. Connect resets
//`endif  // (NOT ALTERA_RESERVED_QIS)


   function automatic [MAX_CONVERSION_SIZE_ALT_XCVR_ATX_S10-1:0] str_2_bin_altera_xcvr_atx_pll_s10;
      input [MAX_STRING_CHARS_ALT_XCVR_ATX_S10*8-1:0] instring;

      integer                 this_char;
      integer                 i;
      begin
   // Initialize accumulator
   str_2_bin_altera_xcvr_atx_pll_s10 = {MAX_CONVERSION_SIZE_ALT_XCVR_ATX_S10{1'b0}};
   for(i=MAX_STRING_CHARS_ALT_XCVR_ATX_S10-1;i>=0;i=i-1) begin
            this_char = instring[i*8+:8];
            // Add value of this digit
            if(this_char >= 48 && this_char <= 57)
              str_2_bin_altera_xcvr_atx_pll_s10 = (str_2_bin_altera_xcvr_atx_pll_s10 * 10) + (this_char - 48);
   end
      end
   endfunction

   // String to binary conversions
   localparam  [127:0] temp_atx_pll_dsm_fractional_division  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_dsm_fractional_division);
   localparam  [31:0] lcl_atx_pll_dsm_fractional_division = temp_atx_pll_dsm_fractional_division[31:0];

   localparam  [127:0] temp_atx_pll_out_freq  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_out_freq);
   localparam  [35:0] lcl_atx_pll_out_freq = temp_atx_pll_out_freq[35:0];

   localparam  [127:0] temp_atx_pll_reference_clock_frequency  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_reference_clock_frequency);
   localparam  [35:0] lcl_atx_pll_reference_clock_frequency = temp_atx_pll_reference_clock_frequency[35:0];   
   
   localparam  [127:0] temp_atx_pll_vco_freq  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_vco_freq);
   localparam  [35:0] lcl_atx_pll_vco_freq = temp_atx_pll_vco_freq[35:0];

   localparam  [127:0] temp_hssi_pma_cgb_master_datarate_bps  = str_2_bin_altera_xcvr_atx_pll_s10(hssi_pma_cgb_master_datarate_bps);
   localparam  [35:0] lcl_hssi_pma_cgb_master_datarate_bps = temp_hssi_pma_cgb_master_datarate_bps[35:0];

   localparam  [127:0] temp_atx_pll_datarate_bps  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_datarate_bps);
   localparam  [35:0] lcl_atx_pll_datarate_bps = temp_atx_pll_datarate_bps[35:0];   

   localparam  [127:0] temp_atx_pll_bandwidth_range_high  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_bandwidth_range_high);
   localparam  [35:0] lcl_atx_pll_bandwidth_range_high = temp_atx_pll_bandwidth_range_high[35:0];

   localparam  [127:0] temp_atx_pll_bandwidth_range_low  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_bandwidth_range_low);
   localparam  [35:0] lcl_atx_pll_bandwidth_range_low = temp_atx_pll_bandwidth_range_low[35:0];

   localparam  [127:0] temp_atx_pll_f_max_lcnt_fpll_cascading  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_lcnt_fpll_cascading);
   localparam  [35:0] lcl_atx_pll_f_max_lcnt_fpll_cascading = temp_atx_pll_f_max_lcnt_fpll_cascading[35:0];

   localparam  [127:0] temp_atx_pll_f_max_pfd  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_pfd);
   localparam  [35:0] lcl_atx_pll_f_max_pfd = temp_atx_pll_f_max_pfd[35:0];

   localparam  [127:0] temp_atx_pll_f_max_pfd_fractional  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_pfd_fractional);
   localparam  [35:0] lcl_atx_pll_f_max_pfd_fractional = temp_atx_pll_f_max_pfd_fractional[35:0];

   localparam  [127:0] temp_atx_pll_f_max_ref  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_ref);
   localparam  [35:0] lcl_atx_pll_f_max_ref = temp_atx_pll_f_max_ref[35:0];

   localparam  [127:0] temp_atx_pll_f_max_tank_0  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_tank_0);
   localparam  [35:0] lcl_atx_pll_f_max_tank_0 = temp_atx_pll_f_max_tank_0[35:0];

   localparam  [127:0] temp_atx_pll_f_max_tank_1  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_tank_1);
   localparam  [35:0] lcl_atx_pll_f_max_tank_1 = temp_atx_pll_f_max_tank_1[35:0];

   localparam  [127:0] temp_atx_pll_f_max_tank_2  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_tank_2);
   localparam  [35:0] lcl_atx_pll_f_max_tank_2 = temp_atx_pll_f_max_tank_2[35:0];

   localparam  [127:0] temp_atx_pll_f_max_vco  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_vco);
   localparam  [35:0] lcl_atx_pll_f_max_vco = temp_atx_pll_f_max_vco[35:0];

   localparam  [127:0] temp_atx_pll_f_max_vco_fractional  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_vco_fractional);
   localparam  [35:0] lcl_atx_pll_f_max_vco_fractional = temp_atx_pll_f_max_vco_fractional[35:0];

   localparam  [127:0] temp_atx_pll_f_max_x1  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_max_x1);
   localparam  [35:0] lcl_atx_pll_f_max_x1 = temp_atx_pll_f_max_x1[35:0];

   localparam  [127:0] temp_atx_pll_f_min_pfd  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_pfd);
   localparam  [35:0] lcl_atx_pll_f_min_pfd = temp_atx_pll_f_min_pfd[35:0];

   localparam  [127:0] temp_atx_pll_f_min_ref  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_ref);
   localparam  [35:0] lcl_atx_pll_f_min_ref = temp_atx_pll_f_min_ref[35:0];

   localparam  [127:0] temp_atx_pll_f_min_tank_0  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_tank_0);
   localparam  [35:0] lcl_atx_pll_f_min_tank_0 = temp_atx_pll_f_min_tank_0[35:0];

   localparam  [127:0] temp_atx_pll_f_min_tank_1  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_tank_1);
   localparam  [35:0] lcl_atx_pll_f_min_tank_1 = temp_atx_pll_f_min_tank_1[35:0];

   localparam  [127:0] temp_atx_pll_f_min_tank_2  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_tank_2);
   localparam  [35:0] lcl_atx_pll_f_min_tank_2 = temp_atx_pll_f_min_tank_2[35:0];

   localparam  [127:0] temp_atx_pll_f_min_vco  = str_2_bin_altera_xcvr_atx_pll_s10(atx_pll_f_min_vco);
   localparam  [35:0] lcl_atx_pll_f_min_vco = temp_atx_pll_f_min_vco[35:0];

   localparam  lcl_adme_assgn_map = {" assignments {device_revision ",atx_pll_silicon_rev,"}"};

   // upper 24 bits are not used, but should not be left at X
   //assign reconfig_readdata0[SIZE_AVMM_RDDATA_BUS-1:8] =  0;
   assign reconfig_readdata1[SIZE_AVMM_RDDATA_BUS-1:8] =  0;

   //-----------------------------------
   // reconfigAVMM to pllAtoms internal wires  
   // interface #0 to PLL, interface #1 to CGB 
   wire  [avmm_interfaces-1    :0] pll_avmm_clk;
//   wire [avmm_interfaces-1    :0]  pll_avmm_rstn;
   wire [avmm_interfaces*8-1  :0]  pll_avmm_writedata;
   wire [avmm_interfaces*10-1  :0]  pll_avmm_address;
   wire [avmm_interfaces-1    :0]  pll_avmm_write;
   wire [avmm_interfaces-1    :0]  pll_avmm_read;

   wire [avmm_interfaces*8-1  :0]  pll_avmmreaddata_lc;                        // NOTE only [7:0] is used
   wire [avmm_interfaces*8-1  :0]  pll_avmmreaddata_refclk;                    // NOTE only [7:0] is used
   wire [avmm_interfaces*8-1  :0]  pll_avmmreaddata_mcgb;                      // NOTE only [15:8] is used
   wire [avmm_interfaces-1    :0]  pll_blockselect_lc;                         // NOTE only [0:0] is used
   wire [avmm_interfaces-1    :0]  pll_blockselect_refclk;                     // NOTE only [0:0] is used
   wire [avmm_interfaces-1    :0]  pll_blockselect_mcgb;                       // NOTE only [1:1] is used

   //-----------------------------------

   //-----------------------------------
   // reconfigAVMM to top wrapper wires  
   // interface #0 to PLL, interface #1 to CGB 
   wire [avmm_interfaces-1    :0]  reconfig_clk;
   wire [avmm_interfaces-1    :0]  reconfig_reset;
   wire [avmm_interfaces*8-1  :0]  reconfig_writedata;
//   wire [avmm_interfaces*9-1  :0]  reconfig_address;
   wire [avmm_interfaces*10-1  :0]  reconfig_address;   
   wire [avmm_interfaces-1    :0]  reconfig_write;
   wire [avmm_interfaces-1    :0]  reconfig_read;
   wire [avmm_interfaces*8-1  :0]  reconfig_readdata;
   wire [avmm_interfaces-1    :0]  reconfig_waitrequest;
   wire [avmm_interfaces-1    :0]  avmm_busy;
   wire [avmm_interfaces-1    :0]  pld_cal_done;
   wire [avmm_interfaces-1    :0]  hip_cal_done_w;

   // AVMM reconfiguration signals for the hardware
   wire [avmm_interfaces-1:0]      avmm_write;
   wire [avmm_interfaces-1:0]      avmm_read;
   wire [avmm_interfaces-1:0]      avmm_waitrequest;
   wire [avmm_interfaces*8-1:0]    avmm_readdata;

   // AVMM reconfiguration signals for embedded debug
   wire [avmm_interfaces*8-1:0]    debug_writedata;
   wire [avmm_interfaces-1:0]      debug_clk;
   wire [avmm_interfaces-1:0]      debug_reset;
   wire [avmm_interfaces*11-1:0]   debug_address; 
   wire [avmm_interfaces-1:0]      debug_write;
   wire [avmm_interfaces-1:0]      debug_read;
   wire [avmm_interfaces-1:0]      debug_busy;
   wire [avmm_interfaces-1:0]      debug_waitrequest;
   wire [avmm_interfaces*8-1:0]    debug_readdata;

   // Wires for control signals from the embedded debug
   wire          pll_powerdown_int;

  // Wire around the HIP
  wire pll_powerdown_adapt;
  wire pll_powerdown_atx;
  wire mcgb_rst_adapt;
  wire mcgb_rst_mcgb;

  wire         pll_powerdown_input;
  wire         mcgb_rst_input;

   generate 
     if (enable_mcgb && enable_mcgb_reset) begin
        wire clk;
        wire reset_n;

        //***************************************************************************
        // Getting the clock from Master TRS
        //***************************************************************************
        altera_s10_xcvr_clkout_endpoint clock_endpoint (  
     .clk_out(clk)
        );  

        //***************************************************************************
        // Need to self-generate internal reset signal
        //***************************************************************************
        alt_xcvr_resync_std #(
     .SYNC_CHAIN_LENGTH(3),
     .INIT_VALUE(0)
        ) reset_n_generator (
     .clk         (clk),
     .reset (1'b0),
     .d   (1'b1),
     .q   (reset_n)
        );

        alt_xcvr_native_anlg_reset_seq #( 
          .CLK_FREQ_IN_HZ               (125000000),
    .DEFAULT_RESET_SEPARATION_NS  (200),
    .RESET_SEPARATION_NS          (200),  
    .NUM_RESETS                   (1)
        ) mcgb_rst_seq (
          .clk        (clk),    
          .reset_n      (reset_n),
          .reset_in     (mcgb_rst),
          .reset_out      (mcgb_rst_input),
          .reset_stat_out   (mcgb_rst_stat)
        );      
     end else begin
        assign mcgb_rst_input = mcgb_rst;
     end
   endgenerate

   assign pll_powerdown_input = pll_powerdown;

   // avmm signals shared accross all interfaces
   assign reconfig_clk[0] = debug_clk;
   assign reconfig_reset[0] = debug_reset;
   assign reconfig_writedata[7:0] = debug_writedata[7:0];
//   assign reconfig_address[8:0] = debug_address[8:0];
   assign reconfig_address[9:0] = debug_address[9:0];   
   assign reconfig_write[0] = debug_write;
   assign reconfig_read[0] = debug_read;
   assign debug_readdata[7:0] = reconfig_readdata[7:0];
   assign debug_waitrequest = reconfig_waitrequest[0];

   assign avmm_busy0 = avmm_busy[0];
   assign hip_cal_done = hip_cal_done_w[0];
   //---
   assign mcgb_cal_busy = 1'b0;
   assign pll_cal_busy = ~pld_cal_done[0];

   generate
      if (avmm_interfaces==2) begin
         assign reconfig_clk[1] = reconfig_clk1;
         assign reconfig_reset[1] = reconfig_reset1;
         assign reconfig_writedata[15:8] = reconfig_writedata1[7:0];
//         assign reconfig_address[17:9] = reconfig_address1[18:10];
         assign reconfig_address[19:10] = reconfig_address1[9:0];   
         assign reconfig_write[1] = reconfig_write1;
         assign reconfig_read[1] = reconfig_read1;
         assign reconfig_readdata1[7:0]=reconfig_readdata[15:8];
         assign reconfig_waitrequest1 = reconfig_waitrequest[1];
         assign avmm_busy1 = avmm_busy[1];
         //assign mcgb_cal_busy = ~pld_cal_done[1];
         assign mcgb_hip_cal_done = hip_cal_done_w[1];
      end else begin
         assign reconfig_readdata1 = 8'b0;
         assign reconfig_waitrequest1 = 1'b0;
         assign avmm_busy1 = 1'b0;
         assign mcgb_hip_cal_done = 1'b0;
      end
   endgenerate
   //-----------------------------------   

   //***************************************************************************
   //************* Embedded JTAG, AVMM and Embedded Streamer Expansion *********
   alt_xcvr_pll_rcfg_opt_logic_3kcg2aa 
     #(
       .dbg_user_identifier                            (dbg_user_identifier                        ),
       .dbg_embedded_debug_enable                      (dbg_embedded_debug_enable                  ),
       .dbg_capability_reg_enable                      (dbg_capability_reg_enable                  ),
       .dbg_stat_soft_logic_enable                     (dbg_stat_soft_logic_enable                 ),
       .dbg_ctrl_soft_logic_enable                     (dbg_ctrl_soft_logic_enable                 ),
       .en_master_cgb                                  (enable_mcgb                                ),
       .INTERFACES                                     (1                                          ),
       .ADDR_BITS                                      (RCFG_ADDR_BITS                             ),
       .ADME_SLAVE_MAP                                 ("altera_xcvr_atx_pll_s10_htile"            ),
       .ADME_ASSGN_MAP                                 (lcl_adme_assgn_map                         ),
       .RECONFIG_SHARED                                (rcfg_enable && rcfg_shared         ),
       .JTAG_ENABLED                                   (rcfg_enable && rcfg_jtag_enable    ),
       .RCFG_EMB_STRM_ENABLED                          (rcfg_enable && rcfg_emb_strm_enable),
       .RCFG_PROFILE_CNT                               (rcfg_profile_cnt                           )
       ) alt_xcvr_atx_pll_optional_rcfg_logic 
       (
  // User reconfig interface ports
  .reconfig_clk                                   (reconfig_clk0        ),
  .reconfig_reset                                 (reconfig_reset0      ),
  .reconfig_write                                 (reconfig_write0      ),
  .reconfig_read                                  (reconfig_read0       ),
  .reconfig_address                               (reconfig_address0    ),
  .reconfig_writedata                             (reconfig_writedata0  ),
  .reconfig_readdata                              (reconfig_readdata0   ),
  .reconfig_waitrequest                           (reconfig_waitrequest0),
  
  // AVMM ports to transceiver                    
  .avmm_clk                                       (debug_clk            ),
  .avmm_reset                                     (debug_reset          ),
  .avmm_write                                     (debug_write          ),
  .avmm_read                                      (debug_read           ),
  .avmm_address                                   (debug_address        ),
  .avmm_writedata                                 (debug_writedata      ),
  .avmm_readdata                                  (debug_readdata       ),
  .avmm_waitrequest                               (debug_waitrequest    ),
  
  // input signals from the core
  .in_pll_powerdown                               (pll_powerdown_input  ),
  .in_pll_locked                                  (pll_locked           ),
  .in_pll_cal_busy                                (pll_cal_busy         ),
  .in_avmm_busy                                   (avmm_busy0           ),
  
  // output signals to the ip
  .out_pll_powerdown                              (pll_powerdown_int    )
  );
   
   //***************** End Embedded JTAG and AVMM Expansion ********************
   //***************************************************************************

   // Following insnatiates following atoms required for ATX PLL
   // Instantiates ct1_hssi_pma_lc_refclk_select_mux, ct1_atx_pll, ct1_hssi_pma_cgb_master
   //-----------------------------------
   // PLL STARTS
   
   wire             feedback_path_for_fb_comp_bonding_to_lc;
   wire             feedback_path_for_fb_comp_bonding_from_cgb;
   
   generate
      if (enable_mcgb == 1 && hssi_pma_cgb_master_cgb_enable_iqtxrxclk == "enable_iqtxrxclk") begin
         assign feedback_path_for_fb_comp_bonding_to_lc = feedback_path_for_fb_comp_bonding_from_cgb;
      end
      else begin
         assign feedback_path_for_fb_comp_bonding_to_lc = 0;
      end
   endgenerate
   
   wire         avmm_clk_refclk,       avmm_clk_lc,       avmm_clk_mcgb;
   //   wire         avmm_rstn_refclk,      avmm_rstn_lc,      avmm_rstn_mcgb;
   wire [7:0]   avmm_writedata_refclk, avmm_writedata_lc, avmm_writedata_mcgb;
   //   wire [8:0]  avmm_address_refclk,   avmm_address_lc,   avmm_address_mcgb;
   wire [9:0]   avmm_address_refclk,   avmm_address_lc,   avmm_address_mcgb;   
   wire         avmm_write_refclk,     avmm_write_lc,     avmm_write_mcgb;
   wire         avmm_read_refclk,      avmm_read_lc,      avmm_read_mcgb;
   wire [7:0]   avmmreaddata_refclk,   avmmreaddata_lc,   avmmreaddata_mcgb;
   wire         blockselect_refclk,    blockselect_lc,    blockselect_mcgb;
   
   assign pll_avmmreaddata_mcgb[7:0] = { 8 {1'b0} };                           // NOTE only [15:8] is used, hence [7:0] is tied-off to '0'
   assign pll_blockselect_mcgb[0:0] = {1'b0};                                  // NOTE only [1:1] is used, hence [0:0] is tied-off to '0'
   
   generate
      if (avmm_interfaces==2) begin
         assign pll_avmmreaddata_lc[avmm_interfaces*8-1:8] = { 8 {1'b0} };             // NOTE only [7:0] is used, hence [15:8] is tied-off to '0'
         assign pll_avmmreaddata_refclk[avmm_interfaces*8-1:8] = { 8 {1'b0} };   // NOTE only [7:0] is used, hence [15:8] is tied-off to '0'
   
         assign pll_blockselect_lc[avmm_interfaces-1:1] = {1'b0};                      // NOTE only [0:0] is used, hence [1:1] is tied-off to '0'
         assign pll_blockselect_refclk[avmm_interfaces-1:1] = {1'b0};            // NOTE only [0:0] is used, hence [1:1] is tied-off to '0'
   
         assign avmm_clk_mcgb              = pll_avmm_clk[1];
   //         assign avmm_rstn_mcgb             = pll_avmm_rstn[1];
         assign avmm_writedata_mcgb        = pll_avmm_writedata[15:8];
   //         assign avmm_address_mcgb          = pll_avmm_address[17:9];
         assign avmm_address_mcgb          = pll_avmm_address[19:10];  
         assign avmm_write_mcgb            = pll_avmm_write[1];
         assign avmm_read_mcgb             = pll_avmm_read[1];
         assign pll_avmmreaddata_mcgb[15:8] = avmmreaddata_mcgb;
         assign pll_blockselect_mcgb[1]    = blockselect_mcgb;
      end else begin
      
// --------------------------------------------------------------------------------------
// Due to the mcgb and atx pll placement requirement, now the AVMM interface0
// will be spanned to mcgb, atx and adapter interfaces (It used to be AVMM1
// --------------------------------------------------------------------------------------

       assign avmm_clk_mcgb              = pll_avmm_clk[0];
      end
   endgenerate
   
   assign avmm_clk_refclk              = pll_avmm_clk[0];
   //   assign avmm_rstn_refclk             = pll_avmm_rstn[0];
   assign avmm_writedata_refclk        = pll_avmm_writedata[7:0];
   //   assign avmm_address_refclk          = pll_avmm_address[8:0];
   assign avmm_address_refclk          = pll_avmm_address[9:0];   
   assign avmm_write_refclk            = pll_avmm_write[0];
   assign avmm_read_refclk             = pll_avmm_read[0];
   assign pll_avmmreaddata_refclk[7:0] = avmmreaddata_refclk;
   assign pll_blockselect_refclk[0]    = blockselect_refclk;
   
   assign avmm_clk_lc              = pll_avmm_clk[0];
   //   assign avmm_rstn_lc             = pll_avmm_rstn[0];
   assign avmm_writedata_lc        = pll_avmm_writedata[7:0];
   //   assign avmm_address_lc          = pll_avmm_address[8:0];
   assign avmm_address_lc          = pll_avmm_address[9:0];   
   assign avmm_write_lc            = pll_avmm_write[0];
   assign avmm_read_lc             = pll_avmm_read[0];
   assign pll_avmmreaddata_lc[7:0] = avmmreaddata_lc;
   assign pll_blockselect_lc[0]    = blockselect_lc;
   
   wire refclk_mux_out;
   
   // OPEN find a better way for the following parameters
   localparam SIZE_CGB_BONDING_CLK = 6;
   localparam SIZE_REFIQCLK = 12;
   localparam REFCLK_CNT = 5;
   
   assign mcgb_serial_clk = tx_bonding_clocks[SIZE_CGB_BONDING_CLK-1];
   
  //-----------------------------------
  // wire around the HIP
  //-----------------------------------
 
  assign pll_powerdown_atx    = (enable_pcie_hip_connectivity) ? pll_powerdown   : pll_powerdown_from_pa_atom;
  assign pll_powerdown_adapt  = (enable_pcie_hip_connectivity) ? 1'b0                 : ~pll_powerdown_int;

  assign mcgb_rst_mcgb        = (enable_pcie_hip_connectivity) ? mcgb_rst        : mcgb_rst_from_pa_atom;
  assign mcgb_rst_adapt       = (enable_pcie_hip_connectivity) ? 1'b0                 : ~mcgb_rst_input;
   
   //-----------------------------------
   // MUX STARTS
   ct1_hssi_cr2_pma_lc_refclk_select_mux
     #(
       //-----------------------------------
       //-----------------------------------
       .enable_debug_info(enable_debug_info), // L-Tile specific
       .powerdown_mode(hssi_pma_lc_refclk_select_mux_powerdown_mode),
       .silicon_rev(hssi_pma_lc_refclk_select_mux_silicon_rev),

        // H-Tile specific
        // TODO - These need to be modified once the atom is fixed (see case 414799)
       .xmux_refclk_src("src_iqclk"), // TODO - temporary - supports only first clock input
       .xpm_iqref_mux_iqclk_sel("ref_iqclk0"),  // TODO - temporary - supports only first clock input
       //.xpll_lccmu_mode("lccmu_normal"),  // TODO - temporary
       .xpll_lccmu_mode(atx_pll_lccmu_mode),  // TODO - temporary
       // End H-Tile specific
       .refclk_select(hssi_pma_lc_refclk_select_mux_refclk_select),
       .inclk0_logical_to_physical_mapping (hssi_pma_lc_refclk_select_mux_inclk0_logical_to_physical_mapping),
       .inclk1_logical_to_physical_mapping (hssi_pma_lc_refclk_select_mux_inclk1_logical_to_physical_mapping),
       .inclk2_logical_to_physical_mapping (hssi_pma_lc_refclk_select_mux_inclk2_logical_to_physical_mapping),
       .inclk3_logical_to_physical_mapping (hssi_pma_lc_refclk_select_mux_inclk3_logical_to_physical_mapping),
       .inclk4_logical_to_physical_mapping (hssi_pma_lc_refclk_select_mux_inclk4_logical_to_physical_mapping)
       //-----------------------------------
       //-----------------------------------
       )
   ct1_hssi_pma_lc_refclk_select_mux_inst 
     (
      // AVMM interface
      .avmmaddress  (avmm_address_refclk),
      .avmmclk      (avmm_clk_refclk),
      .avmmread     (avmm_read_refclk),
      .avmmwrite    (avmm_write_refclk),
      .avmmwritedata(avmm_writedata_refclk),
      .avmmreaddata (avmmreaddata_refclk),
      .blockselect  (blockselect_refclk),
      // refclk inputs
      .core_refclk  (1'b0),
      .iqtxrxclk    (6'b0),
      .lvpecl_in    (1'b0),
      .ref_iqclk    ({{(SIZE_REFIQCLK-REFCLK_CNT){1'b0}}, {pll_refclk4, pll_refclk3, pll_refclk2, pll_refclk1, pll_refclk0}}),
      .refclk       (refclk_mux_out)
      );
   // MUX ENDS
   //-----------------------------------
   
   
   //-----------------------------------
   // LC    STARTS
   //-----------------------------------
   ct1_hssi_cr2_pma_lc_pll
     #(
    //-----------------------------------
    //-----------------------------------
    .enable_debug_info                  (enable_debug_info),
    //.fb_select                        (atx_pll_fb_select),
    .analog_mode                        (atx_pll_analog_mode),
    .bandwidth_range_high               (lcl_atx_pll_bandwidth_range_high),
    .bandwidth_range_low                (lcl_atx_pll_bandwidth_range_low),
    .bcm_silicon_rev                    (atx_pll_bcm_silicon_rev),  // H-tile Specific
    .bonding                            (atx_pll_bonding),
    .bw_mode                            (atx_pll_bw_mode),
    .cal_status                         (atx_pll_cal_status),
    .calibration_mode                   (atx_pll_calibration_mode), 
    .cascadeclk_test                    (atx_pll_cascadeclk_test),
    .cgb_div                            (atx_pll_cgb_div),               // OPEN is not this supposed to be in cgb_master only [CM: ]
    .chgpmp_compensation                (atx_pll_chgpmp_compensation),      
    .chgpmp_current_setting             (atx_pll_chgpmp_current_setting),
    .chgpmp_testmode                    (atx_pll_chgpmp_testmode),
    .clk_high_perf_voltage              (atx_pll_clk_high_perf_voltage),
    .clk_low_power_voltage              (atx_pll_clk_low_power_voltage),
    .clk_mid_power_voltage              (atx_pll_clk_mid_power_voltage),
    .clk_vreg_boost_expected_voltage    (atx_pll_clk_vreg_boost_expected_voltage),
    .clk_vreg_boost_scratch             (atx_pll_clk_vreg_boost_scratch),
    .clk_vreg_boost_step_size           (atx_pll_clk_vreg_boost_step_size),
    .cp_current_boost                   (atx_pll_cp_current_boost),      
    .datarate_bps                       (lcl_atx_pll_datarate_bps),
    .device_variant                     (atx_pll_device_variant),
    .dsm_fractional_division            (lcl_atx_pll_dsm_fractional_division),      // OPEN is this assignment correct [CM: ]
    .dsm_mode                           (atx_pll_dsm_mode),
    .expected_lc_boost_voltage          (atx_pll_expected_lc_boost_voltage),
    .f_max_lcnt_fpll_cascading          (lcl_atx_pll_f_max_lcnt_fpll_cascading),
    .f_max_pfd                          (lcl_atx_pll_f_max_pfd),
    .f_max_pfd_fractional               (lcl_atx_pll_f_max_pfd_fractional),
    .f_max_ref                          (lcl_atx_pll_f_max_ref),
    .f_max_tank_0                       (lcl_atx_pll_f_max_tank_0),
    .f_max_tank_1                       (lcl_atx_pll_f_max_tank_1),
    .f_max_tank_2                       (lcl_atx_pll_f_max_tank_2),
    .f_max_vco                          (lcl_atx_pll_f_max_vco),
    .f_max_vco_fractional               (lcl_atx_pll_f_max_vco_fractional),
    .f_max_x1                           (lcl_atx_pll_f_max_x1),
    .f_min_pfd                          (lcl_atx_pll_f_min_pfd),
    .f_min_ref                          (lcl_atx_pll_f_min_ref),
    .f_min_tank_0                       (lcl_atx_pll_f_min_tank_0),
    .f_min_tank_1                       (lcl_atx_pll_f_min_tank_1),
    .f_min_tank_2                       (lcl_atx_pll_f_min_tank_2),
    .f_min_vco                          (lcl_atx_pll_f_min_vco),
    .fpll_refclk_selection              (atx_pll_fpll_refclk_selection),
    .hclk_en                            (atx_pll_hclk_en),
    .initial_settings                   (atx_pll_initial_settings),
    .iqclk_sel                          (atx_pll_iqclk_sel),
    .is_cascaded_pll                    (atx_pll_is_cascaded_pll),
    .is_otn                             (atx_pll_is_otn),
    .is_sdi                             (atx_pll_is_sdi),
    .l_counter                          (atx_pll_l_counter),
    .lc_cal_reserved                    (atx_pll_lc_cal_reserved), // H-Tile specific
    .lc_cal_status                      (atx_pll_lc_cal_status),
    .lc_calibration                     (atx_pll_lc_calibration), 
    .lc_dyn_reconfig                    (atx_pll_lc_dyn_reconfig), // H-Tile specific
    .enable_hclk                        (atx_pll_enable_hclk),     // H-Tile specific
    .powermode_ac_lc                    (atx_pll_powermode_ac_lc), // H-Tile specific
    .powermode_ac_lc_gtpath             (atx_pll_powermode_ac_lc_gtpath), // H-Tile specific
    .powermode_dc_lc                    (atx_pll_powermode_dc_lc),   // H-Tile specific
    .powermode_dc_lc_gtpath             (atx_pll_powermode_dc_lc_gtpath),  // H-Tile specific
    .lc_reg_status                      (atx_pll_lc_reg_status),
    .lc_sel_tank                        (atx_pll_lc_sel_tank),
    .lc_tank_band                       (atx_pll_lc_tank_band),
    .lc_tank_voltage_coarse             (atx_pll_lc_tank_voltage_coarse),
    .lc_tank_voltage_fine               (atx_pll_lc_tank_voltage_fine),
    .lc_to_fpll_l_counter               (atx_pll_lc_to_fpll_l_counter),       
    .lc_to_fpll_l_counter_scratch       (atx_pll_lc_to_fpll_l_counter_scratch),
    .lc_vreg1_boost                     (atx_pll_lc_vreg1_boost),
    .lc_vreg1_boost_expected_voltage    (atx_pll_lc_vreg1_boost_expected_voltage),
    .lc_vreg1_boost_scratch             (atx_pll_lc_vreg1_boost_scratch),
    .lc_vreg_boost                      (atx_pll_lc_vreg_boost),
    .lc_vreg_boost_expected_voltage     (atx_pll_lc_vreg_boost_expected_voltage),
    .lc_vreg_boost_scratch              (atx_pll_lc_vreg_boost_scratch),
    .lccmu_mode                         (atx_pll_lccmu_mode),
    .lcnt_bypass                        (atx_pll_lcnt_bypass),      
    .lcnt_divide                        (atx_pll_lcnt_divide),      
    .lcnt_off                           (atx_pll_lcnt_off),       
    .lcpll_gt_in_sel                    (atx_pll_lcpll_gt_in_sel        ),  // H-Tile specific
    .lcpll_gt_out_left_enb              (atx_pll_lcpll_gt_out_left_enb  ),  // H-Tile specific
    .lcpll_gt_out_mid_enb               (atx_pll_lcpll_gt_out_mid_enb   ),  // H-Tile specific
    .lcpll_gt_out_right_enb             (atx_pll_lcpll_gt_out_right_enb ),  // H-Tile specific
    .lcpll_lckdet_sel                   (atx_pll_lcpll_lckdet_sel       ),  // H-Tile specific
    .lf_3rd_pole_freq                   (atx_pll_lf_3rd_pole_freq),
    .lf_cbig_size                       (atx_pll_lf_cbig_size),
    .lf_order                           (atx_pll_lf_order),
    .lf_resistance                      (atx_pll_lf_resistance),
    .lf_ripplecap                       (atx_pll_lf_ripplecap),
    .max_fractional_percentage          (atx_pll_max_fractional_percentage),
    .mcgb_vreg_boost_expected_voltage   (atx_pll_mcgb_vreg_boost_expected_voltage),
    .mcgb_vreg_boost_scratch            (atx_pll_mcgb_vreg_boost_scratch),
    .mcgb_vreg_boost_step_size          (atx_pll_mcgb_vreg_boost_step_size),
    .mcnt_divide                        (atx_pll_mcnt_divide),
    .min_fractional_percentage          (atx_pll_min_fractional_percentage),
    .n_counter                          (atx_pll_n_counter),      
    .out_freq                           (lcl_atx_pll_out_freq),
    .output_regulator_supply            (atx_pll_output_regulator_supply),
    .overrange_voltage                  (atx_pll_overrange_voltage),
    .pfd_delay_compensation             (atx_pll_pfd_delay_compensation),
    .pfd_pulse_width                    (atx_pll_pfd_pulse_width),
    .pll_dsm_out_sel                    (atx_pll_pll_dsm_out_sel),
    .pll_ecn_bypass                     (atx_pll_pll_ecn_bypass),
    .pll_ecn_test_en                    (atx_pll_pll_ecn_test_en),
    .pll_fractional_value_ready         (atx_pll_pll_fractional_value_ready),
    .pm_dprio_lc_dprio_status_select    (atx_pll_pm_dprio_lc_dprio_status_select),
    .pma_width                          (atx_pll_pma_width),
    .power_mode                         (atx_pll_power_mode),
    .power_rail_et                      (atx_pll_power_rail_et),
    .powerdown_mode                     (atx_pll_powerdown_mode),
    .primary_use                        (atx_pll_primary_use),
    .prot_mode                          (atx_pll_prot_mode),
    .ref_clk_div                        (atx_pll_ref_clk_div),              // equivalent to n_counter_scratch in A10 ATX
    .reference_clock_frequency          (lcl_atx_pll_reference_clock_frequency),
    .regulator_bypass                   (atx_pll_regulator_bypass),
    .side                               (atx_pll_side),
    .silicon_rev                        (atx_pll_silicon_rev),
    //.speed_grade                      (atx_pll_speed_grade),  // Allow to default
    .sup_mode                           (atx_pll_sup_mode),
    .top_or_bottom                      (atx_pll_top_or_bottom),
    .underrange_voltage                 (atx_pll_underrange_voltage),
    .vccdreg_clk                        (atx_pll_vccdreg_clk),
    .vccdreg_fb                         (atx_pll_vccdreg_fb),
    .vccdreg_fw                         (atx_pll_vccdreg_fw),
    .vco_freq                           (lcl_atx_pll_vco_freq),
    .vreg1_boost_step_size              (atx_pll_vreg1_boost_step_size),
    .vreg_boost_step_size               (atx_pll_vreg_boost_step_size),
    .xatb_lccmu_atb                     (atx_pll_xatb_lccmu_atb),
    .xd2a_lc_d2a_voltage                (atx_pll_xd2a_lc_d2a_voltage) ,
    .direct_fb                          (atx_pll_direct_fb)
       )
   ct1_atx_pll_inst 
     (
         
      .clk0_8g                          (tx_serial_clk),

      .clk180_16g                       ( /*unused*/ ),
      .clk180_8g                        ( /*unused*/ ),

      .lf_rst_n                         (1'b1),
      .rst_n                            (pll_powerdown_atx),
      .refclk                           (refclk_mux_out),
      .lock                             (pll_locked_hip),
      
      .iqtxrxclk                        ({5'b0, feedback_path_for_fb_comp_bonding_to_lc}),
      
      .hclk_out                         (pll_pcie_clk),
      .iqtxrxclk_out                    (pll_cascade_clk),
      .lc_to_fpll_refclk                (atx_to_fpll_cascade_clk),
      
      //-----------------------------------
      .clklow_buf                       (clklow_to_pa_atom),
      .fref_buf                         (fref_to_pa_atom),
      .overrange                        (overrange),
      .underrange                       (underrange),
      //-----------------------------------
      
      // inputs
      .clk0_16g                         (tx_serial_clk_gxt),
      .lc_input_clk0_left               (gxt_input_from_blw_atx), // H-Tile specific
      .lc_input_clk0_right              (gxt_input_from_abv_atx),
      .lc_input_clk180_left             (1'b0),
      .lc_input_clk180_right            (1'b0),
      .ppm_lckdtct                      (1'b0),
      // outputs
      .clk0_16g_left                    (gxt_output_to_blw_atx),
      .clk0_16g_right                   (gxt_output_to_abv_atx),
      .clk180_16g_left                  (),
      .clk180_16g_right                 (),
      .fbclkid_fpll                     (),
      .refclkid_fpll                    (),

      //-----------------------------------
      .avmmaddress                      (avmm_address_lc),
      .avmmclk                          (avmm_clk_lc),
      .avmmread                         (avmm_read_lc),
//      .avmmrstn                       (avmm_rstn_lc),
      .avmmwrite                        (avmm_write_lc),
      .avmmwritedata                    (avmm_writedata_lc),
      .avmmreaddata                     (avmmreaddata_lc),
      .blockselect                      (blockselect_lc)
      //-----------------------------------
      );
   // LC    ENDS
   //-----------------------------------
   
   
   generate
      if (enable_mcgb == 1) begin
   //-----------------------------------
   // CGB STARTS    
   ct1_hssi_cr2_pma_cgb_master
     #(
       //-----------------------------------
       //-----------------------------------
       .enable_debug_info(enable_debug_info),                           // OPEN verify if still exists
       .silicon_rev(hssi_pma_cgb_master_silicon_rev),
       .datarate_bps(lcl_hssi_pma_cgb_master_datarate_bps),
       .x1_div_m_sel(hssi_pma_cgb_master_x1_div_m_sel),
       .prot_mode(hssi_pma_cgb_master_prot_mode),
       .ser_mode(hssi_pma_cgb_master_ser_mode),
       .cgb_enable_iqtxrxclk(hssi_pma_cgb_master_cgb_enable_iqtxrxclk), // OPEN 1) needs to be reviewed 2) in atom default is enable in _hw.tcl default is disable
       //-----------------------------------
       //-----------------------------------
       .cgb_power_down                     (hssi_pma_cgb_master_cgb_power_down                    ),
       .observe_cgb_clocks                 (hssi_pma_cgb_master_observe_cgb_clocks                ),
       //.op_mode                            (hssi_pma_cgb_master_op_mode                           ),
       //.tx_ucontrol_reset_pcie             (hssi_pma_cgb_master_tx_ucontrol_reset_pcie            ),
       .vccdreg_output                     (hssi_pma_cgb_master_vccdreg_output                    ),
       .input_select                       (hssi_pma_cgb_master_input_select                      ),
       .input_select_gen3                  (hssi_pma_cgb_master_input_select_gen3                 ),
       //-----------------------------------
       //-----------------------------------
       .bonding_reset_enable               (hssi_pma_cgb_master_bonding_reset_enable         ),  // NOTE applies to slave cgb // RANGE disallow_bonding_reset (allow_bonding_reset)
       .optimal                            (hssi_pma_cgb_master_optimal), 
       .pcie_gen3_bitwidth                 (hssi_pma_cgb_master_pcie_gen3_bitwidth),
       .powerdown_mode                     (hssi_pma_cgb_master_powerdown_mode),
       .sup_mode                           (hssi_pma_cgb_master_sup_mode),
       .initial_settings                   (hssi_pma_cgb_master_initial_settings),
       //.scratch0_x1_clock_src() // NOTE set by fitter        // RANGE (unused) lcpll_bot lcpll_top fpll_bot fpll_top
       //.scratch1_x1_clock_src() // NOTE set by fitter        // RANGE (unused) lcpll_bot lcpll_top fpll_bot fpll_top
       //.scratch2_x1_clock_src() // NOTE set by fitter        // RANGE (unused) lcpll_bot lcpll_top fpll_bot fpll_top
       //.scratch3_x1_clock_src() // NOTE set by fitter        // RANGE (unused) lcpll_bot lcpll_top fpll_bot fpll_top
       //.x1_clock_source_sel()   // NOTE set by fitter        // RANGE lcpll_bot lcpll_top fpll_bot (fpll_top) lcpll_bot_g1_g2 lcpll_top_g1_g2 fpll_bot_g1_g2 fpll_top_g1_g2 fpll_bot_g2_lcpll_bot_g3 fpll_bot_g2_lcpll_top_g3 fpll_top_g2_lcpll_bot_g3 fpll_top_g2_lcpll_top_g3 
       //-----------------------------------
       //----------------------------------- 
       .msel_er                 ("select_er"),  // H-Tile specific *TODO* // "select_er" "select_et"
       //.xpll_calibration_mode   ("uc_not_rst"),  // H-Tile specific // "cal_off" "uc_not_rst" "uc_rst_lf" "uc_rst_pll"
       .power_rail_er  (hssi_pma_cgb_master_power_rail_er), 
       .powermode_ac_cgb_master (hssi_pma_cgb_master_powermode_ac_cgb_master), 
       .powermode_dc_cgb_master (hssi_pma_cgb_master_powermode_dc_cgb_master)
       //.tx_ucontrol_en("enable")  // TODO:Change when calibration mode issue is fixed.
       )
   ct1_hssi_pma_cgb_master_inst 
     (
      
      .cgb_rstb(mcgb_rst_mcgb),                             //Active Low signal is needed by the cgb master
      
      //-----------------------------------
      .clk_fpll_b(mcgb_aux_clk2),
      .clk_fpll_t(mcgb_aux_clk0),
      .clk_lc_b(mcgb_aux_clk1),
      .clk_lc_t(tx_serial_clk),
      
      .clkb_fpll_b( /*unused*/ ),
      .clkb_fpll_t( /*unused*/ ),
      .clkb_lc_b( /*unused*/ ),
      .clkb_lc_t( /*unused*/ ),
      //-----------------------------------
      
      .cpulse_out_bus(tx_bonding_clocks),               // OPEN is bus ok? 
      
      .tx_iqtxrxclk_out(feedback_path_for_fb_comp_bonding_from_cgb),
      
      .pcie_sw_done(pcie_sw_done),
      .pcie_sw(pcie_sw),
      
      //-----------------------------------                           
      .tx_bonding_rstb(1'b1),                        // NOTE carried over from slave cgb
      //-----------------------------------  
      
      //-----------------------------------          
      .avmmaddress(avmm_address_mcgb),
      .avmmclk(avmm_clk_mcgb),
      .avmmread(avmm_read_mcgb),
//      .avmmrstn(avmm_rstn_mcgb),
      .avmmwrite(avmm_write_mcgb),
      .avmmwritedata(avmm_writedata_mcgb),
      .avmmreaddata(avmmreaddata_mcgb),
      .blockselect(blockselect_mcgb)
       //-----------------------------------           
      );
   // CGB ENDS
   //-----------------------------------   
      end else begin
   assign pcie_sw_done = 2'b0;
   assign tx_bonding_clocks = 6'b0;
      end
   endgenerate
   
   // PLL ENDS 
   //-----------------------------------

   //-----------------------------------
   localparam  avmm_busy_en      = rcfg_separate_avmm_busy ? "enable" : "disable";

   
   // AVMM  STARTS 
   ct1_xcvr_avmm2
     #(
       .avmm_interfaces(avmm_interfaces),
       .rcfg_enable(rcfg_enable),
       .enable_avmm(1),              
       .silicon_rev(hssi_avmm2_if_silicon_rev),      
       .calibration_type(hssi_avmm2_if_calibration_type),
       .pcs_calibration_feature_en(hssi_avmm2_if_pcs_calibration_feature_en),
       .pcs_arbiter_ctrl(hssi_avmm2_if_pcs_arbiter_ctrl),
       .pcs_cal_done(hssi_avmm2_if_pcs_cal_done),
       .pcs_hip_cal_en(hssi_avmm2_if_pcs_hip_cal_en),
       .pcs_cal_reserved(hssi_avmm2_if_pcs_cal_reserved),
       .pldadapt_hip_mode(hssi_avmm2_if_pldadapt_hip_mode),
       .hssiadapt_hip_mode(hssi_avmm2_if_hssiadapt_hip_mode),
       .hssiadapt_avmm_osc_clock_setting(hssi_avmm2_if_hssiadapt_avmm_osc_clock_setting),  
       .pldadapt_avmm_osc_clock_setting(hssi_avmm2_if_pldadapt_avmm_osc_clock_setting), 
       .hssiadapt_avmm_testbus_sel(hssi_avmm2_if_hssiadapt_avmm_testbus_sel),
       .pldadapt_avmm_testbus_sel(hssi_avmm2_if_pldadapt_avmm_testbus_sel),
       .pldadapt_gate_dis(hssi_avmm2_if_pldadapt_gate_dis)  
       )
   s10_xcvr_avmm_inst (
           .avmm_clk(       {reconfig_clk           } ),
           .avmm_reset(     {reconfig_reset         } ),
           .avmm_writedata( {reconfig_writedata     } ),
           .avmm_address(   {reconfig_address       } ),
           .avmm_write(     {reconfig_write         } ),
           .avmm_read(      {reconfig_read          } ),
           .avmm_readdata(  {reconfig_readdata      } ),
           .avmm_waitrequest({reconfig_waitrequest  } ),
           .avmm_busy(      {avmm_busy              } ),
           .pld_cal_done(   {pld_cal_done           } ),
           .hip_cal_done(   {hip_cal_done_w         } ),

           .pll_avmm_clk(pll_avmm_clk),
           .pll_avmm_writedata(pll_avmm_writedata),
           .pll_avmm_address(pll_avmm_address),
           .pll_avmm_write(pll_avmm_write),
           .pll_avmm_read(pll_avmm_read),

           .pll_avmmreaddata_lc_pll(pll_avmmreaddata_lc),                           
           .pll_avmmreaddata_lc_refclk_select(pll_avmmreaddata_refclk), 
           .pll_avmmreaddata_cgb_master(pll_avmmreaddata_mcgb),                                        

           .pll_blockselect_lc_pll(pll_blockselect_lc),            
           .pll_blockselect_lc_refclk_select(pll_blockselect_refclk),  
           .pll_blockselect_cgb_master(pll_blockselect_mcgb),

           .pll_avmmreaddata_cmu_fpll                 ( {avmm_interfaces{8'b0}} ),
           .pll_avmmreaddata_cmu_fpll_refclk_select   ( {avmm_interfaces{8'b0}} ),
           .pll_blockselect_cmu_fpll                  ( {avmm_interfaces{1'b0}} ),
           .pll_blockselect_cmu_fpll_refclk_select    ( {avmm_interfaces{1'b0}} ),

           //HIP signals
           .hip_avmm_read         ( {avmm_interfaces{1'b0}} ),
           .hip_avmm_write        ( {avmm_interfaces{1'b0}}),
           .hip_avmm_reg_addr     ( {avmm_interfaces{21'b0}}),
           .hip_avmm_writedata    ( {avmm_interfaces{8'b0}}   ),
           .hip_aib_avmm_out      ( {avmm_interfaces{15'b0}} ),
           .hip_avmm_readdata     (),
             .hip_avmm_readdatavalid (),
           .hip_avmm_writedone    (),
           .hip_avmm_reserved_out (),
           .hip_aib_avmm_clk      (),
           .hip_aib_avmm_in       (),          
         .pld_hssi_osc_transfer_en(pld_hssi_osc_transfer_en)
           );
    // AVMM  ENDS
    //-----------------------------------

// Instantiating PLD adapt atoms
// PLL and mcgb PLD adapter atoms are required to inetrafce with core
// all control/input signals will come to PLL through PLD adapter
// all status siganls are going to PLD core through this atom

//WYS_BUS_NAME  WYS_BUS_TYPE
  
//lf_rst_n  in
//rst_n         in
//clklow_buf  out
//fref_buf  out
//lock          out
//int_lf_rst_n  out
//int_rst_n out
//int_clklow_buf in
//int_fref_buf  in
//int_lock  in
//avmmaddress in
//avmmclk in
//avmmread  in
//avmmwrite in
//avmmwritedata in
//avmmreaddata  out
//blockselect out

   ct1_atx_pll_pld_adapt lc_pll_pld_adapt_inst
     (
      // Input ports
      .rst_n(pll_powerdown_adapt),
      .int_rst_n(pll_powerdown_from_pa_atom),      
//      .int_clk(reconfig_clk0),

      .lf_rst_n(1'b1),
      .int_lf_rst_n(),      
      
      // Inputs from PLL atom
      .int_clklow_buf(clklow_to_pa_atom),
      .int_fref_buf(fref_to_pa_atom),
      .int_lock(pll_locked_hip),
      
      // Outputs to PLD
      .clklow_buf(clklow),
      .fref_buf(fref),
      .lock(pll_locked),
      .avmmclk(avmm_clk_lc)

/*      .avmmaddress(),
      .avmmread(),
      .avmmwrite(),
      .avmmwritedata(),
      .avmmreaddata(),
      .blockselect(),
 */
      );

// Master CGB PLD adapter atom

   ct1_hssi_pma_cgb_master_pld_adapt cgb_master_pll_pld_adapt_inst
     (
      .cgb_rstb(mcgb_rst_adapt),                       // Input from PLD
      .int_cgb_rstb(mcgb_rst_from_pa_atom),      // this will connect to mcgb_resetmcgb atom
      .avmmclk(avmm_clk_mcgb)
/*
      .avmmaddress(),
      .avmmread(),
      .avmmwrite(),
      .avmmwritedata(),
      .avmmreaddata(),
      .blockselect(),
 */
      );


endmodule


