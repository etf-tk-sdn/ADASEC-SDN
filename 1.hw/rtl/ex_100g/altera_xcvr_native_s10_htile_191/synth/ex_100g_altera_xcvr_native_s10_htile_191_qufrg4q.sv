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



module ex_100g_altera_xcvr_native_s10_htile_191_qufrg4q
  #(

	//---------------------
	// Common Parameters
	//---------------------
	parameter device_revision                  = "14nm5cr2",	
	parameter silicon_revision                 = "14nm5cr2",	
	parameter duplex_mode                      = "duplex",	  // "duplex:TX/RX Duplex" "tx:TX Simplex" "rx:RX Simplex"
	parameter channels                         = 1,		  // legal values 1+
	parameter l_release_aib_reset_first        = 0,		  // PCS and AIB reset release sequence. 0 - release PCS reset before AIB reset, 1 - release AIB reset before PCS reset
	parameter disable_reset_sequencer          = 0,		  // (0,1)
	parameter disable_digital_reset_sequencer  = 0,		  // (0,1)
	parameter enable_direct_reset_control      = 0,           // (0,1)
	parameter enable_calibration               = 0,		  // (0,1)
													                                // 0 - Disable transceiver calibration
													                                // 1 - Enable transceiver calibration
	parameter enable_background_cal		= 1, // 1 -- enable background periodical calibration, 0 -- disable background periodical calibration
	//---------------------
	// Datapath
	//---------------------
	parameter enable_tx_fast_pipeln_reg        = 0,		// 1 - Enable fast pipeline register on TX parallel datapath; 0 - Disable fast pipeline registers on TX parallel data path
	parameter enable_rx_fast_pipeln_reg        = 0,		// 1 - Enable fast pipeline register on RX parallel datapath; 0 - Disable fast pipeline registers on RX parallel data path

	//---------------------
	// PIPE early speed change
	//---------------------
	parameter enable_early_spd_chng            = 0,                // (0,1)
	parameter early_spd_chng_t1                = 0,                // (0,1)
	parameter early_spd_chng_t2                = 0,                // (0,1)
	parameter early_spd_chng_t3                = 0,                // (0,1)
	parameter display_std_tx_pld_adapt_width   = 0,                // (0,1)

	//---------------------
	// PIPE EIOS RX PROTECTION 
	//---------------------
	parameter enable_eios_rx_protect           = 0,                // (0,1)

	//---------------------
	// Bonding
	//---------------------
	parameter bonded_mode	                        = "not_bonded",	// "not_bonded:Not bonded" "pma_only:PMA only bonding" "pma_pcs:PMA and PCS bonding"
	parameter enable_manual_bonding_settings	    = 0,			      // (0,1) 0 - User manual PCS bonding settings, 1 - Auto PCS bonding settings
	parameter pcs_bonding_master	                = 0,						// (0:channels-1), Specifies PCS bonding master
	parameter pcs_reset_sequencing_mode           = "not_bonded",	// "not_bonded:Not bonded" "bonded:Bonded"
	parameter manual_pcs_bonding_mode	            = "individual",	// Manual PCS bonding settings - "ctrl_master" "ctrl_slave_abv" "ctrl_slave_blw" "individual"
	parameter manual_pcs_bonding_comp_cnt	        = 0,				    // Manual PCS bonding settings - 0:255
	parameter manual_tx_hssi_aib_bonding_mode	    = "individual",	// Manual TX HSSI AIB bonding settings - "ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter manual_tx_hssi_aib_bonding_comp_cnt	= 0,		        // Manual TX HSSI AIB bonding settings - 0:255
	parameter manual_tx_core_aib_bonding_mode	    = "individual",	// Manual TX Core AIB bonding settings - "ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter manual_tx_core_aib_bonding_comp_cnt	= 0,		        // Manual TX Core AIB bonding settings - 0:255
	parameter manual_rx_hssi_aib_bonding_mode	    = "individual",	// Manual RX HSSI AIB bonding settings - "ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter manual_rx_hssi_aib_bonding_comp_cnt	= 0,		        // Manual RX HSSI AIB bonding settings - 0:255
	parameter manual_rx_core_aib_bonding_mode	    = "individual",	// Manual RX Core AIB bonding settings - "ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter manual_rx_core_aib_bonding_comp_cnt	= 0,		        // Manual RX Core AIB bonding settings - 0:255	
	parameter number_physical_bonding_clocks	    = 1,	          // 1 2 3 4

	//---------------------
	// PLL & Refclk
	//---------------------
	parameter plls	          = 1,	// 1 2 3 4
	parameter cdr_refclk_cnt	= 1,	// 1 2 3 4 5
	
	//---------------------
	// PHIP
	//---------------------
	parameter enable_hip	= 0,	// NOVAL
	parameter hip_cal_en	= "disable",	//  "disable" "enable"

	//---------------------
	// EHIP
	//---------------------
	parameter enable_ehip	= 0,	// NOVAL
		
	//---------------------
	// Clocks
	//---------------------
	parameter tx_coreclkin_clock_network	  = "dedicated",	// "dedicated:Dedicated Clock" "rowclk:Global Clock"
	parameter tx_pcs_bonding_clock_network	= "dedicated",	// "dedicated:Dedicated Clock" "rowclk:Global Clock"
	parameter rx_coreclkin_clock_network	  = "dedicated",	// "dedicated:Dedicated Clock" "rowclk:Global Clock"
	parameter enable_tx_x2_coreclkin_port	  = 0,			      // 0, 1
	parameter osc_clk_divider	              = 1,	          // TODO - Ajay case:330938 

	//---------------------
	// Reconfiguration
	//---------------------
	parameter rcfg_enable	= 0,	                               // (0,1)
																                             //		0 - Disable the AVMM reconfiguration interface.
																                             //		1 - Enable the AVMM reconfiguration interface.
	parameter rcfg_shared	= 0,		                             						// (0,1)
																                             //		0 - Present separate AVMM interface for each channel,
																                             //		1 - Present shared AVMM interface for all channels using address decoding.
																                             //				Bits [n:10] of "reconfig_address" select the channel to address.
																                             //				Bit  [9] selects between soft registers (1) and HSSI channel registers (0)
																                             //				Bits [8:0] of "reconfig_address" provide the register offset within soft or hard register space.
	parameter rcfg_jtag_enable	= 0,                           							// (0,1)
																                             //		0 - Disable embedded debug master
																                             //		1 - Enable embedded JTAG master. Requires "rcfg_shared==1".

	parameter rcfg_separate_avmm_busy	= 0,					           // (0,1)
																                             //		0 - AVMM busy is reflected on the waitrequest
																                             //		1 - AVMM busy must be read from a soft CSR
	parameter enable_rcfg_tx_digitalreset_release_ctrl	= 0,	 // (0,1)
																                             //		0 - Enable PCS reset sequence control port
																                             //		1 - Disable PCS reset sequence control port
	//---------------------
	// ADME
	//---------------------
	parameter adme_prot_mode		= "basic_tx",
	parameter adme_pma_mode			= "basic_enh",
	parameter adme_tx_power_mode	= "low_power",
	parameter adme_data_rate		= "5000000000",
	parameter adme_enable_bg_cal    	= "0",
	//---------------------
	// Embedded Debug
	//---------------------
	parameter dbg_prbs_soft_logic_enable	= 0,	// enables soft logic for prbs err accumulation
	parameter dbg_odi_soft_logic_enable	  = 0,  // enables soft logic for odi 
	parameter dbg_embedded_debug_enable	  = 0,	// enables embedded debug blocks
	parameter dbg_capability_reg_enable	  = 0,	// enables capability registers to describe the debug endpoint
	parameter dbg_user_identifier	        = 0,	// user-assigned value to either define phy_ip or to link associated ip
	parameter dbg_stat_soft_logic_enable	= 0,	// enables soft logic to read status signals through avmm
	parameter dbg_ctrl_soft_logic_enable	= 0,	// enables soft logic to write control signals through avmm

	//---------------------
	// Embedded Streamer
	//---------------------
	parameter rcfg_emb_strm_enable	= 0,			// (0,1)
	parameter rcfg_profile_cnt	    = 2,			// Number of configuration profiles for embedded reconfiguration streamer		
	
	parameter reduced_reset_sim_time	= 0,	// (0,1)

      
	parameter hssi_avmm1_if_hssiadapt_avmm_clk_dcg_en = "disable", // disable|enable
	parameter hssi_avmm1_if_hssiadapt_avmm_clk_scg_en = "disable", // disable|enable
	parameter hssi_avmm1_if_hssiadapt_osc_clk_scg_en = "disable", // disable|enable
	parameter hssi_avmm1_if_pldadapt_avmm_clk_scg_en = "disable", // disable|enable
	parameter hssi_avmm1_if_pldadapt_osc_clk_scg_en = "disable", // disable|enable
	parameter hssi_pldadapt_rx_hdpldadapt_sr_sr_testbus_sel = "ssr_testbus", // ssr_testbus|fsr_testbus
	parameter hssi_pldadapt_tx_hdpldadapt_sr_sr_testbus_sel = "ssr_testbus", // ssr_testbus|fsr_testbus
	parameter pma_tx_ser_xtx_path_xtx_idle_ctrl = "id_cpen_on", // id_cpen_on|id_cpen_off

	parameter          cdr_pll_analog_mode                                                               = "analog_off"                                                              ,//"analog_off" "dp_1620" "dp_2700" "dp_5400" "dp_8100" "gpon_1244" "gpon_622" "hdmi_3400" "hdmi_6000" "ieee_1000_base_kx" "ieee_100g_base_cr10_10312" "ieee_10g_base_kx4" "ieee_10g_kr_10312" "ieee_40g_base_cr4_10312" "infiniband_fdr_14000" "nppi_10312" "sas_12000" "sonet_oc48_2488" "upi" "user_custom"
	parameter          cdr_pll_atb_select_control                                                        = "atb_off"                                                                 ,//"atb_off" "atb_select_tp_1" "atb_select_tp_10" "atb_select_tp_11" "atb_select_tp_12" "atb_select_tp_13" "atb_select_tp_14" "atb_select_tp_15" "atb_select_tp_16" "atb_select_tp_17" "atb_select_tp_18" "atb_select_tp_19" "atb_select_tp_2" "atb_select_tp_20" "atb_select_tp_21" "atb_select_tp_22" "atb_select_tp_23" "atb_select_tp_24" "atb_select_tp_25" "atb_select_tp_26" "atb_select_tp_27" "atb_select_tp_28" "atb_select_tp_29" "atb_select_tp_3" "atb_select_tp_30" "atb_select_tp_31" "atb_select_tp_32" "atb_select_tp_33" "atb_select_tp_34" "atb_select_tp_35" "atb_select_tp_36" "atb_select_tp_37" "atb_select_tp_38" "atb_select_tp_39" "atb_select_tp_4" "atb_select_tp_40" "atb_select_tp_41" "atb_select_tp_42" "atb_select_tp_43" "atb_select_tp_44" "atb_select_tp_45" "atb_select_tp_46" "atb_select_tp_47" "atb_select_tp_48" "atb_select_tp_49" "atb_select_tp_5" "atb_select_tp_50" "atb_select_tp_51" "atb_select_tp_52" "atb_select_tp_53" "atb_select_tp_54" "atb_select_tp_55" "atb_select_tp_56" "atb_select_tp_57" "atb_select_tp_58" "atb_select_tp_59" "atb_select_tp_6" "atb_select_tp_60" "atb_select_tp_61" "atb_select_tp_62" "atb_select_tp_63" "atb_select_tp_7" "atb_select_tp_8" "atb_select_tp_9"
	parameter          cdr_pll_auto_reset_on                                                             = "auto_reset_on"                                                           ,//"auto_reset_off" "auto_reset_on"
	parameter          cdr_pll_bandwidth_range_high                                                      = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_bandwidth_range_low                                                       = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_bbpd_data_pattern_filter_select                                           = "bbpd_data_pat_off"                                                       ,//"bbpd_data_pat_1" "bbpd_data_pat_2" "bbpd_data_pat_3" "bbpd_data_pat_off"
	parameter          cdr_pll_bti_protected                                                             = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_bw_mode                                                                   = "bw_mode_off"                                                             ,//"bw_mode_off" "high_bw" "low_bw" "mid_bw"
	parameter          cdr_pll_bypass_a_edge                                                             = "bypass_a_edge_off"                                                       ,//"bypass_a_edge_off" "bypass_a_edge_on"
	parameter          cdr_pll_cal_vco_count_length                                                      = "sel_8b_count"                                                            ,//"sel_12b_count" "sel_8b_count"
	parameter          cdr_pll_cdr_d2a_enb                                                               = "bti_d2a_disable"                                                         ,//"bti_d2a_disable" "bti_d2a_enable"
	parameter          cdr_pll_cdr_odi_select                                                            = "sel_cdr"                                                                 ,//"sel_cdr" "sel_odi"
	parameter          cdr_pll_cdr_phaselock_mode                                                        = "no_ignore_lock"                                                          ,//"ignore_lock" "no_ignore_lock"
	parameter          cdr_pll_cdr_powerdown_mode                                                        = "power_down"                                                              ,//"power_down" "power_up"
	parameter          cdr_pll_cgb_div                                                                   = 1                                                                         ,//1:2 4 8
	parameter          cdr_pll_chgpmp_current_dn_pd                                                      = "cp_current_pd_dn_setting0"                                               ,//"cp_current_pd_dn_setting0" "cp_current_pd_dn_setting1" "cp_current_pd_dn_setting2" "cp_current_pd_dn_setting3" "cp_current_pd_dn_setting4"
	parameter          cdr_pll_chgpmp_current_dn_trim                                                    = "cp_current_trimming_dn_setting0"                                         ,//"cp_current_trimming_dn_setting0" "cp_current_trimming_dn_setting1" "cp_current_trimming_dn_setting10" "cp_current_trimming_dn_setting11" "cp_current_trimming_dn_setting12" "cp_current_trimming_dn_setting13" "cp_current_trimming_dn_setting14" "cp_current_trimming_dn_setting15" "cp_current_trimming_dn_setting2" "cp_current_trimming_dn_setting3" "cp_current_trimming_dn_setting4" "cp_current_trimming_dn_setting5" "cp_current_trimming_dn_setting6" "cp_current_trimming_dn_setting7" "cp_current_trimming_dn_setting8" "cp_current_trimming_dn_setting9"
	parameter          cdr_pll_chgpmp_current_pfd                                                        = "cp_current_pfd_setting0"                                                 ,//"cp_current_pfd_setting0" "cp_current_pfd_setting1" "cp_current_pfd_setting2" "cp_current_pfd_setting3" "cp_current_pfd_setting4"
	parameter          cdr_pll_chgpmp_current_up_pd                                                      = "cp_current_pd_up_setting0"                                               ,//"cp_current_pd_up_setting0" "cp_current_pd_up_setting1" "cp_current_pd_up_setting2" "cp_current_pd_up_setting3" "cp_current_pd_up_setting4"
	parameter          cdr_pll_chgpmp_current_up_trim                                                    = "cp_current_trimming_up_setting0"                                         ,//"cp_current_trimming_up_setting0" "cp_current_trimming_up_setting1" "cp_current_trimming_up_setting10" "cp_current_trimming_up_setting11" "cp_current_trimming_up_setting12" "cp_current_trimming_up_setting13" "cp_current_trimming_up_setting14" "cp_current_trimming_up_setting15" "cp_current_trimming_up_setting2" "cp_current_trimming_up_setting3" "cp_current_trimming_up_setting4" "cp_current_trimming_up_setting5" "cp_current_trimming_up_setting6" "cp_current_trimming_up_setting7" "cp_current_trimming_up_setting8" "cp_current_trimming_up_setting9"
	parameter          cdr_pll_chgpmp_dn_pd_trim_double                                                  = "normal_dn_trim_current"                                                  ,//"double_dn_trim_current" "normal_dn_trim_current"
	parameter          cdr_pll_chgpmp_replicate                                                          = "disable_replica_bias_ctrl"                                               ,//"disable_replica_bias_ctrl" "enable_replica_bias_ctrl"
	parameter          cdr_pll_chgpmp_testmode                                                           = "cp_test_disable"                                                         ,//"cp_test_disable" "cp_test_dn" "cp_test_up" "cp_tristate"
	parameter          cdr_pll_chgpmp_up_pd_trim_double                                                  = "normal_up_trim_current"                                                  ,//"double_up_trim_current" "normal_up_trim_current"
	parameter          cdr_pll_chgpmp_vccreg                                                             = "vreg_fw0"                                                                ,//"vreg_fw0" "vreg_fw1" "vreg_fw2" "vreg_fw3" "vreg_fw4" "vreg_fw5" "vreg_fw6" "vreg_fw7"
	parameter          cdr_pll_clk0_dfe_tfall_adj                                                        = "clk0_dfe_tf0"                                                            ,//"clk0_dfe_tf0" "clk0_dfe_tf1" "clk0_dfe_tf2" "clk0_dfe_tf3" "clk0_dfe_tf4" "clk0_dfe_tf5" "clk0_dfe_tf6" "clk0_dfe_tf7"
	parameter          cdr_pll_clk0_dfe_trise_adj                                                        = "clk0_dfe_tr0"                                                            ,//"clk0_dfe_tr0" "clk0_dfe_tr1" "clk0_dfe_tr2" "clk0_dfe_tr3" "clk0_dfe_tr4" "clk0_dfe_tr5" "clk0_dfe_tr6" "clk0_dfe_tr7"
	parameter          cdr_pll_clk90_dfe_tfall_adj                                                       = "clk90_dfe_tf0"                                                           ,//"clk90_dfe_tf0" "clk90_dfe_tf1" "clk90_dfe_tf2" "clk90_dfe_tf3" "clk90_dfe_tf4" "clk90_dfe_tf5" "clk90_dfe_tf6" "clk90_dfe_tf7"
	parameter          cdr_pll_clk90_dfe_trise_adj                                                       = "clk90_dfe_tr0"                                                           ,//"clk90_dfe_tr0" "clk90_dfe_tr1" "clk90_dfe_tr2" "clk90_dfe_tr3" "clk90_dfe_tr4" "clk90_dfe_tr5" "clk90_dfe_tr6" "clk90_dfe_tr7"
	parameter          cdr_pll_clk180_dfe_tfall_adj                                                      = "clk180_dfe_tf0"                                                          ,//"clk180_dfe_tf0" "clk180_dfe_tf1" "clk180_dfe_tf2" "clk180_dfe_tf3" "clk180_dfe_tf4" "clk180_dfe_tf5" "clk180_dfe_tf6" "clk180_dfe_tf7"
	parameter          cdr_pll_clk180_dfe_trise_adj                                                      = "clk180_dfe_tr0"                                                          ,//"clk180_dfe_tr0" "clk180_dfe_tr1" "clk180_dfe_tr2" "clk180_dfe_tr3" "clk180_dfe_tr4" "clk180_dfe_tr5" "clk180_dfe_tr6" "clk180_dfe_tr7"
	parameter          cdr_pll_clk270_dfe_tfall_adj                                                      = "clk270_dfe_tf0"                                                          ,//"clk270_dfe_tf0" "clk270_dfe_tf1" "clk270_dfe_tf2" "clk270_dfe_tf3" "clk270_dfe_tf4" "clk270_dfe_tf5" "clk270_dfe_tf6" "clk270_dfe_tf7"
	parameter          cdr_pll_clk270_dfe_trise_adj                                                      = "clk270_dfe_tr0"                                                          ,//"clk270_dfe_tr0" "clk270_dfe_tr1" "clk270_dfe_tr2" "clk270_dfe_tr3" "clk270_dfe_tr4" "clk270_dfe_tr5" "clk270_dfe_tr6" "clk270_dfe_tr7"
	parameter          cdr_pll_clklow_mux_select                                                         = "clklow_mux_cdr_fbclk"                                                    ,//"clklow_mux_cdr_fbclk" "clklow_mux_dfe_test" "clklow_mux_fpll_test1" "clklow_mux_reserved_1" "clklow_mux_reserved_2" "clklow_mux_reserved_3" "clklow_mux_reserved_4" "clklow_mux_rx_deser_pclk_test"
	parameter          cdr_pll_datarate_bps                                                              = "0"                                                                       ,//NOVAL
	parameter          cdr_pll_diag_loopback_enable                                                      = "no_diag_rev_loopback"                                                    ,//"diag_rev_loopback" "no_diag_rev_loopback"
	parameter          cdr_pll_direct_fb                                                                 = "direct_fb"                                                               ,//"direct_fb" "iqtxrxclk_fb"
	parameter          cdr_pll_disable_up_dn                                                             = "normal_mode"                                                             ,//"normal_mode" "tristate_up_dn_current"
	parameter          cdr_pll_f_max_cmu_out_freq                                                        = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_max_m_counter                                                           = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_max_pfd                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_max_ref                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_max_vco                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_min_gt_channel                                                          = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_min_pfd                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_min_ref                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_f_min_vco                                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_fref_clklow_div                                                           = 1                                                                         ,//1:2 4 8
	parameter          cdr_pll_fref_mux_select                                                           = "fref_mux_cdr_refclk"                                                     ,//"fref_mux_cdr_refclk" "fref_mux_fpll_test0" "fref_mux_reserved_1" "fref_mux_reserved_2" "fref_mux_reserved_3" "fref_mux_reserved_4" "fref_mux_reserved_5" "fref_mux_tx_ser_pclk_test"
	parameter          cdr_pll_gpon_lck2ref_control                                                      = "gpon_lck2ref_off"                                                        ,//"gpon_lck2ref_off" "gpon_lck2ref_on"
	parameter          cdr_pll_initial_settings                                                          = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_iqclk_sel                                                                 = "power_down"                                                              ,//"iqtxrxclk0" "iqtxrxclk1" "iqtxrxclk2" "iqtxrxclk3" "iqtxrxclk4" "iqtxrxclk5" "power_down"
	parameter          cdr_pll_is_cascaded_pll                                                           = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_lck2ref_delay_control                                                     = "lck2ref_delay_off"                                                       ,//"lck2ref_delay_1" "lck2ref_delay_2" "lck2ref_delay_3" "lck2ref_delay_4" "lck2ref_delay_5" "lck2ref_delay_6" "lck2ref_delay_7" "lck2ref_delay_off"
	parameter          cdr_pll_lf_resistor_pd                                                            = "lf_pd_setting0"                                                          ,//"lf_pd_setting0" "lf_pd_setting1" "lf_pd_setting2" "lf_pd_setting3"
	parameter          cdr_pll_lf_resistor_pfd                                                           = "lf_pfd_setting0"                                                         ,//"lf_pfd_setting0" "lf_pfd_setting1" "lf_pfd_setting2" "lf_pfd_setting3"
	parameter          cdr_pll_lf_ripple_cap                                                             = "lf_no_ripple"                                                            ,//"lf_no_ripple" "lf_ripple_cap1"
	parameter          cdr_pll_loop_filter_bias_select                                                   = "lpflt_bias_off"                                                          ,//"lpflt_bias_1" "lpflt_bias_2" "lpflt_bias_3" "lpflt_bias_4" "lpflt_bias_5" "lpflt_bias_6" "lpflt_bias_7" "lpflt_bias_off"
	parameter          cdr_pll_loopback_mode                                                             = "loopback_recovered_data"                                                 ,//"loopback_disabled" "loopback_received_data" "loopback_recovered_data" "rx_refclk" "rx_refclk_cdr_loopback" "unused1" "unused2"
	parameter [4:0]    cdr_pll_lpd_counter                                                               = 5'd0                                                                      ,//0:31
	parameter [4:0]    cdr_pll_lpfd_counter                                                              = 5'd1                                                                      ,//0:31
	parameter          cdr_pll_ltd_ltr_micro_controller_select                                           = "ltd_ltr_pcs"                                                             ,//"ltd_ltr_pcs" "ltd_ucontroller" "ltr_ucontroller"
	parameter [7:0]    cdr_pll_mcnt_div                                                                  = 8'd16                                                                     ,//0:255
	parameter [5:0]    cdr_pll_n_counter                                                                 = 6'd1                                                                      ,//0:63
	parameter          cdr_pll_ncnt_div                                                                  = 1                                                                         ,//1:2 4 8
	parameter          cdr_pll_optimal                                                                   = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_out_freq                                                                  = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_pcie_gen                                                                  = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          cdr_pll_pd_fastlock_mode                                                          = "fast_lock_disable"                                                       ,//"fast_lock_disable" "fast_lock_enable"
	parameter          cdr_pll_pd_l_counter                                                              = 1                                                                         ,//0:2 4 8 16
	parameter          cdr_pll_pfd_l_counter                                                             = 1                                                                         ,//0:2 4 8 16 100
	parameter          cdr_pll_pm_cr2_rx_path_cdr_clock_enable                                           = "cdr_clock_disable"                                                       ,//"cdr_clock_disable" "cdr_clock_enable"
	parameter          cdr_pll_pm_cr2_tx_rx_uc_dyn_reconfig                                              = "uc_dyn_reconfig_off"                                                     ,//"uc_dyn_reconfig_off" "uc_dyn_reconfig_on"
	parameter          cdr_pll_pma_width                                                                 = 8                                                                         ,//8 10 16 20 32 40 64
	parameter          cdr_pll_position                                                                  = "position_off"                                                            ,//"position0" "position1" "position2" "position_off" "position_unknown"
	parameter          cdr_pll_power_mode                                                                = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter          cdr_pll_powermode_ac_bbpd                                                         = "bbpd_ac_off"                                                             ,//"bbpd_ac_bti" "bbpd_ac_off" "bbpd_ac_on"
	parameter          cdr_pll_powermode_ac_rvcotop                                                      = "rvcotop_ac_off"                                                          ,//"rvcotop_ac_bti" "rvcotop_ac_div1" "rvcotop_ac_div16" "rvcotop_ac_div2" "rvcotop_ac_div4" "rvcotop_ac_div8" "rvcotop_ac_off"
	parameter          cdr_pll_powermode_ac_txpll                                                        = "txpll_ac_off"                                                            ,//"txpll_ac_div16" "txpll_ac_div2" "txpll_ac_div4" "txpll_ac_div8" "txpll_ac_off"
	parameter          cdr_pll_powermode_dc_bbpd                                                         = "powerdown_bbpd"                                                          ,//"bbpd_dc_bti" "bbpd_dc_on" "powerdown_bbpd"
	parameter          cdr_pll_powermode_dc_rvcotop                                                      = "powerdown_rvcotop"                                                       ,//"powerdown_rvcotop" "rvcotop_dc_bti" "rvcotop_dc_div1" "rvcotop_dc_div16" "rvcotop_dc_div2" "rvcotop_dc_div4" "rvcotop_dc_div8"
	parameter          cdr_pll_powermode_dc_txpll                                                        = "powerdown_txpll"                                                         ,//"powerdown_txpll" "txpll_dc_div16" "txpll_dc_div2" "txpll_dc_div4" "txpll_dc_div8"
	parameter          cdr_pll_primary_use                                                               = "primary_off"                                                             ,//"cdr" "cmu" "primary_off"
	parameter          cdr_pll_prot_mode                                                                 = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          cdr_pll_reference_clock_frequency                                                 = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_requires_gt_capable_channel                                               = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_reverse_serial_loopback                                                   = "no_loopback"                                                             ,//"loopback_data_0_1" "loopback_data_no_posttap" "loopback_data_with_posttap" "no_loopback"
	parameter          cdr_pll_rstb                                                                      = "cdr_lf_reset_off"                                                        ,//"cdr_lf_reset_off" "cdr_lf_reset_on"
	parameter [7:0]    cdr_pll_set_cdr_input_freq_range                                                  = 8'd0                                                                      ,//0:255
	parameter          cdr_pll_set_cdr_v2i_enable                                                        = "enable_v2i_bias"                                                         ,//"disable_v2i_bias" "enable_v2i_bias"
	parameter          cdr_pll_set_cdr_vco_reset                                                         = "vco_normal"                                                              ,//"vco_normal" "vco_reset"
	parameter [3:0]    cdr_pll_set_cdr_vco_speed                                                         = 4'd0                                                                      ,//0:15
	parameter [7:0]    cdr_pll_set_cdr_vco_speed_fix                                                     = 8'd0                                                                      ,//0:255
	parameter          cdr_pll_set_cdr_vco_speed_pciegen3                                                = "cdr_vco_max_speedbin_pciegen3"                                           ,//"cdr_vco_max_speedbin_pciegen3" "cdr_vco_min_speedbin_pciegen3"
	parameter          cdr_pll_silicon_rev                                                               = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          cdr_pll_speed_grade                                                               = "speed_off"                                                               ,//"e1" "e2" "e3" "e4" "e5" "i1" "i2" "i3" "i4" "i5" "m3" "m4" "speed_off"
	parameter          cdr_pll_sup_mode                                                                  = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          cdr_pll_tx_pll_prot_mode                                                          = "txpll_off"                                                               ,//"txpll_enable" "txpll_enable_pcie" "txpll_off" "txpll_unused"
	parameter          cdr_pll_txpll_hclk_driver_enable                                                  = "hclk_off"                                                                ,//"hclk_off" "hclk_on"
	parameter          cdr_pll_uc_ro_cal                                                                 = "uc_ro_off"                                                               ,//"uc_ro_cal_off" "uc_ro_cal_on" "uc_ro_off"
	parameter          cdr_pll_vco_bypass                                                                = "false"                                                                   ,//"false" "true"
	parameter          cdr_pll_vco_freq                                                                  = "1"                                                                       ,//NOVAL
	parameter          cdr_pll_vco_overrange_voltage                                                     = "vco_overrange_off"                                                       ,//"vco_overrange_off" "vco_overrange_ref_1" "vco_overrange_ref_2" "vco_overrange_ref_3"
	parameter          cdr_pll_vco_underrange_voltage                                                    = "vco_underange_off"                                                       ,//"vco_underange_off" "vco_underange_ref_1" "vco_underange_ref_2" "vco_underange_ref_3"
	parameter          cdr_pll_vreg_output                                                               = "vccdreg_nominal"                                                         ,//"vccdreg_neg_setting1" "vccdreg_neg_setting2" "vccdreg_neg_setting3" "vccdreg_neg_setting4" "vccdreg_nominal" "vccdreg_pos_setting1" "vccdreg_pos_setting10" "vccdreg_pos_setting11" "vccdreg_pos_setting12" "vccdreg_pos_setting13" "vccdreg_pos_setting14" "vccdreg_pos_setting15" "vccdreg_pos_setting16" "vccdreg_pos_setting17" "vccdreg_pos_setting18" "vccdreg_pos_setting19" "vccdreg_pos_setting2" "vccdreg_pos_setting20" "vccdreg_pos_setting21" "vccdreg_pos_setting22" "vccdreg_pos_setting23" "vccdreg_pos_setting24" "vccdreg_pos_setting25" "vccdreg_pos_setting26" "vccdreg_pos_setting27" "vccdreg_pos_setting3" "vccdreg_pos_setting4" "vccdreg_pos_setting5" "vccdreg_pos_setting6" "vccdreg_pos_setting7" "vccdreg_pos_setting8" "vccdreg_pos_setting9"
	parameter          hssi_8g_rx_pcs_auto_error_replacement                                             = "dis_err_replace"                                                         ,//"dis_err_replace" "en_err_replace"
	parameter          hssi_8g_rx_pcs_bit_reversal                                                       = "dis_bit_reversal"                                                        ,//"dis_bit_reversal" "en_bit_reversal"
	parameter          hssi_8g_rx_pcs_bonding_dft_en                                                     = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_8g_rx_pcs_bonding_dft_val                                                    = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_8g_rx_pcs_bypass_pipeline_reg                                                = "dis_bypass_pipeline"                                                     ,//"dis_bypass_pipeline" "en_bypass_pipeline"
	parameter          hssi_8g_rx_pcs_byte_deserializer                                                  = "dis_bds"                                                                 ,//"dis_bds" "en_bds_by_2" "en_bds_by_2_det" "en_bds_by_4"
	parameter          hssi_8g_rx_pcs_cdr_ctrl_rxvalid_mask                                              = "dis_rxvalid_mask"                                                        ,//"dis_rxvalid_mask" "en_rxvalid_mask"
	parameter [19:0]   hssi_8g_rx_pcs_clkcmp_pattern_n                                                   = 20'd0                                                                     ,//0:1048575
	parameter [19:0]   hssi_8g_rx_pcs_clkcmp_pattern_p                                                   = 20'd0                                                                     ,//0:1048575
	parameter          hssi_8g_rx_pcs_clock_gate_bds_dec_asn                                             = "dis_bds_dec_asn_clk_gating"                                              ,//"dis_bds_dec_asn_clk_gating" "en_bds_dec_asn_clk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_cdr_eidle                                               = "dis_cdr_eidle_clk_gating"                                                ,//"dis_cdr_eidle_clk_gating" "en_cdr_eidle_clk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_dw_pc_wrclk                                             = "dis_dw_pc_wrclk_gating"                                                  ,//"dis_dw_pc_wrclk_gating" "en_dw_pc_wrclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_dw_rm_rd                                                = "dis_dw_rm_rdclk_gating"                                                  ,//"dis_dw_rm_rdclk_gating" "en_dw_rm_rdclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_dw_rm_wr                                                = "dis_dw_rm_wrclk_gating"                                                  ,//"dis_dw_rm_wrclk_gating" "en_dw_rm_wrclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_dw_wa                                                   = "dis_dw_wa_clk_gating"                                                    ,//"dis_dw_wa_clk_gating" "en_dw_wa_clk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_pc_rdclk                                                = "dis_pc_rdclk_gating"                                                     ,//"dis_pc_rdclk_gating" "en_pc_rdclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_sw_pc_wrclk                                             = "dis_sw_pc_wrclk_gating"                                                  ,//"dis_sw_pc_wrclk_gating" "en_sw_pc_wrclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_sw_rm_rd                                                = "dis_sw_rm_rdclk_gating"                                                  ,//"dis_sw_rm_rdclk_gating" "en_sw_rm_rdclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_sw_rm_wr                                                = "dis_sw_rm_wrclk_gating"                                                  ,//"dis_sw_rm_wrclk_gating" "en_sw_rm_wrclk_gating"
	parameter          hssi_8g_rx_pcs_clock_gate_sw_wa                                                   = "dis_sw_wa_clk_gating"                                                    ,//"dis_sw_wa_clk_gating" "en_sw_wa_clk_gating"
	parameter          hssi_8g_rx_pcs_clock_observation_in_pld_core                                      = "internal_sw_wa_clk"                                                      ,//"internal_cdr_eidle_clk" "internal_clk_2_b" "internal_dw_rm_rd_clk" "internal_dw_rm_wr_clk" "internal_dw_rx_wr_clk" "internal_dw_wa_clk" "internal_rx_pma_clk_gen3" "internal_rx_rcvd_clk_gen3" "internal_rx_rd_clk" "internal_sm_rm_wr_clk" "internal_sw_rm_rd_clk" "internal_sw_rx_wr_clk" "internal_sw_wa_clk"
	parameter          hssi_8g_rx_pcs_eidle_entry_eios                                                   = "dis_eidle_eios"                                                          ,//"dis_eidle_eios" "en_eidle_eios"
	parameter          hssi_8g_rx_pcs_eidle_entry_iei                                                    = "dis_eidle_iei"                                                           ,//"dis_eidle_iei" "en_eidle_iei"
	parameter          hssi_8g_rx_pcs_eidle_entry_sd                                                     = "dis_eidle_sd"                                                            ,//"dis_eidle_sd" "en_eidle_sd"
	parameter          hssi_8g_rx_pcs_eightb_tenb_decoder                                                = "dis_8b10b"                                                               ,//"dis_8b10b" "en_8b10b_ibm" "en_8b10b_sgx"
	parameter          hssi_8g_rx_pcs_err_flags_sel                                                      = "err_flags_wa"                                                            ,//"err_flags_8b10b" "err_flags_wa"
	parameter          hssi_8g_rx_pcs_fixed_pat_det                                                      = "dis_fixed_patdet"                                                        ,//"dis_fixed_patdet" "en_fixed_patdet"
	parameter [3:0]    hssi_8g_rx_pcs_fixed_pat_num                                                      = 4'd15                                                                     ,//0:15
	parameter          hssi_8g_rx_pcs_force_signal_detect                                                = "en_force_signal_detect"                                                  ,//"dis_force_signal_detect" "en_force_signal_detect"
	parameter          hssi_8g_rx_pcs_gen3_clk_en                                                        = "disable_clk"                                                             ,//"disable_clk" "enable_clk"
	parameter          hssi_8g_rx_pcs_gen3_rx_clk_sel                                                    = "rcvd_clk"                                                                ,//"en_dig_clk1_8g" "rcvd_clk"
	parameter          hssi_8g_rx_pcs_gen3_tx_clk_sel                                                    = "tx_pma_clk"                                                              ,//"en_dig_clk2_8g" "tx_pma_clk"
	parameter          hssi_8g_rx_pcs_hip_mode                                                           = "dis_hip"                                                                 ,//"dis_hip" "en_hip"
	parameter          hssi_8g_rx_pcs_ibm_invalid_code                                                   = "dis_ibm_invalid_code"                                                    ,//"dis_ibm_invalid_code" "en_ibm_invalid_code"
	parameter          hssi_8g_rx_pcs_invalid_code_flag_only                                             = "dis_invalid_code_only"                                                   ,//"dis_invalid_code_only" "en_invalid_code_only"
	parameter          hssi_8g_rx_pcs_pad_or_edb_error_replace                                           = "replace_edb"                                                             ,//"replace_edb" "replace_edb_dynamic" "replace_pad"
	parameter          hssi_8g_rx_pcs_pcs_bypass                                                         = "dis_pcs_bypass"                                                          ,//"dis_pcs_bypass" "en_pcs_bypass"
	parameter          hssi_8g_rx_pcs_phase_comp_rdptr                                                   = "enable_rdptr"                                                            ,//"disable_rdptr" "enable_rdptr"
	parameter          hssi_8g_rx_pcs_phase_compensation_fifo                                            = "low_latency"                                                             ,//"low_latency" "normal_latency" "pld_ctrl_low_latency" "pld_ctrl_normal_latency" "register_fifo"
	parameter          hssi_8g_rx_pcs_pipe_if_enable                                                     = "dis_pipe_rx"                                                             ,//"dis_pipe_rx" "en_pipe3_rx" "en_pipe_rx"
	parameter          hssi_8g_rx_pcs_pma_dw                                                             = "eight_bit"                                                               ,//"eight_bit" "sixteen_bit" "ten_bit" "twenty_bit"
	parameter          hssi_8g_rx_pcs_polinv_8b10b_dec                                                   = "dis_polinv_8b10b_dec"                                                    ,//"dis_polinv_8b10b_dec" "en_polinv_8b10b_dec"
	parameter          hssi_8g_rx_pcs_prot_mode                                                          = "gige"                                                                    ,//"basic_rm_disable" "basic_rm_enable" "cpri" "cpri_rx_tx" "disabled_prot_mode" "gige" "gige_1588" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter          hssi_8g_rx_pcs_rate_match                                                         = "dis_rm"                                                                  ,//"dis_rm" "dw_basic_rm" "gige_rm" "pipe_rm" "pipe_rm_0ppm" "sw_basic_rm"
	parameter          hssi_8g_rx_pcs_rate_match_del_thres                                               = "dis_rm_del_thres"                                                        ,//"dis_rm_del_thres" "dw_basic_rm_del_thres" "gige_rm_del_thres" "pipe_rm_0ppm_del_thres" "pipe_rm_del_thres" "sw_basic_rm_del_thres"
	parameter          hssi_8g_rx_pcs_rate_match_empty_thres                                             = "dis_rm_empty_thres"                                                      ,//"dis_rm_empty_thres" "dw_basic_rm_empty_thres" "gige_rm_empty_thres" "pipe_rm_0ppm_empty_thres" "pipe_rm_empty_thres" "sw_basic_rm_empty_thres"
	parameter          hssi_8g_rx_pcs_rate_match_full_thres                                              = "dis_rm_full_thres"                                                       ,//"dis_rm_full_thres" "dw_basic_rm_full_thres" "gige_rm_full_thres" "pipe_rm_0ppm_full_thres" "pipe_rm_full_thres" "sw_basic_rm_full_thres"
	parameter          hssi_8g_rx_pcs_rate_match_ins_thres                                               = "dis_rm_ins_thres"                                                        ,//"dis_rm_ins_thres" "dw_basic_rm_ins_thres" "gige_rm_ins_thres" "pipe_rm_0ppm_ins_thres" "pipe_rm_ins_thres" "sw_basic_rm_ins_thres"
	parameter          hssi_8g_rx_pcs_rate_match_start_thres                                             = "dis_rm_start_thres"                                                      ,//"dis_rm_start_thres" "dw_basic_rm_start_thres" "gige_rm_start_thres" "pipe_rm_0ppm_start_thres" "pipe_rm_start_thres" "sw_basic_rm_start_thres"
	parameter          hssi_8g_rx_pcs_rx_clk2                                                            = "rcvd_clk_clk2"                                                           ,//"rcvd_clk_clk2" "refclk_dig2_clk2" "tx_pma_clock_clk2"
	parameter          hssi_8g_rx_pcs_rx_clk_free_running                                                = "en_rx_clk_free_run"                                                      ,//"dis_rx_clk_free_run" "en_rx_clk_free_run"
	parameter          hssi_8g_rx_pcs_rx_pcs_urst                                                        = "en_rx_pcs_urst"                                                          ,//"dis_rx_pcs_urst" "en_rx_pcs_urst"
	parameter          hssi_8g_rx_pcs_rx_rcvd_clk                                                        = "rcvd_clk_rcvd_clk"                                                       ,//"rcvd_clk_rcvd_clk" "tx_pma_clock_rcvd_clk"
	parameter          hssi_8g_rx_pcs_rx_rd_clk                                                          = "pld_rx_clk"                                                              ,//"pld_rx_clk" "rx_clk"
	parameter          hssi_8g_rx_pcs_rx_refclk                                                          = "dis_refclk_sel"                                                          ,//"dis_refclk_sel" "en_refclk_sel"
	parameter          hssi_8g_rx_pcs_rx_wr_clk                                                          = "rx_clk2_div_1_2_4"                                                       ,//"rx_clk2_div_1_2_4" "txfifo_rd_clk"
	parameter          hssi_8g_rx_pcs_silicon_rev                                                        = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_8g_rx_pcs_sup_mode                                                           = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_8g_rx_pcs_symbol_swap                                                        = "dis_symbol_swap"                                                         ,//"dis_symbol_swap" "en_symbol_swap"
	parameter          hssi_8g_rx_pcs_sync_sm_idle_eios                                                  = "dis_syncsm_idle"                                                         ,//"dis_syncsm_idle" "en_syncsm_idle"
	parameter          hssi_8g_rx_pcs_test_bus_sel                                                       = "tx_testbus"                                                              ,//"pcie_ctrl_testbus" "rm_testbus" "rx_ctrl_plane_testbus" "rx_ctrl_testbus" "tx_ctrl_plane_testbus" "tx_testbus" "wa_testbus"
	parameter          hssi_8g_rx_pcs_tx_rx_parallel_loopback                                            = "dis_plpbk"                                                               ,//"dis_plpbk" "en_plpbk"
	parameter          hssi_8g_rx_pcs_wa_boundary_lock_ctrl                                              = "bit_slip"                                                                ,//"auto_align_pld_ctrl" "bit_slip" "deterministic_latency" "sync_sm"
	parameter [9:0]    hssi_8g_rx_pcs_wa_clk_slip_spacing                                                = 10'd16                                                                    ,//0:1023
	parameter          hssi_8g_rx_pcs_wa_det_latency_sync_status_beh                                     = "assert_sync_status_non_imm"                                              ,//"assert_sync_status_imm" "assert_sync_status_non_imm" "dont_care_assert_sync"
	parameter          hssi_8g_rx_pcs_wa_disp_err_flag                                                   = "dis_disp_err_flag"                                                       ,//"dis_disp_err_flag" "en_disp_err_flag"
	parameter          hssi_8g_rx_pcs_wa_kchar                                                           = "dis_kchar"                                                               ,//"dis_kchar" "en_kchar"
	parameter          hssi_8g_rx_pcs_wa_pd                                                              = "wa_pd_10"                                                                ,//"wa_pd_10" "wa_pd_16_dw" "wa_pd_16_sw" "wa_pd_20" "wa_pd_32" "wa_pd_40" "wa_pd_7" "wa_pd_8_dw" "wa_pd_8_sw"
	parameter          hssi_8g_rx_pcs_wa_pd_data                                                         = "0"                                                                       ,//NOVAL
	parameter          hssi_8g_rx_pcs_wa_pd_polarity                                                     = "dis_pd_both_pol"                                                         ,//"dis_pd_both_pol" "dont_care_both_pol" "en_pd_both_pol"
	parameter          hssi_8g_rx_pcs_wa_pld_controlled                                                  = "dis_pld_ctrl"                                                            ,//"dis_pld_ctrl" "level_sensitive_dw" "pld_ctrl_sw" "rising_edge_sensitive_dw"
	parameter [5:0]    hssi_8g_rx_pcs_wa_renumber_data                                                   = 6'd0                                                                      ,//0:63
	parameter [7:0]    hssi_8g_rx_pcs_wa_rgnumber_data                                                   = 8'd0                                                                      ,//0:255
	parameter [7:0]    hssi_8g_rx_pcs_wa_rknumber_data                                                   = 8'd0                                                                      ,//0:255
	parameter [1:0]    hssi_8g_rx_pcs_wa_rosnumber_data                                                  = 2'd0                                                                      ,//0:3
	parameter [12:0]   hssi_8g_rx_pcs_wa_rvnumber_data                                                   = 13'd0                                                                     ,//0:8191
	parameter          hssi_8g_rx_pcs_wa_sync_sm_ctrl                                                    = "gige_sync_sm"                                                            ,//"dw_basic_sync_sm" "fibre_channel_sync_sm" "gige_sync_sm" "pipe_sync_sm" "sw_basic_sync_sm"
	parameter [11:0]   hssi_8g_rx_pcs_wait_cnt                                                           = 12'd0                                                                     ,//0:4095
	parameter          hssi_8g_tx_pcs_bit_reversal                                                       = "dis_bit_reversal"                                                        ,//"dis_bit_reversal" "en_bit_reversal"
	parameter          hssi_8g_tx_pcs_bonding_dft_en                                                     = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_8g_tx_pcs_bonding_dft_val                                                    = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_8g_tx_pcs_bypass_pipeline_reg                                                = "dis_bypass_pipeline"                                                     ,//"dis_bypass_pipeline" "en_bypass_pipeline"
	parameter          hssi_8g_tx_pcs_byte_serializer                                                    = "dis_bs"                                                                  ,//"dis_bs" "en_bs_by_2" "en_bs_by_4"
	parameter          hssi_8g_tx_pcs_clock_gate_bs_enc                                                  = "dis_bs_enc_clk_gating"                                                   ,//"dis_bs_enc_clk_gating" "en_bs_enc_clk_gating"
	parameter          hssi_8g_tx_pcs_clock_gate_dw_fifowr                                               = "dis_dw_fifowr_clk_gating"                                                ,//"dis_dw_fifowr_clk_gating" "en_dw_fifowr_clk_gating"
	parameter          hssi_8g_tx_pcs_clock_gate_fiford                                                  = "dis_fiford_clk_gating"                                                   ,//"dis_fiford_clk_gating" "en_fiford_clk_gating"
	parameter          hssi_8g_tx_pcs_clock_gate_sw_fifowr                                               = "dis_sw_fifowr_clk_gating"                                                ,//"dis_sw_fifowr_clk_gating" "en_sw_fifowr_clk_gating"
	parameter          hssi_8g_tx_pcs_clock_observation_in_pld_core                                      = "internal_refclk_b"                                                       ,//"internal_dw_fifo_wr_clk" "internal_fifo_rd_clk" "internal_pipe_tx_clk_out_gen3" "internal_refclk_b" "internal_sw_fifo_wr_clk" "internal_tx_clk_out_gen3"
	parameter          hssi_8g_tx_pcs_data_selection_8b10b_encoder_input                                 = "normal_data_path"                                                        ,//"gige_idle_conversion" "normal_data_path"
	parameter          hssi_8g_tx_pcs_dynamic_clk_switch                                                 = "dis_dyn_clk_switch"                                                      ,//"dis_dyn_clk_switch" "en_dyn_clk_switch"
	parameter          hssi_8g_tx_pcs_eightb_tenb_disp_ctrl                                              = "dis_disp_ctrl"                                                           ,//"dis_disp_ctrl" "en_disp_ctrl" "en_ib_disp_ctrl"
	parameter          hssi_8g_tx_pcs_eightb_tenb_encoder                                                = "dis_8b10b"                                                               ,//"dis_8b10b" "en_8b10b_ibm" "en_8b10b_sgx"
	parameter          hssi_8g_tx_pcs_force_echar                                                        = "dis_force_echar"                                                         ,//"dis_force_echar" "en_force_echar"
	parameter          hssi_8g_tx_pcs_force_kchar                                                        = "dis_force_kchar"                                                         ,//"dis_force_kchar" "en_force_kchar"
	parameter          hssi_8g_tx_pcs_gen3_tx_clk_sel                                                    = "tx_pma_clk"                                                              ,//"dis_tx_clk" "tx_pma_clk"
	parameter          hssi_8g_tx_pcs_gen3_tx_pipe_clk_sel                                               = "func_clk"                                                                ,//"dis_tx_pipe_clk" "func_clk"
	parameter          hssi_8g_tx_pcs_hip_mode                                                           = "dis_hip"                                                                 ,//"dis_hip" "en_hip"
	parameter          hssi_8g_tx_pcs_pcs_bypass                                                         = "dis_pcs_bypass"                                                          ,//"dis_pcs_bypass" "en_pcs_bypass"
	parameter          hssi_8g_tx_pcs_phase_comp_rdptr                                                   = "enable_rdptr"                                                            ,//"disable_rdptr" "enable_rdptr"
	parameter          hssi_8g_tx_pcs_phase_compensation_fifo                                            = "low_latency"                                                             ,//"low_latency" "normal_latency" "pld_ctrl_low_latency" "pld_ctrl_normal_latency" "register_fifo"
	parameter          hssi_8g_tx_pcs_phfifo_write_clk_sel                                               = "pld_tx_clk"                                                              ,//"pld_tx_clk" "tx_clk"
	parameter          hssi_8g_tx_pcs_pma_dw                                                             = "eight_bit"                                                               ,//"eight_bit" "sixteen_bit" "ten_bit" "twenty_bit"
	parameter          hssi_8g_tx_pcs_prot_mode                                                          = "basic"                                                                   ,//"basic" "cpri" "cpri_rx_tx" "disabled_prot_mode" "gige" "gige_1588" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter          hssi_8g_tx_pcs_refclk_b_clk_sel                                                   = "tx_pma_clock"                                                            ,//"refclk_dig" "tx_pma_clock"
	parameter          hssi_8g_tx_pcs_revloop_back_rm                                                    = "dis_rev_loopback_rx_rm"                                                  ,//"dis_rev_loopback_rx_rm" "en_rev_loopback_rx_rm"
	parameter          hssi_8g_tx_pcs_silicon_rev                                                        = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_8g_tx_pcs_sup_mode                                                           = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_8g_tx_pcs_symbol_swap                                                        = "dis_symbol_swap"                                                         ,//"dis_symbol_swap" "en_symbol_swap"
	parameter          hssi_8g_tx_pcs_tx_bitslip                                                         = "dis_tx_bitslip"                                                          ,//"dis_tx_bitslip" "en_tx_bitslip"
	parameter          hssi_8g_tx_pcs_tx_compliance_controlled_disparity                                 = "dis_txcompliance"                                                        ,//"dis_txcompliance" "en_txcompliance_pipe2p0" "en_txcompliance_pipe3p0"
	parameter          hssi_8g_tx_pcs_tx_fast_pld_reg                                                    = "dis_tx_fast_pld_reg"                                                     ,//"dis_tx_fast_pld_reg" "en_tx_fast_pld_reg"
	parameter          hssi_8g_tx_pcs_txclk_freerun                                                      = "dis_freerun_tx"                                                          ,//"dis_freerun_tx" "en_freerun_tx"
	parameter          hssi_8g_tx_pcs_txpcs_urst                                                         = "en_txpcs_urst"                                                           ,//"dis_txpcs_urst" "en_txpcs_urst"
	parameter          hssi_10g_rx_pcs_advanced_user_mode                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_10g_rx_pcs_align_del                                                         = "align_del_en"                                                            ,//"align_del_dis" "align_del_en"
	parameter          hssi_10g_rx_pcs_ber_bit_err_total_cnt                                             = "bit_err_total_cnt_10g"                                                   ,//"bit_err_total_cnt_10g"
	parameter          hssi_10g_rx_pcs_ber_clken                                                         = "ber_clk_dis"                                                             ,//"ber_clk_dis" "ber_clk_en"
	parameter [20:0]   hssi_10g_rx_pcs_ber_xus_timer_window                                              = 21'd19530                                                                 ,//0:2097151
	parameter          hssi_10g_rx_pcs_bitslip_mode                                                      = "bitslip_dis"                                                             ,//"bitslip_dis" "bitslip_en"
	parameter          hssi_10g_rx_pcs_blksync_bitslip_type                                              = "bitslip_comb"                                                            ,//"bitslip_comb" "bitslip_reg"
	parameter [2:0]    hssi_10g_rx_pcs_blksync_bitslip_wait_cnt                                          = 3'd1                                                                      ,//0:7
	parameter          hssi_10g_rx_pcs_blksync_bitslip_wait_type                                         = "bitslip_match"                                                           ,//"bitslip_cnt" "bitslip_match"
	parameter          hssi_10g_rx_pcs_blksync_bypass                                                    = "blksync_bypass_dis"                                                      ,//"blksync_bypass_dis" "blksync_bypass_en"
	parameter          hssi_10g_rx_pcs_blksync_clken                                                     = "blksync_clk_dis"                                                         ,//"blksync_clk_dis" "blksync_clk_en"
	parameter          hssi_10g_rx_pcs_blksync_enum_invalid_sh_cnt                                       = "enum_invalid_sh_cnt_10g"                                                 ,//"enum_invalid_sh_cnt_10g"
	parameter          hssi_10g_rx_pcs_blksync_knum_sh_cnt_postlock                                      = "knum_sh_cnt_postlock_10g"                                                ,//"knum_sh_cnt_postlock_10g"
	parameter          hssi_10g_rx_pcs_blksync_knum_sh_cnt_prelock                                       = "knum_sh_cnt_prelock_10g"                                                 ,//"knum_sh_cnt_prelock_10g"
	parameter          hssi_10g_rx_pcs_blksync_pipeln                                                    = "blksync_pipeln_dis"                                                      ,//"blksync_pipeln_dis" "blksync_pipeln_en"
	parameter          hssi_10g_rx_pcs_clr_errblk_cnt_en                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_10g_rx_pcs_control_del                                                       = "control_del_all"                                                         ,//"control_del_all" "control_del_none"
	parameter          hssi_10g_rx_pcs_crcchk_bypass                                                     = "crcchk_bypass_dis"                                                       ,//"crcchk_bypass_dis" "crcchk_bypass_en"
	parameter          hssi_10g_rx_pcs_crcchk_clken                                                      = "crcchk_clk_dis"                                                          ,//"crcchk_clk_dis" "crcchk_clk_en"
	parameter          hssi_10g_rx_pcs_crcchk_inv                                                        = "crcchk_inv_dis"                                                          ,//"crcchk_inv_dis" "crcchk_inv_en"
	parameter          hssi_10g_rx_pcs_crcchk_pipeln                                                     = "crcchk_pipeln_dis"                                                       ,//"crcchk_pipeln_dis" "crcchk_pipeln_en"
	parameter          hssi_10g_rx_pcs_crcflag_pipeln                                                    = "crcflag_pipeln_dis"                                                      ,//"crcflag_pipeln_dis" "crcflag_pipeln_en"
	parameter          hssi_10g_rx_pcs_ctrl_bit_reverse                                                  = "ctrl_bit_reverse_dis"                                                    ,//"ctrl_bit_reverse_dis" "ctrl_bit_reverse_en"
	parameter          hssi_10g_rx_pcs_data_bit_reverse                                                  = "data_bit_reverse_dis"                                                    ,//"data_bit_reverse_dis" "data_bit_reverse_en"
	parameter          hssi_10g_rx_pcs_dec64b66b_clken                                                   = "dec64b66b_clk_dis"                                                       ,//"dec64b66b_clk_dis" "dec64b66b_clk_en"
	parameter          hssi_10g_rx_pcs_dec_64b66b_rxsm_bypass                                            = "dec_64b66b_rxsm_bypass_dis"                                              ,//"dec_64b66b_rxsm_bypass_dis" "dec_64b66b_rxsm_bypass_en"
	parameter          hssi_10g_rx_pcs_descrm_bypass                                                     = "descrm_bypass_en"                                                        ,//"descrm_bypass_dis" "descrm_bypass_en"
	parameter          hssi_10g_rx_pcs_descrm_clken                                                      = "descrm_clk_dis"                                                          ,//"descrm_clk_dis" "descrm_clk_en"
	parameter          hssi_10g_rx_pcs_descrm_mode                                                       = "async"                                                                   ,//"async" "sync"
	parameter          hssi_10g_rx_pcs_descrm_pipeln                                                     = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_10g_rx_pcs_dft_clk_out_sel                                                   = "rx_master_clk"                                                           ,//"rx_64b66bdec_clk" "rx_ber_clk" "rx_blksync_clk" "rx_crcchk_clk" "rx_descrm_clk" "rx_fec_clk" "rx_frmsync_clk" "rx_gbexp_clk" "rx_master_clk" "rx_rand_clk" "rx_rdfifo_clk" "rx_wrfifo_clk"
	parameter          hssi_10g_rx_pcs_dis_signal_ok                                                     = "dis_signal_ok_dis"                                                       ,//"dis_signal_ok_dis" "dis_signal_ok_en"
	parameter          hssi_10g_rx_pcs_dispchk_bypass                                                    = "dispchk_bypass_dis"                                                      ,//"dispchk_bypass_dis" "dispchk_bypass_en"
	parameter          hssi_10g_rx_pcs_empty_flag_type                                                   = "empty_rd_side"                                                           ,//"empty_rd_side" "empty_wr_side"
	parameter          hssi_10g_rx_pcs_fast_path                                                         = "fast_path_dis"                                                           ,//"fast_path_dis" "fast_path_en"
	parameter          hssi_10g_rx_pcs_fec_clken                                                         = "fec_clk_dis"                                                             ,//"fec_clk_dis" "fec_clk_en"
	parameter          hssi_10g_rx_pcs_fec_enable                                                        = "fec_dis"                                                                 ,//"fec_dis" "fec_en"
	parameter          hssi_10g_rx_pcs_fifo_double_read                                                  = "fifo_double_read_dis"                                                    ,//"fifo_double_read_dis" "fifo_double_read_en"
	parameter          hssi_10g_rx_pcs_fifo_stop_rd                                                      = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_10g_rx_pcs_fifo_stop_wr                                                      = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_10g_rx_pcs_force_align                                                       = "force_align_dis"                                                         ,//"force_align_dis" "force_align_en"
	parameter          hssi_10g_rx_pcs_frmsync_bypass                                                    = "frmsync_bypass_dis"                                                      ,//"frmsync_bypass_dis" "frmsync_bypass_en"
	parameter          hssi_10g_rx_pcs_frmsync_clken                                                     = "frmsync_clk_dis"                                                         ,//"frmsync_clk_dis" "frmsync_clk_en"
	parameter          hssi_10g_rx_pcs_frmsync_enum_scrm                                                 = "enum_scrm_default"                                                       ,//"enum_scrm_default"
	parameter          hssi_10g_rx_pcs_frmsync_enum_sync                                                 = "enum_sync_default"                                                       ,//"enum_sync_default"
	parameter          hssi_10g_rx_pcs_frmsync_flag_type                                                 = "all_framing_words"                                                       ,//"all_framing_words" "location_only"
	parameter          hssi_10g_rx_pcs_frmsync_knum_sync                                                 = "knum_sync_default"                                                       ,//"knum_sync_default"
	parameter [15:0]   hssi_10g_rx_pcs_frmsync_mfrm_length                                               = 16'd2048                                                                  ,//0:65535
	parameter          hssi_10g_rx_pcs_frmsync_pipeln                                                    = "frmsync_pipeln_dis"                                                      ,//"frmsync_pipeln_dis" "frmsync_pipeln_en"
	parameter          hssi_10g_rx_pcs_full_flag_type                                                    = "full_wr_side"                                                            ,//"full_rd_side" "full_wr_side"
	parameter          hssi_10g_rx_pcs_gb_rx_idwidth                                                     = "idwidth_32"                                                              ,//"idwidth_32" "idwidth_40" "idwidth_64"
	parameter          hssi_10g_rx_pcs_gb_rx_odwidth                                                     = "odwidth_66"                                                              ,//"odwidth_32" "odwidth_40" "odwidth_50" "odwidth_64" "odwidth_66" "odwidth_67"
	parameter          hssi_10g_rx_pcs_gbexp_clken                                                       = "gbexp_clk_dis"                                                           ,//"gbexp_clk_dis" "gbexp_clk_en"
	parameter          hssi_10g_rx_pcs_low_latency_en                                                    = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_10g_rx_pcs_lpbk_mode                                                         = "lpbk_dis"                                                                ,//"lpbk_dis" "lpbk_en"
	parameter          hssi_10g_rx_pcs_master_clk_sel                                                    = "master_rx_pma_clk"                                                       ,//"master_refclk_dig" "master_rx_pma_clk" "master_tx_pma_clk"
	parameter          hssi_10g_rx_pcs_pempty_flag_type                                                  = "pempty_rd_side"                                                          ,//"pempty_rd_side" "pempty_wr_side"
	parameter          hssi_10g_rx_pcs_pfull_flag_type                                                   = "pfull_wr_side"                                                           ,//"pfull_rd_side" "pfull_wr_side"
	parameter          hssi_10g_rx_pcs_phcomp_rd_del                                                     = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4"
	parameter          hssi_10g_rx_pcs_pld_if_type                                                       = "fifo"                                                                    ,//"fifo" "reg"
	parameter          hssi_10g_rx_pcs_prot_mode                                                         = "disable_mode"                                                            ,//"basic_krfec_mode" "basic_mode" "disable_mode" "interlaken_mode" "sfis_mode" "teng_1588_krfec_mode" "teng_1588_mode" "teng_baser_krfec_mode" "teng_baser_mode" "teng_sdi_mode" "test_prp_krfec_mode" "test_prp_mode"
	parameter          hssi_10g_rx_pcs_rand_clken                                                        = "rand_clk_dis"                                                            ,//"rand_clk_dis" "rand_clk_en"
	parameter          hssi_10g_rx_pcs_rd_clk_sel                                                        = "rd_rx_pma_clk"                                                           ,//"rd_refclk_dig" "rd_rx_pld_clk" "rd_rx_pma_clk"
	parameter          hssi_10g_rx_pcs_rdfifo_clken                                                      = "rdfifo_clk_dis"                                                          ,//"rdfifo_clk_dis" "rdfifo_clk_en"
	parameter          hssi_10g_rx_pcs_rx_fifo_write_ctrl                                                = "blklock_stops"                                                           ,//"blklock_ignore" "blklock_stops"
	parameter          hssi_10g_rx_pcs_rx_scrm_width                                                     = "bit64"                                                                   ,//"bit64" "bit66" "bit67"
	parameter          hssi_10g_rx_pcs_rx_sh_location                                                    = "lsb"                                                                     ,//"lsb" "msb"
	parameter          hssi_10g_rx_pcs_rx_signal_ok_sel                                                  = "synchronized_ver"                                                        ,//"nonsync_ver" "synchronized_ver"
	parameter          hssi_10g_rx_pcs_rx_sm_bypass                                                      = "rx_sm_bypass_dis"                                                        ,//"rx_sm_bypass_dis" "rx_sm_bypass_en"
	parameter          hssi_10g_rx_pcs_rx_sm_hiber                                                       = "rx_sm_hiber_en"                                                          ,//"rx_sm_hiber_dis" "rx_sm_hiber_en"
	parameter          hssi_10g_rx_pcs_rx_sm_pipeln                                                      = "rx_sm_pipeln_dis"                                                        ,//"rx_sm_pipeln_dis" "rx_sm_pipeln_en"
	parameter          hssi_10g_rx_pcs_rx_testbus_sel                                                    = "crc32_chk_testbus1"                                                      ,//"ber_testbus" "blank_testbus" "blksync_testbus1" "blksync_testbus2" "crc32_chk_testbus1" "crc32_chk_testbus2" "dec64b66b_testbus" "descramble_testbus" "frame_sync_testbus1" "frame_sync_testbus2" "gearbox_exp_testbus" "random_ver_testbus" "rxsm_testbus" "rx_fifo_testbus1" "rx_fifo_testbus2"
	parameter          hssi_10g_rx_pcs_rx_true_b2b                                                       = "b2b"                                                                     ,//"b2b" "single"
	parameter          hssi_10g_rx_pcs_rxfifo_empty                                                      = "empty_default"                                                           ,//"empty_default"
	parameter          hssi_10g_rx_pcs_rxfifo_full                                                       = "full_default"                                                            ,//"full_default"
	parameter          hssi_10g_rx_pcs_rxfifo_mode                                                       = "phase_comp"                                                              ,//"clk_comp_10g" "generic_basic" "generic_interlaken" "phase_comp" "phase_comp_dv" "register_mode"
	parameter [4:0]    hssi_10g_rx_pcs_rxfifo_pempty                                                     = 5'd2                                                                      ,//0:31
	parameter [4:0]    hssi_10g_rx_pcs_rxfifo_pfull                                                      = 5'd23                                                                     ,//0:31
	parameter          hssi_10g_rx_pcs_silicon_rev                                                       = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_10g_rx_pcs_stretch_num_stages                                                = "zero_stage"                                                              ,//"one_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_10g_rx_pcs_sup_mode                                                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_10g_rx_pcs_test_mode                                                         = "test_off"                                                                ,//"pseudo_random" "test_off"
	parameter          hssi_10g_rx_pcs_wrfifo_clken                                                      = "wrfifo_clk_dis"                                                          ,//"wrfifo_clk_dis" "wrfifo_clk_en"
	parameter          hssi_10g_tx_pcs_advanced_user_mode                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_10g_tx_pcs_bitslip_en                                                        = "bitslip_dis"                                                             ,//"bitslip_dis" "bitslip_en"
	parameter          hssi_10g_tx_pcs_bonding_dft_en                                                    = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_10g_tx_pcs_bonding_dft_val                                                   = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_10g_tx_pcs_crcgen_bypass                                                     = "crcgen_bypass_dis"                                                       ,//"crcgen_bypass_dis" "crcgen_bypass_en"
	parameter          hssi_10g_tx_pcs_crcgen_clken                                                      = "crcgen_clk_dis"                                                          ,//"crcgen_clk_dis" "crcgen_clk_en"
	parameter          hssi_10g_tx_pcs_crcgen_err                                                        = "crcgen_err_dis"                                                          ,//"crcgen_err_dis" "crcgen_err_en"
	parameter          hssi_10g_tx_pcs_crcgen_inv                                                        = "crcgen_inv_dis"                                                          ,//"crcgen_inv_dis" "crcgen_inv_en"
	parameter          hssi_10g_tx_pcs_ctrl_bit_reverse                                                  = "ctrl_bit_reverse_dis"                                                    ,//"ctrl_bit_reverse_dis" "ctrl_bit_reverse_en"
	parameter          hssi_10g_tx_pcs_data_bit_reverse                                                  = "data_bit_reverse_dis"                                                    ,//"data_bit_reverse_dis" "data_bit_reverse_en"
	parameter          hssi_10g_tx_pcs_dft_clk_out_sel                                                   = "tx_master_clk"                                                           ,//"tx_64b66benc_txsm_clk" "tx_crcgen_clk" "tx_dispgen_clk" "tx_fec_clk" "tx_frmgen_clk" "tx_gbred_clk" "tx_master_clk" "tx_rdfifo_clk" "tx_scrm_clk" "tx_wrfifo_clk"
	parameter          hssi_10g_tx_pcs_dispgen_bypass                                                    = "dispgen_bypass_dis"                                                      ,//"dispgen_bypass_dis" "dispgen_bypass_en"
	parameter          hssi_10g_tx_pcs_dispgen_clken                                                     = "dispgen_clk_dis"                                                         ,//"dispgen_clk_dis" "dispgen_clk_en"
	parameter          hssi_10g_tx_pcs_dispgen_err                                                       = "dispgen_err_dis"                                                         ,//"dispgen_err_dis" "dispgen_err_en"
	parameter          hssi_10g_tx_pcs_dispgen_pipeln                                                    = "dispgen_pipeln_dis"                                                      ,//"dispgen_pipeln_dis" "dispgen_pipeln_en"
	parameter          hssi_10g_tx_pcs_distdwn_bypass_pipeln                                             = "distdwn_bypass_pipeln_dis"                                               ,//"distdwn_bypass_pipeln_dis" "distdwn_bypass_pipeln_en"
	parameter          hssi_10g_tx_pcs_distup_bypass_pipeln                                              = "distup_bypass_pipeln_dis"                                                ,//"distup_bypass_pipeln_dis" "distup_bypass_pipeln_en"
	parameter          hssi_10g_tx_pcs_dv_bond                                                           = "dv_bond_dis"                                                             ,//"dv_bond_dis" "dv_bond_en"
	parameter          hssi_10g_tx_pcs_empty_flag_type                                                   = "empty_rd_side"                                                           ,//"empty_rd_side" "empty_wr_side"
	parameter          hssi_10g_tx_pcs_enc64b66b_txsm_clken                                              = "enc64b66b_txsm_clk_dis"                                                  ,//"enc64b66b_txsm_clk_dis" "enc64b66b_txsm_clk_en"
	parameter          hssi_10g_tx_pcs_enc_64b66b_txsm_bypass                                            = "enc_64b66b_txsm_bypass_dis"                                              ,//"enc_64b66b_txsm_bypass_dis" "enc_64b66b_txsm_bypass_en"
	parameter          hssi_10g_tx_pcs_fastpath                                                          = "fastpath_dis"                                                            ,//"fastpath_dis" "fastpath_en"
	parameter          hssi_10g_tx_pcs_fec_clken                                                         = "fec_clk_dis"                                                             ,//"fec_clk_dis" "fec_clk_en"
	parameter          hssi_10g_tx_pcs_fec_enable                                                        = "fec_dis"                                                                 ,//"fec_dis" "fec_en"
	parameter          hssi_10g_tx_pcs_fifo_double_write                                                 = "fifo_double_write_dis"                                                   ,//"fifo_double_write_dis" "fifo_double_write_en"
	parameter          hssi_10g_tx_pcs_fifo_reg_fast                                                     = "fifo_reg_fast_dis"                                                       ,//"fifo_reg_fast_dis" "fifo_reg_fast_en"
	parameter          hssi_10g_tx_pcs_fifo_stop_rd                                                      = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_10g_tx_pcs_fifo_stop_wr                                                      = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_10g_tx_pcs_frmgen_burst                                                      = "frmgen_burst_dis"                                                        ,//"frmgen_burst_dis" "frmgen_burst_en"
	parameter          hssi_10g_tx_pcs_frmgen_bypass                                                     = "frmgen_bypass_dis"                                                       ,//"frmgen_bypass_dis" "frmgen_bypass_en"
	parameter          hssi_10g_tx_pcs_frmgen_clken                                                      = "frmgen_clk_dis"                                                          ,//"frmgen_clk_dis" "frmgen_clk_en"
	parameter [15:0]   hssi_10g_tx_pcs_frmgen_mfrm_length                                                = 16'd2048                                                                  ,//0:65535
	parameter          hssi_10g_tx_pcs_frmgen_pipeln                                                     = "frmgen_pipeln_dis"                                                       ,//"frmgen_pipeln_dis" "frmgen_pipeln_en"
	parameter          hssi_10g_tx_pcs_frmgen_pyld_ins                                                   = "frmgen_pyld_ins_dis"                                                     ,//"frmgen_pyld_ins_dis" "frmgen_pyld_ins_en"
	parameter          hssi_10g_tx_pcs_frmgen_wordslip                                                   = "frmgen_wordslip_dis"                                                     ,//"frmgen_wordslip_dis" "frmgen_wordslip_en"
	parameter          hssi_10g_tx_pcs_full_flag_type                                                    = "full_wr_side"                                                            ,//"full_rd_side" "full_wr_side"
	parameter          hssi_10g_tx_pcs_gb_pipeln_bypass                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_10g_tx_pcs_gb_tx_idwidth                                                     = "idwidth_50"                                                              ,//"idwidth_32" "idwidth_40" "idwidth_50" "idwidth_64" "idwidth_66" "idwidth_67"
	parameter          hssi_10g_tx_pcs_gb_tx_odwidth                                                     = "odwidth_32"                                                              ,//"odwidth_32" "odwidth_40" "odwidth_64"
	parameter          hssi_10g_tx_pcs_gbred_clken                                                       = "gbred_clk_dis"                                                           ,//"gbred_clk_dis" "gbred_clk_en"
	parameter          hssi_10g_tx_pcs_indv                                                              = "indv_en"                                                                 ,//"indv_dis" "indv_en"
	parameter          hssi_10g_tx_pcs_low_latency_en                                                    = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_10g_tx_pcs_master_clk_sel                                                    = "master_tx_pma_clk"                                                       ,//"master_refclk_dig" "master_tx_pma_clk"
	parameter          hssi_10g_tx_pcs_pempty_flag_type                                                  = "pempty_rd_side"                                                          ,//"pempty_rd_side" "pempty_wr_side"
	parameter          hssi_10g_tx_pcs_pfull_flag_type                                                   = "pfull_wr_side"                                                           ,//"pfull_rd_side" "pfull_wr_side"
	parameter          hssi_10g_tx_pcs_phcomp_rd_del                                                     = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4" "phcomp_rd_del5" "phcomp_rd_del6"
	parameter          hssi_10g_tx_pcs_pld_if_type                                                       = "fifo"                                                                    ,//"fastreg" "fifo" "reg"
	parameter          hssi_10g_tx_pcs_prot_mode                                                         = "disable_mode"                                                            ,//"basic_krfec_mode" "basic_mode" "disable_mode" "interlaken_mode" "sfis_mode" "teng_1588_krfec_mode" "teng_1588_mode" "teng_baser_krfec_mode" "teng_baser_mode" "teng_sdi_mode" "test_prp_krfec_mode" "test_prp_mode"
	parameter          hssi_10g_tx_pcs_pseudo_random                                                     = "all_0"                                                                   ,//"all_0" "two_lf"
	parameter          hssi_10g_tx_pcs_pseudo_seed_a                                                     = "288230376151711743"                                                      ,//NOVAL
	parameter          hssi_10g_tx_pcs_pseudo_seed_b                                                     = "288230376151711743"                                                      ,//NOVAL
	parameter          hssi_10g_tx_pcs_random_disp                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_10g_tx_pcs_rdfifo_clken                                                      = "rdfifo_clk_dis"                                                          ,//"rdfifo_clk_dis" "rdfifo_clk_en"
	parameter          hssi_10g_tx_pcs_scrm_bypass                                                       = "scrm_bypass_dis"                                                         ,//"scrm_bypass_dis" "scrm_bypass_en"
	parameter          hssi_10g_tx_pcs_scrm_clken                                                        = "scrm_clk_dis"                                                            ,//"scrm_clk_dis" "scrm_clk_en"
	parameter          hssi_10g_tx_pcs_scrm_mode                                                         = "async"                                                                   ,//"async" "sync"
	parameter          hssi_10g_tx_pcs_scrm_pipeln                                                       = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_10g_tx_pcs_sh_err                                                            = "sh_err_dis"                                                              ,//"sh_err_dis" "sh_err_en"
	parameter          hssi_10g_tx_pcs_silicon_rev                                                       = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_10g_tx_pcs_sop_mark                                                          = "sop_mark_dis"                                                            ,//"sop_mark_dis" "sop_mark_en"
	parameter          hssi_10g_tx_pcs_stretch_num_stages                                                = "zero_stage"                                                              ,//"one_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_10g_tx_pcs_sup_mode                                                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_10g_tx_pcs_test_mode                                                         = "test_off"                                                                ,//"pseudo_random" "test_off"
	parameter          hssi_10g_tx_pcs_tx_scrm_err                                                       = "scrm_err_dis"                                                            ,//"scrm_err_dis" "scrm_err_en"
	parameter          hssi_10g_tx_pcs_tx_scrm_width                                                     = "bit64"                                                                   ,//"bit64" "bit66" "bit67"
	parameter          hssi_10g_tx_pcs_tx_sh_location                                                    = "lsb"                                                                     ,//"lsb" "msb"
	parameter          hssi_10g_tx_pcs_tx_sm_bypass                                                      = "tx_sm_bypass_dis"                                                        ,//"tx_sm_bypass_dis" "tx_sm_bypass_en"
	parameter          hssi_10g_tx_pcs_tx_sm_pipeln                                                      = "tx_sm_pipeln_dis"                                                        ,//"tx_sm_pipeln_dis" "tx_sm_pipeln_en"
	parameter          hssi_10g_tx_pcs_tx_testbus_sel                                                    = "crc32_gen_testbus1"                                                      ,//"blank_testbus" "crc32_gen_testbus1" "crc32_gen_testbus2" "disp_gen_testbus1" "disp_gen_testbus2" "enc64b66b_testbus" "frame_gen_testbus1" "frame_gen_testbus2" "gearbox_red_testbus" "scramble_testbus" "txsm_testbus" "tx_cp_bond_testbus" "tx_fifo_testbus1" "tx_fifo_testbus2"
	parameter          hssi_10g_tx_pcs_txfifo_empty                                                      = "empty_default"                                                           ,//"empty_default"
	parameter          hssi_10g_tx_pcs_txfifo_full                                                       = "full_default"                                                            ,//"full_default"
	parameter          hssi_10g_tx_pcs_txfifo_mode                                                       = "phase_comp"                                                              ,//"basic_generic" "interlaken_generic" "phase_comp" "register_mode"
	parameter [3:0]    hssi_10g_tx_pcs_txfifo_pempty                                                     = 4'd2                                                                      ,//0:15
	parameter [3:0]    hssi_10g_tx_pcs_txfifo_pfull                                                      = 4'd11                                                                     ,//0:15
	parameter          hssi_10g_tx_pcs_wr_clk_sel                                                        = "wr_tx_pma_clk"                                                           ,//"wr_refclk_dig" "wr_tx_pld_clk" "wr_tx_pma_clk"
	parameter          hssi_10g_tx_pcs_wrfifo_clken                                                      = "wrfifo_clk_dis"                                                          ,//"wrfifo_clk_dis" "wrfifo_clk_en"
	parameter          hssi_adapt_rx_adapter_lpbk_mode                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_aib_lpbk_mode                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_align_del                                                           = "align_del_en"                                                            ,//"align_del_dis" "align_del_en"
	parameter          hssi_adapt_rx_asn_bypass_clock_gate                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_asn_bypass_pma_pcie_sw_done                                         = "disable"                                                                 ,//"disable" "enable"
	parameter [6:0]    hssi_adapt_rx_asn_wait_for_clock_gate_cnt                                         = 7'd0                                                                      ,//0:127
	parameter [6:0]    hssi_adapt_rx_asn_wait_for_dll_reset_cnt                                          = 7'd0                                                                      ,//0:127
	parameter [6:0]    hssi_adapt_rx_asn_wait_for_fifo_flush_cnt                                         = 7'd0                                                                      ,//0:127
	parameter [6:0]    hssi_adapt_rx_asn_wait_for_pma_pcie_sw_done_cnt                                   = 7'd0                                                                      ,//0:127
	parameter          hssi_adapt_rx_async_direct_hip_en                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_bonding_dft_en                                                      = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_adapt_rx_bonding_dft_val                                                     = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_adapt_rx_chnl_bonding                                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_clock_del_measure_enable                                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_control_del                                                         = "control_del_all"                                                         ,//"control_del_all" "control_del_none"
	parameter          hssi_adapt_rx_ctrl_plane_bonding                                                  = "individual"                                                              ,//"ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter          hssi_adapt_rx_datapath_mapping_mode                                               = "map_8g_1x1xfifo"                                                         ,//"map_10g_1x1xfifo_32bits" "map_10g_1x1xfifo_40bits" "map_10g_2x1xfifo_32bits" "map_10g_2x1xfifo_40bits" "map_10g_2x2x_2x1x_fifo" "map_8g_1x1xfifo" "map_8g_1x1xfifo_20bits_powersaving" "map_8g_1x1xfifo_81016bits_powersaving" "map_8g_1x1x_2x2x_2x1x_fifo" "map_8g_2x1xfifo_16bits" "map_8g_2x1xfifo_20bits" "map_8g_2x1xfifo_pmaif1620_div1" "map_fallback_sdr" "map_hip_en" "map_pld_gen12_cap" "map_pld_gen3_cap"
	parameter          hssi_adapt_rx_ds_bypass_pipeln                                                    = "ds_bypass_pipeln_dis"                                                    ,//"ds_bypass_pipeln_dis" "ds_bypass_pipeln_en"
	parameter          hssi_adapt_rx_duplex_mode                                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_dyn_clk_sw_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_fifo_double_write                                                   = "fifo_double_write_dis"                                                   ,//"fifo_double_write_dis" "fifo_double_write_en"
	parameter          hssi_adapt_rx_fifo_mode                                                           = "phase_comp"                                                              ,//"bypass_mode" "phase_comp" "register_mode"
	parameter          hssi_adapt_rx_fifo_rd_clk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_fifo_rd_clk_sel                                                     = "fifo_rd_pma_aib_rx_clk"                                                  ,//"fifo_rd_hip_aib_clk_2x" "fifo_rd_pld_pcs_rx_clk_out" "fifo_rd_pld_pcs_tx_clk_out" "fifo_rd_pma_aib_rx_clk" "fifo_rd_pma_aib_tx_clk" "fifo_rd_tx_transfer_clk"
	parameter          hssi_adapt_rx_fifo_stop_rd                                                        = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_adapt_rx_fifo_stop_wr                                                        = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_adapt_rx_fifo_width                                                          = "fifo_single_width"                                                       ,//"fifo_double_width" "fifo_single_width"
	parameter          hssi_adapt_rx_fifo_wr_clk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_fifo_wr_clk_sel                                                     = "fifo_wr_pld_pcs_rx_clk_out"                                              ,//"fifo_wr_hip_aib_clk" "fifo_wr_pld_pcs_rx_clk_out" "fifo_wr_pld_pcs_tx_clk_out" "fifo_wr_tx_transfer_clk"
	parameter          hssi_adapt_rx_force_align                                                         = "force_align_dis"                                                         ,//"force_align_dis" "force_align_en"
	parameter          hssi_adapt_rx_free_run_div_clk                                                    = "out_of_reset_sync"                                                       ,//"out_of_reset_async" "out_of_reset_sync"
	parameter          hssi_adapt_rx_fsr_pld_8g_sigdet_out_rst_val                                       = "reset_to_zero_sigdet"                                                    ,//"reset_to_one_sigdet" "reset_to_zero_sigdet"
	parameter          hssi_adapt_rx_fsr_pld_10g_rx_crc32_err_rst_val                                    = "reset_to_zero_crc32"                                                     ,//"reset_to_one_crc32" "reset_to_zero_crc32"
	parameter          hssi_adapt_rx_fsr_pld_ltd_b_rst_val                                               = "reset_to_zero_ltdb"                                                      ,//"reset_to_one_ltdb" "reset_to_zero_ltdb"
	parameter          hssi_adapt_rx_fsr_pld_ltr_rst_val                                                 = "reset_to_zero_ltr"                                                       ,//"reset_to_one_ltr" "reset_to_zero_ltr"
	parameter          hssi_adapt_rx_fsr_pld_rx_fifo_align_clr_rst_val                                   = "reset_to_zero_alignclr"                                                  ,//"reset_to_one_alignclr" "reset_to_zero_alignclr"
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_aib_hssi_pld_sclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_aib_hssi_rx_sr_clk_in_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_csr_clk_hz                                             = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_2x_hz                                      = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_hz                                         = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_pld_pcs_rx_clk_out_hz                                  = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_pld_pma_hclk_hz                                        = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_rx_hd_hssiadapt_pma_aib_rx_clk_hz                                      = 31'd0                                                                     ,//0:2147483647
	parameter          hssi_adapt_rx_hd_hssiadapt_speed_grade                                            = "dash_1"                                                                  ,//"dash_1" "dash_2" "dash_3"
	parameter          hssi_adapt_rx_hip_mode                                                            = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_adapt_rx_hrdrst_dcd_cal_done_bypass                                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_hrdrst_rx_osc_clk_scg_en                                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_hrdrst_user_ctl_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_indv                                                                = "indv_en"                                                                 ,//"indv_dis" "indv_en"
	parameter          hssi_adapt_rx_internal_clk1_sel                                                   = "pld_pma_tx_clk_out_clk1"                                                 ,//"avmm1_dcg_clk_clk1" "avmm1_scg_clk_clk1" "fpll_shared_direct_async_in_clk1" "gate_0_clk1" "pld_pma_clklow_clk1" "pld_pma_fpll_lc_clklow_clk1" "pld_pma_fpll_lc_fref_clk1" "pld_pma_fref_clk1" "pld_pma_rx_clk_out_clk1" "pld_pma_tx_clk_out_clk1" "sr_tx_osc_clkdiv2_clk1" "sr_tx_osc_clk_or_clkdiv_clk1"
	parameter          hssi_adapt_rx_internal_clk1_sel0                                                  = "pma_clks_or_txfifowr_post_ct_or_txfiford_pre_or_post_ct_mux_clk1_mux0"   ,//"pma_clks_or_txfifowr_post_ct_or_txfiford_pre_or_post_ct_mux_clk1_mux0" "txfifowr_from_aib_mux_clk1_mux0"
	parameter          hssi_adapt_rx_internal_clk1_sel1                                                  = "pma_clks_or_txfiford_pre_or_post_ct_mux_clk1_mux1"                       ,//"pma_clks_or_txfiford_pre_or_post_ct_mux_clk1_mux1" "txfifowr_post_ct_mux_clk1_mux1"
	parameter          hssi_adapt_rx_internal_clk1_sel2                                                  = "pma_clks_or_txfiford_pre_ct_mux_clk1_mux2"                               ,//"pma_clks_or_txfiford_pre_ct_mux_clk1_mux2" "txfiford_post_ct_mux_clk1_mux2"
	parameter          hssi_adapt_rx_internal_clk1_sel3                                                  = "pma_clks_clk1_mux3"                                                      ,//"pma_clks_clk1_mux3" "txfiford_pre_ct_mux_clk1_mux3"
	parameter          hssi_adapt_rx_internal_clk2_sel                                                   = "pld_pma_tx_clk_out_clk2"                                                 ,//"aib_hssi_rx_osc_clk_clk2" "avmm2_dcg_clk_clk2" "avmm2_scg_clk_clk2" "gate_0_clk2" "pld_pma_clklow_clk2" "pld_pma_coreclkin_clk2" "pld_pma_fpll_lc_clklow_clk2" "pld_pma_fpll_lc_fref_clk2" "pld_pma_fref_clk2" "pld_pma_rx_clk_out_clk2" "pld_pma_tx_clk_out_clk2" "sr_tx_osc_clkdiv4_clk2"
	parameter          hssi_adapt_rx_internal_clk2_sel0                                                  = "pma_clks_or_rxfiford_post_ct_or_rxfifowr_pre_or_post_ct_mux_clk2_mux0"   ,//"pma_clks_or_rxfiford_post_ct_or_rxfifowr_pre_or_post_ct_mux_clk2_mux0" "rxfiford_to_aib_mux_clk2_mux0"
	parameter          hssi_adapt_rx_internal_clk2_sel1                                                  = "pma_clks_or_rxfifowr_pre_or_post_ct_mux_clk2_mux1"                       ,//"pma_clks_or_rxfifowr_pre_or_post_ct_mux_clk2_mux1" "rxfiford_post_ct_mux_clk2_mux1"
	parameter          hssi_adapt_rx_internal_clk2_sel2                                                  = "pma_clks_or_rxfifowr_pre_ct_mux_clk2_mux2"                               ,//"pma_clks_or_rxfifowr_pre_ct_mux_clk2_mux2" "rxfifowr_post_ct_mux_clk2_mux2"
	parameter          hssi_adapt_rx_internal_clk2_sel3                                                  = "pma_clks_clk2_mux3"                                                      ,//"pma_clks_clk2_mux3" "rxfifowr_pre_ct_mux_clk2_mux3"
	parameter          hssi_adapt_rx_loopback_mode                                                       = "loopback_disable"                                                        ,//"adapter_dfx_loopback_enable" "adapter_func_loopback_enable" "aib_loopback_enable" "loopback_disable"
	parameter          hssi_adapt_rx_osc_clk_scg_en                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_phcomp_rd_del                                                       = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4" "phcomp_rd_del5" "phcomp_rd_del6"
	parameter          hssi_adapt_rx_pipe_mode                                                           = "disable_pipe"                                                            ,//"disable_pipe" "enable_g1" "enable_g2" "enable_g3"
	parameter          hssi_adapt_rx_pma_aib_rx_clk_expected_setting                                     = "not_used"                                                                ,//"dynamic" "not_used" "x1" "x2"
	parameter          hssi_adapt_rx_pma_coreclkin_sel                                                   = "pma_coreclkin_osc_clkdiv2_sel"                                           ,//"pma_coreclkin_osc_clkdiv2_sel" "pma_coreclkin_pld_sel"
	parameter          hssi_adapt_rx_pma_hclk_scg_en                                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_powerdown_mode                                                      = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_adapt_rx_rx_10g_krfec_rx_diag_data_status_polling_bypass                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_adp_go_b4txeq_en                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_datapath_tb_sel                                                  = "cp_bond"                                                                 ,//"aib_dcc_dll_tb" "asn_tb1" "asn_tb2" "avmm_tb" "cp_bond" "hard_reset_tb" "pcs_chnl_tb" "rx_fifo_tb1" "rx_fifo_tb2" "txeq_tb1" "txeq_tb2" "tx_chnl_tb"
	parameter          hssi_adapt_rx_rx_eq_iteration                                                     = "cycles_32"                                                               ,//"cycles_128" "cycles_32" "cycles_64" "no_limit"
	parameter          hssi_adapt_rx_rx_fifo_power_mode                                                  = "full_width_full_depth"                                                   ,//"full_width_full_depth" "full_width_half_depth" "half_width_full_depth" "half_width_half_depth"
	parameter          hssi_adapt_rx_rx_fifo_read_latency_adjust                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_fifo_write_latency_adjust                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_invalid_no_change                                                = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_osc_clock_setting                                                = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_adapt_rx_rx_parity_sel                                                       = "func_sel"                                                                ,//"func_sel" "sr_parity1_sel" "sr_parity2_sel"
	parameter          hssi_adapt_rx_rx_pcs_testbus_sel                                                  = "direct_tr_tb_bit0_sel"                                                   ,//"direct_tr_tb_bit0_sel" "direct_tr_tb_bit1_sel" "direct_tr_tb_bit2_sel" "direct_tr_tb_bit3_sel" "direct_tr_tb_bit4_sel" "direct_tr_tb_bit5_sel" "direct_tr_tb_bit6_sel" "direct_tr_tb_bit7_sel"
	parameter          hssi_adapt_rx_rx_pcspma_testbus_sel                                               = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_8g_a1a2_k1k2_flag_polling_bypass                             = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_8g_wa_boundary_polling_bypass                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_pma_pcie_sw_done_polling_bypass                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_pma_reser_in_polling_bypass                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_pma_testbus_polling_bypass                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pld_test_data_polling_bypass                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pma_rstn_cycles                                                  = "four_cycles"                                                             ,//"eight_cycles" "four_cycles"
	parameter          hssi_adapt_rx_rx_pma_rstn_en                                                      = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_post_cursor_en                                                   = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_pre_cursor_en                                                    = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_rmfflag_stretch_enable                                           = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_rmfflag_stretch_num_stages                                       = "rmfflag_zero_stage"                                                      ,//"rmfflag_one_stage" "rmfflag_three_stage" "rmfflag_two_stage" "rmfflag_zero_stage"
	parameter          hssi_adapt_rx_rx_rxeq_en                                                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_rx_txeq_en                                                          = "disable"                                                                 ,//"disable" "enable"
	parameter [7:0]    hssi_adapt_rx_rx_txeq_time                                                        = 8'd0                                                                      ,//0:255
	parameter          hssi_adapt_rx_rx_use_rxvalid_for_rxeq                                             = "rxvalid"                                                                 ,//"rxelecidle" "rxvalid"
	parameter          hssi_adapt_rx_rx_usertest_sel                                                     = "direct_tr_usertest3_sel"                                                 ,//"direct_tr_usertest0_sel" "direct_tr_usertest1_sel" "direct_tr_usertest2_sel" "direct_tr_usertest3_sel"
	parameter          hssi_adapt_rx_rxfifo_empty                                                        = "empty_default"                                                           ,//"empty_default"
	parameter          hssi_adapt_rx_rxfifo_full                                                         = "full_sw"                                                                 ,//"full_dw" "full_sw"
	parameter          hssi_adapt_rx_rxfifo_mode                                                         = "rxphase_comp"                                                            ,//"rxbypass_mode" "rxphase_comp" "rxregister_mode"
	parameter [4:0]    hssi_adapt_rx_rxfifo_pempty                                                       = 5'd2                                                                      ,//0:31
	parameter [4:0]    hssi_adapt_rx_rxfifo_pfull                                                        = 5'd24                                                                     ,//0:31
	parameter          hssi_adapt_rx_rxfiford_post_ct_sel                                                = "rxfiford_sclk_post_ct"                                                   ,//"rxfiford_post_ct" "rxfiford_sclk_post_ct"
	parameter          hssi_adapt_rx_rxfiford_to_aib_sel                                                 = "rxfiford_sclk_to_aib"                                                    ,//"rxfiford_sclk_to_aib" "rxfiford_to_aib"
	parameter          hssi_adapt_rx_rxfifowr_post_ct_sel                                                = "rxfifowr_sclk_post_ct"                                                   ,//"rxfifowr_post_ct" "rxfifowr_sclk_post_ct"
	parameter          hssi_adapt_rx_rxfifowr_pre_ct_sel                                                 = "rxfifowr_sclk_pre_ct"                                                    ,//"rxfifowr_pre_ct" "rxfifowr_sclk_pre_ct"
	parameter          hssi_adapt_rx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_adapt_rx_stretch_num_stages                                                  = "zero_stage"                                                              ,//"five_stage" "four_stage" "one_stage" "seven_stage" "six_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_adapt_rx_sup_mode                                                            = "user_mode"                                                               ,//"advanced_user_mode" "engineering_mode" "user_mode"
	parameter          hssi_adapt_rx_txeq_clk_scg_en                                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_txeq_clk_sel                                                        = "txeq_pld_pcs_rx_clk_out"                                                 ,//"txeq_hip_aib_txeq_clk_out" "txeq_pld_pcs_rx_clk_out"
	parameter          hssi_adapt_rx_txeq_mode                                                           = "eq_disable"                                                              ,//"eq_disable" "eq_legacy_mode" "eq_pipe_dir_mode"
	parameter          hssi_adapt_rx_txeq_rst_sel                                                        = "txeq_pcs_rx_pld_rst_n"                                                   ,//"txeq_hip_aib_txeq_rst_n" "txeq_pcs_rx_pld_rst_n"
	parameter          hssi_adapt_rx_txfiford_post_ct_sel                                                = "txfiford_sclk_post_ct"                                                   ,//"txfiford_post_ct" "txfiford_sclk_post_ct"
	parameter          hssi_adapt_rx_txfiford_pre_ct_sel                                                 = "txfiford_sclk_pre_ct"                                                    ,//"txfiford_pre_ct" "txfiford_sclk_pre_ct"
	parameter          hssi_adapt_rx_txfifowr_from_aib_sel                                               = "txfifowr_sclk_from_aib"                                                  ,//"txfifowr_from_aib" "txfifowr_sclk_from_aib"
	parameter          hssi_adapt_rx_txfifowr_post_ct_sel                                                = "txfifowr_sclk_post_ct"                                                   ,//"txfifowr_post_ct" "txfifowr_sclk_post_ct"
	parameter          hssi_adapt_rx_us_bypass_pipeln                                                    = "us_bypass_pipeln_dis"                                                    ,//"us_bypass_pipeln_dis" "us_bypass_pipeln_en"
	parameter          hssi_adapt_rx_word_align_enable                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_rx_word_mark                                                           = "wm_en"                                                                   ,//"wm_dis" "wm_en"
	parameter          hssi_adapt_tx_aib_clk_sel                                                         = "aib_clk_pma_aib_tx_clk"                                                  ,//"aib_clk_hip_aib_clk_2x" "aib_clk_pld_pcs_tx_clk_out" "aib_clk_pma_aib_tx_clk"
	parameter          hssi_adapt_tx_bonding_dft_en                                                      = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_adapt_tx_bonding_dft_val                                                     = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_adapt_tx_chnl_bonding                                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_ctrl_plane_bonding                                                  = "individual"                                                              ,//"ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter          hssi_adapt_tx_datapath_mapping_mode                                               = "map_8g_1x1xfifo"                                                         ,//"map_10g_1x1xfifo_32bits" "map_10g_1x1xfifo_40bits" "map_10g_2x1xfifo_32bits" "map_10g_2x1xfifo_40bits" "map_10g_2x2x_2x1x_fifo" "map_8g_1x1xfifo" "map_8g_1x1xfifo_20bits_powersaving" "map_8g_1x1xfifo_81016bits_powersaving" "map_8g_1x1x_2x2x_2x1x_fifo" "map_8g_2x1xfifo_16bits" "map_8g_2x1xfifo_20bits" "map_8g_2x1xfifo_pmaif1620_div1" "map_fallback_sdr" "map_hip_en" "map_pld_gen12_cap" "map_pld_gen3_cap"
	parameter          hssi_adapt_tx_ds_bypass_pipeln                                                    = "ds_bypass_pipeln_dis"                                                    ,//"ds_bypass_pipeln_dis" "ds_bypass_pipeln_en"
	parameter          hssi_adapt_tx_duplex_mode                                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_dv_gating                                                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_dyn_clk_sw_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_fifo_double_read                                                    = "fifo_double_read_dis"                                                    ,//"fifo_double_read_dis" "fifo_double_read_en"
	parameter          hssi_adapt_tx_fifo_mode                                                           = "phase_comp"                                                              ,//"phase_comp" "register_mode"
	parameter          hssi_adapt_tx_fifo_rd_clk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_fifo_rd_clk_sel                                                     = "fifo_rd_pld_pcs_tx_clk_out"                                              ,//"fifo_rd_hip_aib_clk" "fifo_rd_pld_pcs_tx_clk_out" "fifo_rd_tx_transfer_clk"
	parameter          hssi_adapt_tx_fifo_ready_bypass                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_fifo_stop_rd                                                        = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_adapt_tx_fifo_stop_wr                                                        = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_adapt_tx_fifo_width                                                          = "fifo_single_width"                                                       ,//"fifo_double_width" "fifo_single_width"
	parameter          hssi_adapt_tx_fifo_wr_clk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_free_run_div_clk                                                    = "out_of_reset_sync"                                                       ,//"out_of_reset_async" "out_of_reset_sync"
	parameter          hssi_adapt_tx_fsr_hip_fsr_in_bit0_rst_val                                         = "reset_to_zero_hfsrin0"                                                   ,//"reset_to_one_hfsrin0" "reset_to_zero_hfsrin0"
	parameter          hssi_adapt_tx_fsr_hip_fsr_in_bit1_rst_val                                         = "reset_to_zero_hfsrin1"                                                   ,//"reset_to_one_hfsrin1" "reset_to_zero_hfsrin1"
	parameter          hssi_adapt_tx_fsr_hip_fsr_in_bit2_rst_val                                         = "reset_to_zero_hfsrin2"                                                   ,//"reset_to_one_hfsrin2" "reset_to_zero_hfsrin2"
	parameter          hssi_adapt_tx_fsr_hip_fsr_in_bit3_rst_val                                         = "reset_to_zero_hfsrin3"                                                   ,//"reset_to_one_hfsrin3" "reset_to_zero_hfsrin3"
	parameter          hssi_adapt_tx_fsr_hip_fsr_out_bit0_rst_val                                        = "reset_to_zero_hfsrout0"                                                  ,//"reset_to_one_hfsrout0" "reset_to_zero_hfsrout0"
	parameter          hssi_adapt_tx_fsr_hip_fsr_out_bit1_rst_val                                        = "reset_to_zero_hfsrout1"                                                  ,//"reset_to_one_hfsrout1" "reset_to_zero_hfsrout1"
	parameter          hssi_adapt_tx_fsr_hip_fsr_out_bit2_rst_val                                        = "reset_to_zero_hfsrout2"                                                  ,//"reset_to_one_hfsrout2" "reset_to_zero_hfsrout2"
	parameter          hssi_adapt_tx_fsr_hip_fsr_out_bit3_rst_val                                        = "reset_to_zero_hfsrout3"                                                  ,//"reset_to_one_hfsrout3" "reset_to_zero_hfsrout3"
	parameter          hssi_adapt_tx_fsr_mask_tx_pll_rst_val                                             = "reset_to_zero_maskpll"                                                   ,//"reset_to_one_maskpll" "reset_to_zero_maskpll"
	parameter          hssi_adapt_tx_fsr_pld_txelecidle_rst_val                                          = "reset_to_zero_txelec"                                                    ,//"reset_to_one_txelec" "reset_to_zero_txelec"
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_aib_hssi_pld_sclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_sr_clk_in_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_transfer_clk_hz                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_csr_clk_hz                                             = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_2x_hz                                      = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_hz                                         = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_hip_aib_txeq_clk_out_hz                                = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_pld_pcs_tx_clk_out_hz                                  = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_pld_pma_hclk_hz                                        = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_adapt_tx_hd_hssiadapt_pma_aib_tx_clk_hz                                      = 31'd0                                                                     ,//0:2147483647
	parameter          hssi_adapt_tx_hd_hssiadapt_speed_grade                                            = "dash_1"                                                                  ,//"dash_1" "dash_2" "dash_3"
	parameter          hssi_adapt_tx_hip_mode                                                            = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_adapt_tx_hip_osc_clk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_hrdrst_align_bypass                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_hrdrst_dcd_cal_done_bypass                                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_hrdrst_dll_lock_bypass                                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_hrdrst_rx_osc_clk_scg_en                                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_hrdrst_user_ctl_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_indv                                                                = "indv_en"                                                                 ,//"indv_dis" "indv_en"
	parameter          hssi_adapt_tx_loopback_mode                                                       = "loopback_disable"                                                        ,//"adapter_dfx_loopback_enable" "adapter_func_loopback_enable" "aib_loopback_enable" "loopback_disable"
	parameter          hssi_adapt_tx_osc_clk_scg_en                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_phcomp_rd_del                                                       = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4" "phcomp_rd_del5" "phcomp_rd_del6"
	parameter          hssi_adapt_tx_pipe_mode                                                           = "disable_pipe"                                                            ,//"disable_pipe" "enable_g1" "enable_g2" "enable_g3"
	parameter          hssi_adapt_tx_pma_aib_tx_clk_expected_setting                                     = "not_used"                                                                ,//"dynamic" "not_used" "x1" "x2" "x2_not_from_chnl"
	parameter          hssi_adapt_tx_powerdown_mode                                                      = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_adapt_tx_presethint_bypass                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_qpi_sr_enable                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_rxqpi_pullup_rst_val                                                = "reset_to_zero_rxqpi"                                                     ,//"reset_to_one_rxqpi" "reset_to_zero_rxqpi"
	parameter          hssi_adapt_tx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_adapt_tx_stretch_num_stages                                                  = "zero_stage"                                                              ,//"five_stage" "four_stage" "one_stage" "seven_stage" "six_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_adapt_tx_sup_mode                                                            = "user_mode"                                                               ,//"advanced_user_mode" "engineering_mode" "user_mode"
	parameter          hssi_adapt_tx_tx_datapath_tb_sel                                                  = "cp_bond"                                                                 ,//"cp_bond" "hard_reset_tb" "tx_fifo_tb1" "tx_fifo_tb2" "wa"
	parameter          hssi_adapt_tx_tx_fastbond_wren                                                    = "wren_ds_del2_us_del2"                                                    ,//"wren_ds_del1_us_del2" "wren_ds_del2_us_del1" "wren_ds_del2_us_del2" "wren_ds_del2_us_fast" "wren_ds_fast_us_del2"
	parameter          hssi_adapt_tx_tx_fifo_power_mode                                                  = "full_width_full_depth"                                                   ,//"full_width_full_depth" "full_width_half_depth" "half_width_full_depth" "half_width_half_depth"
	parameter          hssi_adapt_tx_tx_fifo_read_latency_adjust                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_tx_fifo_write_latency_adjust                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_tx_osc_clock_setting                                                = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_adapt_tx_tx_qpi_mode_en                                                      = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_tx_tx_rev_lpbk                                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_adapt_tx_tx_usertest_sel                                                     = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_adapt_tx_txfifo_empty                                                        = "empty_default"                                                           ,//"empty_default"
	parameter          hssi_adapt_tx_txfifo_full                                                         = "full_sw"                                                                 ,//"full_dw" "full_sw"
	parameter          hssi_adapt_tx_txfifo_mode                                                         = "txphase_comp"                                                            ,//"txphase_comp" "txregister_mode"
	parameter [4:0]    hssi_adapt_tx_txfifo_pempty                                                       = 5'd2                                                                      ,//0:31
	parameter [4:0]    hssi_adapt_tx_txfifo_pfull                                                        = 5'd24                                                                     ,//0:31
	parameter          hssi_adapt_tx_txqpi_pulldn_rst_val                                                = "reset_to_zero_txqpid"                                                    ,//"reset_to_one_txqpid" "reset_to_zero_txqpid"
	parameter          hssi_adapt_tx_txqpi_pullup_rst_val                                                = "reset_to_zero_txqpiu"                                                    ,//"reset_to_one_txqpiu" "reset_to_zero_txqpiu"
	parameter          hssi_adapt_tx_word_align                                                          = "wa_en"                                                                   ,//"wa_dis" "wa_en"
	parameter          hssi_adapt_tx_word_align_enable                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_aibcr_rx_aib_datasel_gr0                                                     = "aib_datasel0_setting0"                                                   ,//"aib_datasel0_setting0"
	parameter          hssi_aibcr_rx_aib_datasel_gr1                                                     = "aib_datasel1_setting0"                                                   ,//"aib_datasel1_setting0"
	parameter          hssi_aibcr_rx_aib_datasel_gr2                                                     = "aib_datasel2_setting1"                                                   ,//"aib_datasel2_setting1"
	parameter          hssi_aibcr_rx_aib_ddrctrl_gr0                                                     = "aib_ddr0_setting1"                                                       ,//"aib_ddr0_setting0" "aib_ddr0_setting1"
	parameter          hssi_aibcr_rx_aib_ddrctrl_gr1                                                     = "aib_ddr1_setting1"                                                       ,//"aib_ddr1_setting0" "aib_ddr1_setting1"
	parameter          hssi_aibcr_rx_aib_iinasyncen                                                      = "aib_inasyncen_setting0"                                                  ,//"aib_inasyncen_setting0" "aib_inasyncen_setting2"
	parameter          hssi_aibcr_rx_aib_iinclken                                                        = "aib_inclken_setting0"                                                    ,//"aib_inclken_setting0" "aib_inclken_setting3"
	parameter          hssi_aibcr_rx_aib_outctrl_gr0                                                     = "aib_outen0_setting0"                                                     ,//"aib_outen0_setting0" "aib_outen0_setting1"
	parameter          hssi_aibcr_rx_aib_outctrl_gr1                                                     = "aib_outen1_setting0"                                                     ,//"aib_outen1_setting0" "aib_outen1_setting1"
	parameter          hssi_aibcr_rx_aib_outctrl_gr2                                                     = "aib_outen2_setting0"                                                     ,//"aib_outen2_setting0" "aib_outen2_setting1"
	parameter          hssi_aibcr_rx_aib_outctrl_gr3                                                     = "aib_outen3_setting0"                                                     ,//"aib_outen3_setting0" "aib_outen3_setting1"
	parameter          hssi_aibcr_rx_aib_outndrv_r12                                                     = "aib_ndrv12_setting1"                                                     ,//"aib_ndrv12_setting0" "aib_ndrv12_setting1" "aib_ndrv12_setting2" "aib_ndrv12_setting3"
	parameter          hssi_aibcr_rx_aib_outndrv_r56                                                     = "aib_ndrv56_setting1"                                                     ,//"aib_ndrv56_setting0" "aib_ndrv56_setting1" "aib_ndrv56_setting2" "aib_ndrv56_setting3"
	parameter          hssi_aibcr_rx_aib_outndrv_r78                                                     = "aib_ndrv78_setting1"                                                     ,//"aib_ndrv78_setting0" "aib_ndrv78_setting1" "aib_ndrv78_setting2" "aib_ndrv78_setting3"
	parameter          hssi_aibcr_rx_aib_outpdrv_r12                                                     = "aib_pdrv12_setting1"                                                     ,//"aib_pdrv12_setting0" "aib_pdrv12_setting1" "aib_pdrv12_setting2" "aib_pdrv12_setting3"
	parameter          hssi_aibcr_rx_aib_outpdrv_r56                                                     = "aib_pdrv56_setting1"                                                     ,//"aib_pdrv56_setting0" "aib_pdrv56_setting1" "aib_pdrv56_setting2" "aib_pdrv56_setting3"
	parameter          hssi_aibcr_rx_aib_outpdrv_r78                                                     = "aib_pdrv78_setting1"                                                     ,//"aib_pdrv78_setting0" "aib_pdrv78_setting1" "aib_pdrv78_setting2" "aib_pdrv78_setting3"
	parameter          hssi_aibcr_rx_aib_red_rx_shiften                                                  = "aib_red_rx_shift_disable"                                                ,//"aib_red_rx_shift_disable" "aib_red_rx_shift_enable"
	parameter          hssi_aibcr_rx_aib_rx_clkdiv                                                       = "aib_rx_clkdiv_setting1"                                                  ,//"aib_rx_clkdiv_setting0" "aib_rx_clkdiv_setting1" "aib_rx_clkdiv_setting2" "aib_rx_clkdiv_setting3" "aib_rx_clkdiv_setting4" "aib_rx_clkdiv_setting5" "aib_rx_clkdiv_setting6" "aib_rx_clkdiv_setting7"
	parameter          hssi_aibcr_rx_aib_rx_dcc_byp                                                      = "aib_rx_dcc_byp_disable"                                                  ,//"aib_rx_dcc_byp_disable" "aib_rx_dcc_byp_enable"
	parameter          hssi_aibcr_rx_aib_rx_dcc_byp_iocsr_unused                                         = "aib_rx_dcc_byp_disable_iocsr_unused"                                     ,//"aib_rx_dcc_byp_disable_iocsr_unused"
	parameter          hssi_aibcr_rx_aib_rx_dcc_cont_cal                                                 = "aib_rx_dcc_cal_single"                                                   ,//"aib_rx_dcc_cal_cont" "aib_rx_dcc_cal_single"
	parameter          hssi_aibcr_rx_aib_rx_dcc_cont_cal_iocsr_unused                                    = "aib_rx_dcc_cal_single_iocsr_unused"                                      ,//"aib_rx_dcc_cal_single_iocsr_unused"
	parameter          hssi_aibcr_rx_aib_rx_dcc_dft                                                      = "aib_rx_dcc_dft_disable"                                                  ,//"aib_rx_dcc_dft_disable"
	parameter          hssi_aibcr_rx_aib_rx_dcc_dft_sel                                                  = "aib_rx_dcc_dft_mode0"                                                    ,//"aib_rx_dcc_dft_mode0" "aib_rx_dcc_dft_mode1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_dll_entest                                               = "aib_rx_dcc_dll_test_disable"                                             ,//"aib_rx_dcc_dll_test_disable" "aib_rx_dcc_dll_test_enable"
	parameter          hssi_aibcr_rx_aib_rx_dcc_dy_ctl_static                                            = "aib_rx_dcc_dy_ctl_static_setting0"                                       ,//"aib_rx_dcc_dy_ctl_static_setting0" "aib_rx_dcc_dy_ctl_static_setting1" "aib_rx_dcc_dy_ctl_static_setting2"
	parameter          hssi_aibcr_rx_aib_rx_dcc_dy_ctlsel                                                = "aib_rx_dcc_dy_ctlsel_setting0"                                           ,//"aib_rx_dcc_dy_ctlsel_setting0" "aib_rx_dcc_dy_ctlsel_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_en                                                       = "aib_rx_dcc_enable"                                                       ,//"aib_rx_dcc_disable" "aib_rx_dcc_enable"
	parameter          hssi_aibcr_rx_aib_rx_dcc_en_iocsr_unused                                          = "aib_rx_dcc_disable_iocsr_unused"                                         ,//"aib_rx_dcc_disable_iocsr_unused"
	parameter          hssi_aibcr_rx_aib_rx_dcc_manual_dn                                                = "aib_rx_dcc_manual_dn0"                                                   ,//"aib_rx_dcc_manual_dn0"
	parameter          hssi_aibcr_rx_aib_rx_dcc_manual_up                                                = "aib_rx_dcc_manual_up0"                                                   ,//"aib_rx_dcc_manual_up0"
	parameter          hssi_aibcr_rx_aib_rx_dcc_rst_prgmnvrt                                             = "aib_rx_dcc_st_rst_prgmnvrt_setting0"                                     ,//"aib_rx_dcc_st_rst_prgmnvrt_setting0" "aib_rx_dcc_st_rst_prgmnvrt_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_core_dn_prgmnvrt                                      = "aib_rx_dcc_st_core_dn_prgmnvrt_setting0"                                 ,//"aib_rx_dcc_st_core_dn_prgmnvrt_setting0" "aib_rx_dcc_st_core_dn_prgmnvrt_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_core_up_prgmnvrt                                      = "aib_rx_dcc_st_core_up_prgmnvrt_setting0"                                 ,//"aib_rx_dcc_st_core_up_prgmnvrt_setting0" "aib_rx_dcc_st_core_up_prgmnvrt_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_core_updnen                                           = "aib_rx_dcc_st_core_updnen_setting0"                                      ,//"aib_rx_dcc_st_core_updnen_setting0" "aib_rx_dcc_st_core_updnen_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_dftmuxsel                                             = "aib_rx_dcc_st_dftmuxsel_setting0"                                        ,//"aib_rx_dcc_st_dftmuxsel_setting0" "aib_rx_dcc_st_dftmuxsel_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_dly_pst                                               = "aib_rx_dcc_st_dly_pst_setting0"                                          ,//"aib_rx_dcc_st_dly_pst_setting0" "aib_rx_dcc_st_dly_pst_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_en                                                    = "aib_rx_dcc_st_en_setting0"                                               ,//"aib_rx_dcc_st_en_setting0" "aib_rx_dcc_st_en_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_lockreq_muxsel                                        = "aib_rx_dcc_st_lockreq_muxsel_setting0"                                   ,//"aib_rx_dcc_st_lockreq_muxsel_setting0" "aib_rx_dcc_st_lockreq_muxsel_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_new_dll                                               = "aib_rx_dcc_new_dll_setting0"                                             ,//"aib_rx_dcc_new_dll_setting0" "aib_rx_dcc_new_dll_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_new_dll2                                              = "aib_rx_dcc_new_dll2_setting0"                                            ,//"aib_rx_dcc_new_dll2_setting0" "aib_rx_dcc_new_dll2_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_st_rst                                                   = "aib_rx_dcc_st_rst_setting0"                                              ,//"aib_rx_dcc_st_rst_setting0" "aib_rx_dcc_st_rst_setting1"
	parameter          hssi_aibcr_rx_aib_rx_dcc_test_clk_pll_en_n                                        = "aib_rx_dcc_test_clk_pll_en_n_disable"                                    ,//"aib_rx_dcc_test_clk_pll_en_n_disable" "aib_rx_dcc_test_clk_pll_en_n_enable"
	parameter          hssi_aibcr_rx_aib_rx_halfcode                                                     = "aib_rx_halfcode_enable"                                                  ,//"aib_rx_halfcode_disable" "aib_rx_halfcode_enable"
	parameter          hssi_aibcr_rx_aib_rx_selflock                                                     = "aib_rx_selflock_enable"                                                  ,//"aib_rx_selflock_disable" "aib_rx_selflock_enable"
	parameter          hssi_aibcr_rx_dft_hssitestip_dll_dcc_en                                           = "disable_dft"                                                             ,//"disable_dft" "enable_hssitestip_dcc" "enable_hssitestip_dll"
	parameter          hssi_aibcr_rx_op_mode                                                             = "pwr_down"                                                                ,//"dynamic_pwr_down" "pwr_down" "rx_dcc_disable" "rx_dcc_enable" "rx_dcc_enable_low_speed" "rx_dcc_manual" "rx_pma_fall_back"
	parameter          hssi_aibcr_rx_powermode_ac                                                        = "rxdatapath_low_speed_pwr"                                                ,//"rxdatapath_high_speed_pwr" "rxdatapath_low_speed_pwr"
	parameter          hssi_aibcr_rx_powermode_dc                                                        = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_aibcr_rx_redundancy_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_aibcr_rx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_aibcr_rx_sup_mode                                                            = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_aibcr_tx_aib_datasel_gr0                                                     = "aib_datasel0_setting0"                                                   ,//"aib_datasel0_setting0"
	parameter          hssi_aibcr_tx_aib_datasel_gr1                                                     = "aib_datasel1_setting1"                                                   ,//"aib_datasel1_setting1"
	parameter          hssi_aibcr_tx_aib_datasel_gr2                                                     = "aib_datasel2_setting0"                                                   ,//"aib_datasel2_setting0"
	parameter          hssi_aibcr_tx_aib_dllstr_align_clkdiv                                             = "aib_dllstr_align_clkdiv_setting0"                                        ,//"aib_dllstr_align_clkdiv_setting0" "aib_dllstr_align_clkdiv_setting1" "aib_dllstr_align_clkdiv_setting2" "aib_dllstr_align_clkdiv_setting3" "aib_dllstr_align_clkdiv_setting4" "aib_dllstr_align_clkdiv_setting5" "aib_dllstr_align_clkdiv_setting6" "aib_dllstr_align_clkdiv_setting7"
	parameter          hssi_aibcr_tx_aib_dllstr_align_dcc_dll_dft_sel                                    = "aib_dllstr_align_dcc_dll_dft_sel_setting0"                               ,//"aib_dllstr_align_dcc_dll_dft_sel_setting0" "aib_dllstr_align_dcc_dll_dft_sel_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_dft_ch_muxsel                                      = "aib_dllstr_align_dft_ch_muxsel_setting0"                                 ,//"aib_dllstr_align_dft_ch_muxsel_setting0" "aib_dllstr_align_dft_ch_muxsel_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_dly_pst                                            = "aib_dllstr_align_dly_pst_setting0"                                       ,//"aib_dllstr_align_dly_pst_setting0" "aib_dllstr_align_dly_pst_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_dy_ctl_static                                      = "aib_dllstr_align_dy_ctl_static_setting0"                                 ,//"aib_dllstr_align_dy_ctl_static_setting0" "aib_dllstr_align_dy_ctl_static_setting1" "aib_dllstr_align_dy_ctl_static_setting2"
	parameter          hssi_aibcr_tx_aib_dllstr_align_dy_ctlsel                                          = "aib_dllstr_align_dy_ctlsel_setting0"                                     ,//"aib_dllstr_align_dy_ctlsel_setting0" "aib_dllstr_align_dy_ctlsel_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_entest                                             = "aib_dllstr_align_test_disable"                                           ,//"aib_dllstr_align_test_disable" "aib_dllstr_align_test_enable"
	parameter          hssi_aibcr_tx_aib_dllstr_align_halfcode                                           = "aib_dllstr_align_halfcode_enable"                                        ,//"aib_dllstr_align_halfcode_disable" "aib_dllstr_align_halfcode_enable"
	parameter          hssi_aibcr_tx_aib_dllstr_align_selflock                                           = "aib_dllstr_align_selflock_enable"                                        ,//"aib_dllstr_align_selflock_disable" "aib_dllstr_align_selflock_enable"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_core_dn_prgmnvrt                                = "aib_dllstr_align_st_core_dn_prgmnvrt_setting0"                           ,//"aib_dllstr_align_st_core_dn_prgmnvrt_setting0" "aib_dllstr_align_st_core_dn_prgmnvrt_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_core_up_prgmnvrt                                = "aib_dllstr_align_st_core_up_prgmnvrt_setting0"                           ,//"aib_dllstr_align_st_core_up_prgmnvrt_setting0" "aib_dllstr_align_st_core_up_prgmnvrt_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_core_updnen                                     = "aib_dllstr_align_st_core_updnen_setting0"                                ,//"aib_dllstr_align_st_core_updnen_setting0" "aib_dllstr_align_st_core_updnen_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_dftmuxsel                                       = "aib_dllstr_align_st_dftmuxsel_setting0"                                  ,//"aib_dllstr_align_st_dftmuxsel_setting0" "aib_dllstr_align_st_dftmuxsel_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_en                                              = "aib_dllstr_align_st_en_setting0"                                         ,//"aib_dllstr_align_st_en_setting0" "aib_dllstr_align_st_en_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_lockreq_muxsel                                  = "aib_dllstr_align_st_lockreq_muxsel_setting0"                             ,//"aib_dllstr_align_st_lockreq_muxsel_setting0" "aib_dllstr_align_st_lockreq_muxsel_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_new_dll                                         = "aib_dllstr_align_new_dll_setting0"                                       ,//"aib_dllstr_align_new_dll_setting0" "aib_dllstr_align_new_dll_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_new_dll2                                        = "aib_dllstr_align_new_dll2_setting0"                                      ,//"aib_dllstr_align_new_dll2_setting0" "aib_dllstr_align_new_dll2_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_rst                                             = "aib_dllstr_align_st_rst_setting0"                                        ,//"aib_dllstr_align_st_rst_setting0" "aib_dllstr_align_st_rst_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_st_rst_prgmnvrt                                    = "aib_dllstr_align_st_rst_prgmnvrt_setting0"                               ,//"aib_dllstr_align_st_rst_prgmnvrt_setting0" "aib_dllstr_align_st_rst_prgmnvrt_setting1"
	parameter          hssi_aibcr_tx_aib_dllstr_align_test_clk_pll_en_n                                  = "aib_dllstr_align_test_clk_pll_en_n_disable"                              ,//"aib_dllstr_align_test_clk_pll_en_n_disable" "aib_dllstr_align_test_clk_pll_en_n_enable"
	parameter          hssi_aibcr_tx_aib_inctrl_gr0                                                      = "aib_inctrl0_setting0"                                                    ,//"aib_inctrl0_setting0" "aib_inctrl0_setting1" "aib_inctrl0_setting4"
	parameter          hssi_aibcr_tx_aib_inctrl_gr1                                                      = "aib_inctrl1_setting0"                                                    ,//"aib_inctrl1_setting0" "aib_inctrl1_setting3"
	parameter          hssi_aibcr_tx_aib_inctrl_gr2                                                      = "aib_inctrl2_setting0"                                                    ,//"aib_inctrl2_setting0" "aib_inctrl2_setting2"
	parameter          hssi_aibcr_tx_aib_inctrl_gr3                                                      = "aib_inctrl3_setting0"                                                    ,//"aib_inctrl3_setting0" "aib_inctrl3_setting2"
	parameter          hssi_aibcr_tx_aib_outctrl_gr0                                                     = "aib_outen0_setting0"                                                     ,//"aib_outen0_setting0" "aib_outen0_setting1"
	parameter          hssi_aibcr_tx_aib_outctrl_gr1                                                     = "aib_outen1_setting0"                                                     ,//"aib_outen1_setting0" "aib_outen1_setting1"
	parameter          hssi_aibcr_tx_aib_outctrl_gr2                                                     = "aib_outen2_setting0"                                                     ,//"aib_outen2_setting0" "aib_outen2_setting1"
	parameter          hssi_aibcr_tx_aib_outndrv_r12                                                     = "aib_ndrv12_setting1"                                                     ,//"aib_ndrv12_setting0" "aib_ndrv12_setting1" "aib_ndrv12_setting2" "aib_ndrv12_setting3"
	parameter          hssi_aibcr_tx_aib_outndrv_r34                                                     = "aib_ndrv34_setting1"                                                     ,//"aib_ndrv34_setting0" "aib_ndrv34_setting1" "aib_ndrv34_setting2" "aib_ndrv34_setting3"
	parameter          hssi_aibcr_tx_aib_outndrv_r56                                                     = "aib_ndrv56_setting1"                                                     ,//"aib_ndrv56_setting0" "aib_ndrv56_setting1" "aib_ndrv56_setting2" "aib_ndrv56_setting3"
	parameter          hssi_aibcr_tx_aib_outndrv_r78                                                     = "aib_ndrv78_setting1"                                                     ,//"aib_ndrv78_setting0" "aib_ndrv78_setting1" "aib_ndrv78_setting2" "aib_ndrv78_setting3"
	parameter          hssi_aibcr_tx_aib_outpdrv_r12                                                     = "aib_pdrv12_setting1"                                                     ,//"aib_pdrv12_setting0" "aib_pdrv12_setting1" "aib_pdrv12_setting2" "aib_pdrv12_setting3"
	parameter          hssi_aibcr_tx_aib_outpdrv_r34                                                     = "aib_pdrv34_setting1"                                                     ,//"aib_pdrv34_setting0" "aib_pdrv34_setting1" "aib_pdrv34_setting2" "aib_pdrv34_setting3"
	parameter          hssi_aibcr_tx_aib_outpdrv_r56                                                     = "aib_pdrv56_setting1"                                                     ,//"aib_pdrv56_setting0" "aib_pdrv56_setting1" "aib_pdrv56_setting2" "aib_pdrv56_setting3"
	parameter          hssi_aibcr_tx_aib_outpdrv_r78                                                     = "aib_pdrv78_setting1"                                                     ,//"aib_pdrv78_setting0" "aib_pdrv78_setting1" "aib_pdrv78_setting2" "aib_pdrv78_setting3"
	parameter          hssi_aibcr_tx_aib_red_dirclkn_shiften                                             = "aib_red_dirclkn_shift_disable"                                           ,//"aib_red_dirclkn_shift_disable" "aib_red_dirclkn_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_dirclkp_shiften                                             = "aib_red_dirclkp_shift_disable"                                           ,//"aib_red_dirclkp_shift_disable" "aib_red_dirclkp_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_drx_shiften                                                 = "aib_red_drx_shift_disable"                                               ,//"aib_red_drx_shift_disable" "aib_red_drx_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_dtx_shiften                                                 = "aib_red_dtx_shift_disable"                                               ,//"aib_red_dtx_shift_disable" "aib_red_dtx_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_pinp_shiften                                                = "aib_red_pinp_shift_disable"                                              ,//"aib_red_pinp_shift_disable" "aib_red_pinp_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_rx_shiften                                                  = "aib_red_rx_shift_disable"                                                ,//"aib_red_rx_shift_disable" "aib_red_rx_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_tx_shiften                                                  = "aib_red_tx_shift_disable"                                                ,//"aib_red_tx_shift_disable" "aib_red_tx_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_txferclkout_shiften                                         = "aib_red_txferclkout_shift_disable"                                       ,//"aib_red_txferclkout_shift_disable" "aib_red_txferclkout_shift_enable"
	parameter          hssi_aibcr_tx_aib_red_txferclkoutn_shiften                                        = "aib_red_txferclkoutn_shift_disable"                                      ,//"aib_red_txferclkoutn_shift_disable" "aib_red_txferclkoutn_shift_enable"
	parameter          hssi_aibcr_tx_dfd_dll_dcc_en                                                      = "disable_dfd"                                                             ,//"disable_dfd" "enable_dfd_dcc" "enable_dfd_dll"
	parameter          hssi_aibcr_tx_dft_hssitestip_dll_dcc_en                                           = "disable_dft"                                                             ,//"disable_dft" "enable_hssitestip_dcc" "enable_hssitestip_dll"
	parameter          hssi_aibcr_tx_op_mode                                                             = "pwr_down"                                                                ,//"dynamic_pwr_down" "pwr_down" "tx_dll_disable" "tx_dll_enable" "tx_pma_fall_back"
	parameter          hssi_aibcr_tx_powermode_ac                                                        = "txdatapath_low_speed_pwr"                                                ,//"txdatapath_high_speed_pwr" "txdatapath_low_speed_pwr"
	parameter          hssi_aibcr_tx_powermode_dc                                                        = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_aibcr_tx_redundancy_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_aibcr_tx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_aibcr_tx_sup_mode                                                            = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_aibnd_rx_aib_datasel_gr0                                                     = "aib_datasel0_setting0"                                                   ,//"aib_datasel0_setting0"
	parameter          hssi_aibnd_rx_aib_datasel_gr1                                                     = "aib_datasel1_setting1"                                                   ,//"aib_datasel1_setting1"
	parameter          hssi_aibnd_rx_aib_datasel_gr2                                                     = "aib_datasel2_setting1"                                                   ,//"aib_datasel2_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_clkdiv                                             = "aib_dllstr_align_clkdiv_setting0"                                        ,//"aib_dllstr_align_clkdiv_setting0" "aib_dllstr_align_clkdiv_setting1" "aib_dllstr_align_clkdiv_setting2" "aib_dllstr_align_clkdiv_setting3" "aib_dllstr_align_clkdiv_setting4" "aib_dllstr_align_clkdiv_setting5" "aib_dllstr_align_clkdiv_setting6" "aib_dllstr_align_clkdiv_setting7"
	parameter          hssi_aibnd_rx_aib_dllstr_align_dly_pst                                            = "aib_dllstr_align_dly_pst_setting0"                                       ,//"aib_dllstr_align_dly_pst_setting0" "aib_dllstr_align_dly_pst_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_dy_ctl_static                                      = "aib_dllstr_align_dy_ctl_static_setting0"                                 ,//"aib_dllstr_align_dy_ctl_static_setting0" "aib_dllstr_align_dy_ctl_static_setting1" "aib_dllstr_align_dy_ctl_static_setting2"
	parameter          hssi_aibnd_rx_aib_dllstr_align_dy_ctlsel                                          = "aib_dllstr_align_dy_ctlsel_setting0"                                     ,//"aib_dllstr_align_dy_ctlsel_setting0" "aib_dllstr_align_dy_ctlsel_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_entest                                             = "aib_dllstr_align_test_disable"                                           ,//"aib_dllstr_align_test_disable" "aib_dllstr_align_test_enable"
	parameter          hssi_aibnd_rx_aib_dllstr_align_halfcode                                           = "aib_dllstr_align_halfcode_enable"                                        ,//"aib_dllstr_align_halfcode_disable" "aib_dllstr_align_halfcode_enable"
	parameter          hssi_aibnd_rx_aib_dllstr_align_selflock                                           = "aib_dllstr_align_selflock_enable"                                        ,//"aib_dllstr_align_selflock_disable" "aib_dllstr_align_selflock_enable"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_core_dn_prgmnvrt                                = "aib_dllstr_align_st_core_dn_prgmnvrt_setting0"                           ,//"aib_dllstr_align_st_core_dn_prgmnvrt_setting0" "aib_dllstr_align_st_core_dn_prgmnvrt_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_core_up_prgmnvrt                                = "aib_dllstr_align_st_core_up_prgmnvrt_setting0"                           ,//"aib_dllstr_align_st_core_up_prgmnvrt_setting0" "aib_dllstr_align_st_core_up_prgmnvrt_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_core_updnen                                     = "aib_dllstr_align_st_core_updnen_setting0"                                ,//"aib_dllstr_align_st_core_updnen_setting0" "aib_dllstr_align_st_core_updnen_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_dftmuxsel                                       = "aib_dllstr_align_st_dftmuxsel_setting0"                                  ,//"aib_dllstr_align_st_dftmuxsel_setting0" "aib_dllstr_align_st_dftmuxsel_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_en                                              = "aib_dllstr_align_st_en_setting0"                                         ,//"aib_dllstr_align_st_en_setting0" "aib_dllstr_align_st_en_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_hps_ctrl_en                                     = "aib_dllstr_align_hps_ctrl_en_setting0"                                   ,//"aib_dllstr_align_hps_ctrl_en_setting0" "aib_dllstr_align_hps_ctrl_en_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_lockreq_muxsel                                  = "aib_dllstr_align_st_lockreq_muxsel_setting0"                             ,//"aib_dllstr_align_st_lockreq_muxsel_setting0" "aib_dllstr_align_st_lockreq_muxsel_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_new_dll                                         = "aib_dllstr_align_new_dll_setting0"                                       ,//"aib_dllstr_align_new_dll_setting0" "aib_dllstr_align_new_dll_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_rst                                             = "aib_dllstr_align_st_rst_setting0"                                        ,//"aib_dllstr_align_st_rst_setting0" "aib_dllstr_align_st_rst_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_st_rst_prgmnvrt                                    = "aib_dllstr_align_st_rst_prgmnvrt_setting0"                               ,//"aib_dllstr_align_st_rst_prgmnvrt_setting0" "aib_dllstr_align_st_rst_prgmnvrt_setting1"
	parameter          hssi_aibnd_rx_aib_dllstr_align_test_clk_pll_en_n                                  = "aib_dllstr_align_test_clk_pll_en_n_disable"                              ,//"aib_dllstr_align_test_clk_pll_en_n_disable" "aib_dllstr_align_test_clk_pll_en_n_enable"
	parameter          hssi_aibnd_rx_aib_inctrl_gr0                                                      = "aib_inctrl0_setting0"                                                    ,//"aib_inctrl0_setting0" "aib_inctrl0_setting1" "aib_inctrl0_setting4"
	parameter          hssi_aibnd_rx_aib_inctrl_gr1                                                      = "aib_inctrl1_setting0"                                                    ,//"aib_inctrl1_setting0" "aib_inctrl1_setting3"
	parameter          hssi_aibnd_rx_aib_inctrl_gr2                                                      = "aib_inctrl2_setting0"                                                    ,//"aib_inctrl2_setting0" "aib_inctrl2_setting2"
	parameter          hssi_aibnd_rx_aib_inctrl_gr3                                                      = "aib_inctrl3_setting0"                                                    ,//"aib_inctrl3_setting0" "aib_inctrl3_setting3"
	parameter          hssi_aibnd_rx_aib_outctrl_gr0                                                     = "aib_outen0_setting0"                                                     ,//"aib_outen0_setting0" "aib_outen0_setting1"
	parameter          hssi_aibnd_rx_aib_outctrl_gr1                                                     = "aib_outen1_setting0"                                                     ,//"aib_outen1_setting0" "aib_outen1_setting1"
	parameter          hssi_aibnd_rx_aib_outctrl_gr2                                                     = "aib_outen2_setting0"                                                     ,//"aib_outen2_setting0" "aib_outen2_setting1"
	parameter          hssi_aibnd_rx_aib_outndrv_r12                                                     = "aib_ndrv12_setting1"                                                     ,//"aib_ndrv12_setting0" "aib_ndrv12_setting1" "aib_ndrv12_setting2" "aib_ndrv12_setting3"
	parameter          hssi_aibnd_rx_aib_outndrv_r34                                                     = "aib_ndrv34_setting1"                                                     ,//"aib_ndrv34_setting0" "aib_ndrv34_setting1" "aib_ndrv34_setting2" "aib_ndrv34_setting3"
	parameter          hssi_aibnd_rx_aib_outndrv_r56                                                     = "aib_ndrv56_setting1"                                                     ,//"aib_ndrv56_setting0" "aib_ndrv56_setting1" "aib_ndrv56_setting2" "aib_ndrv56_setting3"
	parameter          hssi_aibnd_rx_aib_outndrv_r78                                                     = "aib_ndrv78_setting1"                                                     ,//"aib_ndrv78_setting0" "aib_ndrv78_setting1" "aib_ndrv78_setting2" "aib_ndrv78_setting3"
	parameter          hssi_aibnd_rx_aib_outpdrv_r12                                                     = "aib_pdrv12_setting1"                                                     ,//"aib_pdrv12_setting0" "aib_pdrv12_setting1" "aib_pdrv12_setting2" "aib_pdrv12_setting3"
	parameter          hssi_aibnd_rx_aib_outpdrv_r34                                                     = "aib_pdrv34_setting1"                                                     ,//"aib_pdrv34_setting0" "aib_pdrv34_setting1" "aib_pdrv34_setting2" "aib_pdrv34_setting3"
	parameter          hssi_aibnd_rx_aib_outpdrv_r56                                                     = "aib_pdrv56_setting1"                                                     ,//"aib_pdrv56_setting0" "aib_pdrv56_setting1" "aib_pdrv56_setting2" "aib_pdrv56_setting3"
	parameter          hssi_aibnd_rx_aib_outpdrv_r78                                                     = "aib_pdrv78_setting1"                                                     ,//"aib_pdrv78_setting0" "aib_pdrv78_setting1" "aib_pdrv78_setting2" "aib_pdrv78_setting3"
	parameter          hssi_aibnd_rx_aib_red_shift_en                                                    = "aib_red_shift_disable"                                                   ,//"aib_red_shift_disable" "aib_red_shift_enable"
	parameter          hssi_aibnd_rx_dft_hssitestip_dll_dcc_en                                           = "disable_dft"                                                             ,//"disable_dft" "enable_hssitestip_dcc" "enable_hssitestip_dll"
	parameter          hssi_aibnd_rx_op_mode                                                             = "pwr_down"                                                                ,//"dynamic_pwr_down" "pwr_down" "rx_dll_disable" "rx_dll_enable" "rx_pma_fall_back"
	parameter          hssi_aibnd_rx_powermode_ac                                                        = "rxdatapath_low_speed_pwr"                                                ,//"rxdatapath_high_speed_pwr" "rxdatapath_low_speed_pwr"
	parameter          hssi_aibnd_rx_powermode_dc                                                        = "rxdatapath_powerdown"                                                    ,//"rxdatapath_powerdown" "rxdatapath_powerup"
	parameter          hssi_aibnd_rx_redundancy_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_aibnd_rx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_aibnd_rx_sup_mode                                                            = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_aibnd_tx_aib_datasel_gr0                                                     = "aib_datasel0_setting0"                                                   ,//"aib_datasel0_setting0"
	parameter          hssi_aibnd_tx_aib_datasel_gr1                                                     = "aib_datasel1_setting0"                                                   ,//"aib_datasel1_setting0"
	parameter          hssi_aibnd_tx_aib_datasel_gr2                                                     = "aib_datasel2_setting1"                                                   ,//"aib_datasel2_setting1"
	parameter          hssi_aibnd_tx_aib_datasel_gr3                                                     = "aib_datasel3_setting1"                                                   ,//"aib_datasel3_setting1"
	parameter          hssi_aibnd_tx_aib_ddrctrl_gr0                                                     = "aib_ddr0_setting1"                                                       ,//"aib_ddr0_setting0" "aib_ddr0_setting1"
	parameter          hssi_aibnd_tx_aib_iinasyncen                                                      = "aib_inasyncen_setting0"                                                  ,//"aib_inasyncen_setting0" "aib_inasyncen_setting2"
	parameter          hssi_aibnd_tx_aib_iinclken                                                        = "aib_inclken_setting0"                                                    ,//"aib_inclken_setting0" "aib_inclken_setting3"
	parameter          hssi_aibnd_tx_aib_outctrl_gr0                                                     = "aib_outen0_setting0"                                                     ,//"aib_outen0_setting0" "aib_outen0_setting1"
	parameter          hssi_aibnd_tx_aib_outctrl_gr1                                                     = "aib_outen1_setting0"                                                     ,//"aib_outen1_setting0" "aib_outen1_setting1"
	parameter          hssi_aibnd_tx_aib_outctrl_gr2                                                     = "aib_outen2_setting0"                                                     ,//"aib_outen2_setting0" "aib_outen2_setting1"
	parameter          hssi_aibnd_tx_aib_outctrl_gr3                                                     = "aib_outen3_setting0"                                                     ,//"aib_outen3_setting0" "aib_outen3_setting1"
	parameter          hssi_aibnd_tx_aib_outndrv_r34                                                     = "aib_ndrv34_setting1"                                                     ,//"aib_ndrv34_setting0" "aib_ndrv34_setting1" "aib_ndrv34_setting2" "aib_ndrv34_setting3"
	parameter          hssi_aibnd_tx_aib_outndrv_r56                                                     = "aib_ndrv56_setting1"                                                     ,//"aib_ndrv56_setting0" "aib_ndrv56_setting1" "aib_ndrv56_setting2" "aib_ndrv56_setting3"
	parameter          hssi_aibnd_tx_aib_outpdrv_r34                                                     = "aib_pdrv34_setting1"                                                     ,//"aib_pdrv34_setting0" "aib_pdrv34_setting1" "aib_pdrv34_setting2" "aib_pdrv34_setting3"
	parameter          hssi_aibnd_tx_aib_outpdrv_r56                                                     = "aib_pdrv56_setting1"                                                     ,//"aib_pdrv56_setting0" "aib_pdrv56_setting1" "aib_pdrv56_setting2" "aib_pdrv56_setting3"
	parameter          hssi_aibnd_tx_aib_red_dirclkn_shiften                                             = "aib_red_dirclkn_shift_disable"                                           ,//"aib_red_dirclkn_shift_disable" "aib_red_dirclkn_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_dirclkp_shiften                                             = "aib_red_dirclkp_shift_disable"                                           ,//"aib_red_dirclkp_shift_disable" "aib_red_dirclkp_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_drx_shiften                                                 = "aib_red_drx_shift_disable"                                               ,//"aib_red_drx_shift_disable" "aib_red_drx_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_dtx_shiften                                                 = "aib_red_dtx_shift_disable"                                               ,//"aib_red_dtx_shift_disable" "aib_red_dtx_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_pout_shiften                                                = "aib_red_pout_shift_disable"                                              ,//"aib_red_pout_shift_disable" "aib_red_pout_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_rx_shiften                                                  = "aib_red_rx_shift_disable"                                                ,//"aib_red_rx_shift_disable" "aib_red_rx_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_tx_shiften                                                  = "aib_red_tx_shift_disable"                                                ,//"aib_red_tx_shift_disable" "aib_red_tx_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_txferclkout_shiften                                         = "aib_red_txferclkout_shift_disable"                                       ,//"aib_red_txferclkout_shift_disable" "aib_red_txferclkout_shift_enable"
	parameter          hssi_aibnd_tx_aib_red_txferclkoutn_shiften                                        = "aib_red_txferclkoutn_shift_disable"                                      ,//"aib_red_txferclkoutn_shift_disable" "aib_red_txferclkoutn_shift_enable"
	parameter          hssi_aibnd_tx_aib_tx_clkdiv                                                       = "aib_tx_clkdiv_setting1"                                                  ,//"aib_tx_clkdiv_setting0" "aib_tx_clkdiv_setting1" "aib_tx_clkdiv_setting2" "aib_tx_clkdiv_setting3" "aib_tx_clkdiv_setting4" "aib_tx_clkdiv_setting5" "aib_tx_clkdiv_setting6" "aib_tx_clkdiv_setting7"
	parameter          hssi_aibnd_tx_aib_tx_dcc_byp                                                      = "aib_tx_dcc_byp_disable"                                                  ,//"aib_tx_dcc_byp_disable" "aib_tx_dcc_byp_enable"
	parameter          hssi_aibnd_tx_aib_tx_dcc_byp_iocsr_unused                                         = "aib_tx_dcc_byp_disable_iocsr_unused"                                     ,//"aib_tx_dcc_byp_disable_iocsr_unused"
	parameter          hssi_aibnd_tx_aib_tx_dcc_cont_cal                                                 = "aib_tx_dcc_cal_cont"                                                     ,//"aib_tx_dcc_cal_cont" "aib_tx_dcc_cal_single"
	parameter          hssi_aibnd_tx_aib_tx_dcc_cont_cal_iocsr_unused                                    = "aib_tx_dcc_cal_single_iocsr_unused"                                      ,//"aib_tx_dcc_cal_single_iocsr_unused"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dft                                                      = "aib_tx_dcc_dft_disable"                                                  ,//"aib_tx_dcc_dft_disable"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dft_sel                                                  = "aib_tx_dcc_dft_mode0"                                                    ,//"aib_tx_dcc_dft_mode0" "aib_tx_dcc_dft_mode1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dll_dft_sel                                              = "aib_tx_dcc_dll_dft_sel_setting0"                                         ,//"aib_tx_dcc_dll_dft_sel_setting0" "aib_tx_dcc_dll_dft_sel_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dll_entest                                               = "aib_tx_dcc_dll_test_disable"                                             ,//"aib_tx_dcc_dll_test_disable" "aib_tx_dcc_dll_test_enable"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dy_ctl_static                                            = "aib_tx_dcc_dy_ctl_static_setting0"                                       ,//"aib_tx_dcc_dy_ctl_static_setting0" "aib_tx_dcc_dy_ctl_static_setting1" "aib_tx_dcc_dy_ctl_static_setting2"
	parameter          hssi_aibnd_tx_aib_tx_dcc_dy_ctlsel                                                = "aib_tx_dcc_dy_ctlsel_setting0"                                           ,//"aib_tx_dcc_dy_ctlsel_setting0" "aib_tx_dcc_dy_ctlsel_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_en                                                       = "aib_tx_dcc_enable"                                                       ,//"aib_tx_dcc_disable" "aib_tx_dcc_enable"
	parameter          hssi_aibnd_tx_aib_tx_dcc_en_iocsr_unused                                          = "aib_tx_dcc_disable_iocsr_unused"                                         ,//"aib_tx_dcc_disable_iocsr_unused"
	parameter          hssi_aibnd_tx_aib_tx_dcc_manual_dn                                                = "aib_tx_dcc_manual_dn0"                                                   ,//"aib_tx_dcc_manual_dn0"
	parameter          hssi_aibnd_tx_aib_tx_dcc_manual_up                                                = "aib_tx_dcc_manual_up0"                                                   ,//"aib_tx_dcc_manual_up0"
	parameter          hssi_aibnd_tx_aib_tx_dcc_rst_prgmnvrt                                             = "aib_tx_dcc_st_rst_prgmnvrt_setting0"                                     ,//"aib_tx_dcc_st_rst_prgmnvrt_setting0" "aib_tx_dcc_st_rst_prgmnvrt_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_core_dn_prgmnvrt                                      = "aib_tx_dcc_st_core_dn_prgmnvrt_setting0"                                 ,//"aib_tx_dcc_st_core_dn_prgmnvrt_setting0" "aib_tx_dcc_st_core_dn_prgmnvrt_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_core_up_prgmnvrt                                      = "aib_tx_dcc_st_core_up_prgmnvrt_setting0"                                 ,//"aib_tx_dcc_st_core_up_prgmnvrt_setting0" "aib_tx_dcc_st_core_up_prgmnvrt_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_core_updnen                                           = "aib_tx_dcc_st_core_updnen_setting0"                                      ,//"aib_tx_dcc_st_core_updnen_setting0" "aib_tx_dcc_st_core_updnen_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_dftmuxsel                                             = "aib_tx_dcc_st_dftmuxsel_setting0"                                        ,//"aib_tx_dcc_st_dftmuxsel_setting0" "aib_tx_dcc_st_dftmuxsel_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_dly_pst                                               = "aib_tx_dcc_st_dly_pst_setting0"                                          ,//"aib_tx_dcc_st_dly_pst_setting0" "aib_tx_dcc_st_dly_pst_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_en                                                    = "aib_tx_dcc_st_en_setting0"                                               ,//"aib_tx_dcc_st_en_setting0" "aib_tx_dcc_st_en_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_hps_ctrl_en                                           = "aib_tx_dcc_hps_ctrl_en_setting0"                                         ,//"aib_tx_dcc_hps_ctrl_en_setting0" "aib_tx_dcc_hps_ctrl_en_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_lockreq_muxsel                                        = "aib_tx_dcc_st_lockreq_muxsel_setting0"                                   ,//"aib_tx_dcc_st_lockreq_muxsel_setting0" "aib_tx_dcc_st_lockreq_muxsel_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_new_dll                                               = "aib_tx_dcc_new_dll_setting0"                                             ,//"aib_tx_dcc_new_dll_setting0" "aib_tx_dcc_new_dll_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_st_rst                                                   = "aib_tx_dcc_st_rst_setting0"                                              ,//"aib_tx_dcc_st_rst_setting0" "aib_tx_dcc_st_rst_setting1"
	parameter          hssi_aibnd_tx_aib_tx_dcc_test_clk_pll_en_n                                        = "aib_tx_dcc_test_clk_pll_en_n_disable"                                    ,//"aib_tx_dcc_test_clk_pll_en_n_disable" "aib_tx_dcc_test_clk_pll_en_n_enable"
	parameter          hssi_aibnd_tx_aib_tx_halfcode                                                     = "aib_tx_halfcode_enable"                                                  ,//"aib_tx_halfcode_disable" "aib_tx_halfcode_enable"
	parameter          hssi_aibnd_tx_aib_tx_selflock                                                     = "aib_tx_selflock_enable"                                                  ,//"aib_tx_selflock_disable" "aib_tx_selflock_enable"
	parameter          hssi_aibnd_tx_dfd_dll_dcc_en                                                      = "disable_dfd"                                                             ,//"disable_dfd" "enable_dfd_dcc" "enable_dfd_dll"
	parameter          hssi_aibnd_tx_dft_hssitestip_dll_dcc_en                                           = "disable_dft"                                                             ,//"disable_dft" "enable_hssitestip_dcc" "enable_hssitestip_dll"
	parameter          hssi_aibnd_tx_op_mode                                                             = "tx_dcc_enable"                                                           ,//"dynamic_pwr_down" "pwr_down" "tx_dcc_disable" "tx_dcc_enable" "tx_dcc_enable_low_speed" "tx_dcc_manual" "tx_pma_fall_back"
	parameter          hssi_aibnd_tx_powermode_ac                                                        = "txdatapath_low_speed_pwr"                                                ,//"txdatapath_high_speed_pwr" "txdatapath_low_speed_pwr"
	parameter          hssi_aibnd_tx_powermode_dc                                                        = "txdatapath_powerdown"                                                    ,//"txdatapath_powerdown" "txdatapath_powerup"
	parameter          hssi_aibnd_tx_redundancy_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_aibnd_tx_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_aibnd_tx_sup_mode                                                            = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_avmm1_if_calibration_type                                                    = "one_time"                                                                ,//"continuous" "one_time"
	parameter          hssi_avmm1_if_hssiadapt_avmm_osc_clock_setting                                    = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_avmm1_if_hssiadapt_avmm_testbus_sel                                          = "avmm1_transfer_testbus"                                                  ,//"avmm1_cmn_intf_testbus" "avmm1_transfer_testbus" "avmm2_transfer_testbus" "avmm_clk_dcg_testbus"
	parameter          hssi_avmm1_if_hssiadapt_hip_mode                                                  = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_avmm1_if_hssiadapt_nfhssi_calibratio_feature_en                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_avmm1_if_hssiadapt_read_blocking_enable                                      = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_avmm1_if_hssiadapt_uc_blocking_enable                                        = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_avmm1_if_pcs_arbiter_ctrl                                                    = "avmm1_arbiter_uc_sel"                                                    ,//"avmm1_arbiter_pld_sel" "avmm1_arbiter_uc_sel"
	parameter          hssi_avmm1_if_pcs_cal_done                                                        = "avmm1_cal_done_assert"                                                   ,//"avmm1_cal_done_assert" "avmm1_cal_done_deassert"
	parameter [4:0]    hssi_avmm1_if_pcs_cal_reserved                                                    = 5'd0                                                                      ,//0:31
	parameter          hssi_avmm1_if_pcs_calibration_feature_en                                          = "avmm1_pcs_calibration_dis"                                               ,//"avmm1_pcs_calibration_dis" "avmm1_pcs_calibration_en"
	parameter          hssi_avmm1_if_pcs_hip_cal_en                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_avmm1_if_pldadapt_avmm_osc_clock_setting                                     = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_avmm1_if_pldadapt_avmm_testbus_sel                                           = "avmm1_transfer_testbus"                                                  ,//"avmm1_cmn_intf_testbus" "avmm1_transfer_testbus" "avmm2_transfer_testbus" "unused_testbus"
	parameter          hssi_avmm1_if_pldadapt_gate_dis                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_avmm1_if_pldadapt_hip_mode                                                   = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_avmm1_if_pldadapt_nfhssi_calibratio_feature_en                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_avmm1_if_pldadapt_read_blocking_enable                                       = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_avmm1_if_pldadapt_uc_blocking_enable                                         = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_avmm1_if_silicon_rev                                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm4cr3a" "14nm5" "14nm5cr2" "14nm5bcr2ea" "14nm5cr3a"
	parameter          hssi_common_pcs_pma_interface_asn_clk_enable                                      = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_asn_enable                                          = "dis_asn"                                                                 ,//"dis_asn" "en_asn"
	parameter          hssi_common_pcs_pma_interface_block_sel                                           = "eight_g_pcs"                                                             ,//"eight_g_pcs" "pcie_gen3"
	parameter          hssi_common_pcs_pma_interface_bypass_early_eios                                   = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_pcie_switch                                  = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_pma_ltr                                      = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_pma_sw_done                                  = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_ppm_lock                                     = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_send_syncp_fbkp                              = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_bypass_txdetectrx                                   = "false"                                                                   ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_cdr_control                                         = "en_cdr_ctrl"                                                             ,//"dis_cdr_ctrl" "en_cdr_ctrl"
	parameter          hssi_common_pcs_pma_interface_cid_enable                                          = "en_cid_mode"                                                             ,//"dis_cid_mode" "en_cid_mode"
	parameter [15:0]   hssi_common_pcs_pma_interface_data_mask_count                                     = 16'd2500                                                                  ,//0:65535
	parameter [2:0]    hssi_common_pcs_pma_interface_data_mask_count_multi                               = 3'd1                                                                      ,//0:7
	parameter          hssi_common_pcs_pma_interface_dft_observation_clock_selection                     = "dft_clk_obsrv_tx0"                                                       ,//"dft_clk_obsrv_asn0" "dft_clk_obsrv_asn1" "dft_clk_obsrv_clklow" "dft_clk_obsrv_fref" "dft_clk_obsrv_hclk" "dft_clk_obsrv_rx" "dft_clk_obsrv_tx0" "dft_clk_obsrv_tx1" "dft_clk_obsrv_tx2" "dft_clk_obsrv_tx3" "dft_clk_obsrv_tx4"
	parameter [7:0]    hssi_common_pcs_pma_interface_early_eios_counter                                  = 8'd50                                                                     ,//0:255
	parameter          hssi_common_pcs_pma_interface_force_freqdet                                       = "force_freqdet_dis"                                                       ,//"force0_freqdet_en" "force1_freqdet_en" "force_freqdet_dis"
	parameter          hssi_common_pcs_pma_interface_free_run_clk_enable                                 = "true"                                                                    ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_ignore_sigdet_g23                                   = "false"                                                                   ,//"false" "true"
	parameter [6:0]    hssi_common_pcs_pma_interface_pc_en_counter                                       = 7'd55                                                                     ,//0:127
	parameter [4:0]    hssi_common_pcs_pma_interface_pc_rst_counter                                      = 5'd23                                                                     ,//0:31
	parameter          hssi_common_pcs_pma_interface_pcie_hip_mode                                       = "hip_disable"                                                             ,//"hip_disable" "hip_enable"
	parameter          hssi_common_pcs_pma_interface_ph_fifo_reg_mode                                    = "phfifo_reg_mode_dis"                                                     ,//"phfifo_reg_mode_dis" "phfifo_reg_mode_en"
	parameter [5:0]    hssi_common_pcs_pma_interface_phfifo_flush_wait                                   = 6'd36                                                                     ,//0:63
	parameter          hssi_common_pcs_pma_interface_pipe_if_g3pcs                                       = "pipe_if_8gpcs"                                                           ,//"pipe_if_8gpcs" "pipe_if_g3pcs"
	parameter [17:0]   hssi_common_pcs_pma_interface_pma_done_counter                                    = 18'd175000                                                                ,//0:262143
	parameter          hssi_common_pcs_pma_interface_pma_if_dft_en                                       = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_common_pcs_pma_interface_pma_if_dft_val                                      = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_common_pcs_pma_interface_ppm_cnt_rst                                         = "ppm_cnt_rst_dis"                                                         ,//"ppm_cnt_rst_dis" "ppm_cnt_rst_en"
	parameter          hssi_common_pcs_pma_interface_ppm_deassert_early                                  = "deassert_early_dis"                                                      ,//"deassert_early_dis" "deassert_early_en"
	parameter          hssi_common_pcs_pma_interface_ppm_det_buckets                                     = "ppm_100_bucket"                                                          ,//"disable_prot" "ppm_100_bucket" "ppm_300_100_bucket" "ppm_300_bucket"
	parameter          hssi_common_pcs_pma_interface_ppm_gen1_2_cnt                                      = "cnt_32k"                                                                 ,//"cnt_32k" "cnt_64k"
	parameter          hssi_common_pcs_pma_interface_ppm_post_eidle_delay                                = "cnt_200_cycles"                                                          ,//"cnt_200_cycles" "cnt_400_cycles"
	parameter          hssi_common_pcs_pma_interface_ppmsel                                              = "ppmsel_300"                                                              ,//"ppmsel_100" "ppmsel_1000" "ppmsel_125" "ppmsel_200" "ppmsel_250" "ppmsel_2500" "ppmsel_300" "ppmsel_500" "ppmsel_5000" "ppmsel_62p5" "ppmsel_disable" "ppm_other"
	parameter          hssi_common_pcs_pma_interface_prot_mode                                           = "disable_prot_mode"                                                       ,//"disable_prot_mode" "other_protocols" "pipe_g12" "pipe_g3"
	parameter          hssi_common_pcs_pma_interface_rxvalid_mask                                        = "rxvalid_mask_en"                                                         ,//"rxvalid_mask_dis" "rxvalid_mask_en"
	parameter [11:0]   hssi_common_pcs_pma_interface_sigdet_wait_counter                                 = 12'd2500                                                                  ,//0:4095
	parameter [2:0]    hssi_common_pcs_pma_interface_sigdet_wait_counter_multi                           = 3'd1                                                                      ,//0:7
	parameter          hssi_common_pcs_pma_interface_silicon_rev                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_common_pcs_pma_interface_sim_mode                                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_common_pcs_pma_interface_spd_chg_rst_wait_cnt_en                             = "true"                                                                    ,//"false" "true"
	parameter          hssi_common_pcs_pma_interface_sup_mode                                            = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_common_pcs_pma_interface_testout_sel                                         = "ppm_det_test"                                                            ,//"asn_test" "pma_pll_test" "ppm_det_test" "prbs_gen_test" "prbs_ver_test" "rxpmaif_test" "uhsif_1_test" "uhsif_2_test" "uhsif_3_test"
	parameter [3:0]    hssi_common_pcs_pma_interface_wait_clk_on_off_timer                               = 4'd4                                                                      ,//0:15
	parameter [4:0]    hssi_common_pcs_pma_interface_wait_pipe_synchronizing                             = 5'd23                                                                     ,//0:31
	parameter [10:0]   hssi_common_pcs_pma_interface_wait_send_syncp_fbkp                                = 11'd250                                                                   ,//0:2047
	parameter          hssi_common_pld_pcs_interface_dft_clk_out_en                                      = "dft_clk_out_disable"                                                     ,//"dft_clk_out_disable" "dft_clk_out_enable"
	parameter          hssi_common_pld_pcs_interface_dft_clk_out_sel                                     = "teng_rx_dft_clk"                                                         ,//"eightg_rx_dft_clk" "eightg_tx_dft_clk" "pmaif_dft_clk" "teng_rx_dft_clk" "teng_tx_dft_clk"
	parameter          hssi_common_pld_pcs_interface_hrdrstctrl_en                                       = "hrst_dis"                                                                ,//"hrst_dis" "hrst_en"
	parameter          hssi_common_pld_pcs_interface_pcs_testbus_block_sel                               = "eightg"                                                                  ,//"eightg" "g3pcs" "krfec" "pma_if" "teng"
	parameter          hssi_common_pld_pcs_interface_silicon_rev                                         = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_fifo_rx_pcs_double_read_mode                                                 = "double_read_dis"                                                         ,//"double_read_dis" "double_read_en"
	parameter          hssi_fifo_rx_pcs_prot_mode                                                        = "teng_mode"                                                               ,//"non_teng_mode" "teng_mode"
	parameter          hssi_fifo_rx_pcs_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_fifo_tx_pcs_double_write_mode                                                = "double_write_dis"                                                        ,//"double_write_dis" "double_write_en"
	parameter          hssi_fifo_tx_pcs_prot_mode                                                        = "teng_mode"                                                               ,//"non_teng_mode" "teng_mode"
	parameter          hssi_fifo_tx_pcs_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_gen3_rx_pcs_block_sync                                                       = "enable_block_sync"                                                       ,//"bypass_block_sync" "enable_block_sync"
	parameter          hssi_gen3_rx_pcs_block_sync_sm                                                    = "enable_blk_sync_sm"                                                      ,//"disable_blk_sync_sm" "enable_blk_sync_sm"
	parameter          hssi_gen3_rx_pcs_cdr_ctrl_force_unalgn                                            = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_gen3_rx_pcs_lpbk_force                                                       = "lpbk_frce_dis"                                                           ,//"lpbk_frce_dis" "lpbk_frce_en"
	parameter          hssi_gen3_rx_pcs_mode                                                             = "gen3_func"                                                               ,//"disable_pcs" "gen3_func"
	parameter          hssi_gen3_rx_pcs_rate_match_fifo                                                  = "enable_rm_fifo_600ppm"                                                   ,//"bypass_rm_fifo" "enable_rm_fifo_0ppm" "enable_rm_fifo_600ppm"
	parameter          hssi_gen3_rx_pcs_rate_match_fifo_latency                                          = "regular_latency"                                                         ,//"low_latency" "regular_latency"
	parameter          hssi_gen3_rx_pcs_reverse_lpbk                                                     = "rev_lpbk_en"                                                             ,//"rev_lpbk_dis" "rev_lpbk_en"
	parameter          hssi_gen3_rx_pcs_rx_b4gb_par_lpbk                                                 = "b4gb_par_lpbk_dis"                                                       ,//"b4gb_par_lpbk_dis" "b4gb_par_lpbk_en"
	parameter          hssi_gen3_rx_pcs_rx_force_balign                                                  = "en_force_balign"                                                         ,//"dis_force_balign" "en_force_balign"
	parameter          hssi_gen3_rx_pcs_rx_ins_del_one_skip                                              = "ins_del_one_skip_en"                                                     ,//"ins_del_one_skip_dis" "ins_del_one_skip_en"
	parameter [3:0]    hssi_gen3_rx_pcs_rx_num_fixed_pat                                                 = 4'd8                                                                      ,//0:15
	parameter          hssi_gen3_rx_pcs_rx_test_out_sel                                                  = "rx_test_out0"                                                            ,//"rx_test_out0" "rx_test_out1"
	parameter          hssi_gen3_rx_pcs_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_gen3_rx_pcs_sup_mode                                                         = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_gen3_tx_pcs_mode                                                             = "gen3_func"                                                               ,//"disable_pcs" "gen3_func"
	parameter          hssi_gen3_tx_pcs_reverse_lpbk                                                     = "rev_lpbk_en"                                                             ,//"rev_lpbk_dis" "rev_lpbk_en"
	parameter          hssi_gen3_tx_pcs_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_gen3_tx_pcs_sup_mode                                                         = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter [4:0]    hssi_gen3_tx_pcs_tx_bitslip                                                       = 5'd0                                                                      ,//0:31
	parameter          hssi_gen3_tx_pcs_tx_gbox_byp                                                      = "bypass_gbox"                                                             ,//"bypass_gbox" "enable_gbox"
	parameter          hssi_krfec_rx_pcs_blksync_cor_en                                                  = "detect"                                                                  ,//"correct" "detect"
	parameter          hssi_krfec_rx_pcs_bypass_gb                                                       = "bypass_dis"                                                              ,//"bypass_dis" "bypass_en"
	parameter          hssi_krfec_rx_pcs_clr_ctrl                                                        = "both_enabled"                                                            ,//"both_enabled" "corr_cnt_only" "uncorr_cnt_only"
	parameter          hssi_krfec_rx_pcs_ctrl_bit_reverse                                                = "ctrl_bit_reverse_dis"                                                    ,//"ctrl_bit_reverse_dis" "ctrl_bit_reverse_en"
	parameter          hssi_krfec_rx_pcs_data_bit_reverse                                                = "data_bit_reverse_dis"                                                    ,//"data_bit_reverse_dis" "data_bit_reverse_en"
	parameter          hssi_krfec_rx_pcs_dv_start                                                        = "with_blklock"                                                            ,//"with_blklock" "with_blksync"
	parameter          hssi_krfec_rx_pcs_err_mark_type                                                   = "err_mark_10g"                                                            ,//"err_mark_10g" "err_mark_40g"
	parameter          hssi_krfec_rx_pcs_error_marking_en                                                = "err_mark_dis"                                                            ,//"err_mark_dis" "err_mark_en"
	parameter          hssi_krfec_rx_pcs_low_latency_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_lpbk_mode                                                       = "lpbk_dis"                                                                ,//"lpbk_dis" "lpbk_en"
	parameter [7:0]    hssi_krfec_rx_pcs_parity_invalid_enum                                             = 8'd8                                                                      ,//0:255
	parameter [3:0]    hssi_krfec_rx_pcs_parity_valid_num                                                = 4'd4                                                                      ,//0:15
	parameter          hssi_krfec_rx_pcs_pipeln_blksync                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_descrm                                                   = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_errcorrect                                               = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_errtrap_ind                                              = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_errtrap_lfsr                                             = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_errtrap_loc                                              = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_errtrap_pat                                              = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_gearbox                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_syndrm                                                   = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_pipeln_trans_dec                                                = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_rx_pcs_prot_mode                                                       = "disable_mode"                                                            ,//"basic_mode" "disable_mode" "fortyg_basekr_mode" "teng_1588_basekr_mode" "teng_basekr_mode"
	parameter          hssi_krfec_rx_pcs_receive_order                                                   = "receive_lsb"                                                             ,//"receive_lsb" "receive_msb"
	parameter          hssi_krfec_rx_pcs_rx_testbus_sel                                                  = "overall"                                                                 ,//"blksync" "blksync_cntrs" "decoder_master_sm" "decoder_master_sm_cntrs" "decoder_rd_sm" "errtrap_ind1" "errtrap_ind2" "errtrap_ind3" "errtrap_ind4" "errtrap_ind5" "errtrap_loc" "errtrap_pat1" "errtrap_pat2" "errtrap_pat3" "errtrap_pat4" "errtrap_sm" "fast_search" "fast_search_cntrs" "gb_and_trans" "overall" "syndrm1" "syndrm2" "syndrm_sm"
	parameter          hssi_krfec_rx_pcs_signal_ok_en                                                    = "sig_ok_dis"                                                              ,//"sig_ok_dis" "sig_ok_en"
	parameter          hssi_krfec_rx_pcs_silicon_rev                                                     = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_krfec_rx_pcs_sup_mode                                                        = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_krfec_tx_pcs_burst_err                                                       = "burst_err_dis"                                                           ,//"burst_err_dis" "burst_err_en"
	parameter          hssi_krfec_tx_pcs_burst_err_len                                                   = "burst_err_len1"                                                          ,//"burst_err_len1" "burst_err_len10" "burst_err_len11" "burst_err_len12" "burst_err_len13" "burst_err_len14" "burst_err_len15" "burst_err_len16" "burst_err_len2" "burst_err_len3" "burst_err_len4" "burst_err_len5" "burst_err_len6" "burst_err_len7" "burst_err_len8" "burst_err_len9"
	parameter          hssi_krfec_tx_pcs_ctrl_bit_reverse                                                = "ctrl_bit_reverse_dis"                                                    ,//"ctrl_bit_reverse_dis" "ctrl_bit_reverse_en"
	parameter          hssi_krfec_tx_pcs_data_bit_reverse                                                = "data_bit_reverse_dis"                                                    ,//"data_bit_reverse_dis" "data_bit_reverse_en"
	parameter          hssi_krfec_tx_pcs_enc_frame_query                                                 = "enc_query_dis"                                                           ,//"enc_query_dis" "enc_query_en"
	parameter          hssi_krfec_tx_pcs_low_latency_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_krfec_tx_pcs_pipeln_encoder                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_tx_pcs_pipeln_scrambler                                                = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_krfec_tx_pcs_prot_mode                                                       = "disable_mode"                                                            ,//"basic_mode" "disable_mode" "fortyg_basekr_mode" "teng_1588_basekr_mode" "teng_basekr_mode"
	parameter          hssi_krfec_tx_pcs_silicon_rev                                                     = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_krfec_tx_pcs_sup_mode                                                        = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_krfec_tx_pcs_transcode_err                                                   = "trans_err_dis"                                                           ,//"trans_err_dis" "trans_err_en"
	parameter          hssi_krfec_tx_pcs_transmit_order                                                  = "transmit_lsb"                                                            ,//"transmit_lsb" "transmit_msb"
	parameter          hssi_krfec_tx_pcs_tx_testbus_sel                                                  = "overall"                                                                 ,//"encoder1" "encoder2" "gearbox" "overall" "scramble1" "scramble2" "scramble3"
	parameter [2:0]    hssi_pipe_gen1_2_elec_idle_delay_val                                              = 3'd0                                                                      ,//0:7
	parameter          hssi_pipe_gen1_2_error_replace_pad                                                = "replace_edb"                                                             ,//"replace_edb" "replace_pad"
	parameter          hssi_pipe_gen1_2_hip_mode                                                         = "dis_hip"                                                                 ,//"dis_hip" "en_hip"
	parameter          hssi_pipe_gen1_2_ind_error_reporting                                              = "dis_ind_error_reporting"                                                 ,//"dis_ind_error_reporting" "en_ind_error_reporting"
	parameter [2:0]    hssi_pipe_gen1_2_phystatus_delay_val                                              = 3'd0                                                                      ,//0:7
	parameter          hssi_pipe_gen1_2_phystatus_rst_toggle                                             = "dis_phystatus_rst_toggle"                                                ,//"dis_phystatus_rst_toggle" "en_phystatus_rst_toggle"
	parameter          hssi_pipe_gen1_2_pipe_byte_de_serializer_en                                       = "dont_care_bds"                                                           ,//"dis_bds" "dont_care_bds" "en_bds_by_2"
	parameter          hssi_pipe_gen1_2_prot_mode                                                        = "pipe_g1"                                                                 ,//"basic" "disabled_prot_mode" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter [5:0]    hssi_pipe_gen1_2_rpre_emph_a_val                                                  = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rpre_emph_b_val                                                  = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rpre_emph_c_val                                                  = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rpre_emph_d_val                                                  = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rpre_emph_e_val                                                  = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rvod_sel_a_val                                                   = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rvod_sel_b_val                                                   = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rvod_sel_c_val                                                   = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rvod_sel_d_val                                                   = 6'd0                                                                      ,//0:63
	parameter [5:0]    hssi_pipe_gen1_2_rvod_sel_e_val                                                   = 6'd0                                                                      ,//0:63
	parameter          hssi_pipe_gen1_2_rx_pipe_enable                                                   = "dis_pipe_rx"                                                             ,//"dis_pipe_rx" "en_pipe3_rx" "en_pipe_rx"
	parameter          hssi_pipe_gen1_2_rxdetect_bypass                                                  = "dis_rxdetect_bypass"                                                     ,//"dis_rxdetect_bypass" "en_rxdetect_bypass"
	parameter          hssi_pipe_gen1_2_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_pipe_gen1_2_sup_mode                                                         = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_pipe_gen1_2_tx_pipe_enable                                                   = "dis_pipe_tx"                                                             ,//"dis_pipe_tx" "en_pipe3_tx" "en_pipe_tx"
	parameter          hssi_pipe_gen1_2_txswing                                                          = "dis_txswing"                                                             ,//"dis_txswing" "en_txswing"
	parameter          hssi_pipe_gen3_bypass_rx_detection_enable                                         = "false"                                                                   ,//"false" "true"
	parameter [2:0]    hssi_pipe_gen3_bypass_rx_preset                                                   = 3'd0                                                                      ,//0:7
	parameter          hssi_pipe_gen3_bypass_rx_preset_enable                                            = "false"                                                                   ,//"false" "true"
	parameter [17:0]   hssi_pipe_gen3_bypass_tx_coefficent                                               = 18'd0                                                                     ,//0:262143
	parameter          hssi_pipe_gen3_bypass_tx_coefficent_enable                                        = "false"                                                                   ,//"false" "true"
	parameter [2:0]    hssi_pipe_gen3_elecidle_delay_g3                                                  = 3'd6                                                                      ,//0:7
	parameter          hssi_pipe_gen3_ind_error_reporting                                                = "dis_ind_error_reporting"                                                 ,//"dis_ind_error_reporting" "en_ind_error_reporting"
	parameter          hssi_pipe_gen3_mode                                                               = "pipe_g1"                                                                 ,//"disable_pcs" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter [2:0]    hssi_pipe_gen3_phy_status_delay_g3                                                = 3'd5                                                                      ,//0:7
	parameter [2:0]    hssi_pipe_gen3_phy_status_delay_g12                                               = 3'd5                                                                      ,//0:7
	parameter          hssi_pipe_gen3_phystatus_rst_toggle_g3                                            = "dis_phystatus_rst_toggle_g3"                                             ,//"dis_phystatus_rst_toggle_g3" "en_phystatus_rst_toggle_g3"
	parameter          hssi_pipe_gen3_phystatus_rst_toggle_g12                                           = "dis_phystatus_rst_toggle"                                                ,//"dis_phystatus_rst_toggle" "en_phystatus_rst_toggle"
	parameter          hssi_pipe_gen3_rate_match_pad_insertion                                           = "dis_rm_fifo_pad_ins"                                                     ,//"dis_rm_fifo_pad_ins" "en_rm_fifo_pad_ins"
	parameter          hssi_pipe_gen3_silicon_rev                                                        = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_pipe_gen3_sup_mode                                                           = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_pipe_gen3_test_out_sel                                                       = "disable_test_out"                                                        ,//"disable_test_out" "pipe_ctrl_test_out" "pipe_test_out1" "pipe_test_out2" "pipe_test_out3" "rx_test_out" "tx_test_out"
	parameter          hssi_pldadapt_rx_aib_clk1_sel                                                     = "aib_clk1_rx_transfer_clk"                                                ,//"aib_clk1_pld_pcs_rx_clk_out" "aib_clk1_pld_pma_clkdiv_rx_user" "aib_clk1_rx_transfer_clk"
	parameter          hssi_pldadapt_rx_aib_clk2_sel                                                     = "aib_clk2_rx_transfer_clk"                                                ,//"aib_clk2_pld_pcs_rx_clk_out" "aib_clk2_pld_pma_clkdiv_rx_user" "aib_clk2_rx_transfer_clk"
	parameter          hssi_pldadapt_rx_asn_bypass_pma_pcie_sw_done                                      = "disable"                                                                 ,//"disable" "enable"
	parameter [7:0]    hssi_pldadapt_rx_asn_wait_for_dll_reset_cnt                                       = 8'd0                                                                      ,//0:255
	parameter [7:0]    hssi_pldadapt_rx_asn_wait_for_fifo_flush_cnt                                      = 8'd0                                                                      ,//0:255
	parameter [7:0]    hssi_pldadapt_rx_asn_wait_for_pma_pcie_sw_done_cnt                                = 8'd0                                                                      ,//0:255
	parameter          hssi_pldadapt_rx_bonding_dft_en                                                   = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_pldadapt_rx_bonding_dft_val                                                  = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_pldadapt_rx_chnl_bonding                                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_clock_del_measure_enable                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_ctrl_plane_bonding                                               = "individual"                                                              ,//"ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter          hssi_pldadapt_rx_ds_bypass_pipeln                                                 = "ds_bypass_pipeln_dis"                                                    ,//"ds_bypass_pipeln_dis" "ds_bypass_pipeln_en"
	parameter          hssi_pldadapt_rx_duplex_mode                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_dv_mode                                                          = "dv_mode_dis"                                                             ,//"dv_mode_dis" "dv_mode_en"
	parameter          hssi_pldadapt_rx_fifo_double_read                                                 = "fifo_double_read_dis"                                                    ,//"fifo_double_read_dis" "fifo_double_read_en"
	parameter          hssi_pldadapt_rx_fifo_mode                                                        = "phase_comp"                                                              ,//"clk_comp_10g" "generic_basic" "generic_interlaken" "phase_comp" "register_mode"
	parameter          hssi_pldadapt_rx_fifo_rd_clk_ins_sm_scg_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_fifo_rd_clk_scg_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_fifo_rd_clk_sel                                                  = "fifo_rd_clk_rx_transfer_clk"                                             ,//"fifo_rd_clk_pld_rx_clk1" "fifo_rd_clk_rx_transfer_clk" "fifo_rd_clk_tx_transfer_clk"
	parameter          hssi_pldadapt_rx_fifo_stop_rd                                                     = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_pldadapt_rx_fifo_stop_wr                                                     = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_pldadapt_rx_fifo_width                                                       = "fifo_single_width"                                                       ,//"fifo_double_width" "fifo_single_width"
	parameter          hssi_pldadapt_rx_fifo_wr_clk_del_sm_scg_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_fifo_wr_clk_scg_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_fifo_wr_clk_sel                                                  = "fifo_wr_clk_rx_transfer_clk"                                             ,//"fifo_wr_clk_rx_transfer_clk" "fifo_wr_clk_tx_transfer_clk"
	parameter          hssi_pldadapt_rx_free_run_div_clk                                                 = "out_of_reset_sync"                                                       ,//"out_of_reset_async" "out_of_reset_sync"
	parameter          hssi_pldadapt_rx_fsr_pld_8g_sigdet_out_rst_val                                    = "reset_to_zero_sigdet"                                                    ,//"reset_to_one_sigdet" "reset_to_zero_sigdet"
	parameter          hssi_pldadapt_rx_fsr_pld_10g_rx_crc32_err_rst_val                                 = "reset_to_zero_crc32"                                                     ,//"reset_to_one_crc32" "reset_to_zero_crc32"
	parameter          hssi_pldadapt_rx_fsr_pld_ltd_b_rst_val                                            = "reset_to_zero_ltdb"                                                      ,//"reset_to_one_ltdb" "reset_to_zero_ltdb"
	parameter          hssi_pldadapt_rx_fsr_pld_ltr_rst_val                                              = "reset_to_zero_ltr"                                                       ,//"reset_to_one_ltr" "reset_to_zero_ltr"
	parameter          hssi_pldadapt_rx_fsr_pld_rx_fifo_align_clr_rst_val                                = "reset_to_zero_alignclr"                                                  ,//"reset_to_one_alignclr" "reset_to_zero_alignclr"
	parameter          hssi_pldadapt_rx_gb_rx_idwidth                                                    = "idwidth_32"                                                              ,//"idwidth_32" "idwidth_40" "idwidth_64"
	parameter          hssi_pldadapt_rx_gb_rx_odwidth                                                    = "odwidth_66"                                                              ,//"odwidth_32" "odwidth_40" "odwidth_50" "odwidth_64" "odwidth_66" "odwidth_67"
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_aib_fabric_pld_pma_hclk_hz                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_sr_clk_in_hz                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_transfer_clk_hz                         = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_csr_clk_hz                                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_avmm1_clk_rowclk_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_avmm2_clk_rowclk_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_dcm_hz                                    = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_rowclk_hz                                 = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_sclk1_rowclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_rx_hdpldadapt_pld_sclk2_rowclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter          hssi_pldadapt_rx_hdpldadapt_speed_grade                                           = "dash_1"                                                                  ,//"dash_1" "dash_2" "dash_3"
	parameter          hssi_pldadapt_rx_hip_mode                                                         = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_pldadapt_rx_hrdrst_align_bypass                                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_hrdrst_dll_lock_bypass                                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_hrdrst_rx_osc_clk_scg_en                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_hrdrst_user_ctl_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_indv                                                             = "indv_en"                                                                 ,//"indv_dis" "indv_en"
	parameter          hssi_pldadapt_rx_internal_clk1_sel1                                               = "pma_clks_or_txfiford_post_ct_mux_clk1_mux1"                              ,//"pma_clks_or_txfiford_post_ct_mux_clk1_mux1" "txfifowr_post_ct_mux_clk1_mux1"
	parameter          hssi_pldadapt_rx_internal_clk1_sel2                                               = "pma_clks_clk1_mux2"                                                      ,//"pma_clks_clk1_mux2" "txfiford_post_ct_mux_clk1_mux2"
	parameter          hssi_pldadapt_rx_internal_clk2_sel1                                               = "pma_clks_or_rxfifowr_post_ct_mux_clk2_mux1"                              ,//"pma_clks_or_rxfifowr_post_ct_mux_clk2_mux1" "rxfiford_post_ct_mux_clk2_mux1"
	parameter          hssi_pldadapt_rx_internal_clk2_sel2                                               = "pma_clks_clk2_mux2"                                                      ,//"pma_clks_clk2_mux2" "rxfifowr_post_ct_mux_clk2_mux2"
	parameter          hssi_pldadapt_rx_loopback_mode                                                    = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_low_latency_en                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_lpbk_mode                                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_osc_clk_scg_en                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_phcomp_rd_del                                                    = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4" "phcomp_rd_del5" "phcomp_rd_del6"
	parameter          hssi_pldadapt_rx_pipe_enable                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_pipe_mode                                                        = "disable_pipe"                                                            ,//"disable_pipe" "enable_g1" "enable_g2" "enable_g3"
	parameter          hssi_pldadapt_rx_pld_clk1_delay_en                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_pld_clk1_delay_sel                                               = "delay_path0"                                                             ,//"delay_path0" "delay_path1" "delay_path10" "delay_path11" "delay_path12" "delay_path13" "delay_path14" "delay_path15" "delay_path2" "delay_path3" "delay_path4" "delay_path5" "delay_path6" "delay_path7" "delay_path8" "delay_path9"
	parameter          hssi_pldadapt_rx_pld_clk1_inv_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_pld_clk1_sel                                                     = "pld_clk1_rowclk"                                                         ,//"pld_clk1_dcm" "pld_clk1_rowclk"
	parameter          hssi_pldadapt_rx_pma_hclk_scg_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_powerdown_mode                                                   = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_pldadapt_rx_rx_datapath_tb_sel                                               = "cp_bond"                                                                 ,//"asn_tb" "avmm_tb" "cp_bond" "del_sm_tb" "hard_reset_tb" "insert_sm_tb" "parity_error_tb" "pcs_chnl_tb" "rx_fifo_tb1" "rx_fifo_tb2" "sr_tb" "tx_chnl_tb" "wa"
	parameter          hssi_pldadapt_rx_rx_fastbond_rden                                                 = "rden_ds_del_us_del"                                                      ,//"rden_ds_del_us_del" "rden_ds_del_us_fast" "rden_ds_fast_us_del" "rden_ds_fast_us_fast"
	parameter          hssi_pldadapt_rx_rx_fastbond_wren                                                 = "wren_ds_del_us_del"                                                      ,//"wren_ds_del_us_del" "wren_ds_del_us_fast" "wren_ds_fast_us_del" "wren_ds_fast_us_fast"
	parameter          hssi_pldadapt_rx_rx_fifo_power_mode                                               = "full_width_full_depth"                                                   ,//"full_width_full_depth" "full_width_ps_dw" "full_width_ps_sw" "half_width_full_depth" "half_width_ps_dw" "half_width_ps_sw"
	parameter          hssi_pldadapt_rx_rx_fifo_read_latency_adjust                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_fifo_write_ctrl                                               = "blklock_stops"                                                           ,//"blklock_ignore" "blklock_stops"
	parameter          hssi_pldadapt_rx_rx_fifo_write_latency_adjust                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_osc_clock_setting                                             = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_pldadapt_rx_rx_pld_8g_eidleinfersel_polling_bypass                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_pld_pma_eye_monitor_polling_bypass                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_pld_pma_pcie_switch_polling_bypass                            = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_pld_pma_reser_out_polling_bypass                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_prbs_flags_sr_enable                                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rx_true_b2b                                                      = "b2b"                                                                     ,//"b2b" "single"
	parameter          hssi_pldadapt_rx_rx_usertest_sel                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_pldadapt_rx_rxfifo_empty                                                     = "empty_sw"                                                                ,//"empty_dw" "empty_sw"
	parameter          hssi_pldadapt_rx_rxfifo_full                                                      = "full_pc_sw"                                                              ,//"full_non_pc_dw" "full_non_pc_sw" "full_pc_dw" "full_pc_sw"
	parameter          hssi_pldadapt_rx_rxfifo_mode                                                      = "rxphase_comp"                                                            ,//"rxclk_comp_10g" "rxgeneric_basic" "rxgeneric_interlaken" "rxphase_comp" "rxregister_mode"
	parameter [5:0]    hssi_pldadapt_rx_rxfifo_pempty                                                    = 6'd2                                                                      ,//0:63
	parameter [5:0]    hssi_pldadapt_rx_rxfifo_pfull                                                     = 6'd48                                                                     ,//0:63
	parameter          hssi_pldadapt_rx_rxfiford_post_ct_sel                                             = "rxfiford_sclk_post_ct"                                                   ,//"rxfiford_post_ct" "rxfiford_sclk_post_ct"
	parameter          hssi_pldadapt_rx_rxfifowr_post_ct_sel                                             = "rxfifowr_sclk_post_ct"                                                   ,//"rxfifowr_post_ct" "rxfifowr_sclk_post_ct"
	parameter          hssi_pldadapt_rx_sclk_sel                                                         = "sclk1_rowclk"                                                            ,//"sclk1_rowclk" "sclk2_rowclk"
	parameter          hssi_pldadapt_rx_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_pldadapt_rx_stretch_num_stages                                               = "zero_stage"                                                              ,//"five_stage" "four_stage" "one_stage" "six_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_pldadapt_rx_sup_mode                                                         = "user_mode"                                                               ,//"advanced_user_mode" "engineering_mode" "user_mode"
	parameter          hssi_pldadapt_rx_txfiford_post_ct_sel                                             = "txfiford_sclk_post_ct"                                                   ,//"txfiford_post_ct" "txfiford_sclk_post_ct"
	parameter          hssi_pldadapt_rx_txfifowr_post_ct_sel                                             = "txfifowr_sclk_post_ct"                                                   ,//"txfifowr_post_ct" "txfifowr_sclk_post_ct"
	parameter          hssi_pldadapt_rx_us_bypass_pipeln                                                 = "us_bypass_pipeln_dis"                                                    ,//"us_bypass_pipeln_dis" "us_bypass_pipeln_en"
	parameter          hssi_pldadapt_rx_word_align                                                       = "wa_en"                                                                   ,//"wa_dis" "wa_en"
	parameter          hssi_pldadapt_rx_word_align_enable                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_aib_clk1_sel                                                     = "aib_clk1_pld_pcs_tx_clk_out"                                             ,//"aib_clk1_pld_pcs_tx_clk_out" "aib_clk1_pld_pma_clkdiv_tx_user" "aib_clk1_pma_aib_tx_clk"
	parameter          hssi_pldadapt_tx_aib_clk2_sel                                                     = "aib_clk2_pld_pcs_tx_clk_out"                                             ,//"aib_clk2_pld_pcs_tx_clk_out" "aib_clk2_pld_pma_clkdiv_tx_user" "aib_clk2_pma_aib_tx_clk"
	parameter          hssi_pldadapt_tx_bonding_dft_en                                                   = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_pldadapt_tx_bonding_dft_val                                                  = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_pldadapt_tx_chnl_bonding                                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_ctrl_plane_bonding                                               = "individual"                                                              ,//"ctrl_master" "ctrl_master_bot" "ctrl_master_top" "ctrl_slave_abv" "ctrl_slave_blw" "ctrl_slave_bot" "ctrl_slave_top" "individual"
	parameter          hssi_pldadapt_tx_ds_bypass_pipeln                                                 = "ds_bypass_pipeln_dis"                                                    ,//"ds_bypass_pipeln_dis" "ds_bypass_pipeln_en"
	parameter          hssi_pldadapt_tx_duplex_mode                                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_dv_bond                                                          = "dv_bond_dis"                                                             ,//"dv_bond_dis" "dv_bond_en"
	parameter          hssi_pldadapt_tx_dv_gen                                                           = "dv_gen_dis"                                                              ,//"dv_gen_dis" "dv_gen_en"
	parameter          hssi_pldadapt_tx_fifo_double_write                                                = "fifo_double_write_dis"                                                   ,//"fifo_double_write_dis" "fifo_double_write_en"
	parameter          hssi_pldadapt_tx_fifo_mode                                                        = "phase_comp"                                                              ,//"generic_basic" "generic_interlaken" "phase_comp" "register_mode"
	parameter          hssi_pldadapt_tx_fifo_rd_clk_frm_gen_scg_en                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_fifo_rd_clk_scg_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_fifo_rd_clk_sel                                                  = "fifo_rd_pma_aib_tx_clk"                                                  ,//"fifo_rd_pld_tx_clk1" "fifo_rd_pld_tx_clk2" "fifo_rd_pma_aib_tx_clk"
	parameter          hssi_pldadapt_tx_fifo_stop_rd                                                     = "n_rd_empty"                                                              ,//"n_rd_empty" "rd_empty"
	parameter          hssi_pldadapt_tx_fifo_stop_wr                                                     = "n_wr_full"                                                               ,//"n_wr_full" "wr_full"
	parameter          hssi_pldadapt_tx_fifo_width                                                       = "fifo_single_width"                                                       ,//"fifo_double_width" "fifo_single_width"
	parameter          hssi_pldadapt_tx_fifo_wr_clk_scg_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_fpll_shared_direct_async_in_sel                                  = "fpll_shared_direct_async_in_rowclk"                                      ,//"fpll_shared_direct_async_in_dcm" "fpll_shared_direct_async_in_rowclk"
	parameter          hssi_pldadapt_tx_frmgen_burst                                                     = "frmgen_burst_dis"                                                        ,//"frmgen_burst_dis" "frmgen_burst_en"
	parameter          hssi_pldadapt_tx_frmgen_bypass                                                    = "frmgen_bypass_dis"                                                       ,//"frmgen_bypass_dis" "frmgen_bypass_en"
	parameter [15:0]   hssi_pldadapt_tx_frmgen_mfrm_length                                               = 16'd2048                                                                  ,//0:65535
	parameter          hssi_pldadapt_tx_frmgen_pipeln                                                    = "frmgen_pipeln_dis"                                                       ,//"frmgen_pipeln_dis" "frmgen_pipeln_en"
	parameter          hssi_pldadapt_tx_frmgen_pyld_ins                                                  = "frmgen_pyld_ins_dis"                                                     ,//"frmgen_pyld_ins_dis" "frmgen_pyld_ins_en"
	parameter          hssi_pldadapt_tx_frmgen_wordslip                                                  = "frmgen_wordslip_dis"                                                     ,//"frmgen_wordslip_dis" "frmgen_wordslip_en"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_in_bit0_rst_val                                      = "reset_to_zero_hfsrin0"                                                   ,//"reset_to_one_hfsrin0" "reset_to_zero_hfsrin0"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_in_bit1_rst_val                                      = "reset_to_zero_hfsrin1"                                                   ,//"reset_to_one_hfsrin1" "reset_to_zero_hfsrin1"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_in_bit2_rst_val                                      = "reset_to_zero_hfsrin2"                                                   ,//"reset_to_one_hfsrin2" "reset_to_zero_hfsrin2"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_in_bit3_rst_val                                      = "reset_to_zero_hfsrin3"                                                   ,//"reset_to_one_hfsrin3" "reset_to_zero_hfsrin3"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_out_bit0_rst_val                                     = "reset_to_zero_hfsrout0"                                                  ,//"reset_to_one_hfsrout0" "reset_to_zero_hfsrout0"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_out_bit1_rst_val                                     = "reset_to_zero_hfsrout1"                                                  ,//"reset_to_one_hfsrout1" "reset_to_zero_hfsrout1"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_out_bit2_rst_val                                     = "reset_to_zero_hfsrout2"                                                  ,//"reset_to_one_hfsrout2" "reset_to_zero_hfsrout2"
	parameter          hssi_pldadapt_tx_fsr_hip_fsr_out_bit3_rst_val                                     = "reset_to_zero_hfsrout3"                                                  ,//"reset_to_one_hfsrout3" "reset_to_zero_hfsrout3"
	parameter          hssi_pldadapt_tx_fsr_mask_tx_pll_rst_val                                          = "reset_to_zero_maskpll"                                                   ,//"reset_to_one_maskpll" "reset_to_zero_maskpll"
	parameter          hssi_pldadapt_tx_fsr_pld_txelecidle_rst_val                                       = "reset_to_zero_txelec"                                                    ,//"reset_to_one_txelec" "reset_to_zero_txelec"
	parameter          hssi_pldadapt_tx_gb_tx_idwidth                                                    = "idwidth_66"                                                              ,//"idwidth_32" "idwidth_40" "idwidth_50" "idwidth_64" "idwidth_66" "idwidth_67"
	parameter          hssi_pldadapt_tx_gb_tx_odwidth                                                    = "odwidth_32"                                                              ,//"odwidth_32" "odwidth_40" "odwidth_64"
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_aib_fabric_pld_pma_hclk_hz                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_aib_fabric_pma_aib_tx_clk_hz                          = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_aib_fabric_tx_sr_clk_in_hz                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_csr_clk_hz                                            = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_avmm1_clk_rowclk_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_avmm2_clk_rowclk_hz                               = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_sclk1_rowclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_sclk2_rowclk_hz                                   = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_dcm_hz                                    = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_rowclk_hz                                 = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_dcm_hz                                    = 31'd0                                                                     ,//0:2147483647
	parameter [30:0]   hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_rowclk_hz                                 = 31'd0                                                                     ,//0:2147483647
	parameter          hssi_pldadapt_tx_hdpldadapt_speed_grade                                           = "dash_1"                                                                  ,//"dash_1" "dash_2" "dash_3"
	parameter          hssi_pldadapt_tx_hip_mode                                                         = "disable_hip"                                                             ,//"debug_chnl" "disable_hip" "user_chnl"
	parameter          hssi_pldadapt_tx_hip_osc_clk_scg_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_hrdrst_dcd_cal_done_bypass                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_hrdrst_rx_osc_clk_scg_en                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_hrdrst_user_ctl_en                                               = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_indv                                                             = "indv_en"                                                                 ,//"indv_dis" "indv_en"
	parameter          hssi_pldadapt_tx_loopback_mode                                                    = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_low_latency_en                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_osc_clk_scg_en                                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_phcomp_rd_del                                                    = "phcomp_rd_del2"                                                          ,//"phcomp_rd_del2" "phcomp_rd_del3" "phcomp_rd_del4" "phcomp_rd_del5" "phcomp_rd_del6" "phcomp_rd_del7" "phcomp_rd_del8"
	parameter          hssi_pldadapt_tx_pipe_mode                                                        = "disable_pipe"                                                            ,//"disable_pipe" "enable_g1" "enable_g2" "enable_g3"
	parameter          hssi_pldadapt_tx_pld_clk1_delay_en                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_pld_clk1_delay_sel                                               = "delay_path0"                                                             ,//"delay_path0" "delay_path1" "delay_path10" "delay_path11" "delay_path12" "delay_path13" "delay_path14" "delay_path15" "delay_path2" "delay_path3" "delay_path4" "delay_path5" "delay_path6" "delay_path7" "delay_path8" "delay_path9"
	parameter          hssi_pldadapt_tx_pld_clk1_inv_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_pld_clk1_sel                                                     = "pld_clk1_rowclk"                                                         ,//"pld_clk1_dcm" "pld_clk1_rowclk"
	parameter          hssi_pldadapt_tx_pld_clk2_sel                                                     = "pld_clk2_rowclk"                                                         ,//"pld_clk2_dcm" "pld_clk2_rowclk"
	parameter          hssi_pldadapt_tx_pma_aib_tx_clk_expected_setting                                  = "not_used"                                                                ,//"dynamic" "not_used" "x1" "x2" "x2_not_from_chnl"
	parameter          hssi_pldadapt_tx_powerdown_mode                                                   = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          hssi_pldadapt_tx_sh_err                                                           = "sh_err_dis"                                                              ,//"sh_err_dis" "sh_err_en"
	parameter          hssi_pldadapt_tx_silicon_rev                                                      = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_pldadapt_tx_stretch_num_stages                                               = "zero_stage"                                                              ,//"five_stage" "four_stage" "one_stage" "six_stage" "three_stage" "two_stage" "zero_stage"
	parameter          hssi_pldadapt_tx_sup_mode                                                         = "user_mode"                                                               ,//"advanced_user_mode" "engineering_mode" "user_mode"
	parameter          hssi_pldadapt_tx_tx_datapath_tb_sel                                               = "cp_bond"                                                                 ,//"cp_bond" "dv_gen_tb" "frm_gen_tb1" "frm_gen_tb2" "har_reset_tb" "tx_fifo_tb1" "tx_fifo_tb2"
	parameter          hssi_pldadapt_tx_tx_fastbond_rden                                                 = "rden_ds_del_us_del"                                                      ,//"rden_ds_del_us_del" "rden_ds_del_us_fast" "rden_ds_fast_us_del" "rden_ds_fast_us_fast"
	parameter          hssi_pldadapt_tx_tx_fastbond_wren                                                 = "wren_ds_del_us_del"                                                      ,//"wren_ds_del_us_del" "wren_ds_del_us_fast" "wren_ds_fast_us_del" "wren_ds_fast_us_fast"
	parameter          hssi_pldadapt_tx_tx_fifo_power_mode                                               = "full_width_full_depth"                                                   ,//"full_width_full_depth" "full_width_ps_dw" "full_width_ps_sw" "half_width_full_depth" "half_width_ps_dw" "half_width_ps_sw"
	parameter          hssi_pldadapt_tx_tx_fifo_read_latency_adjust                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_fifo_write_latency_adjust                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_hip_aib_ssr_in_polling_bypass                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_osc_clock_setting                                             = "osc_clk_div_by1"                                                         ,//"osc_clk_div_by1" "osc_clk_div_by2" "osc_clk_div_by4"
	parameter          hssi_pldadapt_tx_tx_pld_8g_tx_boundary_sel_polling_bypass                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_pld_10g_tx_bitslip_polling_bypass                             = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_pld_pma_fpll_cnt_sel_polling_bypass                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_pld_pma_fpll_num_phase_shifts_polling_bypass                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_tx_usertest_sel                                                  = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_txfifo_empty                                                     = "empty_default"                                                           ,//"empty_default"
	parameter          hssi_pldadapt_tx_txfifo_full                                                      = "full_pc_sw"                                                              ,//"full_non_pc_dw" "full_non_pc_sw" "full_pc_dw" "full_pc_sw"
	parameter          hssi_pldadapt_tx_txfifo_mode                                                      = "txphase_comp"                                                            ,//"txgeneric_basic" "txgeneric_interlaken" "txphase_comp" "txregister_mode"
	parameter [4:0]    hssi_pldadapt_tx_txfifo_pempty                                                    = 5'd2                                                                      ,//0:31
	parameter [4:0]    hssi_pldadapt_tx_txfifo_pfull                                                     = 5'd24                                                                     ,//0:31
	parameter          hssi_pldadapt_tx_us_bypass_pipeln                                                 = "us_bypass_pipeln_dis"                                                    ,//"us_bypass_pipeln_dis" "us_bypass_pipeln_en"
	parameter          hssi_pldadapt_tx_word_align_enable                                                = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_pldadapt_tx_word_mark                                                        = "wm_en"                                                                   ,//"wm_dis" "wm_en"
	parameter          hssi_rx_pcs_pma_interface_block_sel                                               = "eight_g_pcs"                                                             ,//"direct_pld" "eight_g_pcs" "ten_g_pcs"
	parameter          hssi_rx_pcs_pma_interface_channel_operation_mode                                  = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pcs_pma_interface_clkslip_sel                                             = "pld"                                                                     ,//"pld" "slip_eight_g_pcs"
	parameter          hssi_rx_pcs_pma_interface_lpbk_en                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pcs_pma_interface_master_clk_sel                                          = "master_rx_pma_clk"                                                       ,//"master_refclk_dig" "master_rx_pma_clk" "master_tx_pma_clk"
	parameter          hssi_rx_pcs_pma_interface_pldif_datawidth_mode                                    = "pldif_data_10bit"                                                        ,//"pldif_data_10bit" "pldif_data_8bit"
	parameter          hssi_rx_pcs_pma_interface_pma_dw_rx                                               = "pma_8b_rx"                                                               ,//"pcie_g3_dyn_dw_rx" "pma_10b_rx" "pma_16b_rx" "pma_20b_rx" "pma_32b_rx" "pma_40b_rx" "pma_64b_rx" "pma_8b_rx"
	parameter          hssi_rx_pcs_pma_interface_pma_if_dft_en                                           = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_rx_pcs_pma_interface_pma_if_dft_val                                          = "dft_0"                                                                   ,//"dft_0" "dft_1"
	parameter          hssi_rx_pcs_pma_interface_prbs9_dwidth                                            = "prbs9_64b"                                                               ,//"prbs9_10b" "prbs9_64b"
	parameter          hssi_rx_pcs_pma_interface_prbs_clken                                              = "prbs_clk_dis"                                                            ,//"prbs_clk_dis" "prbs_clk_en"
	parameter          hssi_rx_pcs_pma_interface_prbs_ver                                                = "prbs_off"                                                                ,//"prbs_15" "prbs_23" "prbs_31" "prbs_7" "prbs_9" "prbs_off"
	parameter          hssi_rx_pcs_pma_interface_prot_mode_rx                                            = "disabled_prot_mode_rx"                                                   ,//"disabled_prot_mode_rx" "eightg_basic_mode_rx" "eightg_g3_pcie_g3_hip_mode_rx" "eightg_g3_pcie_g3_pld_mode_rx" "eightg_only_pld_mode_rx" "eightg_pcie_g12_hip_mode_rx" "eightg_pcie_g12_pld_mode_rx" "pcs_direct_mode_rx" "prbs_mode_rx" "teng_basic_mode_rx" "teng_krfec_mode_rx" "teng_sfis_sdi_mode_rx"
	parameter          hssi_rx_pcs_pma_interface_rx_dyn_polarity_inversion                               = "rx_dyn_polinv_dis"                                                       ,//"rx_dyn_polinv_dis" "rx_dyn_polinv_en"
	parameter          hssi_rx_pcs_pma_interface_rx_lpbk_en                                              = "lpbk_dis"                                                                ,//"lpbk_dis" "lpbk_en"
	parameter          hssi_rx_pcs_pma_interface_rx_prbs_force_signal_ok                                 = "unforce_sig_ok"                                                          ,//"force_sig_ok" "unforce_sig_ok"
	parameter          hssi_rx_pcs_pma_interface_rx_prbs_mask                                            = "prbsmask128"                                                             ,//"prbsmask1024" "prbsmask128" "prbsmask256" "prbsmask512"
	parameter          hssi_rx_pcs_pma_interface_rx_prbs_mode                                            = "teng_mode"                                                               ,//"eightg_mode" "teng_mode"
	parameter          hssi_rx_pcs_pma_interface_rx_signalok_signaldet_sel                               = "sel_sig_det"                                                             ,//"sel_sig_det" "sel_sig_ok"
	parameter          hssi_rx_pcs_pma_interface_rx_static_polarity_inversion                            = "rx_stat_polinv_dis"                                                      ,//"rx_stat_polinv_dis" "rx_stat_polinv_en"
	parameter          hssi_rx_pcs_pma_interface_rx_uhsif_lpbk_en                                        = "uhsif_lpbk_dis"                                                          ,//"uhsif_lpbk_dis" "uhsif_lpbk_en"
	parameter          hssi_rx_pcs_pma_interface_silicon_rev                                             = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_rx_pcs_pma_interface_sup_mode                                                = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_g3pcs_prot_mode                                      = "disabled_prot_mode"                                                      ,//"disabled_prot_mode" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter          hssi_rx_pld_pcs_interface_hd_g3pcs_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_channel_operation_mode                         = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_low_latency_en_rx                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_lpbk_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_prot_mode_rx                                   = "disabled_prot_mode_rx"                                                   ,//"basic_mode_rx" "disabled_prot_mode_rx" "fortyg_basekr_mode_rx" "teng_1588_basekr_mode_rx" "teng_basekr_mode_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_krfec_test_bus_mode                                  = "tx"                                                                      ,//"rx" "tx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_channel_operation_mode                         = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_fifo_mode_rx                                   = "fifo_rx"                                                                 ,//"fifo_rx" "reg_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_hip_mode                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_lpbk_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_pma_dw_rx                                      = "pma_8b_rx"                                                               ,//"pma_10b_rx" "pma_16b_rx" "pma_20b_rx" "pma_8b_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_prot_mode_rx                                   = "disabled_prot_mode_rx"                                                   ,//"basic_rm_disable_rx" "basic_rm_enable_rx" "cpri_rx" "cpri_rx_tx_rx" "disabled_prot_mode_rx" "gige_1588_rx" "gige_rx" "pipe_g1_rx" "pipe_g2_rx" "pipe_g3_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs8g_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_rx                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_channel_operation_mode                        = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_fifo_mode_rx                                  = "fifo_rx"                                                                 ,//"fifo_rx" "reg_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_low_latency_en_rx                             = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_lpbk_en                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_pma_dw_rx                                     = "pma_64b_rx"                                                              ,//"pma_32b_rx" "pma_40b_rx" "pma_64b_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_prot_mode_rx                                  = "disabled_prot_mode_rx"                                                   ,//"basic_krfec_mode_rx" "basic_mode_rx" "disabled_prot_mode_rx" "interlaken_mode_rx" "sfis_mode_rx" "teng_1588_krfec_mode_rx" "teng_1588_mode_rx" "teng_baser_krfec_mode_rx" "teng_baser_mode_rx" "teng_sdi_mode_rx" "test_prp_krfec_mode_rx" "test_prp_mode_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_rx                          = "single_rx"                                                               ,//"double_rx" "single_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_sup_mode                                      = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs10g_test_bus_mode                                 = "tx"                                                                      ,//"rx" "tx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode                   = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_clklow_clk_hz                            = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx                    = "individual_rx"                                                           ,//"ctrl_master_rx" "ctrl_slave_abv_rx" "ctrl_slave_blw_rx" "individual_rx"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_fref_clk_hz                              = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_func_mode                                = "disable"                                                                 ,//"disable" "enable"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz                              = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_hip_en                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en                             = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_low_latency_en_rx                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_lpbk_en                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_operating_voltage                        = "standard"                                                                ,//"standard" "vidint" "vidmin"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_ac_pwr_rules_en                      = "disable"                                                                 ,//"disable" "enable"
	parameter [19:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_pair_ac_pwr_uw_per_mhz               = 20'd0                                                                     ,//0:1048575
	parameter [19:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_ac_pwr_uw_per_mhz                 = 20'd0                                                                     ,//0:1048575
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_pwr_scaling_clk                   = "pma_rx_clk"                                                              ,//"pma_rx_clk"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz    = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_rx                         = "fifo_rx"                                                                 ,//"fifo_rx" "reg_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_rx                      = "disabled_prot_mode_rx"                                                   ,//"disabled_prot_mode_rx" "eightg_and_g3_pld_fifo_mode_rx" "eightg_and_g3_reg_mode_hip_rx" "eightg_and_g3_reg_mode_rx" "pcs_direct_reg_mode_rx" "teng_and_krfec_pld_fifo_mode_rx" "teng_and_krfec_reg_mode_rx" "teng_pld_fifo_mode_rx" "teng_reg_mode_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz   = 30'd0                                                                     ,//0:1073741823
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_rx_clk_hz                            = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_dw_rx                                = "pma_8b_rx"                                                               ,//"pcie_g3_dyn_dw_rx" "pma_10b_rx" "pma_16b_rx" "pma_20b_rx" "pma_32b_rx" "pma_40b_rx" "pma_64b_rx" "pma_8b_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode            = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_rx                         = "pma_8b_rx"                                                               ,//"pcie_g3_dyn_dw_rx" "pma_10b_rx" "pma_16b_rx" "pma_20b_rx" "pma_32b_rx" "pma_40b_rx" "pma_64b_rx" "pma_8b_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_rx                      = "disabled_prot_mode_rx"                                                   ,//"disabled_prot_mode_rx" "eightg_basic_mode_rx" "eightg_g3_pcie_g3_hip_mode_rx" "eightg_g3_pcie_g3_pld_mode_rx" "eightg_only_pld_mode_rx" "eightg_pcie_g12_hip_mode_rx" "eightg_pcie_g12_pld_mode_rx" "pcs_direct_mode_rx" "prbs_mode_rx" "teng_basic_mode_rx" "teng_krfec_mode_rx" "teng_sfis_sdi_mode_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter [29:0]   hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_rx_clk_hz                            = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_prot_mode_rx                             = "disabled_prot_mode_rx"                                                   ,//"basic_10gpcs_krfec_rx" "basic_10gpcs_rx" "basic_8gpcs_rm_disable_rx" "basic_8gpcs_rm_enable_rx" "cpri_8b10b_rx" "disabled_prot_mode_rx" "fortyg_basekr_krfec_rx" "gige_1588_rx" "gige_rx" "interlaken_rx" "pcie_g1_capable_rx" "pcie_g2_capable_rx" "pcie_g3_capable_rx" "pcs_direct_rx" "prbs_rx" "prp_krfec_rx" "prp_rx" "sfis_rx" "teng_1588_basekr_krfec_rx" "teng_1588_baser_rx" "teng_basekr_krfec_rx" "teng_baser_rx" "teng_sdi_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode    = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_rx              = "teng_mode_rx"                                                            ,//"non_teng_mode_rx" "teng_mode_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_rx      = "single_rx"                                                               ,//"double_rx" "single_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode                  = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_rx                     = "single_rx"                                                               ,//"double_rx" "single_rx"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_speed_grade                              = "e2"                                                                      ,//"e2" "e3" "e4" "i2" "i3" "i4"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_sup_mode                                 = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_rx_pld_pcs_interface_hd_pcs_channel_transparent_pcs_rx                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_rx_pld_pcs_interface_pcs_rx_block_sel                                        = "pcs_direct"                                                              ,//"eightg" "pcs_direct" "teng"
	parameter          hssi_rx_pld_pcs_interface_pcs_rx_clk_out_sel                                      = "teng_clk_out"                                                            ,//"eightg_clk_out" "pma_rx_clk" "pma_rx_clk_user" "teng_clk_out"
	parameter          hssi_rx_pld_pcs_interface_pcs_rx_clk_sel                                          = "pld_rx_clk"                                                              ,//"pcs_rx_clk" "pld_rx_clk"
	parameter          hssi_rx_pld_pcs_interface_pcs_rx_hip_clk_en                                       = "hip_rx_enable"                                                           ,//"hip_rx_disable" "hip_rx_enable"
	parameter          hssi_rx_pld_pcs_interface_pcs_rx_output_sel                                       = "teng_output"                                                             ,//"krfec_output" "teng_output"
	parameter          hssi_rx_pld_pcs_interface_silicon_rev                                             = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_tx_pcs_pma_interface_bypass_pma_txelecidle                                   = "false"                                                                   ,//"false" "true"
	parameter          hssi_tx_pcs_pma_interface_channel_operation_mode                                  = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pcs_pma_interface_lpbk_en                                                 = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pcs_pma_interface_master_clk_sel                                          = "master_tx_pma_clk"                                                       ,//"master_refclk_dig" "master_tx_pma_clk"
	parameter          hssi_tx_pcs_pma_interface_pcie_sub_prot_mode_tx                                   = "other_prot_mode"                                                         ,//"other_prot_mode" "pipe_g12" "pipe_g3"
	parameter          hssi_tx_pcs_pma_interface_pldif_datawidth_mode                                    = "pldif_data_10bit"                                                        ,//"pldif_data_10bit" "pldif_data_8bit"
	parameter          hssi_tx_pcs_pma_interface_pma_dw_tx                                               = "pma_8b_tx"                                                               ,//"pcie_g3_dyn_dw_tx" "pma_10b_tx" "pma_16b_tx" "pma_20b_tx" "pma_32b_tx" "pma_40b_tx" "pma_64b_tx" "pma_8b_tx"
	parameter          hssi_tx_pcs_pma_interface_pma_if_dft_en                                           = "dft_dis"                                                                 ,//"dft_dis" "dft_en"
	parameter          hssi_tx_pcs_pma_interface_pmagate_en                                              = "pmagate_dis"                                                             ,//"pmagate_dis" "pmagate_en"
	parameter          hssi_tx_pcs_pma_interface_prbs9_dwidth                                            = "prbs9_64b"                                                               ,//"prbs9_10b" "prbs9_64b"
	parameter          hssi_tx_pcs_pma_interface_prbs_clken                                              = "prbs_clk_dis"                                                            ,//"prbs_clk_dis" "prbs_clk_en"
	parameter          hssi_tx_pcs_pma_interface_prbs_gen_pat                                            = "prbs_gen_dis"                                                            ,//"prbs_15" "prbs_23" "prbs_31" "prbs_7" "prbs_9" "prbs_gen_dis"
	parameter          hssi_tx_pcs_pma_interface_prot_mode_tx                                            = "disabled_prot_mode_tx"                                                   ,//"disabled_prot_mode_tx" "eightg_basic_mode_tx" "eightg_g3_pcie_g3_hip_mode_tx" "eightg_g3_pcie_g3_pld_mode_tx" "eightg_only_pld_mode_tx" "eightg_pcie_g12_hip_mode_tx" "eightg_pcie_g12_pld_mode_tx" "pcs_direct_mode_tx" "prbs_mode_tx" "sqwave_mode_tx" "teng_basic_mode_tx" "teng_krfec_mode_tx" "teng_sfis_sdi_mode_tx" "uhsif_direct_mode_tx" "uhsif_reg_mode_tx"
	parameter          hssi_tx_pcs_pma_interface_silicon_rev                                             = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          hssi_tx_pcs_pma_interface_sq_wave_num                                             = "sq_wave_4"                                                               ,//"sq_wave_1" "sq_wave_4" "sq_wave_6" "sq_wave_8" "sq_wave_default"
	parameter          hssi_tx_pcs_pma_interface_sqwgen_clken                                            = "sqwgen_clk_dis"                                                          ,//"sqwgen_clk_dis" "sqwgen_clk_en"
	parameter          hssi_tx_pcs_pma_interface_sup_mode                                                = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pcs_pma_interface_tx_dyn_polarity_inversion                               = "tx_dyn_polinv_dis"                                                       ,//"tx_dyn_polinv_dis" "tx_dyn_polinv_en"
	parameter          hssi_tx_pcs_pma_interface_tx_pma_data_sel                                         = "pld_dir"                                                                 ,//"block_sel_default" "directed_uhsif_dat" "eight_g_pcs" "pcie_gen3" "pld_dir" "prbs_pat" "registered_uhsif_dat" "sq_wave_pat" "ten_g_pcs"
	parameter          hssi_tx_pcs_pma_interface_tx_static_polarity_inversion                            = "tx_stat_polinv_dis"                                                      ,//"tx_stat_polinv_dis" "tx_stat_polinv_en"
	parameter          hssi_tx_pcs_pma_interface_uhsif_cnt_step_filt_before_lock                         = "uhsif_filt_stepsz_b4lock_4"                                              ,//"uhsif_filt_stepsz_b4lock_2" "uhsif_filt_stepsz_b4lock_4" "uhsif_filt_stepsz_b4lock_6" "uhsif_filt_stepsz_b4lock_8"
	parameter [3:0]    hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_after_lock_value                  = 4'd11                                                                     ,//0:15
	parameter          hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_before_lock                       = "uhsif_filt_cntthr_b4lock_16"                                             ,//"uhsif_filt_cntthr_b4lock_16" "uhsif_filt_cntthr_b4lock_24" "uhsif_filt_cntthr_b4lock_32" "uhsif_filt_cntthr_b4lock_8"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dcn_test_update_period                            = "uhsif_dcn_test_period_4"                                                 ,//"uhsif_dcn_test_period_12" "uhsif_dcn_test_period_16" "uhsif_dcn_test_period_4" "uhsif_dcn_test_period_8"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dcn_testmode_enable                               = "uhsif_dcn_test_mode_disable"                                             ,//"uhsif_dcn_test_mode_disable" "uhsif_dcn_test_mode_enable"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dead_zone_count_thresh                            = "uhsif_dzt_cnt_thr_4"                                                     ,//"uhsif_dzt_cnt_thr_2" "uhsif_dzt_cnt_thr_4" "uhsif_dzt_cnt_thr_6" "uhsif_dzt_cnt_thr_8"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dead_zone_detection_enable                        = "uhsif_dzt_enable"                                                        ,//"uhsif_dzt_disable" "uhsif_dzt_enable"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dead_zone_obser_window                            = "uhsif_dzt_obr_win_32"                                                    ,//"uhsif_dzt_obr_win_16" "uhsif_dzt_obr_win_32" "uhsif_dzt_obr_win_48" "uhsif_dzt_obr_win_64"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dead_zone_skip_size                               = "uhsif_dzt_skipsz_8"                                                      ,//"uhsif_dzt_skipsz_12" "uhsif_dzt_skipsz_16" "uhsif_dzt_skipsz_4" "uhsif_dzt_skipsz_8"
	parameter          hssi_tx_pcs_pma_interface_uhsif_delay_cell_index_sel                              = "uhsif_index_internal"                                                    ,//"uhsif_index_cram" "uhsif_index_internal"
	parameter          hssi_tx_pcs_pma_interface_uhsif_delay_cell_margin                                 = "uhsif_dcn_margin_4"                                                      ,//"uhsif_dcn_margin_2" "uhsif_dcn_margin_3" "uhsif_dcn_margin_4" "uhsif_dcn_margin_5"
	parameter [7:0]    hssi_tx_pcs_pma_interface_uhsif_delay_cell_static_index_value                     = 8'd128                                                                    ,//0:255
	parameter          hssi_tx_pcs_pma_interface_uhsif_dft_dead_zone_control                             = "uhsif_dft_dz_det_val_0"                                                  ,//"uhsif_dft_dz_det_val_0" "uhsif_dft_dz_det_val_1"
	parameter          hssi_tx_pcs_pma_interface_uhsif_dft_up_filt_control                               = "uhsif_dft_up_val_0"                                                      ,//"uhsif_dft_up_val_0" "uhsif_dft_up_val_1"
	parameter          hssi_tx_pcs_pma_interface_uhsif_enable                                            = "uhsif_disable"                                                           ,//"uhsif_disable" "uhsif_enable"
	parameter          hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_after_lock                         = "uhsif_lkd_segsz_aflock_2048"                                             ,//"uhsif_lkd_segsz_aflock_1024" "uhsif_lkd_segsz_aflock_2048" "uhsif_lkd_segsz_aflock_4096" "uhsif_lkd_segsz_aflock_512"
	parameter          hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_before_lock                        = "uhsif_lkd_segsz_b4lock_32"                                               ,//"uhsif_lkd_segsz_b4lock_128" "uhsif_lkd_segsz_b4lock_16" "uhsif_lkd_segsz_b4lock_32" "uhsif_lkd_segsz_b4lock_64"
	parameter [3:0]    hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_after_lock_value              = 4'd8                                                                      ,//0:15
	parameter [3:0]    hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_before_lock_value             = 4'd8                                                                      ,//0:15
	parameter [3:0]    hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_after_lock_value             = 4'd3                                                                      ,//0:15
	parameter [3:0]    hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_before_lock_value            = 4'd3                                                                      ,//0:15
	parameter          hssi_tx_pld_pcs_interface_hd_g3pcs_prot_mode                                      = "disabled_prot_mode"                                                      ,//"disabled_prot_mode" "pipe_g1" "pipe_g2" "pipe_g3"
	parameter          hssi_tx_pld_pcs_interface_hd_g3pcs_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_hd_krfec_channel_operation_mode                         = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_krfec_low_latency_en_tx                              = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_krfec_lpbk_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_krfec_prot_mode_tx                                   = "disabled_prot_mode_tx"                                                   ,//"basic_mode_tx" "disabled_prot_mode_tx" "fortyg_basekr_mode_tx" "teng_1588_basekr_mode_tx" "teng_basekr_mode_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_krfec_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_channel_operation_mode                         = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_fifo_mode_tx                                   = "fifo_tx"                                                                 ,//"fastreg_tx" "fifo_tx" "reg_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_hip_mode                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_lpbk_en                                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_pma_dw_tx                                      = "pma_8b_tx"                                                               ,//"pma_10b_tx" "pma_16b_tx" "pma_20b_tx" "pma_8b_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_prot_mode_tx                                   = "disabled_prot_mode_tx"                                                   ,//"basic_tx" "cpri_rx_tx_tx" "cpri_tx" "disabled_prot_mode_tx" "gige_1588_tx" "gige_tx" "pipe_g1_tx" "pipe_g2_tx" "pipe_g3_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs8g_sup_mode                                       = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_tx                         = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_channel_operation_mode                        = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_fifo_mode_tx                                  = "fifo_tx"                                                                 ,//"fastreg_tx" "fifo_tx" "reg_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_low_latency_en_tx                             = "enable"                                                                  ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_lpbk_en                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_pma_dw_tx                                     = "pma_64b_tx"                                                              ,//"pma_32b_tx" "pma_40b_tx" "pma_64b_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_prot_mode_tx                                  = "disabled_prot_mode_tx"                                                   ,//"basic_krfec_mode_tx" "basic_mode_tx" "disabled_prot_mode_tx" "interlaken_mode_tx" "sfis_mode_tx" "teng_1588_krfec_mode_tx" "teng_1588_mode_tx" "teng_baser_krfec_mode_tx" "teng_baser_mode_tx" "teng_sdi_mode_tx" "test_prp_krfec_mode_tx" "test_prp_mode_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_tx                          = "single_tx"                                                               ,//"double_tx" "single_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs10g_sup_mode                                      = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode                   = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx                    = "individual_tx"                                                           ,//"ctrl_master_tx" "ctrl_slave_abv_tx" "ctrl_slave_blw_tx" "individual_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en                       = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_func_mode                                = "disable"                                                                 ,//"disable" "enable"
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz                              = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_hip_en                                   = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en                             = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_low_latency_en_tx                        = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_lpbk_en                                  = "disable"                                                                 ,//"disable" "enable"
	parameter [19:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_ac_pwr_uw_per_mhz                 = 20'd0                                                                     ,//0:1048575
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_pwr_scaling_clk                   = "pma_tx_clk"                                                              ,//"pma_tx_clk"
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz    = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_tx                         = "fifo_tx"                                                                 ,//"fastreg_tx" "fifo_tx" "reg_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en                      = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_tx                      = "disabled_prot_mode_tx"                                                   ,//"disabled_prot_mode_tx" "eightg_and_g3_fastreg_mode_tx" "eightg_and_g3_pld_fifo_mode_tx" "eightg_and_g3_reg_mode_hip_tx" "eightg_and_g3_reg_mode_tx" "pcs_direct_fastreg_mode_tx" "teng_and_krfec_fastreg_mode_tx" "teng_and_krfec_pld_fifo_mode_tx" "teng_and_krfec_reg_mode_tx" "teng_fastreg_mode_tx" "teng_pld_fifo_mode_tx" "teng_reg_mode_tx" "uhsif_mode_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz   = 30'd0                                                                     ,//0:1073741823
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_tx_clk_hz                            = 30'd0                                                                     ,//0:1073741823
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_uhsif_tx_clk_hz                      = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_dw_tx                                = "pma_8b_tx"                                                               ,//"pcie_g3_dyn_dw_tx" "pma_10b_tx" "pma_16b_tx" "pma_20b_tx" "pma_32b_tx" "pma_40b_tx" "pma_64b_tx" "pma_8b_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode            = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_ctrl_plane_bonding                = "individual"                                                              ,//"ctrl_master" "ctrl_slave_abv" "ctrl_slave_blw" "individual"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en                           = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_tx                         = "pma_8b_tx"                                                               ,//"pcie_g3_dyn_dw_tx" "pma_10b_tx" "pma_16b_tx" "pma_20b_tx" "pma_32b_tx" "pma_40b_tx" "pma_64b_tx" "pma_8b_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_tx                      = "disabled_prot_mode_tx"                                                   ,//"disabled_prot_mode_tx" "eightg_basic_mode_tx" "eightg_g3_pcie_g3_hip_mode_tx" "eightg_g3_pcie_g3_pld_mode_tx" "eightg_only_pld_mode_tx" "eightg_pcie_g12_hip_mode_tx" "eightg_pcie_g12_pld_mode_tx" "pcs_direct_mode_tx" "prbs_mode_tx" "sqwave_mode_tx" "teng_basic_mode_tx" "teng_krfec_mode_tx" "teng_sfis_sdi_mode_tx" "uhsif_direct_mode_tx" "uhsif_reg_mode_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode                          = "disable"                                                                 ,//"disable" "enable"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode                          = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter [29:0]   hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_tx_clk_hz                            = 30'd0                                                                     ,//0:1073741823
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx                             = "disabled_prot_mode_tx"                                                   ,//"basic_10gpcs_krfec_tx" "basic_10gpcs_tx" "basic_8gpcs_tx" "cpri_8b10b_tx" "disabled_prot_mode_tx" "fortyg_basekr_krfec_tx" "gige_1588_tx" "gige_tx" "interlaken_tx" "pcie_g1_capable_tx" "pcie_g2_capable_tx" "pcie_g3_capable_tx" "pcs_direct_tx" "prbs_tx" "prp_krfec_tx" "prp_tx" "sfis_tx" "sqwave_tx" "teng_1588_basekr_krfec_tx" "teng_1588_baser_tx" "teng_basekr_krfec_tx" "teng_baser_tx" "teng_sdi_tx" "uhsif_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode    = "tx_rx_pair_enabled"                                                      ,//"tx_rx_independent" "tx_rx_pair_enabled"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_tx              = "teng_mode_tx"                                                            ,//"non_teng_mode_tx" "teng_mode_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_tx      = "single_tx"                                                               ,//"double_tx" "single_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode                  = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_tx                     = "single_tx"                                                               ,//"double_tx" "single_tx"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_speed_grade                              = "e2"                                                                      ,//"e2" "e3" "e4" "i2" "i3" "i4"
	parameter          hssi_tx_pld_pcs_interface_hd_pcs_channel_sup_mode                                 = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_clk_out_sel                                      = "teng_clk_out"                                                            ,//"eightg_clk_out" "pma_tx_clk" "pma_tx_clk_user" "teng_clk_out"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_clk_source                                       = "teng"                                                                    ,//"eightg" "pma_clk" "teng"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_data_source                                      = "hip_disable"                                                             ,//"hip_disable" "hip_enable"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_en                                    = "delay1_clk_disable"                                                      ,//"delay1_clk_disable" "delay1_clk_enable"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_sel                                   = "pld_tx_clk"                                                              ,//"pcs_tx_clk" "pld_tx_clk"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay1_ctrl                                      = "delay1_path0"                                                            ,//"delay1_path0" "delay1_path1" "delay1_path2" "delay1_path3" "delay1_path4"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay1_data_sel                                  = "one_ff_delay"                                                            ,//"one_ff_delay" "two_ff_delay"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay2_clk_en                                    = "delay2_clk_disable"                                                      ,//"delay2_clk_disable" "delay2_clk_enable"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_delay2_ctrl                                      = "delay2_path0"                                                            ,//"delay2_path0" "delay2_path1" "delay2_path2" "delay2_path3" "delay2_path4"
	parameter          hssi_tx_pld_pcs_interface_pcs_tx_output_sel                                       = "teng_output"                                                             ,//"krfec_output" "teng_output"
	parameter          hssi_tx_pld_pcs_interface_silicon_rev                                             = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_adapt_adapt_mode                                                              = "ctle_dfe_tap1"                                                           ,//"ctle_dfe" "ctle_dfe_mode_2" "ctle_dfe_mode_3" "ctle_dfe_tap1" "ctle_only" "ctle_only_mode_2" "dfe_only" "manual"
	parameter          pma_adapt_adp_ac_ctle_cal_win                                                     = "radp_ac_ctle_cal_win_4"                                                  ,//"radp_ac_ctle_cal_win_1" "radp_ac_ctle_cal_win_2" "radp_ac_ctle_cal_win_4" "radp_ac_ctle_cal_win_8"
	parameter          pma_adapt_adp_ac_ctle_cocurrent_mode_sel                                          = "radp_ac_ctle_cocurrent_mode_sel_mode_1"                                  ,//"radp_ac_ctle_cocurrent_mode_sel_mode_1" "radp_ac_ctle_cocurrent_mode_sel_mode_2"
	parameter          pma_adapt_adp_ac_ctle_en                                                          = "radp_ac_ctle_en_enable"                                                  ,//"radp_ac_ctle_en_disable" "radp_ac_ctle_en_enable"
	parameter          pma_adapt_adp_ac_ctle_hold_en                                                     = "radp_ac_ctle_hold_en_not_hold"                                           ,//"radp_ac_ctle_hold_en_hold" "radp_ac_ctle_hold_en_not_hold"
	parameter          pma_adapt_adp_ac_ctle_initial_load                                                = "radp_ac_ctle_initial_load_0"                                             ,//"radp_ac_ctle_initial_load_0" "radp_ac_ctle_initial_load_1"
	parameter          pma_adapt_adp_ac_ctle_initial_value                                               = "radp_ac_ctle_initial_value_2"                                            ,//"radp_ac_ctle_initial_value_0" "radp_ac_ctle_initial_value_2" "radp_ac_ctle_initial_value_4" "radp_ac_ctle_initial_value_8"
	parameter          pma_adapt_adp_ac_ctle_mode_sel                                                    = "radp_ac_ctle_mode_sel_concurrent"                                        ,//"radp_ac_ctle_mode_sel_concurrent" "radp_ac_ctle_mode_sel_serial"
	parameter          pma_adapt_adp_ac_ctle_ph1_win                                                     = "radp_ac_ctle_ph1_win_2p19"                                               ,//"radp_ac_ctle_ph1_win_2p17" "radp_ac_ctle_ph1_win_2p19" "radp_ac_ctle_ph1_win_2p21" "radp_ac_ctle_ph1_win_2p23"
	parameter          pma_adapt_adp_adapt_control_sel                                                   = "radp_adapt_control_sel_from_cram"                                        ,//"radp_adapt_control_sel_from_adp" "radp_adapt_control_sel_from_cram"
	parameter          pma_adapt_adp_adapt_start                                                         = "radp_adapt_start_0"                                                      ,//"radp_adapt_start_0" "radp_adapt_start_1"
	parameter          pma_adapt_adp_bist_datapath_en                                                    = "radp_bist_datapath_en_disable"                                           ,//"radp_bist_datapath_en_disable" "radp_bist_datapath_en_enable"
	parameter          pma_adapt_adp_bist_errcount_rstn                                                  = "radp_bist_errcount_rstn_0"                                               ,//"radp_bist_errcount_rstn_0" "radp_bist_errcount_rstn_1"
	parameter          pma_adapt_adp_bist_mode_sel                                                       = "radp_bist_mode_sel_prbs31"                                               ,//"radp_bist_mode_sel_prbs15" "radp_bist_mode_sel_prbs23" "radp_bist_mode_sel_prbs31" "radp_bist_mode_sel_prbs7"
	parameter          pma_adapt_adp_clkgate_enb                                                         = "radp_clkgate_enb_disable"                                                ,//"radp_clkgate_enb_disable" "radp_clkgate_enb_enable"
	parameter          pma_adapt_adp_clkout_div_sel                                                      = "radp_clkout_div_sel_div2_4cycle"                                         ,//"radp_clkout_div_sel_div2_4cycle" "radp_clkout_div_sel_div4_8cycle"
	parameter          pma_adapt_adp_ctle_bypass_ac                                                      = "radp_ctle_bypass_ac_not_bypass"                                          ,//"radp_ctle_bypass_ac_bypass" "radp_ctle_bypass_ac_not_bypass"
	parameter          pma_adapt_adp_ctle_bypass_dc                                                      = "radp_ctle_bypass_dc_not_bypass"                                          ,//"radp_ctle_bypass_dc_bypass" "radp_ctle_bypass_dc_not_bypass"
	parameter [3:0]    pma_adapt_adp_dc_ctle_accum_depth                                                 = 4'd8                                                                      ,//0:15
	parameter          pma_adapt_adp_dc_ctle_en                                                          = "radp_dc_ctle_en_enable"                                                  ,//"radp_dc_ctle_en_disable" "radp_dc_ctle_en_enable"
	parameter          pma_adapt_adp_dc_ctle_hold_en                                                     = "radp_dc_ctle_hold_en_not_hold"                                           ,//"radp_dc_ctle_hold_en_hold" "radp_dc_ctle_hold_en_not_hold"
	parameter          pma_adapt_adp_dc_ctle_initial_load                                                = "radp_dc_ctle_initial_load_0"                                             ,//"radp_dc_ctle_initial_load_0" "radp_dc_ctle_initial_load_1"
	parameter          pma_adapt_adp_dc_ctle_initial_value                                               = "radp_dc_ctle_initial_value_16"                                           ,//"radp_dc_ctle_initial_value_0" "radp_dc_ctle_initial_value_16" "radp_dc_ctle_initial_value_32" "radp_dc_ctle_initial_value_8"
	parameter          pma_adapt_adp_dc_ctle_mode0_win_size                                              = "radp_dc_ctle_mode0_win_size_4_taps"                                      ,//"radp_dc_ctle_mode0_win_size_1_taps" "radp_dc_ctle_mode0_win_size_2_taps" "radp_dc_ctle_mode0_win_size_3_taps" "radp_dc_ctle_mode0_win_size_4_taps"
	parameter [3:0]    pma_adapt_adp_dc_ctle_mode0_win_start                                             = 4'd0                                                                      ,//0:15
	parameter [3:0]    pma_adapt_adp_dc_ctle_mode1_h1_ratio                                              = 4'd8                                                                      ,//0:15
	parameter [3:0]    pma_adapt_adp_dc_ctle_mode2_h2_limit                                              = 4'd7                                                                      ,//0:15
	parameter          pma_adapt_adp_dc_ctle_mode_sel                                                    = "radp_dc_ctle_mode_sel_mode_2"                                            ,//"radp_dc_ctle_mode_sel_mode_0" "radp_dc_ctle_mode_sel_mode_1" "radp_dc_ctle_mode_sel_mode_2"
	parameter          pma_adapt_adp_dc_ctle_onetime                                                     = "radp_dc_ctle_onetime_disable"                                            ,//"radp_dc_ctle_onetime_disable" "radp_dc_ctle_onetime_enable"
	parameter          pma_adapt_adp_dc_ctle_onetime_threshold                                           = "radp_dc_ctle_onetime_threshold_256"                                      ,//"radp_dc_ctle_onetime_threshold_1024" "radp_dc_ctle_onetime_threshold_128" "radp_dc_ctle_onetime_threshold_2048" "radp_dc_ctle_onetime_threshold_256" "radp_dc_ctle_onetime_threshold_32" "radp_dc_ctle_onetime_threshold_4096" "radp_dc_ctle_onetime_threshold_512" "radp_dc_ctle_onetime_threshold_64"
	parameter [3:0]    pma_adapt_adp_dfe_accum_depth                                                     = 4'd8                                                                      ,//0:15
	parameter          pma_adapt_adp_dfe_en                                                              = "radp_dfe_en_enable"                                                      ,//"radp_dfe_en_disable" "radp_dfe_en_enable"
	parameter          pma_adapt_adp_dfe_fxtap_bypass                                                    = "radp_dfe_fxtap_bypass_not_bypass"                                        ,//"radp_dfe_fxtap_bypass_bypass" "radp_dfe_fxtap_bypass_not_bypass"
	parameter          pma_adapt_adp_dfe_hold_en                                                         = "radp_dfe_hold_en_not_hold"                                               ,//"radp_dfe_hold_en_hold" "radp_dfe_hold_en_not_hold"
	parameter          pma_adapt_adp_dfe_hold_sel                                                        = "radp_dfe_hold_sel_no"                                                    ,//"radp_dfe_hold_sel_h1" "radp_dfe_hold_sel_h10toh15" "radp_dfe_hold_sel_h1toh3" "radp_dfe_hold_sel_h2" "radp_dfe_hold_sel_h2h3" "radp_dfe_hold_sel_h3" "radp_dfe_hold_sel_h4toh15" "radp_dfe_hold_sel_no"
	parameter          pma_adapt_adp_dfe_onetime                                                         = "radp_dfe_onetime_disable"                                                ,//"radp_dfe_onetime_disable" "radp_dfe_onetime_enable"
	parameter          pma_adapt_adp_dfe_onetime_threshold                                               = "radp_dfe_onetime_threshold_2048"                                         ,//"radp_dfe_onetime_threshold_1024" "radp_dfe_onetime_threshold_128" "radp_dfe_onetime_threshold_2048" "radp_dfe_onetime_threshold_256" "radp_dfe_onetime_threshold_32" "radp_dfe_onetime_threshold_4096" "radp_dfe_onetime_threshold_512" "radp_dfe_onetime_threshold_64"
	parameter          pma_adapt_adp_dfe_tap1_initial_load                                               = "radp_dfe_tap1_initial_load_0"                                            ,//"radp_dfe_tap1_initial_load_0" "radp_dfe_tap1_initial_load_1"
	parameter          pma_adapt_adp_dfe_tap1_initial_value                                              = "radp_dfe_tap1_initial_value_0"                                           ,//"radp_dfe_tap1_initial_value_0" "radp_dfe_tap1_initial_value_16" "radp_dfe_tap1_initial_value_32" "radp_dfe_tap1_initial_value_8"
	parameter          pma_adapt_adp_dfe_tap_sel_en                                                      = "radp_dfe_tap_sel_en_no"                                                  ,//"radp_dfe_tap_sel_en_h10to15" "radp_dfe_tap_sel_en_h1toh15" "radp_dfe_tap_sel_en_h4toh15" "radp_dfe_tap_sel_en_no"
	parameter [3:0]    pma_adapt_adp_dlev_accum_depth                                                    = 4'd6                                                                      ,//0:15
	parameter          pma_adapt_adp_dlev_bypass                                                         = "radp_dlev_bypass_not_bypass"                                             ,//"radp_dlev_bypass_bypass" "radp_dlev_bypass_not_bypass"
	parameter          pma_adapt_adp_dlev_en                                                             = "radp_dlev_en_enable"                                                     ,//"radp_dlev_en_disable" "radp_dlev_en_enable"
	parameter          pma_adapt_adp_dlev_hold_en                                                        = "radp_dlev_hold_en_not_hold"                                              ,//"radp_dlev_hold_en_hold" "radp_dlev_hold_en_not_hold"
	parameter          pma_adapt_adp_dlev_initial_load                                                   = "radp_dlev_initial_load_0"                                                ,//"radp_dlev_initial_load_0" "radp_dlev_initial_load_1"
	parameter          pma_adapt_adp_dlev_initial_value                                                  = "radp_dlev_initial_value_38"                                              ,//"radp_dlev_initial_value_16" "radp_dlev_initial_value_24" "radp_dlev_initial_value_38" "radp_dlev_initial_value_48"
	parameter          pma_adapt_adp_dlev_onetime                                                        = "radp_dlev_onetime_disable"                                               ,//"radp_dlev_onetime_disable" "radp_dlev_onetime_enable"
	parameter          pma_adapt_adp_dlev_onetime_threshold                                              = "radp_dlev_onetime_threshold_4096"                                        ,//"radp_dlev_onetime_threshold_1024" "radp_dlev_onetime_threshold_128" "radp_dlev_onetime_threshold_2048" "radp_dlev_onetime_threshold_256" "radp_dlev_onetime_threshold_32" "radp_dlev_onetime_threshold_4096" "radp_dlev_onetime_threshold_512" "radp_dlev_onetime_threshold_64"
	parameter          pma_adapt_adp_dlev_sel                                                            = "radp_dlev_sel_mux"                                                       ,//"radp_dlev_sel_avg" "radp_dlev_sel_coef_n" "radp_dlev_sel_coef_p" "radp_dlev_sel_mux"
	parameter          pma_adapt_adp_force_freqlock                                                      = "radp_force_freqlock_use"                                                 ,//"radp_force_freqlock_ignore" "radp_force_freqlock_use"
	parameter          pma_adapt_adp_frame_capture                                                       = "radp_frame_capture_0"                                                    ,//"radp_frame_capture_0" "radp_frame_capture_1"
	parameter          pma_adapt_adp_frame_en                                                            = "radp_frame_en_disable"                                                   ,//"radp_frame_en_disable" "radp_frame_en_enable"
	parameter          pma_adapt_adp_frame_odi_sel                                                       = "radp_frame_odi_sel_deser_err"                                            ,//"radp_frame_odi_sel_deser_err" "radp_frame_odi_sel_deser_odi"
	parameter          pma_adapt_adp_frame_out_sel                                                       = "radp_frame_out_sel_select_a"                                             ,//"radp_frame_out_sel_select_a" "radp_frame_out_sel_select_b"
	parameter          pma_adapt_adp_load_sig_sel                                                        = "radp_load_sig_sel_from_interanl"                                         ,//"radp_load_sig_sel_from_cram" "radp_load_sig_sel_from_interanl"
	parameter [3:0]    pma_adapt_adp_oc_accum_depth                                                      = 4'd11                                                                     ,//0:15
	parameter          pma_adapt_adp_oc_bypass                                                           = "radp_oc_bypass_bypass"                                                   ,//"radp_oc_bypass_bypass" "radp_oc_bypass_not_bypass"
	parameter          pma_adapt_adp_oc_en                                                               = "radp_oc_en_disable"                                                      ,//"radp_oc_en_disable" "radp_oc_en_enable"
	parameter          pma_adapt_adp_oc_hold_en                                                          = "radp_oc_hold_en_not_hold"                                                ,//"radp_oc_hold_en_hold" "radp_oc_hold_en_not_hold"
	parameter          pma_adapt_adp_oc_initial_load                                                     = "radp_oc_initial_load_0"                                                  ,//"radp_oc_initial_load_0" "radp_oc_initial_load_1"
	parameter          pma_adapt_adp_oc_initial_sign                                                     = "radp_oc_initial_sign_0"                                                  ,//"radp_oc_initial_sign_0" "radp_oc_initial_sign_1"
	parameter          pma_adapt_adp_oc_onetime                                                          = "radp_oc_onetime_disable"                                                 ,//"radp_oc_onetime_disable" "radp_oc_onetime_enable"
	parameter          pma_adapt_adp_oc_onetime_threshold                                                = "radp_oc_onetime_threshold_1024"                                          ,//"radp_oc_onetime_threshold_1024" "radp_oc_onetime_threshold_128" "radp_oc_onetime_threshold_2048" "radp_oc_onetime_threshold_256" "radp_oc_onetime_threshold_32" "radp_oc_onetime_threshold_4096" "radp_oc_onetime_threshold_512" "radp_oc_onetime_threshold_64"
	parameter          pma_adapt_adp_odi_bit_sel                                                         = "radp_odi_bit_sel_all_bits"                                               ,//"radp_odi_bit_sel_all_bits" "radp_odi_bit_sel_even_bits" "radp_odi_bit_sel_odd_bits"
	parameter          pma_adapt_adp_odi_control_sel                                                     = "radp_odi_control_sel_from_cram"                                          ,//"radp_odi_control_sel_from_adp" "radp_odi_control_sel_from_cram"
	parameter          pma_adapt_adp_odi_count_threshold                                                 = "radp_odi_count_threshold_1e6"                                            ,//"radp_odi_count_threshold_1e6" "radp_odi_count_threshold_1e7" "radp_odi_count_threshold_1e8" "radp_odi_count_threshold_1e9" "radp_odi_count_threshold_2p16" "radp_odi_count_threshold_3e8" "radp_odi_count_threshold_4p29e9" "radp_odi_count_threshold_nonstop"
	parameter          pma_adapt_adp_odi_dfe_spec_en                                                     = "radp_odi_dfe_spec_en_enable"                                             ,//"radp_odi_dfe_spec_en_disable" "radp_odi_dfe_spec_en_enable"
	parameter          pma_adapt_adp_odi_dlev_sel                                                        = "radp_odi_dlev_sel_0"                                                     ,//"radp_odi_dlev_sel_0" "radp_odi_dlev_sel_1"
	parameter          pma_adapt_adp_odi_en                                                              = "radp_odi_en_disable"                                                     ,//"radp_odi_en_disable" "radp_odi_en_enable"
	parameter          pma_adapt_adp_odi_mode                                                            = "radp_odi_mode_detect_errdata"                                            ,//"radp_odi_mode_detect_corrdata" "radp_odi_mode_detect_errdata"
	parameter          pma_adapt_adp_odi_rstn                                                            = "radp_odi_rstn_1"                                                         ,//"radp_odi_rstn_0" "radp_odi_rstn_1"
	parameter          pma_adapt_adp_odi_spec_sel                                                        = "radp_odi_spec_sel_0"                                                     ,//"radp_odi_spec_sel_0" "radp_odi_spec_sel_1"
	parameter          pma_adapt_adp_odi_start                                                           = "radp_odi_start_0"                                                        ,//"radp_odi_start_0" "radp_odi_start_1"
	parameter          pma_adapt_adp_pat_dlev_sign_avg_win                                               = "radp_pat_dlev_sign_avg_win_2x"                                           ,//"radp_pat_dlev_sign_avg_win_1x" "radp_pat_dlev_sign_avg_win_2x" "radp_pat_dlev_sign_avg_win_4x" "radp_pat_dlev_sign_avg_win_8x"
	parameter          pma_adapt_adp_pat_dlev_sign_force                                                 = "radp_pat_dlev_sign_force_generated_internally"                           ,//"radp_pat_dlev_sign_force_determined_by_cram" "radp_pat_dlev_sign_force_generated_internally"
	parameter          pma_adapt_adp_pat_dlev_sign_value                                                 = "radp_pat_dlev_sign_value_0"                                              ,//"radp_pat_dlev_sign_value_0" "radp_pat_dlev_sign_value_1"
	parameter          pma_adapt_adp_pat_spec_sign_avg_win                                               = "radp_pat_spec_sign_avg_win_256"                                          ,//"radp_pat_spec_sign_avg_win_1024" "radp_pat_spec_sign_avg_win_128" "radp_pat_spec_sign_avg_win_2048" "radp_pat_spec_sign_avg_win_256" "radp_pat_spec_sign_avg_win_32" "radp_pat_spec_sign_avg_win_4096" "radp_pat_spec_sign_avg_win_512" "radp_pat_spec_sign_avg_win_64"
	parameter          pma_adapt_adp_pat_spec_sign_force                                                 = "radp_pat_spec_sign_force_generated_internally"                           ,//"radp_pat_spec_sign_force_determined_by_cram" "radp_pat_spec_sign_force_generated_internally"
	parameter          pma_adapt_adp_pat_spec_sign_value                                                 = "radp_pat_spec_sign_value_0"                                              ,//"radp_pat_spec_sign_value_0" "radp_pat_spec_sign_value_1"
	parameter          pma_adapt_adp_pat_trans_filter                                                    = "radp_pat_trans_filter_5"                                                 ,//"radp_pat_trans_filter_2" "radp_pat_trans_filter_3" "radp_pat_trans_filter_4" "radp_pat_trans_filter_5"
	parameter          pma_adapt_adp_pat_trans_only_en                                                   = "radp_pat_trans_only_en_enable"                                           ,//"radp_pat_trans_only_en_disable" "radp_pat_trans_only_en_enable"
	parameter          pma_adapt_adp_pcie_adp_bypass                                                     = "radp_pcie_adp_bypass_no"                                                 ,//"radp_pcie_adp_bypass_bypass" "radp_pcie_adp_bypass_no"
	parameter          pma_adapt_adp_pcie_eqz                                                            = "radp_pcie_eqz_non_pcie_mode"                                             ,//"radp_pcie_eqz_non_pcie_mode" "radp_pcie_eqz_pcie_mode"
	parameter [3:0]    pma_adapt_adp_pcie_hold_sel                                                       = 4'd0                                                                      ,//0:15
	parameter          pma_adapt_adp_pcs_option                                                          = "radp_pcs_option_0"                                                       ,//"radp_pcs_option_0" "radp_pcs_option_1"
	parameter          pma_adapt_adp_po_actslp_ratio                                                     = "radp_po_actslp_ratio_10_percent"                                         ,//"radp_po_actslp_ratio_10_percent" "radp_po_actslp_ratio_1p25percent" "radp_po_actslp_ratio_25_percent" "radp_po_actslp_ratio_4_percent"
	parameter          pma_adapt_adp_po_en                                                               = "radp_po_en_disable"                                                      ,//"radp_po_en_disable" "radp_po_en_enable"
	parameter          pma_adapt_adp_po_gb_act2slp                                                       = "radp_po_gb_act2slp_288ns"                                                ,//"radp_po_gb_act2slp_1132ns" "radp_po_gb_act2slp_288ns" "radp_po_gb_act2slp_566ns" "radp_po_gb_act2slp_864ns"
	parameter          pma_adapt_adp_po_gb_slp2act                                                       = "radp_po_gb_slp2act_288ns"                                                ,//"radp_po_gb_slp2act_1132ns" "radp_po_gb_slp2act_288ns" "radp_po_gb_slp2act_566ns" "radp_po_gb_slp2act_864ns"
	parameter          pma_adapt_adp_po_initwait                                                         = "radp_po_initwait_10sec"                                                  ,//"radp_po_initwait_10sec" "radp_po_initwait_10us" "radp_po_initwait_20sec" "radp_po_initwait_5sec"
	parameter          pma_adapt_adp_po_sleep_win                                                        = "radp_po_sleep_win_2_sec"                                                 ,//"radp_po_sleep_win_0p5_sec" "radp_po_sleep_win_2_sec" "radp_po_sleep_win_5ms" "radp_po_sleep_win_8_sec"
	parameter [2:0]    pma_adapt_adp_reserved                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_adapt_adp_rstn                                                                = "radp_rstn_1"                                                             ,//"radp_rstn_0" "radp_rstn_1"
	parameter          pma_adapt_adp_status_sel                                                          = "radp_status_sel_0"                                                       ,//"radp_status_sel_0" "radp_status_sel_1" "radp_status_sel_10" "radp_status_sel_11" "radp_status_sel_12" "radp_status_sel_13" "radp_status_sel_14" "radp_status_sel_15" "radp_status_sel_16" "radp_status_sel_17" "radp_status_sel_18" "radp_status_sel_19" "radp_status_sel_2" "radp_status_sel_20" "radp_status_sel_21" "radp_status_sel_22" "radp_status_sel_23" "radp_status_sel_24" "radp_status_sel_25" "radp_status_sel_26" "radp_status_sel_27" "radp_status_sel_28" "radp_status_sel_29" "radp_status_sel_3" "radp_status_sel_30" "radp_status_sel_31" "radp_status_sel_32" "radp_status_sel_33" "radp_status_sel_34" "radp_status_sel_35" "radp_status_sel_36" "radp_status_sel_37" "radp_status_sel_38" "radp_status_sel_39" "radp_status_sel_4" "radp_status_sel_40" "radp_status_sel_41" "radp_status_sel_42" "radp_status_sel_43" "radp_status_sel_44" "radp_status_sel_45" "radp_status_sel_46" "radp_status_sel_47" "radp_status_sel_48" "radp_status_sel_49" "radp_status_sel_5" "radp_status_sel_50" "radp_status_sel_51" "radp_status_sel_52" "radp_status_sel_53" "radp_status_sel_54" "radp_status_sel_55" "radp_status_sel_56" "radp_status_sel_57" "radp_status_sel_58" "radp_status_sel_59" "radp_status_sel_6" "radp_status_sel_60" "radp_status_sel_61" "radp_status_sel_62" "radp_status_sel_63" "radp_status_sel_7" "radp_status_sel_8" "radp_status_sel_9"
	parameter [2:0]    pma_adapt_adp_tx_accum_depth                                                      = 3'd4                                                                      ,//0:7
	parameter          pma_adapt_adp_tx_adp_accumulate                                                   = "radp_tx_adp_accumulate_0"                                                ,//"radp_tx_adp_accumulate_0" "radp_tx_adp_accumulate_1"
	parameter          pma_adapt_adp_tx_adp_en                                                           = "radp_tx_adp_en_0"                                                        ,//"radp_tx_adp_en_0" "radp_tx_adp_en_1"
	parameter          pma_adapt_adp_tx_up_dn_flip                                                       = "radp_tx_up_dn_flip_0"                                                    ,//"radp_tx_up_dn_flip_0" "radp_tx_up_dn_flip_1"
	parameter [3:0]    pma_adapt_adp_vga_accum_depth                                                     = 4'd9                                                                      ,//0:15
	parameter          pma_adapt_adp_vga_bypass                                                          = "radp_vga_bypass_not_bypass"                                              ,//"radp_vga_bypass_bypass" "radp_vga_bypass_not_bypass"
	parameter          pma_adapt_adp_vga_ctle_low_limit                                                  = "radp_vga_ctle_low_limit_0"                                               ,//"radp_vga_ctle_low_limit_0" "radp_vga_ctle_low_limit_4"
	parameter [2:0]    pma_adapt_adp_vga_dlev_offset                                                     = 3'd4                                                                      ,//0:7
	parameter [4:0]    pma_adapt_adp_vga_dlev_target                                                     = 5'd15                                                                     ,//0:31
	parameter          pma_adapt_adp_vga_en                                                              = "radp_vga_en_enalbe"                                                      ,//"radp_vga_en_disable" "radp_vga_en_enalbe"
	parameter          pma_adapt_adp_vga_hold_en                                                         = "radp_vga_hold_en_not_hold"                                               ,//"radp_vga_hold_en_hold" "radp_vga_hold_en_not_hold"
	parameter          pma_adapt_adp_vga_initial_load                                                    = "radp_vga_initial_load_0"                                                 ,//"radp_vga_initial_load_0" "radp_vga_initial_load_1"
	parameter          pma_adapt_adp_vga_initial_value                                                   = "radp_vga_initial_value_4"                                                ,//"radp_vga_initial_value_0" "radp_vga_initial_value_16" "radp_vga_initial_value_4" "radp_vga_initial_value_8"
	parameter          pma_adapt_adp_vga_onetime                                                         = "radp_vga_onetime_disable"                                                ,//"radp_vga_onetime_disable" "radp_vga_onetime_enable"
	parameter          pma_adapt_adp_vga_onetime_threshold                                               = "radp_vga_onetime_threshold_512"                                          ,//"radp_vga_onetime_threshold_1024" "radp_vga_onetime_threshold_128" "radp_vga_onetime_threshold_2048" "radp_vga_onetime_threshold_256" "radp_vga_onetime_threshold_32" "radp_vga_onetime_threshold_4096" "radp_vga_onetime_threshold_512" "radp_vga_onetime_threshold_64"
	parameter          pma_adapt_advanced_mode                                                           = "false"                                                                   ,//"false" "true"
	parameter          pma_adapt_datarate_bps                                                            = "0"                                                                       ,//NOVAL
	parameter          pma_adapt_initial_settings                                                        = "true"                                                                    ,//"false" "true"
	parameter          pma_adapt_odi_mode                                                                = "odi_disable"                                                             ,//"odi_disable" "odi_enable"
	parameter          pma_adapt_optimal                                                                 = "false"                                                                   ,//"false" "true"
	parameter          pma_adapt_power_mode                                                              = "powsav_disable"                                                          ,//"powsav_disable" "powsav_enable"
	parameter          pma_adapt_powermode_ac_adaptation                                                 = "adapt_ac_off"                                                            ,//"adapt_ac_off" "adapt_ac_on"
	parameter          pma_adapt_powermode_ac_deser_adapt                                                = "adapt_deser_ac_off"                                                      ,//"adapt_deser_ac_100pc" "adapt_deser_ac_10pc" "adapt_deser_ac_1pc" "adapt_deser_ac_25pc" "adapt_deser_ac_4pc" "adapt_deser_ac_off"
	parameter          pma_adapt_powermode_ac_dfe_adapt                                                  = "adapt_dfe_ac_off"                                                        ,//"adapt_dfe_ac_100pc" "adapt_dfe_ac_10pc" "adapt_dfe_ac_1pc" "adapt_dfe_ac_25pc" "adapt_dfe_ac_4pc" "adapt_dfe_ac_off"
	parameter          pma_adapt_powermode_dc_adaptation                                                 = "powerdown_adapt"                                                         ,//"adapt_dc_on" "powerdown_adapt"
	parameter          pma_adapt_powermode_dc_deser_adapt                                                = "powerdown_adapt_deser"                                                   ,//"adapt_deser_dc_100pc" "adapt_deser_dc_10pc" "adapt_deser_dc_1pc" "adapt_deser_dc_25pc" "adapt_deser_dc_4pc" "powerdown_adapt_deser"
	parameter          pma_adapt_powermode_dc_dfe_adapt                                                  = "powerdown_adapt_dfe"                                                     ,//"adapt_dfe_dc_100pc" "adapt_dfe_dc_10pc" "adapt_dfe_dc_1pc" "adapt_dfe_dc_25pc" "adapt_dfe_dc_4pc" "powerdown_adapt_dfe"
	parameter          pma_adapt_prot_mode                                                               = "basic_rx"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "qpi_rx" "sata_rx"
	parameter          pma_adapt_sequencer_rx_path_rstn_overrideb                                        = "bypass_sequencer"                                                        ,//"bypass_sequencer" "use_sequencer"
	parameter          pma_adapt_sequencer_silicon_rev                                                   = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_adapt_silicon_rev                                                             = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_adapt_sup_mode                                                                = "user_mode"                                                               ,//"engineering_mode" "user_mode"
	parameter          pma_cdr_refclk_powerdown_mode                                                     = "powerdown"                                                               ,//"powerdown" "powerup"
	parameter          pma_cdr_refclk_receiver_detect_src                                                = "core_refclk_src"                                                         ,//"core_refclk_src" "iqclk_src"
	parameter          pma_cdr_refclk_refclk_select                                                      = "ref_iqclk0"                                                              ,//"adj_pll_clk" "coreclk" "fixed_clk" "iqtxrxclk0" "iqtxrxclk1" "iqtxrxclk2" "iqtxrxclk3" "iqtxrxclk4" "iqtxrxclk5" "lvpecl" "power_down" "ref_iqclk0" "ref_iqclk1" "ref_iqclk10" "ref_iqclk11" "ref_iqclk2" "ref_iqclk3" "ref_iqclk4" "ref_iqclk5" "ref_iqclk6" "ref_iqclk7" "ref_iqclk8" "ref_iqclk9"
	parameter          pma_cdr_refclk_silicon_rev                                                        = "14nm5"                                                                   ,//"14nm4cr2" "14nm4cr2ea" "14nm5" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_cgb_bitslip_enable                                                            = "enable_bitslip"                                                          ,//"disable_bitslip" "enable_bitslip"
	parameter          pma_cgb_bti_protected                                                             = "false"                                                                   ,//"false" "true"
	parameter          pma_cgb_cgb_bti_en                                                                = "cgb_bti_disable"                                                         ,//"cgb_bti_disable" "cgb_bti_enable"
	parameter          pma_cgb_cgb_power_down                                                            = "normal_cgb"                                                              ,//"normal_cgb" "power_down_cgb"
	parameter          pma_cgb_datarate_bps                                                              = "0"                                                                       ,//NOVAL
	parameter          pma_cgb_initial_settings                                                          = "false"                                                                   ,//"false" "true"
	parameter          pma_cgb_input_select_gen3                                                         = "not_used"                                                                ,//"cdr_txpll_b" "cdr_txpll_t" "fpll_bot" "fpll_top" "hfclk_x6_dn" "hfclk_x6_up" "hfclk_xn_dn" "hfclk_xn_up" "lcpll_bot" "lcpll_hs" "lcpll_top" "not_used" "same_ch_txpll"
	parameter          pma_cgb_input_select_x1                                                           = "not_used"                                                                ,//"cdr_txpll_b" "cdr_txpll_t" "fpll_bot" "fpll_top" "hfclk_x6_dn" "hfclk_x6_up" "hfclk_xn_dn" "hfclk_xn_up" "lcpll_bot" "lcpll_hs" "lcpll_top" "not_used" "same_ch_txpll"
	parameter          pma_cgb_input_select_xn                                                           = "not_used"                                                                ,//"not_used" "sel_cgb_loc" "sel_x6_dn" "sel_x6_up" "sel_xn_dn" "sel_xn_up"
	parameter          pma_cgb_observe_cgb_clocks                                                        = "observe_nothing"                                                         ,//"observe_cpulseout_bus" "observe_nothing" "observe_x1mux_out"
	parameter          pma_cgb_pcie_gen                                                                  = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          pma_cgb_pcie_gen3_bitwidth                                                        = "pciegen3_wide"                                                           ,//"pciegen3_narrow" "pciegen3_wide"
	parameter [11:0]   pma_cgb_power_rail_er                                                             = 12'd0                                                                     ,//0:4095
	parameter          pma_cgb_powermode_ac_cgb                                                          = "cgb_ac_off"                                                              ,//"cgb_ac_bti" "cgb_ac_hs" "cgb_ac_ls_1p0" "cgb_ac_ls_1p1" "cgb_ac_off"
	parameter          pma_cgb_powermode_dc_cgb                                                          = "powerdown_cgb"                                                           ,//"cgb_dc_bti" "cgb_dc_hs" "cgb_dc_ls_1p0" "cgb_dc_ls_1p1" "powerdown_cgb"
	parameter          pma_cgb_prot_mode                                                                 = "prot_off"                                                                ,//"basic_tx" "gpon_tx" "not_used" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "prot_off" "qpi_tx" "sata_tx"
	parameter          pma_cgb_ser_mode                                                                  = "sixty_four_bit"                                                          ,//"eight_bit" "forty_bit" "sixteen_bit" "sixty_four_bit" "ten_bit" "thirty_two_bit" "twenty_bit"
	parameter          pma_cgb_ser_powerdown                                                             = "normal_poweron_ser"                                                      ,//"normal_poweron_ser" "powerdown_ser"
	parameter          pma_cgb_silicon_rev                                                               = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_cgb_sup_mode                                                                  = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_cgb_tx_ucontrol_en                                                            = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_cgb_tx_ucontrol_pcie                                                          = "gen1"                                                                    ,//"gen1" "gen2" "gen3" "gen4"
	parameter          pma_cgb_tx_ucontrol_reset                                                         = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_cgb_uc_cgb_vreg_boost                                                         = "no_voltage_boost"                                                        ,//"boost_1_step" "boost_2_step" "boost_3_step" "boost_4_step" "boost_5_step" "boost_6_step" "boost_7_step" "no_voltage_boost"
	parameter          pma_cgb_uc_vcc_setting                                                            = "vcc_setting0"                                                            ,//"vcc_setting0" "vcc_setting1" "vcc_setting2" "vcc_setting3"
	parameter          pma_cgb_vccdreg_output                                                            = "vccdreg_nominal"                                                         ,//"vccdreg_neg_setting1" "vccdreg_neg_setting2" "vccdreg_neg_setting3" "vccdreg_neg_setting4" "vccdreg_nominal" "vccdreg_pos_setting1" "vccdreg_pos_setting10" "vccdreg_pos_setting11" "vccdreg_pos_setting12" "vccdreg_pos_setting13" "vccdreg_pos_setting14" "vccdreg_pos_setting15" "vccdreg_pos_setting16" "vccdreg_pos_setting17" "vccdreg_pos_setting18" "vccdreg_pos_setting19" "vccdreg_pos_setting2" "vccdreg_pos_setting20" "vccdreg_pos_setting21" "vccdreg_pos_setting22" "vccdreg_pos_setting23" "vccdreg_pos_setting24" "vccdreg_pos_setting25" "vccdreg_pos_setting26" "vccdreg_pos_setting27" "vccdreg_pos_setting3" "vccdreg_pos_setting4" "vccdreg_pos_setting5" "vccdreg_pos_setting6" "vccdreg_pos_setting7" "vccdreg_pos_setting8" "vccdreg_pos_setting9"
	parameter          pma_cgb_vreg_sel_ref                                                              = "sel_vccer_4ref"                                                          ,//"sel_vccer_4ref" "sel_vccet_4ref"
	parameter          pma_cgb_x1_div_m_sel                                                              = "divbypass"                                                               ,//"divby2" "divby4" "divby8" "divbypass"
	parameter          pma_pcie_gen_switch_silicon_rev                                                   = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_reset_sequencer_rx_path_rstn_overrideb                                        = "bypass_sequencer"                                                        ,//"bypass_sequencer" "use_sequencer"
	parameter          pma_reset_sequencer_silicon_rev                                                   = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_reset_sequencer_xrx_path_uc_cal_clk_bypass                                    = "cal_clk_0"                                                               ,//"cal_clk_0" "cal_clk_1"
	parameter          pma_reset_sequencer_xrx_path_uc_cal_enable                                        = "rx_cal_off"                                                              ,//"rx_cal_off" "rx_cal_on"
	parameter          pma_rx_buf_act_isource_disable                                                    = "isrc_en"                                                                 ,//"isrc_dis" "isrc_en"
	parameter          pma_rx_buf_advanced_mode                                                          = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_buf_bodybias_enable                                                        = "bodybias_dis"                                                            ,//"bodybias_dis" "bodybias_en"
	parameter          pma_rx_buf_bodybias_select                                                        = "bodybias_sel1"                                                           ,//"bodybias_sel1" "bodybias_sel2"
	parameter          pma_rx_buf_bypass_ctle_rf_cal                                                     = "use_dprio_rfcal"                                                         ,//"use_dprio_rfcal" "use_rterm_rfcal"
	parameter          pma_rx_buf_clk_divrx_en                                                           = "normal_clk"                                                              ,//"cdr_clk_2_cgb" "normal_clk"
	parameter          pma_rx_buf_const_gm_en                                                            = "cgm_en_1"                                                                ,//"cgm_en_0" "cgm_en_1" "cgm_en_2" "cgm_en_3" "cgm_en_4" "cgm_en_5" "cgm_en_6" "cgm_en_7"
	parameter [3:0]    pma_rx_buf_ctle_ac_gain                                                           = 4'd0                                                                      ,//0:15
	parameter [5:0]    pma_rx_buf_ctle_eq_gain                                                           = 6'd0                                                                      ,//0:63
	parameter          pma_rx_buf_ctle_hires_bypass                                                      = "ctle_hires_en"                                                           ,//"ctle_hires_bypass" "ctle_hires_en"
	parameter          pma_rx_buf_ctle_oc_ib_sel                                                         = "ib_oc_bw1"                                                               ,//"ib_oc_bw0" "ib_oc_bw1" "ib_oc_bw2" "ib_oc_bw3"
	parameter          pma_rx_buf_ctle_oc_sign                                                           = "add_i_2_p_eq"                                                            ,//"add_i_2_n_eq" "add_i_2_p_eq"
	parameter [2:0]    pma_rx_buf_ctle_rf_cal                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_buf_ctle_tia_isel                                                          = "ib_tia_bw1"                                                              ,//"ib_tia_bw0" "ib_tia_bw1" "ib_tia_bw2" "ib_tia_bw3"
	parameter          pma_rx_buf_datarate_bps                                                           = "0"                                                                       ,//NOVAL
	parameter          pma_rx_buf_diag_lp_en                                                             = "dlp_off"                                                                 ,//"dlp_off" "dlp_on"
	parameter          pma_rx_buf_eq_bw_sel                                                              = "eq_bw_0"                                                                 ,//"eq_bw_0" "eq_bw_1" "eq_bw_2" "eq_bw_3"
	parameter          pma_rx_buf_eq_cdgen_sel                                                           = "eq_cdgen_3"                                                              ,//"eq_cdgen_0" "eq_cdgen_1" "eq_cdgen_2" "eq_cdgen_3"
	parameter          pma_rx_buf_eq_isel                                                                = "eq_isel_0"                                                               ,//"eq_isel_0" "eq_isel_1"
	parameter          pma_rx_buf_eq_sel                                                                 = "eq_sel_1"                                                                ,//"eq_sel_0" "eq_sel_1" "eq_sel_2" "eq_sel_3"
	parameter          pma_rx_buf_initial_settings                                                       = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_buf_link                                                                   = "link_off"                                                                ,//"link_off" "lr" "mr" "sr"
	parameter          pma_rx_buf_loopback_modes                                                         = "loop_off"                                                                ,//"loop_off" "lpbk_disable" "post_cdr" "pre_cdr"
	parameter          pma_rx_buf_offset_cancellation_coarse                                             = "coarse_setting_0"                                                        ,//"coarse_setting_0" "coarse_setting_1" "coarse_setting_2" "coarse_setting_3" "coarse_setting_4" "coarse_setting_5" "coarse_setting_6" "coarse_setting_7"
	parameter          pma_rx_buf_offset_rx_cal_en                                                       = "rx_oc_dis"                                                               ,//"rx_oc_dis" "rx_oc_en"
	parameter          pma_rx_buf_optimal                                                                = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_buf_pdb_rx                                                                 = "power_down_rx"                                                           ,//"normal_rx_on" "power_down_rx"
	parameter          pma_rx_buf_pm_cr2_rx_path_analog_mode                                             = "analog_off"                                                              ,//"analog_off" "user_custom"
	parameter          pma_rx_buf_pm_cr2_rx_path_datarate_bps                                            = "0"                                                                       ,//NOVAL
	parameter [7:0]    pma_rx_buf_pm_cr2_rx_path_datawidth                                               = 8'd0                                                                      ,//0:255
	parameter          pma_rx_buf_pm_cr2_rx_path_gt_enabled                                              = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_rx_buf_pm_cr2_rx_path_initial_settings                                        = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_buf_pm_cr2_rx_path_jtag_hys                                                = "hys_increase_disable"                                                    ,//"hys_increase_disable" "hys_increase_enable"
	parameter          pma_rx_buf_pm_cr2_rx_path_jtag_lp                                                 = "lp_off"                                                                  ,//"lp_off" "lp_on"
	parameter          pma_rx_buf_pm_cr2_rx_path_link                                                    = "link_off"                                                                ,//"link_off" "lr" "mr" "sr"
	parameter          pma_rx_buf_pm_cr2_rx_path_optimal                                                 = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz                                        = "0"                                                                       ,//NOVAL
	parameter          pma_rx_buf_pm_cr2_rx_path_power_mode                                              = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter [11:0]   pma_rx_buf_pm_cr2_rx_path_power_rail_eht                                          = 12'd0                                                                     ,//0:4095
	parameter [11:0]   pma_rx_buf_pm_cr2_rx_path_power_rail_er                                           = 12'd0                                                                     ,//0:4095
	parameter          pma_rx_buf_pm_cr2_rx_path_prot_mode                                               = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_buf_pm_cr2_rx_path_speed_grade                                             = "speed_off"                                                               ,//"e1" "e2" "e3" "e4" "e5" "i1" "i2" "i3" "i4" "i5" "m3" "m4" "speed_off"
	parameter          pma_rx_buf_pm_cr2_rx_path_sup_mode                                                = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_rx_buf_pm_cr2_rx_path_uc_cal_clk_bypass                                       = "cal_clk_0"                                                               ,//"cal_clk_0" "cal_clk_1"
	parameter          pma_rx_buf_pm_cr2_rx_path_uc_cal_enable                                           = "rx_cal_off"                                                              ,//"rx_cal_off" "rx_cal_on"
	parameter          pma_rx_buf_pm_cr2_rx_path_uc_pcie_sw                                              = "uc_pcie_gen1"                                                            ,//"not_allowed" "uc_pcie_gen1" "uc_pcie_gen2" "uc_pcie_gen3"
	parameter          pma_rx_buf_pm_cr2_rx_path_uc_rx_rstb                                              = "rx_reset_on"                                                             ,//"rx_reset_off" "rx_reset_on"
  parameter          pma_rx_buf_pm_cr2_rx_path_tile_type                                               = "h"                                                                       ,//"h" "l"
	parameter          pma_rx_buf_pm_cr2_tx_rx_cvp_mode                                                  = "cvp_off"                                                                 ,//"cvp_off" "cvp_on"
	parameter          pma_rx_buf_pm_cr2_tx_rx_pcie_gen                                                  = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          pma_rx_buf_pm_cr2_tx_rx_pcie_gen_bitwidth                                         = "pcie_gen3_32b"                                                           ,//"pcie_gen3_16b" "pcie_gen3_32b"
	parameter          pma_rx_buf_pm_cr2_tx_rx_testmux_select                                            = "setting0"                                                                ,//"setting0" "setting1" "setting10" "setting11" "setting12" "setting13" "setting14" "setting15" "setting2" "setting3" "setting4" "setting5" "setting6" "setting7" "setting8" "setting9"
	parameter          pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_left                                           = "uc_odi_eye_left_off"                                                     ,//"uc_odi_eye_left_off" "uc_odi_eye_left_on"
	parameter          pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_right                                          = "uc_odi_eye_right_off"                                                    ,//"uc_odi_eye_right_off" "uc_odi_eye_right_on"
	parameter          pma_rx_buf_pm_cr2_tx_rx_uc_rx_cal                                                 = "uc_rx_cal_off"                                                           ,//"uc_rx_cal_off" "uc_rx_cal_on"
	parameter          pma_rx_buf_power_mode                                                             = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter [11:0]   pma_rx_buf_power_rail_er                                                          = 12'd0                                                                     ,//0:4095
	parameter          pma_rx_buf_powermode_ac_ctle                                                      = "ctle_pwr_ac1"                                                            ,//"ctle_pwr_ac1" "ctle_pwr_ac2" "ctle_pwr_ac3" "ctle_pwr_ac4"
	parameter          pma_rx_buf_powermode_ac_vcm                                                       = "vcm_pwr_ac0"                                                             ,//"vcm_pwr_ac0" "vcm_pwr_ac1" "vcm_pwr_ac2" "vcm_pwr_ac3"
	parameter          pma_rx_buf_powermode_ac_vga                                                       = "vga_pwr_ac_half"                                                         ,//"vga_pwr_ac_full" "vga_pwr_ac_half"
	parameter          pma_rx_buf_powermode_dc_ctle                                                      = "powerdown_ctle"                                                          ,//"ctle_pwr_dc1" "ctle_pwr_dc2" "ctle_pwr_dc3" "ctle_pwr_dc4" "powerdown_ctle"
	parameter          pma_rx_buf_powermode_dc_vcm                                                       = "powerdown_vcm"                                                           ,//"powerdown_vcm" "vcm_pwr_dc0" "vcm_pwr_dc1" "vcm_pwr_dc2" "vcm_pwr_dc3"
	parameter          pma_rx_buf_powermode_dc_vga                                                       = "powerdown_vga"                                                           ,//"powerdown_vga" "vga_pwr_dc_full" "vga_pwr_dc_half"
	parameter          pma_rx_buf_prot_mode                                                              = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_buf_qpi_afe_en                                                             = "ctle_mode_en"                                                            ,//"ctle_mode_en" "qpi_mode_en"
	parameter          pma_rx_buf_qpi_enable                                                             = "non_qpi_mode"                                                            ,//"non_qpi_mode" "qpi_mode"
	parameter          pma_rx_buf_refclk_en                                                              = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_rx_buf_rx_atb_select                                                          = "atb_disable"                                                             ,//"atb_disable"
	parameter          pma_rx_buf_rx_vga_oc_en                                                           = "vga_cal_off"                                                             ,//"vga_cal_off" "vga_cal_on"
	parameter          pma_rx_buf_sel_vcm_ctle                                                           = "vocm_eq_gndref"                                                          ,//"vocm_eq_fixed" "vocm_eq_gndref"
	parameter          pma_rx_buf_sel_vcm_tia                                                            = "vocm_tia_fixed"                                                          ,//"vocm_tia_fixed" "vocm_tia_gndref"
	parameter          pma_rx_buf_silicon_rev                                                            = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_rx_buf_sup_mode                                                               = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_rx_buf_term_sel                                                               = "r_r4"                                                                    ,//"r_ext0" "r_r1" "r_r2" "r_r3" "r_r4" "r_r5" "r_r6" "r_unused"
	parameter          pma_rx_buf_term_sync_bypass                                                       = "bypass_termsync"                                                         ,//"bypass_termsync" "not_bypass_termsync"
	parameter          pma_rx_buf_term_tri_enable                                                        = "disable_tri"                                                             ,//"disable_tri" "enable_tri"
	parameter          pma_rx_buf_tia_sel                                                                = "tia_sel_1"                                                               ,//"tia_sel_0" "tia_sel_1"
	parameter [3:0]    pma_rx_buf_vcm_cal_i                                                              = 4'd0                                                                      ,//0:15
	parameter          pma_rx_buf_vcm_current_add                                                        = "vcm_current_default"                                                     ,//"vcm_current_1" "vcm_current_2" "vcm_current_3" "vcm_current_default"
	parameter          pma_rx_buf_vcm_sel                                                                = "vcm_l0"                                                                  ,//"vcm_l0" "vcm_l1" "vcm_l2" "vcm_l3"
	parameter [3:0]    pma_rx_buf_vcm_sel_vccref                                                         = 4'd0                                                                      ,//0:15
	parameter [4:0]    pma_rx_buf_vga_dc_gain                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_buf_vga_halfbw_en                                                          = "vga_half_bw_disabled"                                                    ,//"vga_half_bw_disabled" "vga_half_bw_enabled"
	parameter          pma_rx_buf_vga_ib_max_en                                                          = "vga_ib_max_disable"                                                      ,//"vga_ib_max_disable" "vga_ib_max_enable"
	parameter          pma_rx_buf_vga_mode                                                               = "vga_off"                                                                 ,//"vga_current_full" "vga_current_reduced" "vga_off"
	parameter          pma_rx_buf_xrx_path_xcdr_deser_xcdr_loopback_mode                                 = "loopback_recovered_data"                                                 ,//"loopback_disabled" "loopback_received_data" "loopback_recovered_data" "rx_refclk" "rx_refclk_cdr_loopback" "unused1" "unused2"

	// Sujoy - these need to be cleaned up
	parameter          pma_rx_buf_dfe_h1_cal_en                                                          = "dfe_h1_cal_disable",
	parameter          pma_rx_buf_dfe_h1_sw_togg                                                         = "dfe_h1_tog_neg",
	parameter          pma_rx_buf_rx_lfeq_enable                                                         = "rx_lfeq_disable",
	parameter          pma_rx_buf_rx_ltr_load_init                                                       = "rx_load_original",
	parameter [4:0]    pma_rx_buf_rx_oc_or_lfeq_coeff                                                    = 5'b0,

	parameter          pma_rx_deser_bitslip_bypass                                                       = "bs_bypass_no"                                                            ,//"bs_bypass_no" "bs_bypass_yes"
	parameter          pma_rx_deser_bti_protected                                                        = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_deser_clkdiv_source                                                        = "vco_bypass_normal"                                                       ,//"clklow_to_clkdivrx" "fref_to_clkdivrx" "vco_bypass_normal"
	parameter          pma_rx_deser_clkdivrx_user_mode                                                   = "clkdivrx_user_disabled"                                                  ,//"clkdivrx_user_clkdiv" "clkdivrx_user_clkdiv_div2" "clkdivrx_user_disabled" "clkdivrx_user_div33" "clkdivrx_user_div40" "clkdivrx_user_div66"
	parameter          pma_rx_deser_datarate_bps                                                         = "0"                                                                       ,//NOVAL
	parameter          pma_rx_deser_deser_aib_dftppm_en                                                  = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_rx_deser_deser_aibck_en                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_rx_deser_deser_aibck_x1                                                       = "normal"                                                                  ,//"clk1x_over_ride" "normal"
	parameter          pma_rx_deser_deser_factor                                                         = "deser_10b"                                                               ,//"deser_10b" "deser_16b" "deser_20b" "deser_32b" "deser_40b" "deser_64b" "deser_8b"
	parameter          pma_rx_deser_deser_powerdown                                                      = "deser_power_up"                                                          ,//"deser_power_down" "deser_power_up"
	parameter          pma_rx_deser_force_adaptation_outputs                                             = "normal_outputs"                                                          ,//"forced_0101" "forced_1010" "forced_all_ones" "forced_all_zeros" "normal_outputs"
	parameter          pma_rx_deser_force_clkdiv_for_testing                                             = "normal_clkdiv"                                                           ,//"forced_0" "forced_1" "normal_clkdiv"
	parameter          pma_rx_deser_odi_adapt_bti_en                                                     = "deser_bti_disable"                                                       ,//"deser_bti_disable" "deser_bti_enable"
	parameter          pma_rx_deser_optimal                                                              = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_deser_pcie_g3_hclk_en                                                      = "disable_hclk_div2"                                                       ,//"disable_hclk_div2" "enable_hclk_div2"
	parameter          pma_rx_deser_pm_cr2_tx_rx_pcie_gen                                                = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          pma_rx_deser_pm_cr2_tx_rx_pcie_gen_bitwidth                                       = "pcie_gen3_32b"                                                           ,//"pcie_gen3_16b" "pcie_gen3_32b"
	parameter          pma_rx_deser_powermode_ac_deser                                                   = "deser_ac_off"                                                            ,//"deser_ac_10b_nobs" "deser_ac_16b_nobs" "deser_ac_20b_nobs" "deser_ac_32b_nobs" "deser_ac_40b_nobs" "deser_ac_64b_nobs" "deser_ac_8b_nobs" "deser_ac_bti" "deser_ac_off"
	parameter          pma_rx_deser_powermode_ac_deser_bs                                                = "deser_ac_bs_off"                                                         ,//"deser_ac_bs" "deser_ac_bs_off"
	parameter          pma_rx_deser_powermode_dc_deser                                                   = "powerdown_deser"                                                         ,//"deser_dc_10b_nobs" "deser_dc_16b_nobs" "deser_dc_20b_nobs" "deser_dc_32b_nobs" "deser_dc_40b_nobs" "deser_dc_64b_nobs" "deser_dc_8b_nobs" "deser_dc_bti" "powerdown_deser"
	parameter          pma_rx_deser_powermode_dc_deser_bs                                                = "powerdown_deser_bs"                                                      ,//"deser_dc_bs" "powerdown_deser_bs"
	parameter          pma_rx_deser_prot_mode                                                            = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_deser_rst_n_adapt_odi                                                      = "no_rst_adapt_odi"                                                        ,//"no_rst_adapt_odi" "yes_rst_adapt_odi"
	parameter          pma_rx_deser_sd_clk                                                               = "sd_clk_disabled"                                                         ,//"sd_clk_disabled" "sd_clk_enabled"
	parameter          pma_rx_deser_silicon_rev                                                          = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_rx_deser_sup_mode                                                             = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_rx_deser_tdr_mode                                                             = "select_bbpd_data"                                                        ,//"select_bbpd_data" "select_odi_data"
	parameter          pma_rx_dfe_adapt_bti_en                                                           = "adapt_bti_disable"                                                       ,//"adapt_bti_disable" "adapt_bti_enable"
	parameter          pma_rx_dfe_atb_select                                                             = "atb_disable"                                                             ,//"atb_disable" "atb_sel0" "atb_sel1" "atb_sel10" "atb_sel11" "atb_sel12" "atb_sel13" "atb_sel14" "atb_sel15" "atb_sel16" "atb_sel17" "atb_sel18" "atb_sel19" "atb_sel2" "atb_sel20" "atb_sel21" "atb_sel22" "atb_sel23" "atb_sel24" "atb_sel25" "atb_sel26" "atb_sel27" "atb_sel28" "atb_sel29" "atb_sel3" "atb_sel30" "atb_sel4" "atb_sel5" "atb_sel6" "atb_sel7" "atb_sel8" "atb_sel9"
	parameter          pma_rx_dfe_bti_protected                                                          = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_dfe_datarate_bps                                                           = "0"                                                                       ,//NOVAL
	parameter          pma_rx_dfe_dfe_bti_en                                                             = "dfe_bti_disable"                                                         ,//"dfe_bti_disable" "dfe_bti_enable"
	parameter          pma_rx_dfe_dfe_mode                                                               = "dfe_mode_off"                                                            ,//"cdr_mode" "ctle_only" "dfe_mode_off" "dfe_tap1" "dfe_tap1_15" "dfe_tap1_3" "dfe_tap1_9"
	parameter          pma_rx_dfe_dft_en                                                                 = "dft_disable"                                                             ,//"dft_disable" "dft_enalbe"
	parameter          pma_rx_dfe_dft_hilospeed_sel                                                      = "dft_osc_lospeed_path"                                                    ,//"dft_osc_hispeed_path" "dft_osc_lospeed_path"
	parameter          pma_rx_dfe_dft_osc_sel                                                            = "dft_osc_even"                                                            ,//"dft_osc_even" "dft_osc_odd"
	parameter          pma_rx_dfe_h1edge_bti_en                                                          = "h1edge_bti_disable"                                                      ,//"h1edge_bti_disable" "h1edge_bti_enable"
	parameter          pma_rx_dfe_initial_settings                                                       = "true"                                                                    ,//"false" "true"
	parameter          pma_rx_dfe_latch_xcouple_disable                                                  = "latch_xcouple_enable"                                                    ,//"latch_xcouple_disable" "latch_xcouple_enable"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdr0e                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdr0e_sgn                                                        = "oc_sa_cdr0e_sgn_0"                                                       ,//"oc_sa_cdr0e_sgn_0" "oc_sa_cdr0e_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdr0o                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdr0o_sgn                                                        = "oc_sa_cdr0o_sgn_0"                                                       ,//"oc_sa_cdr0o_sgn_0" "oc_sa_cdr0o_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdrne                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdrne_sgn                                                        = "oc_sa_cdrne_sgn_0"                                                       ,//"oc_sa_cdrne_sgn_0" "oc_sa_cdrne_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdrno                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdrno_sgn                                                        = "oc_sa_cdrno_sgn_0"                                                       ,//"oc_sa_cdrno_sgn_0" "oc_sa_cdrno_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdrpe                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdrpe_sgn                                                        = "oc_sa_cdrpe_sgn_0"                                                       ,//"oc_sa_cdrpe_sgn_0" "oc_sa_cdrpe_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_cdrpo                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_cdrpo_sgn                                                        = "oc_sa_cdrpo_sgn_0"                                                       ,//"oc_sa_cdrpo_sgn_0" "oc_sa_cdrpo_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_dne                                                              = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_dne_sgn                                                          = "oc_sa_dne_sgn_0"                                                         ,//"oc_sa_dne_sgn_0" "oc_sa_dne_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_dno                                                              = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_dno_sgn                                                          = "oc_sa_dno_sgn_0"                                                         ,//"oc_sa_dno_sgn_0" "oc_sa_dno_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_dpe                                                              = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_dpe_sgn                                                          = "oc_sa_dpe_sgn_0"                                                         ,//"oc_sa_dpe_sgn_0" "oc_sa_dpe_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_dpo                                                              = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_dpo_sgn                                                          = "oc_sa_dpo_sgn_0"                                                         ,//"oc_sa_dpo_sgn_0" "oc_sa_dpo_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_odie                                                             = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_odie_sgn                                                         = "oc_sa_odie_sgn_0"                                                        ,//"oc_sa_odie_sgn_0" "oc_sa_odie_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_odio                                                             = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_odio_sgn                                                         = "oc_sa_odio_sgn_0"                                                        ,//"oc_sa_odio_sgn_0" "oc_sa_odio_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_vrefe                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_vrefe_sgn                                                        = "oc_sa_vrefe_sgn_0"                                                       ,//"oc_sa_vrefe_sgn_0" "oc_sa_vrefe_sgn_1"
	parameter [4:0]    pma_rx_dfe_oc_sa_vrefo                                                            = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_oc_sa_vrefo_sgn                                                        = "oc_sa_vrefo_sgn_0"                                                       ,//"oc_sa_vrefo_sgn_0" "oc_sa_vrefo_sgn_1"
	parameter          pma_rx_dfe_odi_bti_en                                                             = "odi_bti_disable"                                                         ,//"odi_bti_disable" "odi_bti_enable"
	parameter          pma_rx_dfe_odi_dlev_sign                                                          = "odi_dlev_pos"                                                            ,//"odi_dlev_neg" "odi_dlev_pos"
	parameter          pma_rx_dfe_odi_h1_sign                                                            = "odi_h1_pos"                                                              ,//"odi_h1_neg" "odi_h1_pos"
	parameter          pma_rx_dfe_optimal                                                                = "true"                                                                    ,//"false" "true"
	parameter          pma_rx_dfe_pdb                                                                    = "dfe_enable"                                                              ,//"dfe_enable" "dfe_powerdown" "dfe_reset"
	parameter          pma_rx_dfe_pdb_edge_pre_h1                                                        = "cdr_pre_h1_disable"                                                      ,//"cdr_pre_h1_disable" "cdr_pre_h1_enable"
	parameter          pma_rx_dfe_pdb_edge_pst_h1                                                        = "cdr_pst_h1_disable"                                                      ,//"cdr_pst_h1_disable" "cdr_pst_h1_enable"
	parameter          pma_rx_dfe_pdb_tap_4t9                                                            = "tap4t9_dfe_powerdown"                                                    ,//"tap4t9_dfe_enable" "tap4t9_dfe_powerdown"
	parameter          pma_rx_dfe_pdb_tap_10t15                                                          = "tap10t15_dfe_powerdown"                                                  ,//"tap10t15_dfe_enable" "tap10t15_dfe_powerdown"
	parameter          pma_rx_dfe_pdb_tapsum                                                             = "tapsum_disable"                                                          ,//"tapsum_disable" "tapsum_enable"
	parameter          pma_rx_dfe_power_mode                                                             = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter          pma_rx_dfe_powermode_ac_dfe                                                       = "ac_cdr_mode"                                                             ,//"ac_cdr_mode" "ac_ctle_only" "ac_dfe_tap1" "ac_dfe_tap1_15" "ac_dfe_tap1_3" "ac_dfe_tap1_9" "dfe_ac_bti"
	parameter          pma_rx_dfe_powermode_dc_dfe                                                       = "powerdown_dfe"                                                           ,//"dc_cdr_mode" "dc_ctle_only" "dc_dfe_tap1" "dc_dfe_tap1_15" "dc_dfe_tap1_3" "dc_dfe_tap1_9" "dfe_dc_bti" "powerdown_dfe"
	parameter          pma_rx_dfe_prot_mode                                                              = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_dfe_sel_oc_en                                                              = "off_canc_disable"                                                        ,//"off_canc_disable" "off_canc_enable"
	parameter          pma_rx_dfe_sel_probe_tstmx                                                        = "probe_tstmx_none"                                                        ,//"probe_tap10_coeff" "probe_tap11_coeff" "probe_tap12_coeff" "probe_tap13_coeff" "probe_tap14_coeff" "probe_tap15_coeff" "probe_tap1_coeff" "probe_tap2_coeff" "probe_tap3_coeff" "probe_tap4_coeff" "probe_tap5_coeff" "probe_tap6_coeff" "probe_tap7_coeff" "probe_tap8_coeff" "probe_tap9_coeff" "probe_tstmx_none"
	parameter          pma_rx_dfe_silicon_rev                                                            = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_rx_dfe_sup_mode                                                               = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter [5:0]    pma_rx_dfe_tap1_coeff                                                             = 6'd0                                                                      ,//0:63
	parameter          pma_rx_dfe_tap1_sgn                                                               = "tap1_sign_0"                                                             ,//"tap1_sign_0" "tap1_sign_1"
	parameter [4:0]    pma_rx_dfe_tap2_coeff                                                             = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_tap2_sgn                                                               = "tap2_sign_0"                                                             ,//"tap2_sign_0" "tap2_sign_1"
	parameter [4:0]    pma_rx_dfe_tap3_coeff                                                             = 5'd0                                                                      ,//0:31
	parameter          pma_rx_dfe_tap3_sgn                                                               = "tap3_sign_0"                                                             ,//"tap3_sign_0" "tap3_sign_1"
	parameter [3:0]    pma_rx_dfe_tap4_coeff                                                             = 4'd0                                                                      ,//0:15
	parameter          pma_rx_dfe_tap4_sgn                                                               = "tap4_sign_0"                                                             ,//"tap4_sign_0" "tap4_sign_1"
	parameter [3:0]    pma_rx_dfe_tap5_coeff                                                             = 4'd0                                                                      ,//0:15
	parameter          pma_rx_dfe_tap5_sgn                                                               = "tap5_sign_0"                                                             ,//"tap5_sign_0" "tap5_sign_1"
	parameter [3:0]    pma_rx_dfe_tap6_coeff                                                             = 4'd0                                                                      ,//0:15
	parameter          pma_rx_dfe_tap6_sgn                                                               = "tap6_sign_0"                                                             ,//"tap6_sign_0" "tap6_sign_1"
	parameter [3:0]    pma_rx_dfe_tap7_coeff                                                             = 4'd0                                                                      ,//0:15
	parameter          pma_rx_dfe_tap7_sgn                                                               = "tap7_sign_0"                                                             ,//"tap7_sign_0" "tap7_sign_1"
	parameter [2:0]    pma_rx_dfe_tap8_coeff                                                             = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap8_sgn                                                               = "tap8_sign_0"                                                             ,//"tap8_sign_0" "tap8_sign_1"
	parameter [2:0]    pma_rx_dfe_tap9_coeff                                                             = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap9_sgn                                                               = "tap9_sign_0"                                                             ,//"tap9_sign_0" "tap9_sign_1"
	parameter [2:0]    pma_rx_dfe_tap10_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap10_sgn                                                              = "tap10_sign_0"                                                            ,//"tap10_sign_0" "tap10_sign_1"
	parameter [2:0]    pma_rx_dfe_tap11_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap11_sgn                                                              = "tap11_sign_0"                                                            ,//"tap11_sign_0" "tap11_sign_1"
	parameter [2:0]    pma_rx_dfe_tap12_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap12_sgn                                                              = "tap12_sign_0"                                                            ,//"tap12_sign_0" "tap12_sign_1"
	parameter [2:0]    pma_rx_dfe_tap13_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap13_sgn                                                              = "tap13_sign_0"                                                            ,//"tap13_sign_0" "tap13_sign_1"
	parameter [2:0]    pma_rx_dfe_tap14_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap14_sgn                                                              = "tap14_sign_0"                                                            ,//"tap14_sign_0" "tap14_sign_1"
	parameter [2:0]    pma_rx_dfe_tap15_coeff                                                            = 3'd0                                                                      ,//0:7
	parameter          pma_rx_dfe_tap15_sgn                                                              = "tap15_sign_0"                                                            ,//"tap15_sign_0" "tap15_sign_1"
	parameter          pma_rx_dfe_tapsum_bw_sel                                                          = "tapsum_hibw"                                                             ,//"tapsum_hibw" "tapsum_lowbw" "tapsum_medbw"
	parameter [5:0]    pma_rx_dfe_vref_coeff                                                             = 6'd0                                                                      ,//0:63
	parameter          pma_rx_odi_datarate_bps                                                           = "0"                                                                       ,//NOVAL
	parameter          pma_rx_odi_enable_cdr_lpbk                                                        = "disable_lpbk"                                                            ,//"disable_lpbk" "enable_lpbk"
	parameter          pma_rx_odi_initial_settings                                                       = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_odi_monitor_bw_sel                                                         = "bw_1"                                                                    ,//"bw_1" "bw_2" "bw_3" "bw_4"
	parameter          pma_rx_odi_optimal                                                                = "true"                                                                    ,//"false" "true"
	parameter          pma_rx_odi_phase_steps_64_vs_128                                                  = "phase_steps_64"                                                          ,//"phase_steps_128" "phase_steps_64"
	parameter          pma_rx_odi_phase_steps_sel                                                        = "step40"                                                                  ,//"step1" "step10" "step100" "step101" "step102" "step103" "step104" "step105" "step106" "step107" "step108" "step109" "step11" "step110" "step111" "step112" "step113" "step114" "step115" "step116" "step117" "step118" "step119" "step12" "step120" "step121" "step122" "step123" "step124" "step125" "step126" "step127" "step128" "step13" "step14" "step15" "step16" "step17" "step18" "step19" "step2" "step20" "step21" "step22" "step23" "step24" "step25" "step26" "step27" "step28" "step29" "step3" "step30" "step31" "step32" "step33" "step34" "step35" "step36" "step37" "step38" "step39" "step4" "step40" "step41" "step42" "step43" "step44" "step45" "step46" "step47" "step48" "step49" "step5" "step50" "step51" "step52" "step53" "step54" "step55" "step56" "step57" "step58" "step59" "step6" "step60" "step61" "step62" "step63" "step64" "step65" "step66" "step67" "step68" "step69" "step7" "step70" "step71" "step72" "step73" "step74" "step75" "step76" "step77" "step78" "step79" "step8" "step80" "step81" "step82" "step83" "step84" "step85" "step86" "step87" "step88" "step89" "step9" "step90" "step91" "step92" "step93" "step94" "step95" "step96" "step97" "step98" "step99"
	parameter          pma_rx_odi_power_mode                                                             = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter          pma_rx_odi_prot_mode                                                              = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_odi_silicon_rev                                                            = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_rx_odi_step_ctrl_sel                                                          = "feedback_mode"                                                           ,//"dprio_mode" "feedback_mode" "jm_mode"
	parameter          pma_rx_odi_sup_mode                                                               = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_rx_odi_vert_threshold                                                         = "vert_0"                                                                  ,//"vert_0" "vert_1" "vert_10" "vert_11" "vert_12" "vert_13" "vert_14" "vert_15" "vert_16" "vert_17" "vert_18" "vert_19" "vert_2" "vert_20" "vert_21" "vert_22" "vert_23" "vert_24" "vert_25" "vert_26" "vert_27" "vert_28" "vert_29" "vert_3" "vert_30" "vert_31" "vert_32" "vert_33" "vert_34" "vert_35" "vert_36" "vert_37" "vert_38" "vert_39" "vert_4" "vert_40" "vert_41" "vert_42" "vert_43" "vert_44" "vert_45" "vert_46" "vert_47" "vert_48" "vert_49" "vert_5" "vert_50" "vert_51" "vert_52" "vert_53" "vert_54" "vert_55" "vert_56" "vert_57" "vert_58" "vert_59" "vert_6" "vert_60" "vert_61" "vert_62" "vert_63" "vert_7" "vert_8" "vert_9"
	parameter          pma_rx_odi_vreg_voltage_sel                                                       = "vreg0"                                                                   ,//"vreg0" "vreg1" "vreg2" "vreg3"
	parameter          pma_rx_odi_xrx_path_x119_rx_path_rstn_overrideb                                   = "bypass_sequencer"                                                        ,//"bypass_sequencer" "use_sequencer"
	parameter          pma_rx_sd_link                                                                    = "link_off"                                                                ,//"link_off" "lr" "mr" "sr"
	parameter          pma_rx_sd_optimal                                                                 = "false"                                                                   ,//"false" "true"
	parameter          pma_rx_sd_power_mode                                                              = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter          pma_rx_sd_prot_mode                                                               = "prot_off"                                                                ,//"basic_rx" "gpon_rx" "not_used" "pcie_gen1_rx" "pcie_gen2_rx" "pcie_gen3_rx" "pcie_gen4_rx" "prot_off" "qpi_rx" "sata_rx"
	parameter          pma_rx_sd_sd_output_off                                                           = "clk_divrx_2"                                                             ,//"clk_divrx_1" "clk_divrx_10" "clk_divrx_11" "clk_divrx_12" "clk_divrx_13" "clk_divrx_14" "clk_divrx_2" "clk_divrx_3" "clk_divrx_4" "clk_divrx_5" "clk_divrx_6" "clk_divrx_7" "clk_divrx_8" "clk_divrx_9" "force_sd_output_off_when_remote_tx_off_10clkdivrx" "force_sd_output_off_when_remote_tx_off_11clkdivrx" "force_sd_output_off_when_remote_tx_off_12clkdivrx" "force_sd_output_off_when_remote_tx_off_13clkdivrx" "force_sd_output_off_when_remote_tx_off_14clkdivrx" "force_sd_output_off_when_remote_tx_off_1clkdivrx" "force_sd_output_off_when_remote_tx_off_2clkdivrx" "force_sd_output_off_when_remote_tx_off_3clkdivrx" "force_sd_output_off_when_remote_tx_off_4clkdivrx" "force_sd_output_off_when_remote_tx_off_5clkdivrx" "force_sd_output_off_when_remote_tx_off_6clkdivrx" "force_sd_output_off_when_remote_tx_off_7clkdivrx" "force_sd_output_off_when_remote_tx_off_8clkdivrx" "force_sd_output_off_when_remote_tx_off_9clkdivrx" "reserved_sd_output_off1"
	parameter          pma_rx_sd_sd_output_on                                                            = "force_sd_output_on"                                                      ,//"data_pulse_10" "data_pulse_12" "data_pulse_14" "data_pulse_16" "data_pulse_18" "data_pulse_20" "data_pulse_22" "data_pulse_24" "data_pulse_26" "data_pulse_28" "data_pulse_30" "data_pulse_4" "data_pulse_6" "data_pulse_8" "force_sd_output_on" "reserved_sd_output_on1"
	parameter          pma_rx_sd_sd_pdb                                                                  = "sd_off"                                                                  ,//"sd_off" "sd_on"
	parameter          pma_rx_sd_sd_threshold                                                            = "sdlv_4"                                                                  ,//"sdlv_0" "sdlv_1" "sdlv_10" "sdlv_11" "sdlv_12" "sdlv_13" "sdlv_14" "sdlv_15" "sdlv_2" "sdlv_3" "sdlv_4" "sdlv_5" "sdlv_6" "sdlv_7" "sdlv_8" "sdlv_9"
	parameter          pma_rx_sd_silicon_rev                                                             = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_rx_sd_sup_mode                                                                = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_tx_buf_bti_protected                                                          = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_calibration_en                                                         = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_calibration_resistor_value                                             = "res_setting0"                                                            ,//"res_setting0" "res_setting1" "res_setting2" "res_setting3"
	parameter          pma_tx_buf_cdr_cp_calibration_en                                                  = "cdr_cp_cal_disable"                                                      ,//"cdr_cp_cal_disable" "cdr_cp_cal_enable"
	parameter          pma_tx_buf_chgpmp_current_dn_trim                                                 = "cp_current_trimming_dn_setting0"                                         ,//"cp_current_trimming_dn_setting0" "cp_current_trimming_dn_setting1" "cp_current_trimming_dn_setting10" "cp_current_trimming_dn_setting11" "cp_current_trimming_dn_setting12" "cp_current_trimming_dn_setting13" "cp_current_trimming_dn_setting14" "cp_current_trimming_dn_setting15" "cp_current_trimming_dn_setting2" "cp_current_trimming_dn_setting3" "cp_current_trimming_dn_setting4" "cp_current_trimming_dn_setting5" "cp_current_trimming_dn_setting6" "cp_current_trimming_dn_setting7" "cp_current_trimming_dn_setting8" "cp_current_trimming_dn_setting9"
	parameter          pma_tx_buf_chgpmp_current_up_trim                                                 = "cp_current_trimming_up_setting0"                                         ,//"cp_current_trimming_up_setting0" "cp_current_trimming_up_setting1" "cp_current_trimming_up_setting10" "cp_current_trimming_up_setting11" "cp_current_trimming_up_setting12" "cp_current_trimming_up_setting13" "cp_current_trimming_up_setting14" "cp_current_trimming_up_setting15" "cp_current_trimming_up_setting2" "cp_current_trimming_up_setting3" "cp_current_trimming_up_setting4" "cp_current_trimming_up_setting5" "cp_current_trimming_up_setting6" "cp_current_trimming_up_setting7" "cp_current_trimming_up_setting8" "cp_current_trimming_up_setting9"
	parameter          pma_tx_buf_chgpmp_dn_trim_double                                                  = "normal_dn_trim_current"                                                  ,//"double_dn_trim_current" "normal_dn_trim_current"
	parameter          pma_tx_buf_chgpmp_up_trim_double                                                  = "normal_up_trim_current"                                                  ,//"double_up_trim_current" "normal_up_trim_current"
	parameter          pma_tx_buf_compensation_en                                                        = "enable"                                                                  ,//"disable" "enable"
	parameter          pma_tx_buf_compensation_posttap_en                                                = "enable"                                                                  ,//"disable" "enable"
	parameter          pma_tx_buf_cpen_ctrl                                                              = "cp_l0"                                                                   ,//"cp_l0" "cp_l1"
	parameter          pma_tx_buf_datarate_bps                                                           = "0"                                                                       ,//NOVAL
	parameter          pma_tx_buf_dcc_finestep_enin                                                      = "enable"                                                                  ,//"disable" "enable"
	parameter          pma_tx_buf_dcd_clk_div_ctrl                                                       = "dcd_ck_div128"                                                           ,//"dcd_ck_div128" "dcd_ck_div256"
	parameter          pma_tx_buf_dcd_detection_en                                                       = "enable"                                                                  ,//"disable" "enable"
	parameter          pma_tx_buf_dft_sel                                                                = "dft_disabled"                                                            ,//"dft_disabled" "en_t50_8_s_main_59_56" "en_tri_s_po1_24" "s_main_15_8" "s_main_23_16" "s_main_31_24" "s_main_39_32" "s_main_47_40" "s_main_55_48" "s_main_7_0" "s_po1_15_8" "s_po1_23_16" "s_po1_7_0" "s_pr1_15_8" "s_pr1_7_0" "tx50_7_0"
	parameter          pma_tx_buf_duty_cycle_correction_bandwidth                                        = "dcc_bw_0"                                                                ,//"dcc_bw_0" "dcc_bw_1" "dcc_bw_2" "dcc_bw_3"
	parameter          pma_tx_buf_duty_cycle_correction_bandwidth_dn                                     = "dcd_bw_dn_0"                                                             ,//"dcd_bw_dn_0" "dcd_bw_dn_1" "dcd_bw_dn_2" "dcd_bw_dn_3"
	parameter          pma_tx_buf_duty_cycle_correction_reference1                                       = "dcc_ref1_5"                                                              ,//"dcc_ref1_0" "dcc_ref1_1" "dcc_ref1_10" "dcc_ref1_11" "dcc_ref1_12" "dcc_ref1_13" "dcc_ref1_14" "dcc_ref1_15" "dcc_ref1_2" "dcc_ref1_3" "dcc_ref1_4" "dcc_ref1_5" "dcc_ref1_6" "dcc_ref1_7" "dcc_ref1_8" "dcc_ref1_9"
	parameter          pma_tx_buf_duty_cycle_correction_reference2                                       = "dcc_ref2_7"                                                              ,//"dcc_ref2_0" "dcc_ref2_1" "dcc_ref2_2" "dcc_ref2_3" "dcc_ref2_4" "dcc_ref2_5" "dcc_ref2_6" "dcc_ref2_7"
	parameter          pma_tx_buf_duty_cycle_correction_reset_n                                          = "reset_n"                                                                 ,//"reset" "reset_n"
	parameter          pma_tx_buf_duty_cycle_cp_comp_en                                                  = "cp_comp_off"                                                             ,//"cp_comp_off" "cp_comp_on"
	parameter          pma_tx_buf_duty_cycle_detector_cp_cal                                             = "dcd_cp_cal_disable"                                                      ,//"dcd_cp_cal_disable" "dcd_cp_cal_in" "dcd_cp_cal_ip" "dcd_cp_cal_tri"
	parameter          pma_tx_buf_duty_cycle_detector_sa_cal                                             = "dcd_sa_cal_disable"                                                      ,//"dcd_sa_cal_disable" "dcd_sa_cal_enable"
	parameter          pma_tx_buf_duty_cycle_input_polarity                                              = "dcc_input_pos"                                                           ,//"dcc_input_neg" "dcc_input_pos"
	parameter          pma_tx_buf_duty_cycle_setting                                                     = "dcc_t32"                                                                 ,//"dcc_t0" "dcc_t1" "dcc_t10" "dcc_t11" "dcc_t12" "dcc_t13" "dcc_t14" "dcc_t15" "dcc_t16" "dcc_t17" "dcc_t18" "dcc_t19" "dcc_t2" "dcc_t20" "dcc_t21" "dcc_t22" "dcc_t23" "dcc_t24" "dcc_t25" "dcc_t26" "dcc_t27" "dcc_t28" "dcc_t29" "dcc_t3" "dcc_t30" "dcc_t31" "dcc_t32" "dcc_t33" "dcc_t34" "dcc_t35" "dcc_t36" "dcc_t37" "dcc_t38" "dcc_t39" "dcc_t4" "dcc_t40" "dcc_t41" "dcc_t42" "dcc_t43" "dcc_t44" "dcc_t45" "dcc_t46" "dcc_t47" "dcc_t48" "dcc_t49" "dcc_t5" "dcc_t50" "dcc_t51" "dcc_t52" "dcc_t53" "dcc_t54" "dcc_t55" "dcc_t56" "dcc_t57" "dcc_t58" "dcc_t59" "dcc_t6" "dcc_t60" "dcc_t61" "dcc_t62" "dcc_t63" "dcc_t7" "dcc_t8" "dcc_t9"
	parameter          pma_tx_buf_duty_cycle_setting_aux                                                 = "dcc2_t32"                                                                ,//"dcc2_t0" "dcc2_t1" "dcc2_t10" "dcc2_t11" "dcc2_t12" "dcc2_t13" "dcc2_t14" "dcc2_t15" "dcc2_t16" "dcc2_t17" "dcc2_t18" "dcc2_t19" "dcc2_t2" "dcc2_t20" "dcc2_t21" "dcc2_t22" "dcc2_t23" "dcc2_t24" "dcc2_t25" "dcc2_t26" "dcc2_t27" "dcc2_t28" "dcc2_t29" "dcc2_t3" "dcc2_t30" "dcc2_t31" "dcc2_t32" "dcc2_t33" "dcc2_t34" "dcc2_t35" "dcc2_t36" "dcc2_t37" "dcc2_t38" "dcc2_t39" "dcc2_t4" "dcc2_t40" "dcc2_t41" "dcc2_t42" "dcc2_t43" "dcc2_t44" "dcc2_t45" "dcc2_t46" "dcc2_t47" "dcc2_t48" "dcc2_t49" "dcc2_t5" "dcc2_t50" "dcc2_t51" "dcc2_t52" "dcc2_t53" "dcc2_t54" "dcc2_t55" "dcc2_t56" "dcc2_t57" "dcc2_t58" "dcc2_t59" "dcc2_t6" "dcc2_t60" "dcc2_t61" "dcc2_t62" "dcc2_t63" "dcc2_t7" "dcc2_t8" "dcc2_t9"
	parameter          pma_tx_buf_initial_settings                                                       = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_jtag_drv_sel                                                           = "drv1"                                                                    ,//"drv1" "drv2" "drv3" "drv4"
	parameter          pma_tx_buf_jtag_lp                                                                = "lp_off"                                                                  ,//"lp_off" "lp_on"
	parameter          pma_tx_buf_link                                                                   = "link_off"                                                                ,//"link_off" "lr" "mr" "sr"
	parameter          pma_tx_buf_low_power_en                                                           = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_buf_lst                                                                    = "atb_disabled"                                                            ,//"atb_0" "atb_1" "atb_10" "atb_11" "atb_12" "atb_13" "atb_14" "atb_2" "atb_3" "atb_4" "atb_5" "atb_6" "atb_7" "atb_8" "atb_9" "atb_disabled"
	parameter          pma_tx_buf_optimal                                                                = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_pcie_gen                                                               = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          pma_tx_buf_pm_cr2_tx_path_analog_mode                                             = "analog_off"                                                              ,//"analog_off" "cei_11100_lr" "cei_11100_sr" "cei_12500_lr" "cei_12500_sr" "cei_19000_vsr" "cei_28000_vsr" "cei_4976_lr" "cei_4976_sr" "cei_6375_lr" "cei_6375_sr" "cei_9950_lr" "cei_9950_sr" "cpri_12500" "cpri_e12hv" "cpri_e12lv" "cpri_e12lvii" "cpri_e12lviii" "cpri_e24lv" "cpri_e24lvii" "cpri_e24lviii" "cpri_e30lv" "cpri_e30lvii" "cpri_e30lviii" "cpri_e48lvii" "cpri_e48lviii" "cpri_e60lvii" "cpri_e60lviii" "cpri_e6hv" "cpri_e6lv" "cpri_e6lvii" "cpri_e6lviii" "cpri_e96lviii" "cpri_e99lviii" "dp_1620" "dp_2700" "dp_5400" "fc_1600_df_ea_s" "fc_1600_df_el_s" "fc_400_df_ea_s" "fc_400_df_el_s" "fc_800_df_ea_s" "fc_800_df_el_s" "gige_1250" "gpon_1244" "gpon_155" "gpon_2488" "gpon_622" "hdmi_3400" "hdmi_6000" "higig_3125" "higig_3750" "higig_4062" "higig_5000" "higig_6250" "higig_6562" "hmc_10000" "hmc_12500" "hmc_15000" "ieee_1000_base_cx" "ieee_1000_base_kx" "ieee_100g_base_cr10_10312" "ieee_10g_base_cr_10312" "ieee_10g_base_cx4" "ieee_10g_base_kx4" "ieee_10g_kr_10312" "ieee_40g_base_cr4_10312" "ieee_40g_base_kr_10312" "ieee_itut_10g_gpon_epon" "infiniband_ddr_5000" "infiniband_fdr_14000" "infiniband_qdr_10000" "infiniband_sdr_2500" "interlaken_11100" "interlaken_12500" "interlaken_25781" "interlaken_3125" "interlaken_6375" "jesd204_a_b_12500" "jesd204_a_b_312" "jesd204_a_b_3125" "jesd204_a_b_6375" "nppi_10312" "otu2_10709" "pcie_cable" "qsgmii_5000" "sas_12000" "sas_1500" "sas_3000" "sas_6000" "sata_1500" "sata_3000" "sata_6000" "sdi_12000" "sdi_1485_hd" "sdi_270_sd" "sdi_2970_3g" "sdi_6000" "serial_lite_iii_16400" "serial_lite_iii_17400" "sff_8431" "sfi_2488" "sfi_3125" "sfi_s_11200" "sfi_s_6250" "sonet_oc12_622" "sonet_oc192_9953" "sonet_oc48_2488" "srio_10312_lr" "srio_10312_sr" "srio_1250_lr" "srio_1250_sr" "srio_2500_lr" "srio_2500_sr" "srio_3125_lr" "srio_3125_sr" "srio_5000_lr" "srio_5000_mr" "srio_5000_sr" "srio_6250_lr" "srio_6250_mr" "srio_6250_sr" "upi" "user_custom" "xaui_3125" "xfp_10310" "xfp_10520" "xfp_10700" "xfp_11320" "xfp_12500" "xfp_9950"
	parameter          pma_tx_buf_pm_cr2_tx_path_calibration_en                                          = "false"                                                                   ,//"false" "true"
	parameter [3:0]    pma_tx_buf_pm_cr2_tx_path_clock_divider_ratio                                     = 4'd0                                                                      ,//0:15
	parameter          pma_tx_buf_pm_cr2_tx_path_datarate_bps                                            = "0"                                                                       ,//NOVAL
	parameter [7:0]    pma_tx_buf_pm_cr2_tx_path_datawidth                                               = 8'd0                                                                      ,//0:255
	parameter          pma_tx_buf_pm_cr2_tx_path_gt_enabled                                              = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_buf_idle_ctrl                                                              = "id_cpen_on"                                                              ,//"id_cpen_on" "id_cpen_off"
	parameter          pma_tx_buf_pm_cr2_tx_path_initial_settings                                        = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_pm_cr2_tx_path_link                                                    = "link_off"                                                                ,//"link_off" "lr" "mr" "sr"
	parameter          pma_tx_buf_pm_cr2_tx_path_optimal                                                 = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz                                        = "0"                                                                       ,//NOVAL
	parameter          pma_tx_buf_pm_cr2_tx_path_power_mode                                              = "power_off"                                                               ,//"high_perf" "low_power" "mid_power" "power_off"
	parameter [11:0]   pma_tx_buf_pm_cr2_tx_path_power_rail_eht                                          = 12'd0                                                                     ,//0:4095
	parameter [11:0]   pma_tx_buf_pm_cr2_tx_path_power_rail_et                                           = 12'd0                                                                     ,//0:4095
	parameter          pma_tx_buf_pm_cr2_tx_path_prot_mode                                               = "prot_off"                                                                ,//"basic_tx" "gpon_tx" "not_used" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "prot_off" "qpi_tx" "sata_tx"
	parameter          pma_tx_buf_pm_cr2_tx_path_speed_grade                                             = "speed_off"                                                               ,//"e1" "e2" "e3" "e4" "e5" "i1" "i2" "i3" "i4" "i5" "m3" "m4" "speed_off"
	parameter          pma_tx_buf_pm_cr2_tx_path_sup_mode                                                = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_tx_buf_pm_cr2_tx_path_swing_level                                             = "swing_off"                                                               ,//"hv" "lv" "lvii" "lviii" "swing_off"
	parameter          pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz                                           = "0"                                                                       ,//NOVAL
  parameter          pma_tx_buf_pm_cr2_tx_path_tile_type                                               = "h"                                                                       ,//"h" "l"
	parameter [4:0]    pma_tx_buf_pm_cr2_tx_rx_mcgb_location_for_pcie                                    = 5'd0                                                                      ,//0:31
	parameter [11:0]   pma_tx_buf_power_rail_er                                                          = 12'd0                                                                     ,//0:4095
	parameter          pma_tx_buf_powermode_ac_post_tap                                                  = "tx_post_tap_ac_off"                                                      ,//"tx_post_tap_ac_off" "tx_post_tap_no_jitcomp_ac_on" "tx_post_tap_w_jitcomp_ac_on"
	parameter          pma_tx_buf_powermode_ac_pre_tap                                                   = "tx_pre_tap_ac_off"                                                       ,//"tx_pre_tap_ac_off" "tx_pre_tap_ac_on"
	parameter          pma_tx_buf_powermode_ac_tx_vod_no_jitcomp                                         = "tx_vod_no_jitcomp_ac_l0"                                                 ,//"tx_vod_no_jitcomp_ac_l0" "tx_vod_no_jitcomp_ac_l11" "tx_vod_no_jitcomp_ac_l12" "tx_vod_no_jitcomp_ac_l13" "tx_vod_no_jitcomp_ac_l14" "tx_vod_no_jitcomp_ac_l15" "tx_vod_no_jitcomp_ac_l16" "tx_vod_no_jitcomp_ac_l17" "tx_vod_no_jitcomp_ac_l18" "tx_vod_no_jitcomp_ac_l19" "tx_vod_no_jitcomp_ac_l20" "tx_vod_no_jitcomp_ac_l21" "tx_vod_no_jitcomp_ac_l22" "tx_vod_no_jitcomp_ac_l23" "tx_vod_no_jitcomp_ac_l24" "tx_vod_no_jitcomp_ac_l25" "tx_vod_no_jitcomp_ac_l26" "tx_vod_no_jitcomp_ac_l27" "tx_vod_no_jitcomp_ac_l28" "tx_vod_no_jitcomp_ac_l29" "tx_vod_no_jitcomp_ac_l30" "tx_vod_no_jitcomp_ac_l31"
	parameter          pma_tx_buf_powermode_ac_tx_vod_w_jitcomp                                          = "tx_vod_w_jitcomp_ac_l0"                                                  ,//"tx_vod_w_jitcomp_ac_l0" "tx_vod_w_jitcomp_ac_l11" "tx_vod_w_jitcomp_ac_l12" "tx_vod_w_jitcomp_ac_l13" "tx_vod_w_jitcomp_ac_l14" "tx_vod_w_jitcomp_ac_l15" "tx_vod_w_jitcomp_ac_l16" "tx_vod_w_jitcomp_ac_l17" "tx_vod_w_jitcomp_ac_l18" "tx_vod_w_jitcomp_ac_l19" "tx_vod_w_jitcomp_ac_l20" "tx_vod_w_jitcomp_ac_l21" "tx_vod_w_jitcomp_ac_l22" "tx_vod_w_jitcomp_ac_l23" "tx_vod_w_jitcomp_ac_l24" "tx_vod_w_jitcomp_ac_l25" "tx_vod_w_jitcomp_ac_l26" "tx_vod_w_jitcomp_ac_l27" "tx_vod_w_jitcomp_ac_l28" "tx_vod_w_jitcomp_ac_l29" "tx_vod_w_jitcomp_ac_l30" "tx_vod_w_jitcomp_ac_l31"
	parameter          pma_tx_buf_powermode_dc_post_tap                                                  = "powerdown_tx_post_tap"                                                   ,//"powerdown_tx_post_tap" "tx_post_tap_no_jitcomp_dc_on" "tx_post_tap_w_jitcomp_dc_on"
	parameter          pma_tx_buf_powermode_dc_pre_tap                                                   = "powerdown_tx_pre_tap"                                                    ,//"powerdown_tx_pre_tap" "tx_pre_tap_dc_on"
	parameter          pma_tx_buf_powermode_dc_tx_vod_no_jitcomp                                         = "powerdown_tx_vod_no_jitcomp"                                             ,//"powerdown_tx_vod_no_jitcomp" "tx_vod_no_jitcomp_dc_l11" "tx_vod_no_jitcomp_dc_l12" "tx_vod_no_jitcomp_dc_l13" "tx_vod_no_jitcomp_dc_l14" "tx_vod_no_jitcomp_dc_l15" "tx_vod_no_jitcomp_dc_l16" "tx_vod_no_jitcomp_dc_l17" "tx_vod_no_jitcomp_dc_l18" "tx_vod_no_jitcomp_dc_l19" "tx_vod_no_jitcomp_dc_l20" "tx_vod_no_jitcomp_dc_l21" "tx_vod_no_jitcomp_dc_l22" "tx_vod_no_jitcomp_dc_l23" "tx_vod_no_jitcomp_dc_l24" "tx_vod_no_jitcomp_dc_l25" "tx_vod_no_jitcomp_dc_l26" "tx_vod_no_jitcomp_dc_l27" "tx_vod_no_jitcomp_dc_l28" "tx_vod_no_jitcomp_dc_l29" "tx_vod_no_jitcomp_dc_l30" "tx_vod_no_jitcomp_dc_l31"
	parameter          pma_tx_buf_powermode_dc_tx_vod_w_jitcomp                                          = "powerdown_tx_vod_w_jitcomp"                                              ,//"powerdown_tx_vod_w_jitcomp" "tx_vod_w_jitcomp_dc_l11" "tx_vod_w_jitcomp_dc_l12" "tx_vod_w_jitcomp_dc_l13" "tx_vod_w_jitcomp_dc_l14" "tx_vod_w_jitcomp_dc_l15" "tx_vod_w_jitcomp_dc_l16" "tx_vod_w_jitcomp_dc_l17" "tx_vod_w_jitcomp_dc_l18" "tx_vod_w_jitcomp_dc_l19" "tx_vod_w_jitcomp_dc_l20" "tx_vod_w_jitcomp_dc_l21" "tx_vod_w_jitcomp_dc_l22" "tx_vod_w_jitcomp_dc_l23" "tx_vod_w_jitcomp_dc_l24" "tx_vod_w_jitcomp_dc_l25" "tx_vod_w_jitcomp_dc_l26" "tx_vod_w_jitcomp_dc_l27" "tx_vod_w_jitcomp_dc_l28" "tx_vod_w_jitcomp_dc_l29" "tx_vod_w_jitcomp_dc_l30" "tx_vod_w_jitcomp_dc_l31"
	parameter          pma_tx_buf_pre_emp_sign_1st_post_tap                                              = "fir_post_1t_neg"                                                         ,//"fir_post_1t_neg" "fir_post_1t_pos"
	parameter          pma_tx_buf_pre_emp_sign_pre_tap_1t                                                = "fir_pre_1t_neg"                                                          ,//"fir_pre_1t_neg" "fir_pre_1t_pos"
	parameter [4:0]    pma_tx_buf_pre_emp_switching_ctrl_1st_post_tap                                    = 5'd0                                                                      ,//0:31
	parameter [4:0]    pma_tx_buf_pre_emp_switching_ctrl_pre_tap_1t                                      = 5'd0                                                                      ,//0:31
	parameter          pma_tx_buf_prot_mode                                                              = "prot_off"                                                                ,//"basic_tx" "gpon_tx" "not_used" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "prot_off" "qpi_tx" "sata_tx"
	parameter          pma_tx_buf_res_cal_local                                                          = "non_local"                                                               ,//"local" "non_local"
	parameter          pma_tx_buf_rx_det                                                                 = "mode_0"                                                                  ,//"mode_0" "mode_1" "mode_10" "mode_11" "mode_12" "mode_13" "mode_14" "mode_15" "mode_2" "mode_3" "mode_4" "mode_5" "mode_6" "mode_7" "mode_8" "mode_9"
	parameter          pma_tx_buf_rx_det_output_sel                                                      = "rx_det_pcie_out"                                                         ,//"rx_det_pcie_out" "rx_det_qpi_out"
	parameter          pma_tx_buf_rx_det_pdb                                                             = "rx_det_off"                                                              ,//"rx_det_off" "rx_det_on"
	parameter          pma_tx_buf_sense_amp_offset_cal_curr_n                                            = "sa_os_cal_in_0"                                                          ,//"sa_os_cal_in_0" "sa_os_cal_in_1" "sa_os_cal_in_2" "sa_os_cal_in_3"
	parameter [4:0]    pma_tx_buf_sense_amp_offset_cal_curr_p                                            = 5'd0                                                                      ,//0:31
	parameter          pma_tx_buf_ser_powerdown                                                          = "power_down_ser"                                                          ,//"normal_ser_on" "power_down_ser"
	parameter          pma_tx_buf_silicon_rev                                                            = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_tx_buf_slew_rate_ctrl                                                         = "slew_r5"                                                                 ,//"slew_r0" "slew_r1" "slew_r2" "slew_r3" "slew_r4" "slew_r5" "slew_r6" "slew_r7"
	parameter          pma_tx_buf_sup_mode                                                               = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_tx_buf_swing_level                                                            = "swing_off"                                                               ,//"hv" "lv" "lvii" "lviii" "swing_off"
	parameter          pma_tx_buf_term_code                                                              = "rterm_code7"                                                             ,//"rterm_code0" "rterm_code1" "rterm_code10" "rterm_code11" "rterm_code12" "rterm_code13" "rterm_code14" "rterm_code15" "rterm_code2" "rterm_code3" "rterm_code4" "rterm_code5" "rterm_code6" "rterm_code7" "rterm_code8" "rterm_code9"
	parameter          pma_tx_buf_term_n_tune                                                            = "rterm_n0"                                                                ,//"rterm_n0" "rterm_n1" "rterm_n10" "rterm_n11" "rterm_n12" "rterm_n13" "rterm_n14" "rterm_n15" "rterm_n2" "rterm_n3" "rterm_n4" "rterm_n5" "rterm_n6" "rterm_n7" "rterm_n8" "rterm_n9"
	parameter          pma_tx_buf_term_p_tune                                                            = "rterm_p0"                                                                ,//"rterm_p0" "rterm_p1" "rterm_p10" "rterm_p11" "rterm_p12" "rterm_p13" "rterm_p14" "rterm_p15" "rterm_p2" "rterm_p3" "rterm_p4" "rterm_p5" "rterm_p6" "rterm_p7" "rterm_p8" "rterm_p9"
	parameter          pma_tx_buf_term_sel                                                               = "r_r1"                                                                    ,//"r_r1" "r_r1_calp" "r_r1_capn" "r_r2" "r_r2_caln" "r_r2_calp"
	parameter          pma_tx_buf_tri_driver                                                             = "tri_driver_disable"                                                      ,//"tri_driver_disable" "tri_driver_enable"
	parameter          pma_tx_buf_tx_powerdown                                                           = "normal_tx_on"                                                            ,//"normal_tx_on" "power_down_tx"
	parameter          pma_tx_buf_tx_rst_enable                                                          = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_buf_uc_gen3                                                                = "gen3_off"                                                                ,//"gen3_off" "gen3_on"
	parameter          pma_tx_buf_uc_gen4                                                                = "gen4_off"                                                                ,//"gen4_off" "gen4_on"
	parameter          pma_tx_buf_uc_tx_cal                                                              = "uc_tx_cal_off"                                                           ,//"uc_tx_cal_off" "uc_tx_cal_on"
	parameter          pma_tx_buf_uc_vcc_setting                                                         = "vcc_setting0"                                                            ,//"vcc_setting0" "vcc_setting1" "vcc_setting2" "vcc_setting3"
	parameter          pma_tx_buf_user_fir_coeff_ctrl_sel                                                = "ram_ctl"                                                                 ,//"dynamic_ctl" "ram_ctl"
	parameter [4:0]    pma_tx_buf_vod_output_swing_ctrl                                                  = 5'd0                                                                      ,//0:31
	parameter          pma_tx_buf_vreg_output                                                            = "vccdreg_nominal"                                                         ,//"vccdreg_neg_setting1" "vccdreg_neg_setting2" "vccdreg_neg_setting3" "vccdreg_neg_setting4" "vccdreg_nominal" "vccdreg_pos_setting1" "vccdreg_pos_setting10" "vccdreg_pos_setting11" "vccdreg_pos_setting12" "vccdreg_pos_setting13" "vccdreg_pos_setting14" "vccdreg_pos_setting15" "vccdreg_pos_setting16" "vccdreg_pos_setting17" "vccdreg_pos_setting18" "vccdreg_pos_setting19" "vccdreg_pos_setting2" "vccdreg_pos_setting20" "vccdreg_pos_setting21" "vccdreg_pos_setting22" "vccdreg_pos_setting23" "vccdreg_pos_setting24" "vccdreg_pos_setting25" "vccdreg_pos_setting26" "vccdreg_pos_setting27" "vccdreg_pos_setting3" "vccdreg_pos_setting4" "vccdreg_pos_setting5" "vccdreg_pos_setting6" "vccdreg_pos_setting7" "vccdreg_pos_setting8" "vccdreg_pos_setting9"
	parameter          pma_tx_buf_xtx_path_xcgb_tx_ucontrol_en                                           = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_sequencer_silicon_rev                                                      = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_tx_sequencer_tx_path_rstn_overrideb                                           = "bypass_sequencer"                                                        ,//"bypass_sequencer" "use_sequencer"
	parameter          pma_tx_sequencer_xrx_path_uc_cal_clk_bypass                                       = "cal_clk_0"                                                               ,//"cal_clk_0" "cal_clk_1"
	parameter          pma_tx_sequencer_xtx_path_xcgb_tx_ucontrol_en                                     = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_ser_bti_protected                                                          = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_ser_control_clks_divtx_aibtx                                               = "no_dft_control_clkdivtx_clkaibtx"                                        ,//"dft_control_clkdivtx_clkaibtx_high" "dft_control_clkdivtx_clkaibtx_low" "no_dft_control_clkdivtx_clkaibtx"
	parameter          pma_tx_ser_datarate_bps                                                           = "0"                                                                       ,//NOVAL
	parameter          pma_tx_ser_duty_cycle_correction_mode_ctrl                                        = "dcc_disable"                                                             ,//"dcc_0000011111" "dcc_1111100000" "dcc_continuous" "dcc_disable"
	parameter          pma_tx_ser_initial_settings                                                       = "false"                                                                   ,//"false" "true"
	parameter          pma_tx_ser_pcie_gen                                                               = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter [11:0]   pma_tx_ser_power_rail_er                                                          = 12'd0                                                                     ,//0:4095
	parameter          pma_tx_ser_powermode_ac_ser                                                       = "ac_clk_divtx_user_1_no_jitcomp1p0"                                       ,//"ac_clk_divtx_user_0_jitcomp1p0" "ac_clk_divtx_user_0_jitcomp1p1" "ac_clk_divtx_user_0_no_jitcomp1p0" "ac_clk_divtx_user_0_no_jitcomp1p1" "ac_clk_divtx_user_1_jitcomp1p0" "ac_clk_divtx_user_1_jitcomp1p1" "ac_clk_divtx_user_1_no_jitcomp1p0" "ac_clk_divtx_user_1_no_jitcomp1p1" "ac_clk_divtx_user_2_jitcomp1p0" "ac_clk_divtx_user_2_jitcomp1p1" "ac_clk_divtx_user_2_no_jitcomp1p0" "ac_clk_divtx_user_2_no_jitcomp1p1" "ac_clk_divtx_user_33_jitcomp1p0" "ac_clk_divtx_user_33_jitcomp1p1" "ac_clk_divtx_user_33_no_jitcomp1p0" "ac_clk_divtx_user_33_no_jitcomp1p1" "ac_clk_divtx_user_40_jitcomp1p0" "ac_clk_divtx_user_40_jitcomp1p1" "ac_clk_divtx_user_40_no_jitcomp1p0" "ac_clk_divtx_user_40_no_jitcomp1p1" "ac_clk_divtx_user_66_jitcomp1p0" "ac_clk_divtx_user_66_jitcomp1p1" "ac_clk_divtx_user_66_no_jitcomp1p0" "ac_clk_divtx_user_66_no_jitcomp1p1" "ser_ac_bti"
	parameter          pma_tx_ser_powermode_dc_ser                                                       = "powerdown_serpw"                                                         ,//"dc_clk_divtx_user_0_jitcomp1p0" "dc_clk_divtx_user_0_jitcomp1p1" "dc_clk_divtx_user_0_no_jitcomp1p0" "dc_clk_divtx_user_0_no_jitcomp1p1" "dc_clk_divtx_user_1_jitcomp1p0" "dc_clk_divtx_user_1_jitcomp1p1" "dc_clk_divtx_user_1_no_jitcomp1p0" "dc_clk_divtx_user_1_no_jitcomp1p1" "dc_clk_divtx_user_2_jitcomp1p0" "dc_clk_divtx_user_2_jitcomp1p1" "dc_clk_divtx_user_2_no_jitcomp1p0" "dc_clk_divtx_user_2_no_jitcomp1p1" "dc_clk_divtx_user_33_jitcomp1p0" "dc_clk_divtx_user_33_jitcomp1p1" "dc_clk_divtx_user_33_no_jitcomp1p0" "dc_clk_divtx_user_33_no_jitcomp1p1" "dc_clk_divtx_user_40_jitcomp1p0" "dc_clk_divtx_user_40_jitcomp1p1" "dc_clk_divtx_user_40_no_jitcomp1p0" "dc_clk_divtx_user_40_no_jitcomp1p1" "dc_clk_divtx_user_66_jitcomp1p0" "dc_clk_divtx_user_66_jitcomp1p1" "dc_clk_divtx_user_66_no_jitcomp1p0" "dc_clk_divtx_user_66_no_jitcomp1p1" "powerdown_serpw" "ser_dc_bti"
	parameter          pma_tx_ser_prot_mode                                                              = "prot_off"                                                                ,//"basic_tx" "gpon_tx" "not_used" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "prot_off" "qpi_tx" "sata_tx"
	parameter          pma_tx_ser_ser_aibck_enable                                                       = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_tx_ser_ser_aibck_x1_override                                                  = "normal"                                                                  ,//"clk1x_over_ride" "normal"
	parameter          pma_tx_ser_ser_clk_divtx_user_sel                                                 = "divtx_user_33"                                                           ,//"divtx_user_1" "divtx_user_2" "divtx_user_33" "divtx_user_40" "divtx_user_66" "divtx_user_off"
	parameter          pma_tx_ser_ser_clk_mon                                                            = "disable_clk_mon"                                                         ,//"disable_clk_mon" "enable_clk_mon_0101" "enable_clk_mon_1010"
	parameter          pma_tx_ser_ser_dftppm_clkselect                                                   = "div_dftppm"                                                              ,//"aib_dftppm" "div_dftppm"
	parameter          pma_tx_ser_ser_in_jitcomp                                                         = "jitcomp_on"                                                              ,//"jitcomp_off" "jitcomp_on"
	parameter          pma_tx_ser_ser_powerdown                                                          = "normal_poweron_ser"                                                      ,//"normal_poweron_ser" "powerdown_ser"
	parameter          pma_tx_ser_ser_preset_bti_en                                                      = "ser_preset_bti_disable"                                                  ,//"ser_preset_bti_disable" "ser_preset_bti_enable"
	parameter          pma_tx_ser_silicon_rev                                                            = "14nm5cr2"                                                                ,//"14nm4cr2" "14nm4cr2ea" "14nm5bcr2b" "14nm5cr2" "14nm5bcr2ea"
	parameter          pma_tx_ser_sup_mode                                                               = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_tx_ser_uc_vcc_setting                                                         = "vcc_setting0"                                                            ,//"vcc_setting0" "vcc_setting1" "vcc_setting2" "vcc_setting3"
	parameter          pma_txpath_chnsequencer_pcie_gen                                                  = "non_pcie"                                                                ,//"non_pcie" "pcie_gen1_100mhzref" "pcie_gen1_125mhzref" "pcie_gen2_100mhzref" "pcie_gen2_125mhzref" "pcie_gen3_100mhzref" "pcie_gen3_125mhzref"
	parameter          pma_txpath_chnsequencer_prot_mode                                                 = "prot_off"                                                                ,//"basic_tx" "gpon_tx" "not_used" "pcie_gen1_tx" "pcie_gen2_tx" "pcie_gen3_tx" "pcie_gen4_tx" "prot_off" "qpi_tx" "sata_tx"
	parameter          pma_txpath_chnsequencer_silicon_rev                                               = "14nm5cr2ea"                                                              ,//"14nm4acr2b" "14nm4acr2ea" "14nm5bcr2b" "14nm5cr2ea"
	parameter          pma_txpath_chnsequencer_sup_mode                                                  = "sup_off"                                                                 ,//"engineering_mode" "sup_off" "user_mode"
	parameter          pma_txpath_chnsequencer_txpath_chnseq_enable                                      = "disable"                                                                 ,//"disable" "enable"
	parameter          pma_txpath_chnsequencer_txpath_chnseq_idle_direct_on                              = "cgb_idle_direct_off"                                                     ,//"cgb_idle_direct_off" "cgb_idle_direct_on"
	parameter [3:0]    pma_txpath_chnsequencer_txpath_chnseq_stage_select                                = 4'd0                                                                      ,//0:15
	parameter          pma_txpath_chnsequencer_txpath_chnseq_wakeup_bypass                               = "bypass_off"                                                              //"bypass_off" "bypass_on"
  ) (

	//------------------------
	// Common Ports
	//------------------------
	
  // Resets
	input   wire	[0:0]			      rcfg_tx_digitalreset_release_ctrl,
	input	  wire	[channels-1:0]	tx_analogreset,			               // TX PMA reset
	input	  wire	[channels-1:0]	tx_digitalreset,		               // TX PCS reset
	input	  wire	[channels-1:0]	tx_aibreset,			                 // TX AIB reset
	input	  wire	[channels-1:0]	rx_analogreset,			               // RX PMA reset
	input	  wire	[channels-1:0]	rx_digitalreset,		               // RX PCS reset
	input	  wire	[channels-1:0]	rx_aibreset,			                 // RX AIB reset	
	output	wire	[channels-1:0]	tx_analogreset_stat,
	output	wire	[channels-1:0]	tx_digitalreset_stat,
	output	wire	[channels-1:0]	rx_analogreset_stat,
	output	wire	[channels-1:0]	rx_digitalreset_stat,

	output	wire	[channels-1:0]	tx_transfer_ready,	               // TX transfer ready
	output	wire	[channels-1:0]	rx_transfer_ready,	               // RX transfer ready
	output	wire	[channels-1:0]	tx_fifo_ready,	                   // TX FIFO ready
	output	wire	[channels-1:0]	rx_fifo_ready,	                   // RX FIFO ready
	output	wire	[channels-1:0]	tx_digitalreset_timeout,	         // TX digital reset timeout
	output	wire	[channels-1:0]	rx_digitalreset_timeout,	         // RX digital reset timeout	
	output	wire	[channels-1:0]	tx_cal_busy,		                   // TX calibration in progress
	output	wire	[channels-1:0]	rx_cal_busy,		                   // RX calibration in progress
	output	wire	[channels-1:0]	avmm_busy,

	// TX serial clocks
	input	wire	[channels-1:0]	tx_serial_clk0,		// clkout from external PLL
	input	wire	[channels-1:0]	tx_serial_clk1,		// clkout from external PLL
	input	wire	[channels-1:0]	tx_serial_clk2,		// clkout from external PLL
	input	wire	[channels-1:0]	tx_serial_clk3,		// clkout from external PLL

	// Bonding clocks
	input	wire	[channels*6-1:0]	tx_bonding_clocks,	// Bonding clock bundle from Master CGB
	input	wire	[channels*6-1:0]	tx_bonding_clocks1,	// Bonding clock bundle from Master CGB
	input	wire	[channels*6-1:0]	tx_bonding_clocks2,	// Bonding clock bundle from Master CGB
	input	wire	[channels*6-1:0]	tx_bonding_clocks3,	// Bonding clock bundle from Master CGB

	// CDR reference clocks
	input	wire	[0:0]	rx_cdr_refclk0,		// RX PLL reference clock 0
	input	wire	[0:0]	rx_cdr_refclk1,		// RX PLL reference clock 1
	input	wire	[0:0]	rx_cdr_refclk2,		// RX PLL reference clock 2
	input	wire	[0:0]	rx_cdr_refclk3,		// RX PLL reference clock 3
	input	wire	[0:0]	rx_cdr_refclk4,		// RX PLL reference clock 4

	// TX and RX serial ports
	output	wire	[channels-1:0]	tx_serial_data,		// TX serial data output to HSSI pin
	input	  wire	[channels-1:0]	rx_serial_data,		// RX serial data input from HSSI pin

	// PMA control ports
	input	wire	[channels-1:0]	rx_pma_clkslip,		 // Slip RX PMA by one clock cycle
	input	wire	[channels-1:0]	rx_seriallpbken,	 // Enable TX-to-RX loopback
	input	wire	[channels-1:0]	rx_set_locktodata, // Set CDR to manual lock to data mode
	input	wire	[channels-1:0]	rx_set_locktoref,	 // Set CDR to manual lock to reference mode

	// PMA status ports
	output	wire	[channels-1:0]	rx_is_lockedtoref,
	output	wire	[channels-1:0]	rx_is_lockedtodata,

	// Adaptation
	input	wire	[channels-1:0]	rx_adapt_reset,	// For adaptation engine control: user needs to apply reset first
	input	wire	[channels-1:0]	rx_adapt_start,	// For adaptation engine control: user, after releasing reset, needs to apply start

	// QPI specific ports
	input	wire	 [channels-1:0]	rx_pma_qpipulldn,
	input	wire	 [channels-1:0]	tx_pma_qpipulldn,
	input	wire	 [channels-1:0]	tx_pma_qpipullup,
	output	wire [channels-1:0]	tx_pma_rxfound,
	input	wire	 [channels-1:0]	tx_pma_txdetectrx,
	input	wire	 [channels-1:0]	tx_pma_elecidle,	// TX electrical idle

	//-------------------------
	// Common datapath ports
	//-------------------------
  
  // Clock ports
	input	  wire	[channels-1:0]	tx_coreclkin,			// TX parallel clock input
	input	  wire	[channels-1:0]	rx_coreclkin,			// RX parallel clock input
	input	  wire	[channels-1:0]	tx_x2_coreclkin,	// TX x2 parallel clock input
	output	wire	[channels-1:0]	tx_clkout,				// TX Parallel clock output 1
	output	wire	[channels-1:0]	tx_clkout2,				// TX Parallel clock output 2
	output	wire	[channels-1:0]	rx_clkout,				// RX parallel clock output 1
	output	wire	[channels-1:0]	rx_clkout2,				// RX parallel clock output 2
  output	wire	[channels-1:0]	tx_clkout_hioint,
	output	wire	[channels-1:0]	tx_clkout2_hioint,
	output	wire	[channels-1:0]	rx_clkout_hioint,
	output	wire	[channels-1:0]	rx_clkout2_hioint,
	output	wire	[channels-1:0]	delay_measurement_clkout,	 // Clock delay measurement output 1 
	output	wire	[channels-1:0]	delay_measurement_clkout2, // Clock delay measurement output 2
	output	wire	[channels-1:0]	tx_pma_iqtxrx_clkout,	     // TX clock output from PMA to iqtxrx lines (for cascading)
	output	wire	[channels-1:0]	rx_pma_iqtxrx_clkout,	     // RX clock output from PMA to iqtxrx lines (for cascading)

	// Latency and Deterministic Latency
	input	 wire	[channels-1:0]	latency_sclk,				       // Sampling clock for FIFO latency measurement
	input	 wire	[channels-1:0]	clk_delay_sclk,				     // Sampling clock for clock delay measurement
	output wire	[channels-1:0]	tx_fifo_latency_pulse,		 // Latency pulse of TX Core FIFO
	output wire	[channels-1:0]	rx_fifo_latency_pulse,		 // Latency pulse of RX Core FIFO
	output wire	[channels-1:0]	tx_pcs_fifo_latency_pulse, // Latency pulse of TX PCS FIFO
	output wire	[channels-1:0]	rx_pcs_fifo_latency_pulse, // Latency pulse of RX PCS FIFO
	input	 wire	[channels-1:0]	tx_fifo_latency_adj_ena,	 // Input to enable TX FIFO latency adjustment 
	input	 wire	[channels-1:0]	rx_fifo_latency_adj_ena,	 // Input to enable RX FIFO latency adjustment

  // Debug port
  output wire [channels-1:0]  osc_transfer_en,           // Internal use: OSC transfer enable status

	// parallel data ports
	input	 wire	[channels*80-1:0]	tx_parallel_data,		// PCS TX parallel data interface
	output wire	[channels*80-1:0]	rx_parallel_data,		// PCS RX parallel data interface

	input	 wire	[channels-1:0] rx_bitslip,					  // RX bitslip (Standard and Enhanced PCS). Asynchronous. Rising edge triggers single bit slip.
	input	 wire	[channels-1:0] rx_prbs_err_clr,
	output wire	[channels-1:0] rx_prbs_done,
	output wire	[channels-1:0] rx_prbs_err,

	// FIFO ports
	output wire	[channels-1:0]	tx_fifo_full,
	output wire	[channels-1:0]	tx_fifo_empty,
	output wire	[channels-1:0]	tx_fifo_pfull,
	output wire	[channels-1:0]	tx_fifo_pempty,
	output wire	[channels-1:0]	tx_dll_lock,
	output wire	[channels-1:0]	rx_fifo_full,
	output wire	[channels-1:0]	rx_fifo_empty,
	output wire	[channels-1:0]	rx_fifo_pfull,
	output wire	[channels-1:0]	rx_fifo_pempty,
	input	 wire	[channels-1:0]	rx_fifo_rd_en,
	output wire	[channels-1:0]	rx_fifo_insert,
	output wire	[channels-1:0]	rx_fifo_del,
	input	 wire	[channels-1:0]	rx_fifo_align_clr,	
	output wire	[channels-1:0]	tx_pcs_fifo_full,
	output wire	[channels-1:0]	tx_pcs_fifo_empty,	
	output wire	[channels-1:0]	rx_pcs_fifo_full,
	output wire	[channels-1:0]	rx_pcs_fifo_empty,

	// 8G PCS ports
	input	 wire	[channels-1:0]	 rx_std_bitrev_ena,
	input	 wire	[channels-1:0]	 rx_std_byterev_ena,
	input	 wire	[channels-1:0]	 tx_polinv,
	input	 wire	[channels-1:0]	 rx_polinv,
	input	 wire	[channels*5-1:0] tx_std_bitslipboundarysel,
	output wire	[channels*5-1:0] rx_std_bitslipboundarysel,
	input	 wire	[channels-1:0]	 rx_std_wa_patternalign,
	input	 wire	[channels-1:0]	 rx_std_wa_a1a2size,
	output wire	[channels-1:0]	 rx_std_rmfifo_full,
	output wire	[channels-1:0]	 rx_std_rmfifo_empty,
	output wire	[channels-1:0]	 rx_std_signaldetect,

	// 10G PCS ports
	output wire	[channels-1:0]	 tx_enh_frame,
	input	 wire	[channels-1:0]	 tx_enh_frame_burst_en,
	input	 wire	[channels*2-1:0] tx_enh_frame_diag_status,
	output wire	[channels-1:0]	 rx_enh_frame,
	output wire	[channels-1:0]	 rx_enh_frame_lock,
	output wire	[channels*2-1:0] rx_enh_frame_diag_status,
	output wire	[channels-1:0]	 rx_enh_crc32_err,
	output wire	[channels-1:0]	 rx_enh_highber,
	input	 wire	[channels-1:0]	 rx_enh_highber_clr_cnt,
	input	 wire	[channels-1:0]	 rx_enh_clr_errblk_count,
	output wire	[channels-1:0]	 rx_enh_blk_lock,
	input	 wire	[channels*7-1:0] tx_enh_bitslip,

	// PIPE interface ports
	input	 wire	[1:0]	           pipe_sw_done,					
	output wire	[1:0]	           pipe_sw,						
	input	 wire	[0:0]	           pipe_hclk_in,	
	output wire	[0:0]	           pipe_hclk_out,
	input	 wire	[channels*3-1:0]   pipe_rx_eidleinfersel,
	output wire	[channels-1:0]	   pipe_rx_elecidle,

	// Bonding ports for HIP mode
	input	 wire	[channels*30-1:0]	pcs_bonding_bot_data_in,
	output wire	[channels*30-1:0]	pcs_bonding_bot_data_out,
	input	 wire	[channels*30-1:0]	pcs_bonding_top_data_in,
	output wire	[channels*30-1:0]	pcs_bonding_top_data_out,
	input	 wire	[channels*5-1:0]	pld_aib_bond_tx_ds_in,
	input	 wire	[channels*5-1:0]	pld_aib_bond_tx_us_in,
	output wire	[channels*5-1:0]	pld_aib_bond_tx_ds_out,
	output wire	[channels*5-1:0]	pld_aib_bond_tx_us_out,
	input	 wire	[channels*5-1:0]	pld_aib_bond_rx_ds_in,
	input	 wire	[channels*5-1:0]	pld_aib_bond_rx_us_in,
	output wire	[channels*5-1:0]	pld_aib_bond_rx_ds_out,
	output wire	[channels*5-1:0]	pld_aib_bond_rx_us_out,
	input	 wire	[channels*7-1:0]	hssi_aib_bond_tx_ds_in,
	input	 wire	[channels*7-1:0]	hssi_aib_bond_tx_us_in,
	output wire	[channels*7-1:0]	hssi_aib_bond_tx_ds_out,
	output wire	[channels*7-1:0]	hssi_aib_bond_tx_us_out,
	input	 wire	[channels*8-1:0]	hssi_aib_bond_rx_ds_in,
	input	 wire	[channels*8-1:0]	hssi_aib_bond_rx_us_in,
	output wire	[channels*8-1:0]	hssi_aib_bond_rx_ds_out,
	output wire	[channels*8-1:0]	hssi_aib_bond_rx_us_out,

	// PHIP ports
	input	wire	[channels*101-1:0] hip_aib_data_in,
	output wire	[channels*132-1:0] hip_aib_data_out,
	input	 wire	[channels*92-1:0]	 hip_pcs_data_in,
	output wire	[channels*62-1:0]	 hip_pcs_data_out,
	output wire	[channels-1:0]		 hip_cal_done,

	input	 wire	[channels*4-1:0]	 hip_aib_fsr_in,
	input	 wire	[channels*40-1:0]	 hip_aib_ssr_in,
	output wire	[channels*4-1:0]	 hip_aib_fsr_out,
	output wire	[channels*8-1:0]	 hip_aib_ssr_out,

    input wire [channels*2-1:0]    hip_in_reserved_out,

    // signals for PCIe EIOS protection
    output wire [channels-1:0]   pld_pmaif_mask_tx_pll, 
    output wire [channels-1:0]   pldadapt_out_test_data_b10,
    input                        eios_rx_prot_req,    
    input                        pipe_rstn_in, 

	// EHIP ports
	input	  wire [channels*105-1:0] ehip_aib_data_in,
	output  wire [channels*132-1:0] ehip_aib_data_out,
  output  wire [channels*147-1:0] ehip_aib_pld_tx_data_out,
  input   wire [channels*147-1:0] ehip_pcs_pld_tx_data_in,
  output  wire [channels*149-1:0] ehip_pcs_pld_rx_data_out,  
  output  wire [channels-1:0]     tx_pldpcs_clkout,
  output  wire [channels-1:0]     rx_pldpcs_clkout,
  output  wire [channels-1:0]     out_pma_aib_tx_clk,
	//input	  wire [channels*92-1:0]	ehip_pcs_data_in,
	//output  wire [channels*62-1:0]	ehip_pcs_data_out,


	// Reconfiguration ports
	input	 wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)-1:0]		reconfig_clk,
	input	 wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)-1:0]		reconfig_reset,
	input	 wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)-1:0]		reconfig_write,
	input	 wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)-1:0]		reconfig_read,
/*<TODO: Changed [(rcfg_enable&&rcfg_shared ? (11+altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(channels-1)) : (11*channels))-1:0] -> [(rcfg_enable&&rcfg_shared ? (11+altera_xcvr_native_s10_htile_functions_h::clogb2_alt_xcvr_native_s10(channels-1)) : (11*channels))-1:0]	*/
        input	 wire	[(rcfg_enable&&rcfg_shared ? (11+altera_xcvr_native_s10_functions_h::clogb2_alt_xcvr_native_s10(channels-1)) : (11*channels))-1:0]	reconfig_address,
	input	 wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)*32-1:0]	reconfig_writedata,
	output wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)*32-1:0]	reconfig_readdata,
	output wire	[(rcfg_enable&&rcfg_shared ? 1 : channels)-1:0]		reconfig_waitrequest
	

);

localparam  RCFG_ADDR_BITS  = 11;
localparam  xcvr_native_mode  =   (duplex_mode == "duplex") ? "mode_duplex"
                                : (duplex_mode == "tx")     ? "mode_tx_only"
                                :                             "mode_rx_only";

localparam	avmm_busy_en      = rcfg_separate_avmm_busy ? "enable" : "disable";

// Reset Sequencing
localparam  lcl_enable_reset_sequencer = disable_reset_sequencer ? 0 : 1;
localparam  tx_enable = (duplex_mode == "rx") ? 0 : 1;
localparam  rx_enable = (duplex_mode == "tx") ? 0 : 1;	
localparam  pipe_mode_enable = (hssi_8g_rx_pcs_prot_mode == "pipe_g1" || 
                                hssi_8g_rx_pcs_prot_mode == "pipe_g2" || 
                                hssi_8g_rx_pcs_prot_mode == "pipe_g3"
                               );

localparam  CLK_FREQ_IN_HZ                = 125000000;
localparam  DEFAULT_RESET_SEPARATION_NS   = 200;
localparam  TX_ANALOG_RESET_SEPARATION_NS = 1000;
localparam  RX_ANALOG_RESET_SEPARATION_NS = 1000;
localparam  DIGITAL_RESET_SEPARATION_NS   = 200;
localparam  TX_PCS_RESET_EXTENSION_NS     = pipe_mode_enable ? 250 : 0;
localparam  RX_PCS_RESET_EXTENSION_NS     = 0;

// Bonding
localparam  enable_pcs_aib_bonding    = (bonded_mode == "pma_pcs") ? 1 : 0;
localparam  enable_rx_pcs_aib_bonding = (hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx == "individual_rx") ? 0 : 1;

localparam	enable_pcs_bonding = enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "individual") ? 0 : 1
										             : enable_pcs_aib_bonding;
localparam  lcl_pcs_aib_bonding_master = enable_pcs_aib_bonding ? pcs_bonding_master : channels / 2;

localparam	enable_tx_hssi_aib_bonding = enable_manual_bonding_settings ? (manual_tx_hssi_aib_bonding_mode == "individual") ? 0 : 1
										                     : (hssi_adapt_tx_ctrl_plane_bonding == "individual") ? 0 : 1;
localparam	enable_tx_core_aib_bonding = enable_manual_bonding_settings ? (manual_tx_core_aib_bonding_mode == "individual") ? 0 : 1
										                     : (hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? 0 : 1;										
localparam	enable_rx_hssi_aib_bonding = enable_manual_bonding_settings ? (manual_rx_hssi_aib_bonding_mode == "individual") ? 0 : 1
										                     : (hssi_adapt_rx_ctrl_plane_bonding == "individual") ? 0 : 1;
localparam	enable_rx_core_aib_bonding = enable_manual_bonding_settings ? (manual_rx_core_aib_bonding_mode == "individual") ? 0 : 1
										                     : (hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? 0 : 1;										

localparam  tx_bonded_mode_reset_sequence = enable_pcs_aib_bonding ? "bonded" 
													                  : (pcs_reset_sequencing_mode == "bonded") ? "non_bonded_simultaneous"
													                  : "non_bonded";

localparam  rx_bonded_mode_reset_sequence = enable_rx_pcs_aib_bonding ? "bonded" 
													                  : (pcs_reset_sequencing_mode == "bonded") ? "non_bonded_simultaneous"
													                  : "non_bonded";

// ADME
localparam  lcl_adme_assgn_map = {" assignments {dataRate ",adme_data_rate," protMode ",adme_prot_mode," pmaMode ",adme_pma_mode," txPowerMode ",adme_tx_power_mode," device_revision ",device_revision," enable_background_cal ",adme_enable_bg_cal,"}"};


// Datapath wires
wire [channels*80-1:0] int_tx_parallel_data;
wire [channels*80-1:0] int_rx_parallel_data;

// Reset wires
wire int_tx_release_aib_first;
wire [channels-1:0] int_tx_analog_reset;
wire [channels-1:0] int_rx_analog_reset;
wire [channels-1:0] int_pld_pma_rxpma_rst;
wire [channels-1:0] int_pld_pma_txpma_rst;
wire [channels-1:0] int_pld_adapter_rx_pld_rst;
wire [channels-1:0] int_pld_adapter_tx_pld_rst;
wire [channels-1:0] int_pld_pcs_rx_pld_rst;
wire [channels-1:0] int_pld_pcs_tx_pld_rst;
wire [channels-1:0] int_tx_transfer_ready;
wire [channels-1:0] int_rx_transfer_ready;

//early speed change wires
wire [channels*80-1:0] int_tx_parallel_data_esc;
wire [channels*2-1:0]  int_hip_in_reserved_out;	
wire [channels-1:0]    tx_elec_idle;
wire [channels*2-1:0]  pipe_rate;
wire                   pclk;
wire [1:0]             pcie_sw;
wire                   early_spd_chng;
wire                   reset_n_esc;

// eios rx protect wires
wire                   pipe_clk;
wire [1:0]             pipe_rate_master;

// Bonding wires
wire [7:0] aibhssi_bond_rx_ds_in [channels-1:0];
wire [7:0] aibhssi_bond_rx_us_in [channels-1:0];
wire [7:0] aibhssi_bond_rx_ds_out [channels-1:0];
wire [7:0] aibhssi_bond_rx_us_out [channels-1:0];

wire [6:0] aibhssi_bond_tx_ds_in [channels-1:0];
wire [6:0] aibhssi_bond_tx_us_in [channels-1:0];
wire [6:0] aibhssi_bond_tx_ds_out [channels-1:0];
wire [6:0] aibhssi_bond_tx_us_out [channels-1:0];

wire [4:0] hdpldadapt_bond_rx_ds_in [channels-1:0];
wire [4:0] hdpldadapt_bond_rx_us_in [channels-1:0];
wire [4:0] hdpldadapt_bond_rx_ds_out [channels-1:0];
wire [4:0] hdpldadapt_bond_rx_us_out [channels-1:0];

wire [4:0] hdpldadapt_bond_tx_ds_in [channels-1:0];
wire [4:0] hdpldadapt_bond_tx_us_in [channels-1:0];
wire [4:0] hdpldadapt_bond_tx_ds_out [channels-1:0];
wire [4:0] hdpldadapt_bond_tx_us_out [channels-1:0];

wire  [4:0]   bond_pcs10g_in_bot [channels-1:0];
wire  [4:0]   bond_pcs10g_in_top [channels-1:0];
wire  [4:0]   bond_pcs10g_out_bot [channels-1:0];
wire  [4:0]   bond_pcs10g_out_top [channels-1:0];

wire  [12:0]  bond_pcs8g_in_bot [channels-1:0];
wire  [12:0]  bond_pcs8g_in_top [channels-1:0];
wire  [12:0]  bond_pcs8g_out_bot [channels-1:0];
wire  [12:0]  bond_pcs8g_out_top [channels-1:0];

wire  [11:0]  bond_pmaif_in_bot [channels-1:0];
wire  [11:0]  bond_pmaif_in_top [channels-1:0];
wire  [11:0]  bond_pmaif_out_bot [channels-1:0];
wire  [11:0]  bond_pmaif_out_top [channels-1:0];

// AVMM reconfiguration interface signals
wire  [channels-1:0]    avmm_clk;
wire  [channels-1:0]    avmm_reset;
wire  [channels-1:0]    avmm_write;
wire  [channels-1:0]    avmm_read;
wire  [channels*RCFG_ADDR_BITS-1:0] avmm_address;
wire  [channels*8-1:0]  avmm_writedata;
wire  [channels*8-1:0]  avmm_readdata;
wire  [channels-1:0]    avmm_waitrequest;

wire  [channels-1:0]    avmm_request_int;


// RECAL AVMM reconfiguration interface signals
wire  [channels-1:0]    user_avmm_clk;
wire  [channels-1:0]    user_avmm_reset;
wire  [channels-1:0]    user_avmm_write;
wire  [channels-1:0]    user_avmm_read;
wire  [channels*RCFG_ADDR_BITS-1:0] user_avmm_address;
wire  [channels*8-1:0]  user_avmm_writedata;
wire  [channels*8-1:0]  user_avmm_readdata;
wire  [channels-1:0]    user_avmm_waitrequest;
//wire  [channels-1:0]    r_recal;
wire  [channels-1:0]    recal_waitrequest;
// wires for control signals from embedded debug
`ifdef ALTERA_XCVR_S10_PRBS_STATUS_SSRPATH
wire [channels-1:0]     rx_prbs_err_int;
wire [channels-1:0]     rx_prbs_done_int;
`endif
wire [channels-1:0]     int_rx_prbs_err_clr;
wire [channels-1:0]     int_rx_set_locktoref;
wire [channels-1:0]     int_rx_set_locktodata;
wire [channels-1:0]     int_rx_seriallpbken;
wire [channels-1:0]     int_tx_analogreset;
wire [channels-1:0]     int_tx_digitalreset;
wire [channels-1:0]     int_rx_analogreset;
wire [channels-1:0]     int_rx_digitalreset;

wire  [channels-1:0]    int_tx_cal_busy_mask;      // TX calibration in progress
wire  [channels-1:0]    int_rx_cal_busy_mask;      // RX calibration in progress

wire  [channels-1:0]  pld_cal_done;

// Scan test wires
wire                    int_adapter_clk_sel_n;
wire                    int_adapter_scan_mode_n;
wire                    int_adapter_scan_shift_n;

//background calibration enable reg output
wire [channels-1 :0]    bg_cal_en;

assign  tx_cal_busy = ~pld_cal_done & int_tx_cal_busy_mask;
assign  rx_cal_busy = ~pld_cal_done & int_rx_cal_busy_mask;

assign int_tx_release_aib_first =  enable_rcfg_tx_digitalreset_release_ctrl ? rcfg_tx_digitalreset_release_ctrl
									                : l_release_aib_reset_first ? 1'b1 : 1'b0;
// eios rx protect clock and rate signals
generate if  (enable_eios_rx_protect) begin : g_eios_rp_en
  assign   pipe_clk           =  tx_coreclkin[lcl_pcs_aib_bonding_master]  ;
  assign   pipe_rate_master   =  int_tx_parallel_data_esc[lcl_pcs_aib_bonding_master*80+33:lcl_pcs_aib_bonding_master*80+32];  
           //pipe interface mapping offset for pipe_rate is 32; take the delayed version from esc if it is enabled
end else begin : g_eios_rp_dis
  assign   pipe_clk           = 1'b0  ;
  assign   pipe_rate_master   = 2'b00;
end
endgenerate

// Ensure scan settings are tied off but disabled
assign int_adapter_clk_sel_n    = 1'b1;
assign int_adapter_scan_mode_n  = 1'b1;
assign int_adapter_scan_shift_n = 1'b1;

wire [channels-1:0] 	int_avmm_busy; //CORE_IP OUTPUT
wire [channels-1 :0] bg_cal_avmm_busy;
//***************************************************************************
//************* Embedded JTAG, AVMM and Embedded Streamer Expansion *********
generate if(enable_background_cal == 0) begin: g_recal_disable_rcfg_opt_logic
alt_xcvr_native_rcfg_opt_logic_qufrg4q #(
  .dbg_user_identifier                            ( dbg_user_identifier                 ),
  .duplex_mode                                    ( duplex_mode                         ),
  .dbg_embedded_debug_enable                      ( dbg_embedded_debug_enable           ),
  .dbg_capability_reg_enable                      ( dbg_capability_reg_enable           ),
  .dbg_prbs_soft_logic_enable                     ( dbg_prbs_soft_logic_enable          ),
  .dbg_odi_soft_logic_enable                      ( dbg_odi_soft_logic_enable           ),
  .dbg_stat_soft_logic_enable                     ( dbg_stat_soft_logic_enable          ),
  .dbg_ctrl_soft_logic_enable                     ( dbg_ctrl_soft_logic_enable          ),
  .CHANNELS                                       ( channels                            ),
  .ADDR_BITS                                      ( RCFG_ADDR_BITS                      ),
  .ADME_SLAVE_MAP                                 ( "altera_xcvr_native_s10_htile"      ),
  .ADME_ASSGN_MAP                                 ( lcl_adme_assgn_map                  ),
  .RECONFIG_SHARED                                ( rcfg_enable && rcfg_shared          ),
  .JTAG_ENABLED                                   ( rcfg_enable && rcfg_jtag_enable     ),
  .RCFG_EMB_STRM_ENABLED                          ( rcfg_enable && rcfg_emb_strm_enable ),
  .RCFG_PROFILE_CNT                               ( rcfg_profile_cnt                    ),
  .enable_eios_rx_protect                         ( enable_eios_rx_protect              ),
  .pcs_aib_bonding_master                         ( lcl_pcs_aib_bonding_master          ),
  .enable_background_cal			              ( enable_background_cal   		    )
) alt_xcvr_native_optional_rcfg_logic (
  // User reconfig interface ports
  .reconfig_clk                                   ( reconfig_clk                        ),
  .reconfig_reset                                 ( reconfig_reset                      ),
  .reconfig_write                                 ( reconfig_write                      ),
  .reconfig_read                                  ( reconfig_read                       ),
  .reconfig_address                               ( reconfig_address                    ),
  .reconfig_writedata                             ( reconfig_writedata                  ),
  .reconfig_readdata                              ( reconfig_readdata                   ),
  .reconfig_waitrequest                           ( reconfig_waitrequest                ),
  
  // AVMM ports to transceiver                    
  .avmm_clk                                       ( avmm_clk                            ),
  .avmm_reset                                     ( avmm_reset                          ),
  .avmm_write                                     ( avmm_write                          ),
  .avmm_read                                      ( avmm_read                           ),
  .avmm_address                                   ( avmm_address                        ),
  .avmm_writedata                                 ( avmm_writedata                      ),
  .avmm_readdata                                  ( avmm_readdata                       ),
  .avmm_waitrequest                               ( avmm_waitrequest                    ),
  
  // input signals from the PHY for PRBS error accumulation
  .prbs_err_signal                                ( rx_prbs_err                         ),
  .prbs_done_signal                               ( rx_prbs_done                        ),

  // input rx_clkout for PRBS
  .in_rx_clkout                                   ( rx_clkout                           ),

  // siganls from pipe and mac interface, for eios_rx_protect
  .pipe_clk                                       ( pipe_clk                            ), 
  .pipe_rstn                                      ( pipe_rstn_in                        ),  
  .pipe_rate                                      ( pipe_rate_master                    ), 
  .eios_rx_prot_req                               ( eios_rx_prot_req                    ), 
  .pld_pmaif_mask_tx_pll                          ( pld_pmaif_mask_tx_pll               ),    
  .pcie_ctrl_testbus_b10                          ( pldadapt_out_test_data_b10          ),    

  // input status signals from the transceiver
  .in_rx_is_lockedtoref                           ( rx_is_lockedtoref                   ),
  .in_rx_is_lockedtodata                          ( rx_is_lockedtodata                  ),
  .in_tx_cal_busy                                 ( tx_cal_busy                         ),
  .in_rx_cal_busy                                 ( rx_cal_busy                         ),
  .in_avmm_busy                                   ( int_avmm_busy                       ),
  .in_tx_transfer_ready                           ( int_tx_transfer_ready               ),
  .in_rx_transfer_ready                           ( int_rx_transfer_ready               ),

  // input control signals from the core
  .in_rx_prbs_err_clr                             ( rx_prbs_err_clr                     ),
  .in_set_rx_locktoref                            ( rx_set_locktoref                    ),
  .in_set_rx_locktodata                           ( rx_set_locktodata                   ),
  .in_en_serial_lpbk                              ( rx_seriallpbken                     ),
  .in_rx_analogreset                              ( rx_analogreset                      ),
  .in_rx_digitalreset                             ( rx_digitalreset						),  
  .in_tx_analogreset                              ( tx_analogreset                      ),
  .in_tx_digitalreset                             ( tx_digitalreset						),  
 
  // output control signals to the phy
  .out_prbs_err_clr                               ( int_rx_prbs_err_clr                 ),
  .out_set_rx_locktoref                           ( int_rx_set_locktoref                ),
  .out_set_rx_locktodata                          ( int_rx_set_locktodata               ),
  .out_en_serial_lpbk                             ( int_rx_seriallpbken                 ),
  .out_rx_analogreset                             ( int_rx_analogreset                  ),
  .out_rx_digitalreset                            ( int_rx_digitalreset                 ),  
  .out_tx_analogreset                             ( int_tx_analogreset                  ),
  .out_tx_digitalreset                            ( int_tx_digitalreset                 ),   
  .out_tx_cal_busy_mask                           ( int_tx_cal_busy_mask                ),
  .out_rx_cal_busy_mask                           ( int_rx_cal_busy_mask                ),
  .bg_cal_en ()
);
end else begin:g_recal_enable_rcfg_opt_logic
alt_xcvr_native_rcfg_opt_logic_qufrg4q #(
  .dbg_user_identifier                            ( dbg_user_identifier                 ),
  .duplex_mode                                    ( duplex_mode                         ),
  .dbg_embedded_debug_enable                      ( dbg_embedded_debug_enable           ),
  .dbg_capability_reg_enable                      ( dbg_capability_reg_enable           ),
  .dbg_prbs_soft_logic_enable                     ( dbg_prbs_soft_logic_enable          ),
  .dbg_odi_soft_logic_enable                      ( dbg_odi_soft_logic_enable           ),
  .dbg_stat_soft_logic_enable                     ( dbg_stat_soft_logic_enable          ),
  .dbg_ctrl_soft_logic_enable                     ( dbg_ctrl_soft_logic_enable          ),
  .CHANNELS                                       ( channels                            ),
  .ADDR_BITS                                      ( RCFG_ADDR_BITS                      ),
  .ADME_SLAVE_MAP                                 ( "altera_xcvr_native_s10_htile"      ),
  .ADME_ASSGN_MAP                                 ( lcl_adme_assgn_map                  ),
  .RECONFIG_SHARED                                ( rcfg_enable && rcfg_shared          ),
  .JTAG_ENABLED                                   ( rcfg_enable && rcfg_jtag_enable     ),
  .RCFG_EMB_STRM_ENABLED                          ( rcfg_enable && rcfg_emb_strm_enable ),
  .RCFG_PROFILE_CNT                               ( rcfg_profile_cnt                    ),
  .enable_eios_rx_protect                         ( 1'b0 ),
  .pcs_aib_bonding_master                         ( lcl_pcs_aib_bonding_master          ),
  .enable_background_cal			  ( enable_background_cal		)
) alt_xcvr_native_optional_rcfg_logic (
  // User reconfig interface ports
  .reconfig_clk                                   ( reconfig_clk                        ),
  .reconfig_reset                                 ( reconfig_reset                      ),
  .reconfig_write                                 ( reconfig_write                      ),
  .reconfig_read                                  ( reconfig_read                       ),
  .reconfig_address                               ( reconfig_address                    ),
  .reconfig_writedata                             ( reconfig_writedata                  ),
  .reconfig_readdata                              ( reconfig_readdata                   ),
  .reconfig_waitrequest                           ( reconfig_waitrequest                ),
  
//CHANGE TO SUPPORT BACKGROUND RECAL IP
  // AVMM ports to transceiver                    
  .avmm_clk                                       ( user_avmm_clk                            ),
  .avmm_reset                                     ( user_avmm_reset                          ),
  .avmm_write                                     ( user_avmm_write                          ),
  .avmm_read                                      ( user_avmm_read                           ),
  .avmm_address                                   ( user_avmm_address                        ),
  .avmm_writedata                                 ( user_avmm_writedata                      ),
  .avmm_readdata                                  ( user_avmm_readdata                       ),
  .avmm_waitrequest                               ( user_avmm_waitrequest                    ),
  
  // siganls from pipe and mac interface, for eios_rx_protect
  .pipe_clk                                       ( pipe_clk                            ), 
  .pipe_rstn                                      ( pipe_rstn_in                        ),  
  .pipe_rate                                      ( pipe_rate_master                    ), 
  .eios_rx_prot_req                               ( eios_rx_prot_req                    ), 
  .pld_pmaif_mask_tx_pll                          ( pld_pmaif_mask_tx_pll               ),    
  .pcie_ctrl_testbus_b10                          ( pldadapt_out_test_data_b10          ),    

  // input signals from the PHY for PRBS error accumulation
  .prbs_err_signal                                ( rx_prbs_err                         ),
  .prbs_done_signal                               ( rx_prbs_done                        ),

  // input rx_clkout for PRBS
  .in_rx_clkout                                   ( rx_clkout                           ),

  // input status signals from the transceiver
  .in_rx_is_lockedtoref                           ( rx_is_lockedtoref                   ),
  .in_rx_is_lockedtodata                          ( rx_is_lockedtodata                  ),
  .in_tx_cal_busy                                 ( tx_cal_busy                         ),
  .in_rx_cal_busy                                 ( rx_cal_busy                         ),
  .in_avmm_busy                                   ( bg_cal_avmm_busy                           ),
  .in_tx_transfer_ready                           ( int_tx_transfer_ready               ),
  .in_rx_transfer_ready                           ( int_rx_transfer_ready               ),

  // input control signals from the core
  .in_rx_prbs_err_clr                             ( rx_prbs_err_clr                     ),
  .in_set_rx_locktoref                            ( rx_set_locktoref                    ),
  .in_set_rx_locktodata                           ( rx_set_locktodata                   ),
  .in_en_serial_lpbk                              ( rx_seriallpbken                     ),
  .in_rx_analogreset                              ( rx_analogreset                      ),
  .in_rx_digitalreset                             ( rx_digitalreset						),  
  .in_tx_analogreset                              ( tx_analogreset                      ),
  .in_tx_digitalreset                             ( tx_digitalreset						),  
 
  // output control signals to the phy
  .out_prbs_err_clr                               ( int_rx_prbs_err_clr                 ),
  .out_set_rx_locktoref                           ( int_rx_set_locktoref                ),
  .out_set_rx_locktodata                          ( int_rx_set_locktodata               ),
  .out_en_serial_lpbk                             ( int_rx_seriallpbken                 ),
  .out_rx_analogreset                             ( int_rx_analogreset                  ),
  .out_rx_digitalreset                            ( int_rx_digitalreset                 ),  
  .out_tx_analogreset                             ( int_tx_analogreset                  ),
  .out_tx_digitalreset                            ( int_tx_digitalreset                 ),   
  .out_tx_cal_busy_mask                           ( int_tx_cal_busy_mask                ),
  .out_rx_cal_busy_mask                           ( int_rx_cal_busy_mask                ),
  .bg_cal_en					  (bg_cal_en)
);
end
endgenerate
//***************** End Embedded JTAG and AVMM Expansion ********************
//***************************************************************************

//****************************************************************************
//********************* Background RE-CAL Module *****************************
wire [channels-1 :0] recal_cntr_clk;

genvar ig;
   generate for(ig=0;ig<channels;ig=ig+1) begin:  g_recal
   if (enable_background_cal == 1 && rcfg_enable == 1) begin
   alt_xcvr_native_re_cal_chnl # (
	.PRESET_RECAL_WAIT_CYCLE (5) //PARAMETER SET LOW FOR TEST PURPOSE
   ) alt_xcvr_recal (
	.cntr_clk(),

	.user_clk(user_avmm_clk[ig]),
	.user_avmm_reset(user_avmm_reset[ig]),
	.user_read(user_avmm_read[ig]),
	.user_write(user_avmm_write[ig]),
	.user_address(user_avmm_address[ig*RCFG_ADDR_BITS+:RCFG_ADDR_BITS]),
	.user_writedata(user_avmm_writedata[ig*8+:8]),
	.user_readdata(user_avmm_readdata[ig*8+:8]),
	.user_waitrequest(user_avmm_waitrequest[ig]),


//CORE-IP AVMM SIDE
	.avmm_read(avmm_read[ig]),
	.avmm_write(avmm_write[ig]),
	.avmm_address(avmm_address[ig*RCFG_ADDR_BITS+:RCFG_ADDR_BITS]),
	.avmm_writedata(avmm_writedata[ig*8+:8]),
	.avmm_readdata(avmm_readdata[ig*8+:8]),
	.avmm_waitrequest(avmm_waitrequest[ig]),

	.avmm_clk(avmm_clk[ig]),
	.avmm_reset(avmm_reset[ig]),

// Recal SM
	.r_bg_cal(bg_cal_en[ig]), // "1" to enable recal
	.pld_cal_done(pld_cal_done[ig]),
	.pld_avmm1_busy(int_avmm_busy[ig]),
	.out_bg_cal_pld_avmm1_busy (bg_cal_avmm_busy[ig])

   );
   end else if (enable_background_cal == 1 && rcfg_enable == 0) begin
   alt_xcvr_native_re_cal_chnl # (
	.PRESET_RECAL_WAIT_CYCLE (5) //PARAMETER SET LOW FOR TEST PURPOSE
   ) alt_xcvr_recal (
	.cntr_clk(recal_cntr_clk[ig]),
	.user_clk(recal_cntr_clk[ig]),
	.user_avmm_reset(1'b0),
	.user_read(1'b0),
	.user_write(1'b0),
	.user_address(11'h000),
	.user_writedata(8'h00),
	.user_readdata(),
	.user_waitrequest(),

//CORE-IP AVMM SIDE
	.avmm_read(avmm_read[ig]),
	.avmm_write(avmm_write[ig]),
	.avmm_address(avmm_address[ig*RCFG_ADDR_BITS+:RCFG_ADDR_BITS]),
	.avmm_writedata(avmm_writedata[ig*8+:8]),
	.avmm_readdata(avmm_readdata[ig*8+:8]),
	.avmm_waitrequest(avmm_waitrequest[ig]),
	.avmm_clk(avmm_clk[ig]),
	.avmm_reset(avmm_reset[ig]),
// Recal SM
	.r_bg_cal(bg_cal_en[ig]), // "1" to enable recal
	.pld_cal_done(pld_cal_done[ig]),
	.pld_avmm1_busy(int_avmm_busy[ig]),
	.out_bg_cal_pld_avmm1_busy(bg_cal_avmm_busy[ig])
   );
   end
end
   endgenerate

//********************** End background RE-CAL Module ************************
//****************************************************************************
assign avmm_busy = (enable_background_cal==1)?bg_cal_avmm_busy:int_avmm_busy;

//***************************************************************************
//************* Datapath connections *******************************************
//genvar ig;

wire[channels*80-1:0] temp_rx_parallel_data; 

generate


	// TX parallel data
	if (enable_tx_fast_pipeln_reg) begin 		
		(* altera_attribute = "-name FORCE_HYPER_REGISTER_FOR_CORE_PERIPHERY_TRANSFER ON" *)
		reg [channels*80-1:0] tx_parallel_data_fast_pipeln_reg;
		
		for(ig=0;ig<channels;ig=ig+1) begin : g_tx_fast_pipeln_reg
			always @(posedge tx_coreclkin[ig]) begin
				tx_parallel_data_fast_pipeln_reg[ig*80+:80] <= int_tx_parallel_data_esc[ig*80+:80];
			end
		end
		assign int_tx_parallel_data = tx_parallel_data_fast_pipeln_reg;
	end else begin
		assign int_tx_parallel_data = int_tx_parallel_data_esc;
	end	

	// RX parallel data
	if (enable_rx_fast_pipeln_reg) begin 
		(* altera_attribute = "-name FORCE_HYPER_REGISTER_FOR_PERIPHERY_CORE_TRANSFER ON" *)
		reg [channels*80-1:0] rx_parallel_data_fast_pipeln_reg;

		for(ig=0;ig<channels;ig=ig+1) begin : g_rx_fast_pipeln_reg
			always @(posedge rx_coreclkin[ig]) begin
				rx_parallel_data_fast_pipeln_reg[ig*80+:80] <= int_rx_parallel_data[ig*80+:80];
			end
		end		
		assign temp_rx_parallel_data = rx_parallel_data_fast_pipeln_reg;
	end else begin
		assign temp_rx_parallel_data = int_rx_parallel_data;
	end

endgenerate


//***************** End Datapath connections ***********************************
//***************************************************************************

//Force output local fault code for teng_baser_krfec_mode, teng_baser_mode and teng_1588_mode when aibreset is high or rx_parallel_data is invalid
wire [channels-1:0]        output_lf;
wire [channels*80-1:0]     out_lf;
wire [channels-1:0]        sync_int_pld_adapter_rx_pld_rst;

wire [75:0]                forced_lf;

assign {forced_lf[71:40], forced_lf[31:0]} = {8'h1, 8'h0, 8'h0, 8'h9c, 8'h1, 8'h0, 8'h0, 8'h9c};
assign {forced_lf[75:72], forced_lf[35:32]} = {8'h11};          

generate

    for(ig=0;ig<channels;ig=ig+1) begin :g_lf_conditions

      if (hssi_10g_rx_pcs_prot_mode == "teng_baser_krfec_mode" || hssi_10g_rx_pcs_prot_mode == "teng_baser_mode" || hssi_10g_rx_pcs_prot_mode == "teng_1588_mode") begin :g_enforce_local_fault

		assign out_lf[ig*80+79:ig*80] = {temp_rx_parallel_data[ig*80+79:ig*80+76], forced_lf[75:40], temp_rx_parallel_data[ig*80+39:ig*80+36], forced_lf[35:0]};

                alt_xcvr_resync_std #(
                  .SYNC_CHAIN_LENGTH(3),
                  .WIDTH(1),
                  .INIT_VALUE(1'b1)
                ) transfer_ready_synchronizers (
                  .clk(rx_coreclkin[ig]),
                  .reset(int_pld_adapter_rx_pld_rst[ig]),
                  .d(1'b0),
                  .q(sync_int_pld_adapter_rx_pld_rst[ig])
                );

		assign output_lf[ig] = (sync_int_pld_adapter_rx_pld_rst[ig] || ~int_rx_parallel_data[ig*80+79]);

                assign rx_parallel_data[ig*80+79:ig*80] = output_lf[ig] ? out_lf[ig*80+79:ig*80] : temp_rx_parallel_data[ig*80+79:ig*80];

	end else begin
		assign rx_parallel_data[ig*80+79:ig*80] = temp_rx_parallel_data[ig*80+79:ig*80];
	end
    end
endgenerate


//***************************************************************************
//***************** Early Speed Change connections *******************************************
generate
        if (enable_early_spd_chng) begin : g_pipe_esc_enabled 		
           assign pclk        =  tx_coreclkin[lcl_pcs_aib_bonding_master];
           assign reset_n_esc = ~tx_digitalreset[lcl_pcs_aib_bonding_master];
           for(ig=0;ig<channels;ig=ig+1) begin : g_w_pipe_esc
              //inputs
              assign tx_elec_idle[ig]                              = tx_parallel_data[ig*80+10];			//pipe interface mapping offset for tx_elecidle is 10 
              assign pipe_rate[ig*2+1:ig*2]                        = tx_parallel_data[ig*80+33:ig*80+32];		//pipe interface mapping offset for pipe_rate is 32 
              //outputs
              assign int_hip_in_reserved_out[ig*2+1:ig*2]          = {1'b0,early_spd_chng};
              assign int_tx_parallel_data_esc[ig*80+79:ig*80+34]   = tx_parallel_data[ig*80+79:ig*80+34];
              assign int_tx_parallel_data_esc[ig*80+33:ig*80+32]   = pcie_sw;
              assign int_tx_parallel_data_esc[ig*80+31:ig*80]      = tx_parallel_data[ig*80+31:ig*80];
           end

           alt_xcvr_early_spd_chng_s10_htile #(  
              .NUM_CHANNELS(channels),	
              .WIDTH(display_std_tx_pld_adapt_width),
              .BONDING_MASTER(lcl_pcs_aib_bonding_master),
              .T1(early_spd_chng_t1),
              .T2(early_spd_chng_t2),	
              .T3(early_spd_chng_t3)
           ) pipe_early_spd_chng_inst (
              .clk(pclk),  
              .reset_n(reset_n_esc),  
              .tx_elec_idle(tx_elec_idle),
              .pipe_rate(pipe_rate),
              .early_spd_chng(early_spd_chng),
              .pcie_sw(pcie_sw)
           );

	end else begin: g_pipe_esc_disabled
           //outputs
           assign int_hip_in_reserved_out          = hip_in_reserved_out;
           assign int_tx_parallel_data_esc         = tx_parallel_data;
	end

endgenerate

//***************** End Early Speed Change connections ***********************************
//***************************************************************************




//***************************************************************************
//************* Reset connections *******************************************	
generate
	if (enable_direct_reset_control) begin : g_reset // direct reset
		assign int_pld_pma_rxpma_rst      = rx_analogreset;
		assign int_pld_pma_txpma_rst      = tx_analogreset;
		assign int_pld_adapter_rx_pld_rst = rx_aibreset;	
		assign int_pld_adapter_tx_pld_rst = tx_aibreset;	
		assign int_pld_pcs_rx_pld_rst     = rx_digitalreset;
		assign int_pld_pcs_tx_pld_rst     = tx_digitalreset;
		assign tx_transfer_ready          = int_tx_transfer_ready;
		assign rx_transfer_ready          = int_rx_transfer_ready;
	end else if (enable_hip) begin : g_hip_reset // HIP mode reset
		assign int_pld_pma_rxpma_rst      = rx_analogreset;
		assign int_pld_pma_txpma_rst      = tx_analogreset;
		assign int_pld_adapter_rx_pld_rst = rx_aibreset;	
		assign int_pld_adapter_tx_pld_rst = tx_aibreset;	
		assign int_pld_pcs_rx_pld_rst     = rx_digitalreset;
		assign int_pld_pcs_tx_pld_rst     = tx_digitalreset;
		assign tx_transfer_ready          = int_tx_transfer_ready;
		assign rx_transfer_ready          = int_rx_transfer_ready;
  
  end else if (disable_digital_reset_sequencer) begin: g_ehip_reset // eHIP mode reset
    
    //Pass through digital resets from input pins
		assign int_pld_adapter_rx_pld_rst = rx_aibreset;	
		assign int_pld_adapter_tx_pld_rst = tx_aibreset;	
		assign int_pld_pcs_rx_pld_rst     = rx_digitalreset;
		assign int_pld_pcs_tx_pld_rst     = tx_digitalreset;
		assign tx_transfer_ready          = int_tx_transfer_ready;
		assign rx_transfer_ready          = int_rx_transfer_ready;
    //Analog resets originate from the reset sequencer
		assign int_pld_pma_rxpma_rst      = int_rx_analog_reset;
		assign int_pld_pma_txpma_rst      = int_tx_analog_reset;

		alt_xcvr_native_anlg_reset_seq_wrapper #(
			.CLK_FREQ_IN_HZ					       (CLK_FREQ_IN_HZ						     ),
			.DEFAULT_RESET_SEPARATION_NS	 (DEFAULT_RESET_SEPARATION_NS		 ),
			.TX_ANALOG_RESET_SEPARATION_NS (TX_ANALOG_RESET_SEPARATION_NS	 ),	
			.RX_ANALOG_RESET_SEPARATION_NS (RX_ANALOG_RESET_SEPARATION_NS	 ),	
			.ENABLE_RESET_SEQUENCER			   (lcl_enable_reset_sequencer		 ),
			.TX_ENABLE						         (tx_enable							         ),
			.RX_ENABLE						         (rx_enable							         ),				
			.NUM_CHANNELS					         (channels							         ),
			.REDUCED_RESET_SIM_TIME			   (reduced_reset_sim_time				 )
		) alt_xcvr_native_anlg_reset_seq_wrapper_inst (    
			.tx_analog_reset		           (int_tx_analogreset			  ),
			.rx_analog_reset		           (int_rx_analogreset			  ),

			.tx_analogreset_stat	         (tx_analogreset_stat		    ),
			.rx_analogreset_stat	         (rx_analogreset_stat		    ),
			.tx_analog_reset_out	         (int_tx_analog_reset		    ),
			.rx_analog_reset_out	         (int_rx_analog_reset		    )
		);

	end else begin : g_non_hip_reset // Non HIP mode reset
		
    assign tx_transfer_ready     = int_tx_transfer_ready;
		assign rx_transfer_ready     = int_rx_transfer_ready;
		assign int_pld_pma_txpma_rst = int_tx_analog_reset;
		assign int_pld_pma_rxpma_rst = int_rx_analog_reset;
						
		alt_xcvr_native_reset_seq #(
			.CLK_FREQ_IN_HZ					       (CLK_FREQ_IN_HZ						     ),
			.DEFAULT_RESET_SEPARATION_NS	 (DEFAULT_RESET_SEPARATION_NS		 ),
			.TX_ANALOG_RESET_SEPARATION_NS (TX_ANALOG_RESET_SEPARATION_NS	 ),	
			.RX_ANALOG_RESET_SEPARATION_NS (RX_ANALOG_RESET_SEPARATION_NS	 ),	
			.DIGITAL_RESET_SEPARATION_NS	 (DIGITAL_RESET_SEPARATION_NS		 ),
			.TX_PCS_RESET_EXTENSION_NS		 (TX_PCS_RESET_EXTENSION_NS			 ),
			.RX_PCS_RESET_EXTENSION_NS		 (RX_PCS_RESET_EXTENSION_NS			 ),	
			.ENABLE_RESET_SEQUENCER			   (lcl_enable_reset_sequencer		 ),
			.TX_ENABLE						         (tx_enable							         ),
			.RX_ENABLE						         (rx_enable							         ),				
			.TX_RESET_MODE					       (tx_bonded_mode_reset_sequence	 ),
			.RX_RESET_MODE					       (rx_bonded_mode_reset_sequence	 ),
			.TX_BONDING_MASTER				     (lcl_pcs_aib_bonding_master		 ),
			.RX_BONDING_MASTER				     (lcl_pcs_aib_bonding_master		 ),
			.NUM_CHANNELS					         (channels							         ),
			.REDUCED_RESET_SIM_TIME			   (reduced_reset_sim_time				 )
		) alt_xcvr_native_reset_seq (    
			.tx_release_aib_first     (int_tx_release_aib_first   ),
			.tx_analog_reset		      (int_tx_analogreset			    ),
			.rx_analog_reset		      (int_rx_analogreset			    ),
			.tx_digital_reset		      (int_tx_digitalreset		    ),
			.rx_digital_reset		      (int_rx_digitalreset		    ),
			.tx_transfer_ready		    (int_tx_transfer_ready		  ),
			.rx_transfer_ready		    (int_rx_transfer_ready		  ),			
			.tx_analogreset_stat	    (tx_analogreset_stat		    ),
			.rx_analogreset_stat	    (rx_analogreset_stat		    ),
			.tx_analog_reset_out	    (int_tx_analog_reset		    ),
			.rx_analog_reset_out	    (int_rx_analog_reset		    ),
			.tx_digitalreset_stat	    (tx_digitalreset_stat		    ),
			.rx_digitalreset_stat	    (rx_digitalreset_stat		    ),
			.tx_digitalreset_timeout	(tx_digitalreset_timeout		),
			.rx_digitalreset_timeout	(rx_digitalreset_timeout		),
			.tx_aib_reset_out		      (int_pld_adapter_tx_pld_rst	),
			.rx_aib_reset_out		      (int_pld_adapter_rx_pld_rst	),
			.tx_pcs_reset_out		      (int_pld_pcs_tx_pld_rst		  ),
			.rx_pcs_reset_out		      (int_pld_pcs_rx_pld_rst		  )
		);

	end	
endgenerate

//***************** End reset connectopms ***********************************
//***************************************************************************

generate
  for(ig=0;ig<channels;ig=ig+1) begin : g_xcvr_native_insts

  // [ADW] - temporary macro for enabling a switch between the datapath and SSR
  // chain for prbs status signals. By default, choose the datapath source.
  // Bits 35 and 36 reflect prbs_err and prbs_done, respectively
  `ifdef ALTERA_XCVR_S10_PRBS_STATUS_SSRPATH
    assign rx_prbs_err[ig]  = rx_prbs_err_int[ig];
    assign rx_prbs_done[ig] = rx_prbs_done_int[ig];
  `else
    assign rx_prbs_err[ig]  = rx_parallel_data[(ig*80) + 35];
    assign rx_prbs_done[ig] = rx_parallel_data[(ig*80) + 36];
  `endif
    
	//****************
	// Clock connections
	//************	
	wire	int_tx_coreclkin_rowclk;
	wire	int_tx_coreclkin_dclk;
	wire	int_rx_coreclkin_rowclk;
	wire	int_rx_coreclkin_dclk;
	wire	int_tx_x2_coreclkin_rowclk;
	wire	int_tx_x2_coreclkin_dclk;

	assign int_tx_coreclkin_rowclk	= (tx_coreclkin_clock_network == "rowclk") ? tx_coreclkin[ig] : 1'b0;
	assign int_tx_coreclkin_dclk	  = (tx_coreclkin_clock_network == "rowclk") ? 1'b0             : tx_coreclkin[ig];
	assign int_rx_coreclkin_rowclk	= (rx_coreclkin_clock_network == "rowclk") ? rx_coreclkin[ig] : 1'b0;
	assign int_rx_coreclkin_dclk	  = (rx_coreclkin_clock_network == "rowclk") ? 1'b0             : rx_coreclkin[ig];

	if (enable_tx_x2_coreclkin_port) begin
	
    assign int_tx_x2_coreclkin_rowclk	= (tx_pcs_bonding_clock_network == "rowclk") ? tx_x2_coreclkin[ig] : 1'b0;
		assign int_tx_x2_coreclkin_dclk		= (tx_pcs_bonding_clock_network == "rowclk") ? 1'b0                : tx_x2_coreclkin[ig];
	
  end else if (enable_tx_core_aib_bonding) begin 

		assign int_tx_x2_coreclkin_rowclk	= (tx_pcs_bonding_clock_network == "rowclk") ? 
                                        (hssi_pldadapt_tx_fifo_rd_clk_sel == "fifo_rd_pld_tx_clk1") ? 
                                        1'b0 : (hssi_pldadapt_tx_fifo_rd_clk_sel == "fifo_rd_pld_tx_clk2") ? 
															                 (hssi_pldadapt_tx_pma_aib_tx_clk_expected_setting ==  "x2_not_from_chnl") ? 
                                               tx_coreclkin[ig] : tx_clkout2[lcl_pcs_aib_bonding_master] : 1'b0 : 1'b0;
                                             
		assign int_tx_x2_coreclkin_dclk		= (tx_pcs_bonding_clock_network == "rowclk") ? 
                                        1'b0 : (hssi_pldadapt_tx_fifo_rd_clk_sel == "fifo_rd_pld_tx_clk1") ? 
                                        1'b0 : (hssi_pldadapt_tx_fifo_rd_clk_sel == "fifo_rd_pld_tx_clk2") ? 
															                 (hssi_pldadapt_tx_pma_aib_tx_clk_expected_setting ==  "x2_not_from_chnl") ? 
                                               tx_coreclkin[ig] : tx_clkout2[lcl_pcs_aib_bonding_master] : 1'b0;
	end else begin

		assign int_tx_x2_coreclkin_rowclk	= 1'b0;
		assign int_tx_x2_coreclkin_dclk		= 1'b0;

	end
	
	//************
	// PCIE rate switch signals
	//************	
	wire  [1:0] int_pipe_sw_done;
    wire  [1:0] int_pipe_sw;
	wire        int_pipe_hclk_out;

	if (enable_hip || ig == lcl_pcs_aib_bonding_master) begin
						assign int_pipe_sw_done = pipe_sw_done;
						assign pipe_sw			= int_pipe_sw;
						assign pipe_hclk_out	= int_pipe_hclk_out;
	end else begin
						assign int_pipe_sw_done = 2'd0;
	end	

	//************
	// PCIE Gen3  RX EIOS protection signals
	//************	
    wire          int_pld_pmaif_mask_tx_pll;
    wire [19:0]   int_pldadapt_out_test_data; 
    assign     pld_pmaif_mask_tx_pll[ig] = int_pld_pmaif_mask_tx_pll;
    assign     pldadapt_out_test_data_b10[ig] = int_pldadapt_out_test_data[10];
		
	//************
	// Bonding connections
	//************		
	wire [7:0] int_aibhssi_bond_rx_ds_in;
	wire [7:0] int_aibhssi_bond_rx_us_in;
	wire [7:0] int_aibhssi_bond_rx_ds_out;
	wire [7:0] int_aibhssi_bond_rx_us_out;

	wire [6:0] int_aibhssi_bond_tx_ds_in;
	wire [6:0] int_aibhssi_bond_tx_us_in;
	wire [6:0] int_aibhssi_bond_tx_ds_out;
	wire [6:0] int_aibhssi_bond_tx_us_out;

	wire [4:0] int_hdpldadapt_bond_rx_ds_in;
	wire [4:0] int_hdpldadapt_bond_rx_us_in;
	wire [4:0] int_hdpldadapt_bond_rx_ds_out;
	wire [4:0] int_hdpldadapt_bond_rx_us_out;

	wire [4:0] int_hdpldadapt_bond_tx_ds_in;
	wire [4:0] int_hdpldadapt_bond_tx_us_in;
	wire [4:0] int_hdpldadapt_bond_tx_ds_out;
	wire [4:0] int_hdpldadapt_bond_tx_us_out;

	assign int_aibhssi_bond_rx_ds_in  = aibhssi_bond_rx_ds_in[ig];
	assign int_aibhssi_bond_rx_us_in  = aibhssi_bond_rx_us_in[ig];
	assign aibhssi_bond_rx_ds_out[ig] = int_aibhssi_bond_rx_ds_out;
	assign aibhssi_bond_rx_us_out[ig] = int_aibhssi_bond_rx_us_out;

	assign int_aibhssi_bond_tx_ds_in  = aibhssi_bond_tx_ds_in[ig];
	assign int_aibhssi_bond_tx_us_in  = aibhssi_bond_tx_us_in[ig];
	assign aibhssi_bond_tx_ds_out[ig] = int_aibhssi_bond_tx_ds_out;
	assign aibhssi_bond_tx_us_out[ig] = int_aibhssi_bond_tx_us_out;

	assign int_hdpldadapt_bond_rx_ds_in  = hdpldadapt_bond_rx_ds_in[ig];
	assign int_hdpldadapt_bond_rx_us_in  = hdpldadapt_bond_rx_us_in[ig];
	assign hdpldadapt_bond_rx_ds_out[ig] = int_hdpldadapt_bond_rx_ds_out;
	assign hdpldadapt_bond_rx_us_out[ig] = int_hdpldadapt_bond_rx_us_out;

	assign int_hdpldadapt_bond_tx_ds_in  = hdpldadapt_bond_tx_ds_in[ig];
	assign int_hdpldadapt_bond_tx_us_in  = hdpldadapt_bond_tx_us_in[ig];
	assign hdpldadapt_bond_tx_ds_out[ig] = int_hdpldadapt_bond_tx_ds_out;
	assign hdpldadapt_bond_tx_us_out[ig] = int_hdpldadapt_bond_tx_us_out;
	
	if (enable_hip)	 begin : g_hip_pcs_bonding_connections

    assign bond_pcs10g_in_bot[ig] = pcs_bonding_bot_data_in[(ig*30 + 25) +: 5];
    assign bond_pcs8g_in_bot[ig]  = pcs_bonding_bot_data_in[(ig*30 + 12) +: 13];
    assign bond_pmaif_in_bot[ig]  = pcs_bonding_bot_data_in[ig*30 +: 12];
    
    assign bond_pcs10g_in_top[ig] = pcs_bonding_top_data_in[(ig*30 + 25) +: 5];
    assign bond_pcs8g_in_top[ig]  = pcs_bonding_top_data_in[(ig*30 + 12) +: 13];
    assign bond_pmaif_in_top[ig]  = pcs_bonding_top_data_in[ig*30 +: 12];
    
    assign pcs_bonding_bot_data_out[(ig*30 + 25) +: 5]  = bond_pcs10g_out_bot[ig];
    assign pcs_bonding_bot_data_out[(ig*30 + 12) +: 13] = bond_pcs8g_out_bot[ig];
    assign pcs_bonding_bot_data_out[ig*30 +: 12]        = bond_pmaif_out_bot[ig];
    
    assign pcs_bonding_top_data_out[(ig*30 + 25) +: 5]  = bond_pcs10g_out_top[ig];
    assign pcs_bonding_top_data_out[(ig*30 + 12) +: 13] = bond_pcs8g_out_top[ig];
    assign pcs_bonding_top_data_out[ig*30 +: 12]        = bond_pmaif_out_top[ig];

	end else if (enable_pcs_bonding) begin : g_pcs_bonding_connections
		
    if(ig == (channels-1)) begin
		  assign  bond_pcs10g_in_top[ig]  = 5'd0;
		  assign  bond_pcs8g_in_top[ig]   = 13'd0;
		  assign  bond_pmaif_in_top[ig]   = 12'd0;
		end else begin
		  assign  bond_pcs10g_in_top[ig]  = bond_pcs10g_out_bot[ig+1];
		  assign  bond_pcs8g_in_top[ig]   = bond_pcs8g_out_bot[ig+1];
		  assign  bond_pmaif_in_top[ig]   = bond_pmaif_out_bot[ig+1];
		end

		if(ig == 0) begin
		  assign  bond_pcs10g_in_bot[ig]  = 5'd0;
		  assign  bond_pcs8g_in_bot[ig]   = 13'd0;
		  assign  bond_pmaif_in_bot[ig]   = 12'd0;
		end else begin
		  assign  bond_pcs10g_in_bot[ig]  = bond_pcs10g_out_top[ig-1];
		  assign  bond_pcs8g_in_bot[ig]   = bond_pcs8g_out_top[ig-1];
		  assign  bond_pmaif_in_bot[ig]   = bond_pmaif_out_top[ig-1];
		end
	end else begin : g_pcs_no_bonding_connections
		  assign  bond_pcs10g_in_top[ig]  = 5'd0;
		  assign  bond_pcs10g_in_bot[ig]  = 5'd0;
		  assign  bond_pcs8g_in_top[ig]   = 13'd0;
		  assign  bond_pcs8g_in_bot[ig]   = 13'd0;
		  assign  bond_pmaif_in_top[ig]   = 12'd0;
		  assign  bond_pmaif_in_bot[ig]   = 12'd0;
	end

	if (enable_hip)	 begin : g_hip_aib_bonding_connections								

    assign aibhssi_bond_rx_ds_in[ig] = hssi_aib_bond_rx_ds_in[ig*8 +: 8];
    assign aibhssi_bond_rx_us_in[ig] = hssi_aib_bond_rx_us_in[ig*8 +: 8];
    assign aibhssi_bond_tx_ds_in[ig] = hssi_aib_bond_tx_ds_in[ig*7 +: 7];
    assign aibhssi_bond_tx_us_in[ig] = hssi_aib_bond_tx_us_in[ig*7 +: 7];
    
    assign hdpldadapt_bond_rx_ds_in[ig] = pld_aib_bond_rx_ds_in[ig*5 +: 5];
    assign hdpldadapt_bond_rx_us_in[ig] = pld_aib_bond_rx_us_in[ig*5 +: 5];								
    assign hdpldadapt_bond_tx_ds_in[ig] = pld_aib_bond_tx_ds_in[ig*5 +: 5];
    assign hdpldadapt_bond_tx_us_in[ig] = pld_aib_bond_tx_us_in[ig*5 +: 5];
    
    assign hssi_aib_bond_rx_ds_out[ig*8 +: 8] = aibhssi_bond_rx_ds_out[ig];
    assign hssi_aib_bond_rx_us_out[ig*8 +: 8] = aibhssi_bond_rx_us_out[ig];
    assign hssi_aib_bond_tx_ds_out[ig*7 +: 7] = aibhssi_bond_tx_ds_out[ig];
    assign hssi_aib_bond_tx_us_out[ig*7 +: 7] = aibhssi_bond_tx_us_out[ig];
    
    assign pld_aib_bond_rx_ds_out[ig*5 +: 5] = hdpldadapt_bond_rx_ds_out[ig];
    assign pld_aib_bond_rx_us_out[ig*5 +: 5] = hdpldadapt_bond_rx_us_out[ig];								
    assign pld_aib_bond_tx_ds_out[ig*5 +: 5] = hdpldadapt_bond_tx_ds_out[ig];
    assign pld_aib_bond_tx_us_out[ig*5 +: 5] = hdpldadapt_bond_tx_us_out[ig];

	end else begin 

		if (enable_tx_hssi_aib_bonding) begin : g_tx_hssi_aib_bonding_connections
			if (ig == channels-1) begin
				assign aibhssi_bond_tx_us_in[ig] = 7'b0;
			end else begin
				assign aibhssi_bond_tx_us_in[ig] = aibhssi_bond_tx_ds_out[ig+1];
			end

			if (ig == 0) begin
				assign aibhssi_bond_tx_ds_in[ig] = 7'b0;
			end else begin
				assign aibhssi_bond_tx_ds_in[ig] = aibhssi_bond_tx_us_out[ig-1];		
			end
		end else begin
			assign aibhssi_bond_tx_us_in[ig] = 7'b0;
			assign aibhssi_bond_tx_ds_in[ig] = 7'b0;
		end
	   
	    if (enable_tx_core_aib_bonding) begin : g_tx_core_aib_bonding_connections
			if (ig == channels-1) begin
				assign hdpldadapt_bond_tx_us_in[ig] = 5'b0;
			end else begin
				assign hdpldadapt_bond_tx_us_in[ig] = hdpldadapt_bond_tx_ds_out[ig+1];
			end

			if (ig == 0) begin
				assign hdpldadapt_bond_tx_ds_in[ig] = 5'b0;
			end else begin
				assign hdpldadapt_bond_tx_ds_in[ig] = hdpldadapt_bond_tx_us_out[ig-1];	
			end
		end else begin
			assign hdpldadapt_bond_tx_us_in[ig] = 5'b0;
			assign hdpldadapt_bond_tx_ds_in[ig] = 5'b0;
		end

	    if (enable_rx_hssi_aib_bonding) begin : g_rx_hssi_aib_bonding_connections
			if (ig == channels-1) begin
				assign aibhssi_bond_rx_us_in[ig] = 8'b0;
			end else begin
				assign aibhssi_bond_rx_us_in[ig] = aibhssi_bond_rx_ds_out[ig+1];
			end

			if (ig == 0) begin
				assign aibhssi_bond_rx_ds_in[ig] = 8'b0;
			end else begin
				assign aibhssi_bond_rx_ds_in[ig] = aibhssi_bond_rx_us_out[ig-1];	
			end			
		end else begin
			assign aibhssi_bond_rx_us_in[ig] = 8'b0;
			assign aibhssi_bond_rx_ds_in[ig] = 8'b0;
		end

	    if (enable_rx_core_aib_bonding) begin : g_rx_core_aib_bonding_connections
			if (ig == channels-1) begin
				assign hdpldadapt_bond_rx_us_in[ig] = 5'b0;
			end else begin
				assign hdpldadapt_bond_rx_us_in[ig] = hdpldadapt_bond_rx_ds_out[ig+1];
			end

			if (ig == 0) begin
				assign hdpldadapt_bond_rx_ds_in[ig] = 5'b0;
			end else begin
				assign hdpldadapt_bond_rx_ds_in[ig] = hdpldadapt_bond_rx_us_out[ig-1];	
			end				
		end else begin
			assign hdpldadapt_bond_rx_us_in[ig] = 5'b0;
			assign hdpldadapt_bond_rx_ds_in[ig] = 5'b0;
		end
	end	

	// Begin: HIP to PCS interface connections
	//-----------------------------------------
	wire [91:0] hip_pcs_data_in_per_chan;

	// HIP (output) to PCS (input) per channel 
	wire [63:0] int_in_hip_tx_data;
	wire		    int_in_pcs_pld_8g_g3_rx_pld_rst_n;	
	wire		    int_in_pcs_pld_8g_g3_tx_pld_rst_n;	
	wire		    int_in_pld_pma_rxpma_rstb;		
	wire		    int_in_pld_pma_txpma_rstb;		
	wire [1:0]	int_in_pld_rate;				
	wire		    int_in_pld_8g_rxpolarity;		
	wire [2:0]	int_in_pld_g3_current_rxpreset;	
	wire [17:0]	int_in_pld_g3_current_coeff;	

	// HIP (input) to Adapter (output) per channel
	wire		    int_out_aibhssi_pld_8g_g3_rx_pld_rst_n;	
	wire		    int_out_aibhssi_pld_8g_g3_tx_pld_rst_n;		
	wire		    int_out_aibhssi_pld_pma_txpma_rstb;
	wire		    int_out_aibhssi_pld_pma_rxpma_rstb;
	wire [23:0] int_out_aib_hip_ctrl_out;	
		
	// Select data from the "ehip_*" ports or "hip_*" ports
  // NOTE: the "ehip_*" bus is used for naming clarity only. The ehip and phip
  // share the same physical interface to the PCS
  //assign hip_pcs_data_in_per_chan				    = enable_ehip ? ehip_pcs_data_in[ig*92 +: 92] : hip_pcs_data_in[ig*92 +: 92];	
  assign hip_pcs_data_in_per_chan				    = hip_pcs_data_in[ig*92 +: 92];	
  
  //Break out the data bus into relevant signals connected to the PHY
	assign int_in_hip_tx_data				          =              hip_pcs_data_in_per_chan[63:0];
	assign int_in_pcs_pld_8g_g3_rx_pld_rst_n	= enable_hip ? hip_pcs_data_in_per_chan[64]		  : int_out_aibhssi_pld_8g_g3_rx_pld_rst_n;
	assign int_in_pcs_pld_8g_g3_tx_pld_rst_n	= enable_hip ? hip_pcs_data_in_per_chan[65]		  : int_out_aibhssi_pld_8g_g3_tx_pld_rst_n;
	assign int_in_pld_pma_rxpma_rstb		      = enable_hip ? hip_pcs_data_in_per_chan[66]		  : int_out_aibhssi_pld_pma_rxpma_rstb;
	assign int_in_pld_pma_txpma_rstb		      = enable_hip ? hip_pcs_data_in_per_chan[67]		  : int_out_aibhssi_pld_pma_txpma_rstb;
	assign int_in_pld_rate					          = enable_hip ? hip_pcs_data_in_per_chan[69:68]	: int_out_aib_hip_ctrl_out[1:0];
	assign int_in_pld_8g_rxpolarity			      = enable_hip ? hip_pcs_data_in_per_chan[70]		  : int_out_aib_hip_ctrl_out[2];
	assign int_in_pld_g3_current_rxpreset	    = enable_hip ? hip_pcs_data_in_per_chan[73:71]	: int_out_aib_hip_ctrl_out[5:3];
	assign int_in_pld_g3_current_coeff		    = enable_hip ? hip_pcs_data_in_per_chan[91:74]	: int_out_aib_hip_ctrl_out[23:6];

	// HIP (input) to PCS (output) 
	wire [50:0]	int_out_hip_rx_data;
	wire [7:0]	int_out_hip_ctrl_out;
	wire [2:0]	int_out_hip_clk_out;

	// Fan out data to the the "ehip_*" ports or "hip_*" ports
  // NOTE: the "ehip_*" bus is used for naming clarity only. The ehip and phip
  // share the same physical interface to the PCS
	//assign ehip_pcs_data_out[ig*62 +: 62] = {int_out_hip_clk_out, int_out_hip_ctrl_out, int_out_hip_rx_data};
	assign  hip_pcs_data_out[ig*62 +: 62] = {int_out_hip_clk_out, int_out_hip_ctrl_out, int_out_hip_rx_data};
	
	
	// BEGIN: HIP to Adapter interface connections
	//---------------------------------------------
  
  wire [100:0] hip_aib_data_in_per_chan;
  wire [104:0] ehip_aib_data_in_per_chan;

	// HIP (output) to Adapter (input) per channel
	wire [77:0]	int_in_hip_aib_sync_data_out; 
	wire [3:0]	int_in_aibhssi_hip_aib_fsr_out;			
	wire [7:0]	int_in_aibhssi_hip_aib_ssr_out;			
	wire		    int_in_hip_aib_clk;
	wire		    int_in_hip_aib_clk_2x;	
	wire [9:0]	int_in_hip_aib_txeq_out;
	wire		    int_in_hip_aib_txeq_clk_out;
	wire		    int_in_hip_aib_txeq_rst_n;
	wire		    int_in_hip_aib_async_out;

	// Re-name the bus for easy generate loop unrolling per channel
  assign  hip_aib_data_in_per_chan        =  hip_aib_data_in[ig*101 +: 101];
	assign ehip_aib_data_in_per_chan        = ehip_aib_data_in[ig*105 +: 105];

	// Select data from the "ehip_*" ports or "hip_*" ports
  // NOTE: the "ehip_*" bus is used for naming clarity only. The ehip and phip
  // share the same physical interface to the Crete adapter
	assign int_in_hip_aib_sync_data_out     = enable_ehip ? ehip_aib_data_in_per_chan[77:0]   : hip_aib_data_in_per_chan[77:0];
	assign int_in_aibhssi_hip_aib_fsr_out	  = enable_ehip ? ehip_aib_data_in_per_chan[81:78]  : hip_aib_data_in_per_chan[81:78];
	assign int_in_aibhssi_hip_aib_ssr_out 	= enable_ehip ? ehip_aib_data_in_per_chan[89:82]  : {4'b0, hip_aib_data_in_per_chan[85:82]};
	assign int_in_hip_aib_clk			          = enable_ehip ? ehip_aib_data_in_per_chan[90]     : hip_aib_data_in_per_chan[86];
	assign int_in_hip_aib_clk_2x		        = enable_ehip ? ehip_aib_data_in_per_chan[91]     : hip_aib_data_in_per_chan[87];
	assign int_in_hip_aib_txeq_out		      = enable_ehip ? ehip_aib_data_in_per_chan[101:92] : hip_aib_data_in_per_chan[97:88];
	assign int_in_hip_aib_txeq_clk_out	    = enable_ehip ? ehip_aib_data_in_per_chan[102]    : hip_aib_data_in_per_chan[98];
	assign int_in_hip_aib_txeq_rst_n	      = enable_ehip ? ehip_aib_data_in_per_chan[103]    : hip_aib_data_in_per_chan[99];
	assign int_in_hip_aib_async_out		      = enable_ehip ? ehip_aib_data_in_per_chan[104]    : hip_aib_data_in_per_chan[100];

	// HIP (input) to Adapter (output) per channel
	wire [77:0]	int_out_hip_aib_sync_data_in;
	wire [3:0]	int_out_aibhssi_hip_aib_fsr_in;			
	wire [39:0]	int_out_aibhssi_hip_aib_ssr_in;			
	wire [2:0]	int_out_hip_aib_status;	
	wire [6:0]	int_out_aib_hip_txeq_in;

	// Fan out data to the the "ehip_*" ports or "hip_*" ports
  // NOTE: the "ehip_*" bus is used for naming clarity only. The ehip and phip
  // share the same physical interface to the PCS
	assign  hip_aib_data_out[ig*132 +: 132] = {int_out_aib_hip_txeq_in, int_out_hip_aib_status, int_out_aibhssi_hip_aib_ssr_in, int_out_aibhssi_hip_aib_fsr_in, int_out_hip_aib_sync_data_in};
	assign ehip_aib_data_out[ig*132 +: 132] = {int_out_aib_hip_txeq_in, int_out_hip_aib_status, int_out_aibhssi_hip_aib_ssr_in, int_out_aibhssi_hip_aib_fsr_in, int_out_hip_aib_sync_data_in};

  // END: HIP to Adapter Interface Connections
  // ------------------------------------------
	
  // BEGIN: EHIP TX/RX Data Connections for ANLT
  // --------------------------------------------

  wire         aib_tx_data_valid;
  wire [17:0]  aib_tx_control;
  wire [127:0] aib_tx_data;

  wire         pcs_tx_data_valid;
  wire [17:0]  pcs_tx_control;
  wire [127:0] pcs_tx_data;
  
  wire         pcs_rx_data_valid;
  wire [19:0]  pcs_rx_control;
  wire [127:0] pcs_rx_data;
  
  wire         ehip_aib_tx_data_valid;
  wire [17:0]  ehip_aib_tx_control;
  wire [127:0] ehip_aib_tx_data;
  
  wire         ehip_pcs_tx_data_valid;
  wire [17:0]  ehip_pcs_tx_control;
  wire [127:0] ehip_pcs_tx_data;
  
  wire         ehip_pcs_rx_data_valid;
  wire [19:0]  ehip_pcs_rx_control;
  wire [127:0] ehip_pcs_rx_data;

  //Obtain per-channel valid, control, and data 
  assign {ehip_pcs_tx_data_valid, ehip_pcs_tx_control, ehip_pcs_tx_data} = ehip_pcs_pld_tx_data_in[ig*147 +: 147];

  //TX signals: connect to ports if ehip is enabled, otherwise, pass through 
  if (enable_ehip) begin
    assign ehip_aib_tx_data_valid = aib_tx_data_valid      ;
    assign ehip_aib_tx_control    = aib_tx_control         ;
    assign ehip_aib_tx_data       = aib_tx_data            ;
    assign pcs_tx_data_valid      = ehip_pcs_tx_data_valid ; 
    assign pcs_tx_control         = ehip_pcs_tx_control    ; 
    assign pcs_tx_data            = ehip_pcs_tx_data       ; 
  end
  else begin
    assign ehip_aib_tx_data_valid = 1'b0              ;
    assign ehip_aib_tx_control    = 18'b0             ;
    assign ehip_aib_tx_data       = 128'b0            ;
    assign pcs_tx_data_valid      = aib_tx_data_valid ;
    assign pcs_tx_control         = aib_tx_control    ;
    assign pcs_tx_data            = aib_tx_data       ;
  end

  //RX signals: fan-out to ports if ehip is enabled
  if (enable_ehip) begin
    assign ehip_pcs_rx_data_valid = pcs_rx_data_valid;
    assign ehip_pcs_rx_control    = pcs_rx_control;
    assign ehip_pcs_rx_data       = pcs_rx_data;
  end
  else begin
    assign ehip_pcs_rx_data_valid = 1'b0;
    assign ehip_pcs_rx_control    = {20{1'b0}};
    assign ehip_pcs_rx_data       = {128{1'b0}};
  end

  //Gather all ehip signals into a single bus
  assign ehip_aib_pld_tx_data_out[ig*147 +: 147] = {ehip_aib_tx_data_valid, ehip_aib_tx_control, ehip_aib_tx_data};
  assign ehip_pcs_pld_rx_data_out[ig*149 +: 149] = {ehip_pcs_rx_data_valid, ehip_pcs_rx_control, ehip_pcs_rx_data};  

  // END: EHIP TX/RX Data Connections for ANLT
  // ------------------------------------------

  //mcgb_location calculation
  //--------------------------
  localparam [4:0] lcl_pma_tx_buf_pm_cr2_tx_rx_mcgb_location_for_pcie = altera_xcvr_native_s10_functions_h::get_mcgb_location_alt_xcvr_native_s10(lcl_pcs_aib_bonding_master, ig);

	//**************************
	// Channel level bonding parameters	
	//**************************
	localparam  lcl_pma_cgb_select_done_master_or_slave = (pma_cgb_prot_mode == "not_used") ? "choose_slave_pcie_sw_done" 
															: enable_pcs_aib_bonding ? "choose_master_pcie_sw_done" : "choose_slave_pcie_sw_done";

	localparam lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx = 
				enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "individual") ? "individual_tx"
					: (manual_pcs_bonding_mode == "ctrl_master") ? "ctrl_master_tx"
					: (manual_pcs_bonding_mode == "ctrl_slave_abv") ? "ctrl_slave_abv_tx" 
					: "ctrl_slave_blw_tx" 
				: (hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx == "individual_tx") ? "individual_tx"				
					: (ig < lcl_pcs_aib_bonding_master) ? "ctrl_slave_blw_tx"
					: (ig > lcl_pcs_aib_bonding_master) ? "ctrl_slave_abv_tx"
					: "ctrl_master_tx";

	localparam  lcl_hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx = 
				  enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "individual") ? "individual_rx"
					: (manual_pcs_bonding_mode == "ctrl_master") ? "ctrl_master_rx"
					: (manual_pcs_bonding_mode == "ctrl_slave_abv") ? "ctrl_slave_abv_rx" 
					: "ctrl_slave_blw_rx" 
                  : (hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx == "individual_rx") ? "individual_rx"					
					: (ig < lcl_pcs_aib_bonding_master) ? "ctrl_slave_blw_rx"
					: (ig > lcl_pcs_aib_bonding_master) ? "ctrl_slave_abv_rx"
					: "ctrl_master_rx";

	localparam  lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_ctrl_plane_bonding =
				  enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "individual") ? "individual"
					: (manual_pcs_bonding_mode == "ctrl_master") ? "ctrl_master"
					: (manual_pcs_bonding_mode == "ctrl_slave_abv") ? "ctrl_slave_abv" 
					: "ctrl_slave_blw" 
                  : (hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx != "pcie_g1_capable_tx" && hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx != "pcie_g2_capable_tx" && hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx != "pcie_g3_capable_tx") ? "individual"
                    : (hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx == "individual_tx") ? "individual"					
					: (ig < lcl_pcs_aib_bonding_master) ? "ctrl_slave_blw"
					: (ig > lcl_pcs_aib_bonding_master) ? "ctrl_slave_abv"
					: "ctrl_master";

	//**************************
	// Adapter level bonding parameters
	//**************************
	// ctrl_plane_bonding
	localparam lcl_hssi_pldadapt_tx_ctrl_plane_bonding = enable_tx_core_aib_bonding ? enable_manual_bonding_settings ? manual_tx_core_aib_bonding_mode															
																: (ig < lcl_pcs_aib_bonding_master) ? (ig == 0) ? "ctrl_slave_bot"	: "ctrl_slave_blw"
																: (ig > lcl_pcs_aib_bonding_master) ? (ig == (channels-1)) ? "ctrl_slave_top" : "ctrl_slave_abv"
																: (ig == 0 ) ? "ctrl_master_bot" : (ig == (channels-1)) ? "ctrl_master_top"	: "ctrl_master"
														 : "individual";

	localparam lcl_hssi_pldadapt_rx_ctrl_plane_bonding = enable_rx_core_aib_bonding ? enable_manual_bonding_settings ? manual_rx_core_aib_bonding_mode															
																: (ig < lcl_pcs_aib_bonding_master) ? (ig == 0) ? "ctrl_slave_bot"	: "ctrl_slave_blw"
																: (ig > lcl_pcs_aib_bonding_master) ? (ig == (channels-1)) ? "ctrl_slave_top" : "ctrl_slave_abv"
																: (ig == 0 ) ? "ctrl_master_bot" : (ig == (channels-1)) ? "ctrl_master_top"	: "ctrl_master"
														 : "individual";

	localparam lcl_hssi_adapt_tx_ctrl_plane_bonding = enable_tx_hssi_aib_bonding ? enable_manual_bonding_settings ? manual_tx_hssi_aib_bonding_mode															
																: (ig < lcl_pcs_aib_bonding_master) ? (ig == 0) ? "ctrl_slave_bot"	: "ctrl_slave_blw"
																: (ig > lcl_pcs_aib_bonding_master) ? (ig == (channels-1)) ? "ctrl_slave_top" : "ctrl_slave_abv"
																: (ig == 0 ) ? "ctrl_master_bot" : (ig == (channels-1)) ? "ctrl_master_top"	: "ctrl_master"
													  : "individual";

	localparam lcl_hssi_adapt_rx_ctrl_plane_bonding = enable_rx_hssi_aib_bonding ? enable_manual_bonding_settings ? manual_rx_hssi_aib_bonding_mode															
																: (ig < lcl_pcs_aib_bonding_master) ? (ig == 0) ? "ctrl_slave_bot"	: "ctrl_slave_blw"
																: (ig > lcl_pcs_aib_bonding_master) ? (ig == (channels-1)) ? "ctrl_slave_top" : "ctrl_slave_abv"
																: (ig == 0 ) ? "ctrl_master_bot" : (ig == (channels-1)) ? "ctrl_master_top"	: "ctrl_master"
													  : "individual";

	// comp_cnt
	localparam  [7:0] lcl_tx_hssi_aib_bonding_comp_cnt = enable_tx_hssi_aib_bonding ? 
															enable_manual_bonding_settings ? manual_tx_hssi_aib_bonding_comp_cnt[7:0]														
															: altera_xcvr_native_s10_functions_h::get_comp_cnt_alt_xcvr_native_s10(channels, lcl_pcs_aib_bonding_master, ig)
														 : 8'd0;

	localparam  [7:0] lcl_rx_hssi_aib_bonding_comp_cnt = enable_rx_hssi_aib_bonding ? 
															enable_manual_bonding_settings ? manual_rx_hssi_aib_bonding_comp_cnt[7:0]		
															: altera_xcvr_native_s10_functions_h::get_comp_cnt_alt_xcvr_native_s10(channels, lcl_pcs_aib_bonding_master, ig)
														 : 8'd0;

	localparam  [7:0] lcl_tx_core_aib_bonding_comp_cnt = enable_tx_core_aib_bonding ? 
															enable_manual_bonding_settings ? manual_tx_core_aib_bonding_comp_cnt[7:0]
															: altera_xcvr_native_s10_functions_h::get_comp_cnt_alt_xcvr_native_s10(channels, lcl_pcs_aib_bonding_master, ig)
														 : 8'd0;

	localparam  [7:0] lcl_rx_core_aib_bonding_comp_cnt = enable_rx_core_aib_bonding ? 
															enable_manual_bonding_settings ? manual_rx_core_aib_bonding_comp_cnt[7:0]
															: altera_xcvr_native_s10_functions_h::get_comp_cnt_alt_xcvr_native_s10(channels, lcl_pcs_aib_bonding_master, ig)
														 : 8'd0;
	// hrdrst_rst_sm_dis
	localparam lcl_tx_hssi_aib_bonding_hrdrst_rst_sm_dis = (lcl_hssi_adapt_tx_ctrl_plane_bonding == "individual") ? "enable_tx_rst_sm"														
																	: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master") ? "enable_tx_rst_sm"														
																	: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "enable_tx_rst_sm"
																	: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "enable_tx_rst_sm"
																	: "disable_tx_rst_sm";	

	localparam lcl_rx_hssi_aib_bonding_hrdrst_rst_sm_dis = (lcl_hssi_adapt_rx_ctrl_plane_bonding == "individual") ? "enable_rx_rst_sm"														
																	: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master") ? "enable_rx_rst_sm"														
																	: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "enable_rx_rst_sm"
																	: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "enable_rx_rst_sm"
																	: "disable_rx_rst_sm";	

	localparam lcl_tx_core_aib_bonding_hrdrst_rst_sm_dis = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? "enable_tx_rst_sm"														
																	: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master") ? "enable_tx_rst_sm"														
																	: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "enable_tx_rst_sm"
																	: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "enable_tx_rst_sm"
																	: "disable_tx_rst_sm";	

	localparam lcl_rx_core_aib_bonding_hrdrst_rst_sm_dis = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? "enable_rx_rst_sm"														
																	: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master") ? "enable_rx_rst_sm"														
																	: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "enable_rx_rst_sm"
																	: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "enable_rx_rst_sm"
																	: "disable_rx_rst_sm";	

	// us/ds master channel settings
	localparam lcl_hssi_pldadapt_tx_ds_last_chnl = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? "ds_last_chnl"														
														: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_last_chnl"														
														: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_bot") ? "ds_last_chnl"
														: "ds_not_last_chnl";		

	localparam lcl_hssi_pldadapt_tx_us_last_chnl = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? "us_last_chnl"														
														: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "us_last_chnl"
														: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_top") ? "us_last_chnl"
														: "us_not_last_chnl";		

	localparam lcl_hssi_pldadapt_tx_us_master = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? "us_master_en"
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master") ? "us_master_en"
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "us_master_en"
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "us_master_en"
													: "us_master_dis";		

	localparam lcl_hssi_pldadapt_tx_ds_master = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "individual") ? "ds_master_en"		
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master") ? "ds_master_en"	
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "ds_master_en"
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_master_en"
													: "ds_master_dis";		
	
	 localparam lcl_hssi_pldadapt_tx_compin_sel = (lcl_hssi_pldadapt_tx_ctrl_plane_bonding=="individual") ? "compin_master"
                                                    : (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_blw") ? "compin_slave_bot"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_abv") ? "compin_slave_top"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_top") ? "compin_slave_top"														   												
													: (lcl_hssi_pldadapt_tx_ctrl_plane_bonding == "ctrl_slave_bot") ? "compin_slave_bot"
													: "compin_default";

	localparam lcl_hssi_pldadapt_rx_ds_last_chnl = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? "ds_last_chnl"														
														: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_last_chnl"														
														: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_bot") ? "ds_last_chnl"
														: "ds_not_last_chnl";		

	localparam lcl_hssi_pldadapt_rx_us_last_chnl = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? "us_last_chnl"														
														: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "us_last_chnl"														
														: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_top") ? "us_last_chnl"
														: "us_not_last_chnl";		

	localparam lcl_hssi_pldadapt_rx_us_master = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? "us_master_en"														
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master") ? "us_master_en"														
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "us_master_en"
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "us_master_en"
													: "us_master_dis";		

	localparam lcl_hssi_pldadapt_rx_ds_master = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "individual") ? "ds_master_en"														
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master") ? "ds_master_en"														
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "ds_master_en"
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_master_en"
													: "ds_master_dis";		
	
	 localparam lcl_hssi_pldadapt_rx_compin_sel = (lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="individual") ? "compin_master"
                                                    : (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "compin_master"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_blw") ? "compin_slave_bot"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_abv") ? "compin_slave_top"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_top") ? "compin_slave_top"														   												
													: (lcl_hssi_pldadapt_rx_ctrl_plane_bonding == "ctrl_slave_bot") ? "compin_slave_bot"
													: "compin_default";
	
	localparam lcl_hssi_pldadapt_rx_asn_en = ((hssi_pldadapt_rx_pipe_mode=="enable_g1")||(hssi_pldadapt_rx_pipe_mode=="enable_g2")||(hssi_pldadapt_rx_pipe_mode=="enable_g3")) ? 
												((lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="individual")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master_top")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master_bot")) ? "enable"	: "disable"
												: "disable";	

    localparam lcl_hssi_pldadapt_rx_pma_hclk_scg_en = ((hssi_pldadapt_rx_pipe_mode=="enable_g1")||(hssi_pldadapt_rx_pipe_mode=="enable_g2")||(hssi_pldadapt_rx_pipe_mode=="enable_g3")) ? 
												((lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="individual")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master_top")||(lcl_hssi_pldadapt_rx_ctrl_plane_bonding=="ctrl_master_bot")) ? "disable"	: "enable"
												: "enable";	

	localparam lcl_hssi_adapt_tx_ds_last_chnl = (lcl_hssi_adapt_tx_ctrl_plane_bonding == "individual") ? "ds_last_chnl"														
														: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_last_chnl"														
														: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_bot") ? "ds_last_chnl"
														: "ds_not_last_chnl";		

	localparam lcl_hssi_adapt_tx_us_last_chnl = (lcl_hssi_adapt_tx_ctrl_plane_bonding == "individual") ? "us_last_chnl"														
														: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "us_last_chnl"
														: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_top") ? "us_last_chnl"
														: "us_not_last_chnl";		

	localparam lcl_hssi_adapt_tx_us_master = (lcl_hssi_adapt_tx_ctrl_plane_bonding == "individual") ? "us_master_en"
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master") ? "us_master_en"
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "us_master_en"
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "us_master_en"
													: "us_master_dis";		

	localparam lcl_hssi_adapt_tx_ds_master = (lcl_hssi_adapt_tx_ctrl_plane_bonding == "individual") ? "ds_master_en"		
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master") ? "ds_master_en"	
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "ds_master_en"
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_master_en"
													: "ds_master_dis";		
	
	 localparam lcl_hssi_adapt_tx_compin_sel = (lcl_hssi_adapt_tx_ctrl_plane_bonding=="individual") ? "compin_master"
                                                    : (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master") ? "compin_master"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_top") ? "compin_master"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_master_bot") ? "compin_master"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_blw") ? "compin_slave_bot"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_abv") ? "compin_slave_top"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_top") ? "compin_slave_top"														   												
													: (lcl_hssi_adapt_tx_ctrl_plane_bonding == "ctrl_slave_bot") ? "compin_slave_bot"
													: "compin_default";

	localparam lcl_hssi_adapt_rx_ds_last_chnl = (lcl_hssi_adapt_rx_ctrl_plane_bonding == "individual") ? "ds_last_chnl"														
														: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_last_chnl"														
														: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_bot") ? "ds_last_chnl"
														: "ds_not_last_chnl";		

	localparam lcl_hssi_adapt_rx_us_last_chnl = (lcl_hssi_adapt_rx_ctrl_plane_bonding == "individual") ? "us_last_chnl"														
														: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "us_last_chnl"														
														: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_top") ? "us_last_chnl"
														: "us_not_last_chnl";		

	localparam lcl_hssi_adapt_rx_us_master = (lcl_hssi_adapt_rx_ctrl_plane_bonding == "individual") ? "us_master_en"														
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master") ? "us_master_en"														
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "us_master_en"
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "us_master_en"
													: "us_master_dis";		

	localparam lcl_hssi_adapt_rx_ds_master = (lcl_hssi_adapt_rx_ctrl_plane_bonding == "individual") ? "ds_master_en"														
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master") ? "ds_master_en"														
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "ds_master_en"
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "ds_master_en"
													: "ds_master_dis";		
	
	 localparam lcl_hssi_adapt_rx_compin_sel = (lcl_hssi_adapt_rx_ctrl_plane_bonding=="individual") ? "compin_master"
                                                    : (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master") ? "compin_master"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_top") ? "compin_master"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_master_bot") ? "compin_master"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_blw") ? "compin_slave_bot"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_abv") ? "compin_slave_top"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_top") ? "compin_slave_top"														   												
													: (lcl_hssi_adapt_rx_ctrl_plane_bonding == "ctrl_slave_bot") ? "compin_slave_bot"
													: "compin_default";
	
	localparam lcl_hssi_adapt_rx_asn_en = ((hssi_adapt_rx_pipe_mode=="enable_g1")||(hssi_adapt_rx_pipe_mode=="enable_g2")||(hssi_adapt_rx_pipe_mode=="enable_g3")) ? 
												((lcl_hssi_adapt_rx_ctrl_plane_bonding=="individual")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_master")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_master_top")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_master_bot")) ? "enable" : "disable"
												: "disable";	

	localparam lcl_hssi_adapt_rx_slv_asn_en = ((hssi_adapt_rx_pipe_mode=="enable_g1")||(hssi_adapt_rx_pipe_mode=="enable_g2")||(hssi_adapt_rx_pipe_mode=="enable_g3")) ? 
												((lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_slave_abv")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_slave_blw")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_slave_top")||(lcl_hssi_adapt_rx_ctrl_plane_bonding=="ctrl_slave_bot")) ? "enable" : "disable"
												: "disable";	
	
	// PCS level bonding parameters
	localparam lcl_hssi_tx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_tx = lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx; 
	localparam lcl_hssi_tx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_tx = lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx; 
	localparam lcl_hssi_rx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_rx = lcl_hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx; 
	localparam lcl_hssi_rx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_rx = lcl_hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx; 
	localparam lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding = lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_ctrl_plane_bonding;		

	localparam  lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_consumption = enable_pcs_bonding ?
																	enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "ctrl_master") ? "bundled_master"
																		: (manual_pcs_bonding_mode == "ctrl_slave_abv") ? "bundled_slave_above" 
																		: "bundled_slave_below" 
																	: (ig < lcl_pcs_aib_bonding_master) ? "bundled_slave_below"
																		: (ig > lcl_pcs_aib_bonding_master) ? "bundled_slave_above"
																		: "bundled_master"
																 : "individual";

    localparam  lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption = (lcl_hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx == "individual_rx")? "individual" 
                                                                    : (ig < lcl_pcs_aib_bonding_master) ? "bundled_slave_below"
                                                                    : (ig > lcl_pcs_aib_bonding_master) ? "bundled_slave_above"
                                                                    : "bundled_master";

	localparam  lcl_hssi_10g_tx_pcs_ctrl_plane_bonding = enable_pcs_bonding ? 
															enable_manual_bonding_settings ? (manual_pcs_bonding_mode == "ctrl_master") ? "ctrl_master"
																: (manual_pcs_bonding_mode == "ctrl_slave_abv") ? "ctrl_slave_abv" 
																: "ctrl_slave_blw" 
															: (ig < lcl_pcs_aib_bonding_master) ? "ctrl_slave_blw"
																: (ig > lcl_pcs_aib_bonding_master) ? "ctrl_slave_abv"
																: "ctrl_master"
													     : "individual";												    

	localparam  [7:0] lcl_hssi_10g_tx_pcs_comp_cnt = enable_pcs_bonding ? 
														enable_manual_bonding_settings ? manual_pcs_bonding_comp_cnt[7:0]
															: altera_xcvr_native_s10_functions_h::get_comp_cnt_alt_xcvr_native_s10(channels, lcl_pcs_aib_bonding_master, ig)
														: 8'd0;

    localparam lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_compensation = (hssi_8g_rx_pcs_byte_deserializer=="en_bds_by_4") ? "en_compensation" : "dis_compensation";
    localparam lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_distribution = (lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_consumption=="bundled_master") ? "master_chnl_distr" : "not_master_chnl_distr";
    localparam lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_distribution = (lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption=="bundled_master") ? "master_chnl_distr" : "not_master_chnl_distr";
    localparam lcl_hssi_8g_rx_pcs_auto_speed_nego                 = (((hssi_8g_rx_pcs_prot_mode=="pipe_g3")&&((lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption=="individual")||(lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption=="bundled_master")))) ?
                                                                       "en_asn_g2_freq_scal" :
                                                                    (((hssi_8g_rx_pcs_prot_mode=="pipe_g2")&&((lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption=="individual")||(lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption=="bundled_master")))) ?
                                                                       "en_asn_g2_freq_scal" :
                                                                       "dis_asn";

    localparam lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_compensation = ((hssi_8g_tx_pcs_byte_serializer=="en_bs_by_4")) ? "en_compensation" : "dis_compensation";
    localparam lcl_hssi_8g_tx_pcs_auto_speed_nego_gen2            = (((hssi_8g_tx_pcs_prot_mode=="pipe_g2")&&((lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_consumption=="individual")||(lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_consumption=="bundled_master")))) ?
                                                                       "en_asn_g2_freq_scal" :
                                                                       "dis_asn_g2";

    localparam lcl_hssi_10g_tx_pcs_compin_sel     = ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="individual")||(lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_master")) ?
                                                       "compin_master" :
                                                    ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_blw")) ?
                                                       "compin_slave_bot" :
                                                    ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                       "compin_slave_top" :
                                                       "compin_default";
    localparam lcl_hssi_10g_tx_pcs_distdwn_master = ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="individual")||(lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_master")) ?
                                                       "distdwn_master_en" :
                                                    ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_blw")||(lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                       "distdwn_master_dis" :
                                                       "distdwn_master_dis";
    localparam lcl_hssi_10g_tx_pcs_distup_master  = ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="individual")||(lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_master")) ?
                                                       "distup_master_en" :
                                                    ((lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_blw")||(lcl_hssi_10g_tx_pcs_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                       "distup_master_dis" :
                                                       "distup_master_dis";
    

    localparam lcl_hssi_common_pcs_pma_interface_cp_cons_sel = ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="individual")||(lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_master")) ?
                                                                  "cp_cons_master" :
                                                               ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_blw")) ?
                                                                  "cp_cons_slave_blw" :
                                                               ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                                  "cp_cons_slave_abv" :
                                                                  "cp_cons_default";
    localparam lcl_hssi_common_pcs_pma_interface_cp_dwn_mstr = ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="individual")||(lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_master")) ?
                                                                  "true" :
                                                               ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_blw")||(lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                                  "false" :
                                                                  "true";
    localparam lcl_hssi_common_pcs_pma_interface_cp_up_mstr  = ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="individual")||(lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_master")) ?
                                                                  "true" :
                                                               ((lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_blw")||(lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding=="ctrl_slave_abv")) ?
                                                                  "false" :
                                                                  "true";

	// String to binary conversions
  localparam  [127:0] temp_lcl_hssi_10g_tx_pcs_pseudo_seed_a              = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(hssi_10g_tx_pcs_pseudo_seed_a);
  localparam  [127:0] temp_lcl_hssi_10g_tx_pcs_pseudo_seed_b              = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(hssi_10g_tx_pcs_pseudo_seed_b);
  localparam  [127:0] temp_lcl_hssi_8g_rx_pcs_wa_pd_data                  = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(hssi_8g_rx_pcs_wa_pd_data);
  localparam  [127:0] temp_lcl_pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz);
  localparam  [127:0] temp_lcl_pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz);
  localparam  [127:0] temp_lcl_pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz);			
	localparam  [127:0] temp_lcl_pma_tx_buf_pm_cr2_tx_path_datarate_bps     = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_tx_buf_pm_cr2_tx_path_datarate_bps);
	localparam  [127:0] temp_lcl_pma_tx_ser_datarate_bps                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_tx_ser_datarate_bps);	
	localparam  [127:0] temp_lcl_pma_tx_buf_datarate_bps                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_tx_buf_datarate_bps);	
	localparam  [127:0] temp_lcl_pma_rx_buf_datarate_bps                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_rx_buf_datarate_bps);	
	localparam  [127:0] temp_lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps     = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(pma_rx_buf_pm_cr2_rx_path_datarate_bps);	
	localparam  [127:0] temp_lcl_cdr_pll_reference_clock_frequency          = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_reference_clock_frequency);
	localparam  [127:0] temp_lcl_cdr_pll_vco_freq                           = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_vco_freq);
	localparam  [127:0] temp_lcl_cdr_pll_out_freq                           = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_out_freq);			
	localparam  [127:0] temp_lcl_cdr_pll_bandwidth_range_high               = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_bandwidth_range_high);
	localparam  [127:0] temp_lcl_cdr_pll_bandwidth_range_low                = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_bandwidth_range_low);
	localparam  [127:0] temp_lcl_cdr_pll_f_max_cmu_out_freq                 = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_max_cmu_out_freq);
	localparam  [127:0] temp_lcl_cdr_pll_f_max_m_counter                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_max_m_counter);
	localparam  [127:0] temp_lcl_cdr_pll_f_max_pfd			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_max_pfd);
	localparam  [127:0] temp_lcl_cdr_pll_f_max_ref			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_max_ref);
	localparam  [127:0] temp_lcl_cdr_pll_f_max_vco			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_max_vco);
	localparam  [127:0] temp_lcl_cdr_pll_f_min_gt_channel	                  = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_min_gt_channel);
	localparam  [127:0] temp_lcl_cdr_pll_f_min_pfd			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_min_pfd);
	localparam  [127:0] temp_lcl_cdr_pll_f_min_ref			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_min_ref);
	localparam  [127:0] temp_lcl_cdr_pll_f_min_vco			                    = altera_xcvr_native_s10_functions_h::str_2_bin_alt_xcvr_native_s10(cdr_pll_f_min_vco);	
  localparam  [57:0] lcl_hssi_10g_tx_pcs_pseudo_seed_a                    = altera_xcvr_native_s10_functions_h::set_10g_scrm_seed_user_alt_xcvr_native_s10(hssi_10g_tx_pcs_prot_mode,temp_lcl_hssi_10g_tx_pcs_pseudo_seed_a [57:0],ig); // randomization per channel for interlaken
  localparam  [57:0] lcl_hssi_10g_tx_pcs_pseudo_seed_b                    = temp_lcl_hssi_10g_tx_pcs_pseudo_seed_b [57:0]; 
  localparam  [39:0] lcl_hssi_8g_rx_pcs_wa_pd_data                        = temp_lcl_hssi_8g_rx_pcs_wa_pd_data [39:0];
  localparam  [31:0] lcl_pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz       = temp_lcl_pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz[31:0];
  localparam  [31:0] lcl_pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz       = temp_lcl_pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz[31:0];
  localparam  [31:0] lcl_pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz          = temp_lcl_pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz[31:0];	
	localparam  [35:0] lcl_pma_tx_buf_pm_cr2_tx_path_datarate_bps		        = temp_lcl_pma_tx_buf_pm_cr2_tx_path_datarate_bps[35:0];
	localparam  [35:0] lcl_pma_tx_ser_datarate_bps		                      = temp_lcl_pma_tx_ser_datarate_bps[35:0];
	localparam  [35:0] lcl_pma_tx_buf_datarate_bps		                      = temp_lcl_pma_tx_buf_datarate_bps[35:0];
	localparam  [35:0] lcl_pma_rx_buf_datarate_bps		                      = temp_lcl_pma_rx_buf_datarate_bps[35:0];
	localparam  [35:0] lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps		        = temp_lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps[35:0];
	localparam  [35:0] lcl_cdr_pll_reference_clock_frequency                = temp_lcl_cdr_pll_reference_clock_frequency[35:0];	
	localparam  [35:0] lcl_cdr_pll_vco_freq                                 = temp_lcl_cdr_pll_vco_freq[35:0];
	localparam  [35:0] lcl_cdr_pll_out_freq                                 = temp_lcl_cdr_pll_out_freq[35:0];
	localparam  [35:0] lcl_cdr_pll_bandwidth_range_high                     = temp_lcl_cdr_pll_bandwidth_range_high[35:0];
	localparam  [35:0] lcl_cdr_pll_bandwidth_range_low                      = temp_lcl_cdr_pll_bandwidth_range_low[35:0];
	localparam  [35:0] lcl_cdr_pll_f_max_cmu_out_freq                       = temp_lcl_cdr_pll_f_max_cmu_out_freq[35:0];
	localparam  [35:0] lcl_cdr_pll_f_max_m_counter		                      = temp_lcl_cdr_pll_f_max_m_counter[35:0];
	localparam  [35:0] lcl_cdr_pll_f_max_pfd			                          = temp_lcl_cdr_pll_f_max_pfd[35:0];
	localparam  [35:0] lcl_cdr_pll_f_max_ref			                          = temp_lcl_cdr_pll_f_max_ref[35:0];
	localparam  [35:0] lcl_cdr_pll_f_max_vco			                          = temp_lcl_cdr_pll_f_max_vco[35:0];
	localparam  [35:0] lcl_cdr_pll_f_min_gt_channel	                        = temp_lcl_cdr_pll_f_min_gt_channel[35:0];
	localparam  [35:0] lcl_cdr_pll_f_min_pfd			                          = temp_lcl_cdr_pll_f_min_pfd[35:0];
	localparam  [35:0] lcl_cdr_pll_f_min_ref		                            = temp_lcl_cdr_pll_f_min_ref[35:0];
	localparam  [35:0] lcl_cdr_pll_f_min_vco		                            = temp_lcl_cdr_pll_f_min_vco[35:0];	

    ct2_xcvr_native #(

        .device_revision	  (device_revision),
        .bonded_lanes		    (1),
        .bonding_master_ch	(0),
        .xcvr_native_mode	  (xcvr_native_mode),

        //AVMM1 soft logic parameters (ct2_xcvr_avmm1.sv)
        .avmm_interfaces	  (1),
        .rcfg_enable		    (rcfg_enable),
        .silicon_rev        (device_revision),
        .calibration_type   (hssi_avmm1_if_calibration_type), 


        .pma_bti_clk_dec_silicon_rev (/*TODO - Added*/),
        .pma_bti_clk_dec_xrx_path_xcdr_deser_xdeser_odi_adapt_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xrx_path_xdfe_adapt_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xrx_path_xdfe_dfe_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xrx_path_xdfe_h1edge_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xrx_path_xdfe_odi_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xtx_path_xcgb_cgb_bti_en (/*TODO - Added*/),
        .pma_bti_clk_dec_xtx_path_xser_ser_preset_bti_en (/*TODO - Added*/),


        //The mcgb_location is calculated locally in this terp file 
        // The value passed down by the tcl framework is meaningless
        .pma_tx_buf_pm_cr2_tx_rx_mcgb_location_for_pcie                      (lcl_pma_tx_buf_pm_cr2_tx_rx_mcgb_location_for_pcie),

	    	.hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx      (lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_tx),
		    .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_ctrl_plane_bonding  (lcl_hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_ctrl_plane_bonding),
	    	.hssi_tx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_tx            (lcl_hssi_tx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_tx           (lcl_hssi_tx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_tx),
		    .hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx      (lcl_hssi_rx_pld_pcs_interface_hd_pcs_channel_ctrl_plane_bonding_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_rx            (lcl_hssi_rx_pld_pcs_interface_hd_pcs8g_ctrl_plane_bonding_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_rx           (lcl_hssi_rx_pld_pcs_interface_hd_pcs10g_ctrl_plane_bonding_rx),   
		    .hssi_8g_rx_pcs_ctrl_plane_bonding_compensation                      (lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_compensation),
        .hssi_8g_rx_pcs_ctrl_plane_bonding_consumption                       (lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_consumption    ),
        .hssi_8g_rx_pcs_ctrl_plane_bonding_distribution                      (lcl_hssi_8g_rx_pcs_ctrl_plane_bonding_distribution   ),
        .hssi_8g_rx_pcs_auto_speed_nego                                      (lcl_hssi_8g_rx_pcs_auto_speed_nego                ),
        .hssi_8g_tx_pcs_ctrl_plane_bonding_compensation                      (lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_compensation),
        .hssi_8g_tx_pcs_ctrl_plane_bonding_consumption                       (lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_consumption    ),
        .hssi_8g_tx_pcs_ctrl_plane_bonding_distribution                      (lcl_hssi_8g_tx_pcs_ctrl_plane_bonding_distribution   ),
        .hssi_8g_tx_pcs_auto_speed_nego_gen2                                 (lcl_hssi_8g_tx_pcs_auto_speed_nego_gen2           ),
        .hssi_10g_tx_pcs_ctrl_plane_bonding                                  (lcl_hssi_10g_tx_pcs_ctrl_plane_bonding),
        .hssi_10g_tx_pcs_comp_cnt                                            (lcl_hssi_10g_tx_pcs_comp_cnt          ),
        .hssi_10g_tx_pcs_compin_sel                                          (lcl_hssi_10g_tx_pcs_compin_sel        ),        
        .hssi_10g_tx_pcs_distdwn_master                                      (lcl_hssi_10g_tx_pcs_distdwn_master    ),        
        .hssi_10g_tx_pcs_distup_master                                       (lcl_hssi_10g_tx_pcs_distup_master     ),        
        .hssi_common_pcs_pma_interface_ctrl_plane_bonding                    (lcl_hssi_common_pcs_pma_interface_ctrl_plane_bonding),
        .hssi_common_pcs_pma_interface_cp_cons_sel                           (lcl_hssi_common_pcs_pma_interface_cp_cons_sel       ),
        .hssi_common_pcs_pma_interface_cp_dwn_mstr                           (lcl_hssi_common_pcs_pma_interface_cp_dwn_mstr       ),
        .hssi_common_pcs_pma_interface_cp_up_mstr                            (lcl_hssi_common_pcs_pma_interface_cp_up_mstr        ),
	      

		    .pma_cgb_select_done_master_or_slave (lcl_pma_cgb_select_done_master_or_slave),						    
        .hssi_10g_tx_pcs_pseudo_seed_a       (lcl_hssi_10g_tx_pcs_pseudo_seed_a),					// String to bin conversion
        .hssi_10g_tx_pcs_pseudo_seed_b       (lcl_hssi_10g_tx_pcs_pseudo_seed_b),					// String to bin conversion
        .hssi_8g_rx_pcs_wa_pd_data           (lcl_hssi_8g_rx_pcs_wa_pd_data),							// String to bin conversion

		    .pma_cgb_datarate_bps				        (lcl_pma_tx_buf_pm_cr2_tx_path_datarate_bps), // String to bin conversion
		    .pma_adapt_datarate_bps					    (lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps), // String to bin conversion
		    .pma_rx_deser_datarate_bps				  (lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps), // String to bin conversion
		    .pma_rx_dfe_datarate_bps				    (lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps), // String to bin conversion
		    .pma_rx_odi_datarate_bps	  			  (lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps), // String to bin conversion

		    .cdr_pll_datarate_bps					      (lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps), // String to bin conversion
		    .cdr_pll_reference_clock_frequency	(lcl_cdr_pll_reference_clock_frequency),		  // String to bin conversion
		    .cdr_pll_vco_freq					          (lcl_cdr_pll_vco_freq),             // String to bin conversion
		    .cdr_pll_out_freq						        (lcl_cdr_pll_out_freq),             // String to bin conversion
		    .cdr_pll_bandwidth_range_high			  (lcl_cdr_pll_bandwidth_range_high), // String to bin conversion
		    .cdr_pll_bandwidth_range_low			  (lcl_cdr_pll_bandwidth_range_low),  // String to bin conversion
		    .cdr_pll_f_max_cmu_out_freq				  (lcl_cdr_pll_f_max_cmu_out_freq),   // String to bin conversion        
        .cdr_pll_f_max_m_counter				    (lcl_cdr_pll_f_max_m_counter),      // String to bin conversion
        .cdr_pll_f_max_pfd						      (lcl_cdr_pll_f_max_pfd), // String to bin conversion
        .cdr_pll_f_max_ref						      (lcl_cdr_pll_f_max_ref), // String to bin conversion
        .cdr_pll_f_max_vco						      (lcl_cdr_pll_f_max_vco), // String to bin conversion
        .cdr_pll_f_min_gt_channel				    (lcl_cdr_pll_f_min_gt_channel), // String to bin conversion
        .cdr_pll_f_min_pfd					        (lcl_cdr_pll_f_min_pfd), // String to bin conversion
        .cdr_pll_f_min_ref					        (lcl_cdr_pll_f_min_ref), // String to bin conversion
        .cdr_pll_f_min_vco						      (lcl_cdr_pll_f_min_vco), // String to bin conversion
        .pma_tx_buf_datarate_bps            (lcl_pma_tx_buf_datarate_bps),
        .pma_rx_buf_datarate_bps            (lcl_pma_rx_buf_datarate_bps),

        //-----------------------------------------------------------------------------------------
        // TODO: check these string to binary conversions
        //-----------------------------------------------------------------------------------------

	      .pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz ( lcl_pma_tx_buf_pm_cr2_tx_path_pma_tx_divclk_hz ), // String to bin conversion
	      .pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz	  ( lcl_pma_tx_buf_pm_cr2_tx_path_tx_pll_clk_hz    ), // String to bin conversion    
	      .pma_tx_buf_pm_cr2_tx_path_datarate_bps     ( lcl_pma_tx_buf_pm_cr2_tx_path_datarate_bps     ), // String to bin conversion
        .pma_tx_ser_datarate_bps                    ( lcl_pma_tx_ser_datarate_bps                    ), // String to bin conversion

	      .pma_rx_buf_pm_cr2_rx_path_datarate_bps     ( lcl_pma_rx_buf_pm_cr2_rx_path_datarate_bps     ), // String to bin conversion
	      .pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz ( lcl_pma_rx_buf_pm_cr2_rx_path_pma_rx_divclk_hz ), // String to bin conversion

        .hssi_adapt_rx_ctrl_plane_bonding    (lcl_hssi_adapt_rx_ctrl_plane_bonding),
        .hssi_adapt_rx_ds_last_chnl          (lcl_hssi_adapt_rx_ds_last_chnl),
        .hssi_adapt_rx_us_last_chnl          (lcl_hssi_adapt_rx_us_last_chnl),
        .hssi_adapt_rx_asn_en                (lcl_hssi_adapt_rx_asn_en),
        .hssi_adapt_rx_slv_asn_en            (lcl_hssi_adapt_rx_slv_asn_en),
        .hssi_adapt_rx_us_master             (lcl_hssi_adapt_rx_us_master),
        .hssi_adapt_rx_ds_master             (lcl_hssi_adapt_rx_ds_master),
        .hssi_adapt_rx_compin_sel            (lcl_hssi_adapt_rx_compin_sel),
        .hssi_adapt_rx_comp_cnt              (lcl_rx_hssi_aib_bonding_comp_cnt),
        .hssi_adapt_tx_ctrl_plane_bonding    (lcl_hssi_adapt_tx_ctrl_plane_bonding),
        .hssi_adapt_tx_ds_last_chnl          (lcl_hssi_adapt_tx_ds_last_chnl),
        .hssi_adapt_tx_us_last_chnl          (lcl_hssi_adapt_tx_us_last_chnl),
        .hssi_adapt_tx_us_master             (lcl_hssi_adapt_tx_us_master),
        .hssi_adapt_tx_ds_master             (lcl_hssi_adapt_tx_ds_master),
        .hssi_adapt_tx_compin_sel            (lcl_hssi_adapt_tx_compin_sel),
        .hssi_adapt_tx_comp_cnt              (lcl_tx_hssi_aib_bonding_comp_cnt),        
        .hssi_pldadapt_rx_ctrl_plane_bonding (lcl_hssi_pldadapt_rx_ctrl_plane_bonding),
        .hssi_pldadapt_rx_ds_last_chnl       (lcl_hssi_pldadapt_rx_ds_last_chnl),
        .hssi_pldadapt_rx_us_last_chnl       (lcl_hssi_pldadapt_rx_us_last_chnl),
        .hssi_pldadapt_rx_asn_en             (lcl_hssi_pldadapt_rx_asn_en),
		    .hssi_pldadapt_rx_pma_hclk_scg_en    (lcl_hssi_pldadapt_rx_pma_hclk_scg_en),
        .hssi_pldadapt_rx_us_master          (lcl_hssi_pldadapt_rx_us_master),
        .hssi_pldadapt_rx_ds_master          (lcl_hssi_pldadapt_rx_ds_master),
        .hssi_pldadapt_rx_compin_sel         (lcl_hssi_pldadapt_rx_compin_sel),
        .hssi_pldadapt_rx_comp_cnt           (lcl_rx_core_aib_bonding_comp_cnt),        
        .hssi_pldadapt_tx_ctrl_plane_bonding (lcl_hssi_pldadapt_tx_ctrl_plane_bonding),
        .hssi_pldadapt_tx_ds_last_chnl       (lcl_hssi_pldadapt_tx_ds_last_chnl),
        .hssi_pldadapt_tx_us_last_chnl       (lcl_hssi_pldadapt_tx_us_last_chnl),
        .hssi_pldadapt_tx_us_master          (lcl_hssi_pldadapt_tx_us_master),
        .hssi_pldadapt_tx_ds_master          (lcl_hssi_pldadapt_tx_ds_master),
        .hssi_pldadapt_tx_compin_sel         (lcl_hssi_pldadapt_tx_compin_sel),
        .hssi_pldadapt_tx_comp_cnt           (lcl_tx_core_aib_bonding_comp_cnt),
        .hssi_pldadapt_tx_hrdrst_rst_sm_dis  (lcl_tx_core_aib_bonding_hrdrst_rst_sm_dis),
        .hssi_pldadapt_rx_hrdrst_rst_sm_dis  (lcl_rx_core_aib_bonding_hrdrst_rst_sm_dis),
        .hssi_adapt_tx_hrdrst_rst_sm_dis     (lcl_tx_hssi_aib_bonding_hrdrst_rst_sm_dis),
        .hssi_adapt_rx_hrdrst_rst_sm_dis     (lcl_rx_hssi_aib_bonding_hrdrst_rst_sm_dis),

	      .pma_cdr_refclk_inclk0_logical_to_physical_mapping ( "ref_iqclk0"                                       ),
	      .pma_cdr_refclk_inclk1_logical_to_physical_mapping ( (cdr_refclk_cnt > 1) ? "ref_iqclk1" : "power_down" ),
	      .pma_cdr_refclk_inclk2_logical_to_physical_mapping ( (cdr_refclk_cnt > 2) ? "ref_iqclk2" : "power_down" ),
	      .pma_cdr_refclk_inclk3_logical_to_physical_mapping ( (cdr_refclk_cnt > 3) ? "ref_iqclk3" : "power_down" ),
	      .pma_cdr_refclk_inclk4_logical_to_physical_mapping ( (cdr_refclk_cnt > 4) ? "ref_iqclk4" : "power_down" ),

        //-----------------------------------------------------------------------------------------
        // TODO: check this mapping
        //-----------------------------------------------------------------------------------------
	      .pma_cgb_scratch0_x1_clock_src ( (pma_cgb_prot_mode == "not_used") ? "not_used" :  (bonded_mode == "not_bonded")                ? "fpll_bot"  : "not_used" ),
	      .pma_cgb_scratch1_x1_clock_src ( (pma_cgb_prot_mode == "not_used") ? "not_used" : ((bonded_mode == "not_bonded") && (plls > 1)) ? "lcpll_bot" : "not_used" ),
	      .pma_cgb_scratch2_x1_clock_src ( (pma_cgb_prot_mode == "not_used") ? "not_used" : ((bonded_mode == "not_bonded") && (plls > 2)) ? "fpll_top"  : "not_used" ),
	      .pma_cgb_scratch3_x1_clock_src ( (pma_cgb_prot_mode == "not_used") ? "not_used" : ((bonded_mode == "not_bonded") && (plls > 3)) ? "lcpll_top" : "not_used" ),

        .hssi_rx_pld_pcs_interface_reconfig_settings (/*TODO - Added*/),
        .hssi_tx_pld_pcs_interface_reconfig_settings (/*TODO - Added*/),
        .hssi_10g_tx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_8g_rx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_8g_tx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_10g_rx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_pipe_gen3_reconfig_settings (/*TODO - Added*/),
        .hssi_gen3_rx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_gen3_tx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_krfec_rx_pcs_reconfig_settings (/*TODO - Added*/),
        .hssi_pipe_gen1_2_reconfig_settings (/*TODO - Added*/),
        .hssi_common_pld_pcs_interface_reconfig_settings (/*TODO - Added*/),
        .hssi_common_pcs_pma_interface_reconfig_settings (/*TODO - Added*/),
        .hssi_rx_pcs_pma_interface_reconfig_settings (/*TODO - Added*/),
        .hssi_tx_pcs_pma_interface_reconfig_settings (/*TODO - Added*/),


//        .hssi_avmm1_if_hssiadapt_avmm_clk_dcg_en(hssi_avmm1_if_hssiadapt_avmm_clk_dcg_en),
//        .hssi_avmm1_if_hssiadapt_avmm_clk_scg_en(hssi_avmm1_if_hssiadapt_avmm_clk_scg_en),
//        .hssi_avmm1_if_hssiadapt_osc_clk_scg_en(hssi_avmm1_if_hssiadapt_osc_clk_scg_en),
//        .hssi_avmm1_if_pldadapt_avmm_clk_scg_en(hssi_avmm1_if_pldadapt_avmm_clk_scg_en),
//        .hssi_avmm1_if_pldadapt_osc_clk_scg_en(hssi_avmm1_if_pldadapt_osc_clk_scg_en),
//        .hssi_pldadapt_rx_hdpldadapt_sr_sr_testbus_sel(hssi_pldadapt_rx_hdpldadapt_sr_sr_testbus_sel),
//        .hssi_pldadapt_tx_hdpldadapt_sr_sr_testbus_sel(hssi_pldadapt_tx_hdpldadapt_sr_sr_testbus_sel),
        .pma_tx_ser_xtx_path_xtx_idle_ctrl(pma_tx_ser_xtx_path_xtx_idle_ctrl),

	
        .cdr_pll_analog_mode (cdr_pll_analog_mode),
        .cdr_pll_atb_select_control (cdr_pll_atb_select_control),
        .cdr_pll_auto_reset_on (cdr_pll_auto_reset_on),
        .cdr_pll_bbpd_data_pattern_filter_select (cdr_pll_bbpd_data_pattern_filter_select),
        .cdr_pll_bti_protected (cdr_pll_bti_protected),
        .cdr_pll_bw_mode (cdr_pll_bw_mode),
        .cdr_pll_bypass_a_edge (cdr_pll_bypass_a_edge),
        .cdr_pll_cal_vco_count_length (cdr_pll_cal_vco_count_length),
        .cdr_pll_cdr_d2a_enb (cdr_pll_cdr_d2a_enb),
        .cdr_pll_cdr_odi_select (cdr_pll_cdr_odi_select),
        .cdr_pll_cdr_phaselock_mode (cdr_pll_cdr_phaselock_mode),
        .cdr_pll_cdr_powerdown_mode (cdr_pll_cdr_powerdown_mode),
        .cdr_pll_cgb_div (cdr_pll_cgb_div),
        .cdr_pll_chgpmp_current_dn_pd (cdr_pll_chgpmp_current_dn_pd),
        .cdr_pll_chgpmp_current_dn_trim (cdr_pll_chgpmp_current_dn_trim),
        .cdr_pll_chgpmp_current_pfd (cdr_pll_chgpmp_current_pfd),
        .cdr_pll_chgpmp_current_up_pd (cdr_pll_chgpmp_current_up_pd),
        .cdr_pll_chgpmp_current_up_trim (cdr_pll_chgpmp_current_up_trim),
        .cdr_pll_chgpmp_dn_pd_trim_double (cdr_pll_chgpmp_dn_pd_trim_double),
        .cdr_pll_chgpmp_replicate (cdr_pll_chgpmp_replicate),
        .cdr_pll_chgpmp_testmode (cdr_pll_chgpmp_testmode),
        .cdr_pll_chgpmp_up_pd_trim_double (cdr_pll_chgpmp_up_pd_trim_double),
        .cdr_pll_chgpmp_vccreg (cdr_pll_chgpmp_vccreg),
        .cdr_pll_clk0_dfe_tfall_adj (cdr_pll_clk0_dfe_tfall_adj),
        .cdr_pll_clk0_dfe_trise_adj (cdr_pll_clk0_dfe_trise_adj),
        .cdr_pll_clk90_dfe_tfall_adj (cdr_pll_clk90_dfe_tfall_adj),
        .cdr_pll_clk90_dfe_trise_adj (cdr_pll_clk90_dfe_trise_adj),
        .cdr_pll_clk180_dfe_tfall_adj (cdr_pll_clk180_dfe_tfall_adj),
        .cdr_pll_clk180_dfe_trise_adj (cdr_pll_clk180_dfe_trise_adj),
        .cdr_pll_clk270_dfe_tfall_adj (cdr_pll_clk270_dfe_tfall_adj),
        .cdr_pll_clk270_dfe_trise_adj (cdr_pll_clk270_dfe_trise_adj),
        .cdr_pll_clklow_mux_select (cdr_pll_clklow_mux_select),
        .cdr_pll_diag_loopback_enable (cdr_pll_diag_loopback_enable),
        .cdr_pll_direct_fb (cdr_pll_direct_fb),
        .cdr_pll_disable_up_dn (cdr_pll_disable_up_dn),
        .cdr_pll_fref_clklow_div (cdr_pll_fref_clklow_div),
        .cdr_pll_fref_mux_select (cdr_pll_fref_mux_select),
        .cdr_pll_gpon_lck2ref_control (cdr_pll_gpon_lck2ref_control),
        .cdr_pll_initial_settings (cdr_pll_initial_settings),
        .cdr_pll_iqclk_sel (cdr_pll_iqclk_sel),
        .cdr_pll_is_cascaded_pll (cdr_pll_is_cascaded_pll),
        .cdr_pll_lck2ref_delay_control (cdr_pll_lck2ref_delay_control),
        .cdr_pll_lf_resistor_pd (cdr_pll_lf_resistor_pd),
        .cdr_pll_lf_resistor_pfd (cdr_pll_lf_resistor_pfd),
        .cdr_pll_lf_ripple_cap (cdr_pll_lf_ripple_cap),
        .cdr_pll_loop_filter_bias_select (cdr_pll_loop_filter_bias_select),
        .cdr_pll_loopback_mode (cdr_pll_loopback_mode),
        .cdr_pll_lpd_counter (cdr_pll_lpd_counter),
        .cdr_pll_lpfd_counter (cdr_pll_lpfd_counter),
        .cdr_pll_ltd_ltr_micro_controller_select (cdr_pll_ltd_ltr_micro_controller_select),
        .cdr_pll_mcnt_div (cdr_pll_mcnt_div),
        .cdr_pll_n_counter (cdr_pll_n_counter),
        .cdr_pll_ncnt_div (cdr_pll_ncnt_div),
        .cdr_pll_optimal (cdr_pll_optimal),
        .cdr_pll_pcie_gen (cdr_pll_pcie_gen),
        .cdr_pll_pd_fastlock_mode (cdr_pll_pd_fastlock_mode),
        .cdr_pll_pd_l_counter (cdr_pll_pd_l_counter),
        .cdr_pll_pfd_l_counter (cdr_pll_pfd_l_counter),
        .cdr_pll_pm_cr2_rx_path_cdr_clock_enable (cdr_pll_pm_cr2_rx_path_cdr_clock_enable),
        .cdr_pll_pm_cr2_tx_rx_uc_dyn_reconfig (cdr_pll_pm_cr2_tx_rx_uc_dyn_reconfig),
        .cdr_pll_pma_width (cdr_pll_pma_width),
        .cdr_pll_position (cdr_pll_position),
        .cdr_pll_power_mode (cdr_pll_power_mode),
        .cdr_pll_powermode_ac_bbpd (cdr_pll_powermode_ac_bbpd),
        .cdr_pll_powermode_ac_rvcotop (cdr_pll_powermode_ac_rvcotop),
        .cdr_pll_powermode_ac_txpll (cdr_pll_powermode_ac_txpll),
        .cdr_pll_powermode_dc_bbpd (cdr_pll_powermode_dc_bbpd),
        .cdr_pll_powermode_dc_rvcotop (cdr_pll_powermode_dc_rvcotop),
        .cdr_pll_powermode_dc_txpll (cdr_pll_powermode_dc_txpll),
        .cdr_pll_primary_use (cdr_pll_primary_use),
        .cdr_pll_prot_mode (cdr_pll_prot_mode),
        .cdr_pll_requires_gt_capable_channel (cdr_pll_requires_gt_capable_channel),
        .cdr_pll_reverse_serial_loopback (cdr_pll_reverse_serial_loopback),
        .cdr_pll_rstb (cdr_pll_rstb),
        .cdr_pll_set_cdr_input_freq_range (cdr_pll_set_cdr_input_freq_range),
        .cdr_pll_set_cdr_v2i_enable (cdr_pll_set_cdr_v2i_enable),
        .cdr_pll_set_cdr_vco_reset (cdr_pll_set_cdr_vco_reset),
        .cdr_pll_set_cdr_vco_speed (cdr_pll_set_cdr_vco_speed),
        .cdr_pll_set_cdr_vco_speed_fix (cdr_pll_set_cdr_vco_speed_fix),
        .cdr_pll_set_cdr_vco_speed_pciegen3 (cdr_pll_set_cdr_vco_speed_pciegen3),
        .cdr_pll_silicon_rev (cdr_pll_silicon_rev),
        .cdr_pll_speed_grade (cdr_pll_speed_grade),
        .cdr_pll_sup_mode (cdr_pll_sup_mode),
        .cdr_pll_tx_pll_prot_mode (cdr_pll_tx_pll_prot_mode),
        .cdr_pll_txpll_hclk_driver_enable (cdr_pll_txpll_hclk_driver_enable),
        .cdr_pll_uc_ro_cal (cdr_pll_uc_ro_cal),
        .cdr_pll_vco_bypass (cdr_pll_vco_bypass),
        .cdr_pll_vco_overrange_voltage (cdr_pll_vco_overrange_voltage),
        .cdr_pll_vco_underrange_voltage (cdr_pll_vco_underrange_voltage),
        .cdr_pll_vreg_output (cdr_pll_vreg_output),
        .hssi_8g_rx_pcs_auto_error_replacement (hssi_8g_rx_pcs_auto_error_replacement),
        .hssi_8g_rx_pcs_bit_reversal (hssi_8g_rx_pcs_bit_reversal),
        .hssi_8g_rx_pcs_bonding_dft_en (hssi_8g_rx_pcs_bonding_dft_en),
        .hssi_8g_rx_pcs_bonding_dft_val (hssi_8g_rx_pcs_bonding_dft_val),
        .hssi_8g_rx_pcs_bypass_pipeline_reg (hssi_8g_rx_pcs_bypass_pipeline_reg),
        .hssi_8g_rx_pcs_byte_deserializer (hssi_8g_rx_pcs_byte_deserializer),
        .hssi_8g_rx_pcs_cdr_ctrl_rxvalid_mask (hssi_8g_rx_pcs_cdr_ctrl_rxvalid_mask),
        .hssi_8g_rx_pcs_clkcmp_pattern_n (hssi_8g_rx_pcs_clkcmp_pattern_n),
        .hssi_8g_rx_pcs_clkcmp_pattern_p (hssi_8g_rx_pcs_clkcmp_pattern_p),
        .hssi_8g_rx_pcs_clock_gate_bds_dec_asn (hssi_8g_rx_pcs_clock_gate_bds_dec_asn),
        .hssi_8g_rx_pcs_clock_gate_cdr_eidle (hssi_8g_rx_pcs_clock_gate_cdr_eidle),
        .hssi_8g_rx_pcs_clock_gate_dw_pc_wrclk (hssi_8g_rx_pcs_clock_gate_dw_pc_wrclk),
        .hssi_8g_rx_pcs_clock_gate_dw_rm_rd (hssi_8g_rx_pcs_clock_gate_dw_rm_rd),
        .hssi_8g_rx_pcs_clock_gate_dw_rm_wr (hssi_8g_rx_pcs_clock_gate_dw_rm_wr),
        .hssi_8g_rx_pcs_clock_gate_dw_wa (hssi_8g_rx_pcs_clock_gate_dw_wa),
        .hssi_8g_rx_pcs_clock_gate_pc_rdclk (hssi_8g_rx_pcs_clock_gate_pc_rdclk),
        .hssi_8g_rx_pcs_clock_gate_sw_pc_wrclk (hssi_8g_rx_pcs_clock_gate_sw_pc_wrclk),
        .hssi_8g_rx_pcs_clock_gate_sw_rm_rd (hssi_8g_rx_pcs_clock_gate_sw_rm_rd),
        .hssi_8g_rx_pcs_clock_gate_sw_rm_wr (hssi_8g_rx_pcs_clock_gate_sw_rm_wr),
        .hssi_8g_rx_pcs_clock_gate_sw_wa (hssi_8g_rx_pcs_clock_gate_sw_wa),
        .hssi_8g_rx_pcs_clock_observation_in_pld_core (hssi_8g_rx_pcs_clock_observation_in_pld_core),
        .hssi_8g_rx_pcs_eidle_entry_eios (hssi_8g_rx_pcs_eidle_entry_eios),
        .hssi_8g_rx_pcs_eidle_entry_iei (hssi_8g_rx_pcs_eidle_entry_iei),
        .hssi_8g_rx_pcs_eidle_entry_sd (hssi_8g_rx_pcs_eidle_entry_sd),
        .hssi_8g_rx_pcs_eightb_tenb_decoder (hssi_8g_rx_pcs_eightb_tenb_decoder),
        .hssi_8g_rx_pcs_err_flags_sel (hssi_8g_rx_pcs_err_flags_sel),
        .hssi_8g_rx_pcs_fixed_pat_det (hssi_8g_rx_pcs_fixed_pat_det),
        .hssi_8g_rx_pcs_fixed_pat_num (hssi_8g_rx_pcs_fixed_pat_num),
        .hssi_8g_rx_pcs_force_signal_detect (hssi_8g_rx_pcs_force_signal_detect),
        .hssi_8g_rx_pcs_gen3_clk_en (hssi_8g_rx_pcs_gen3_clk_en),
        .hssi_8g_rx_pcs_gen3_rx_clk_sel (hssi_8g_rx_pcs_gen3_rx_clk_sel),
        .hssi_8g_rx_pcs_gen3_tx_clk_sel (hssi_8g_rx_pcs_gen3_tx_clk_sel),
        .hssi_8g_rx_pcs_hip_mode (hssi_8g_rx_pcs_hip_mode),
        .hssi_8g_rx_pcs_ibm_invalid_code (hssi_8g_rx_pcs_ibm_invalid_code),
        .hssi_8g_rx_pcs_invalid_code_flag_only (hssi_8g_rx_pcs_invalid_code_flag_only),
        .hssi_8g_rx_pcs_pad_or_edb_error_replace (hssi_8g_rx_pcs_pad_or_edb_error_replace),
        .hssi_8g_rx_pcs_pcs_bypass (hssi_8g_rx_pcs_pcs_bypass),
        .hssi_8g_rx_pcs_phase_comp_rdptr (hssi_8g_rx_pcs_phase_comp_rdptr),
        .hssi_8g_rx_pcs_phase_compensation_fifo (hssi_8g_rx_pcs_phase_compensation_fifo),
        .hssi_8g_rx_pcs_pipe_if_enable (hssi_8g_rx_pcs_pipe_if_enable),
        .hssi_8g_rx_pcs_pma_dw (hssi_8g_rx_pcs_pma_dw),
        .hssi_8g_rx_pcs_polinv_8b10b_dec (hssi_8g_rx_pcs_polinv_8b10b_dec),
        .hssi_8g_rx_pcs_prot_mode (hssi_8g_rx_pcs_prot_mode),
        .hssi_8g_rx_pcs_rate_match (hssi_8g_rx_pcs_rate_match),
        .hssi_8g_rx_pcs_rate_match_del_thres (hssi_8g_rx_pcs_rate_match_del_thres),
        .hssi_8g_rx_pcs_rate_match_empty_thres (hssi_8g_rx_pcs_rate_match_empty_thres),
        .hssi_8g_rx_pcs_rate_match_full_thres (hssi_8g_rx_pcs_rate_match_full_thres),
        .hssi_8g_rx_pcs_rate_match_ins_thres (hssi_8g_rx_pcs_rate_match_ins_thres),
        .hssi_8g_rx_pcs_rate_match_start_thres (hssi_8g_rx_pcs_rate_match_start_thres),
        .hssi_8g_rx_pcs_rx_clk2 (hssi_8g_rx_pcs_rx_clk2),
        .hssi_8g_rx_pcs_rx_clk_free_running (hssi_8g_rx_pcs_rx_clk_free_running),
        .hssi_8g_rx_pcs_rx_pcs_urst (hssi_8g_rx_pcs_rx_pcs_urst),
        .hssi_8g_rx_pcs_rx_rcvd_clk (hssi_8g_rx_pcs_rx_rcvd_clk),
        .hssi_8g_rx_pcs_rx_rd_clk (hssi_8g_rx_pcs_rx_rd_clk),
        .hssi_8g_rx_pcs_rx_refclk (hssi_8g_rx_pcs_rx_refclk),
        .hssi_8g_rx_pcs_rx_wr_clk (hssi_8g_rx_pcs_rx_wr_clk),
        .hssi_8g_rx_pcs_silicon_rev (hssi_8g_rx_pcs_silicon_rev),
        .hssi_8g_rx_pcs_sup_mode (hssi_8g_rx_pcs_sup_mode),
        .hssi_8g_rx_pcs_symbol_swap (hssi_8g_rx_pcs_symbol_swap),
        .hssi_8g_rx_pcs_sync_sm_idle_eios (hssi_8g_rx_pcs_sync_sm_idle_eios),
        .hssi_8g_rx_pcs_test_bus_sel (hssi_8g_rx_pcs_test_bus_sel),
        .hssi_8g_rx_pcs_tx_rx_parallel_loopback (hssi_8g_rx_pcs_tx_rx_parallel_loopback),
        .hssi_8g_rx_pcs_wa_boundary_lock_ctrl (hssi_8g_rx_pcs_wa_boundary_lock_ctrl),
        .hssi_8g_rx_pcs_wa_clk_slip_spacing (hssi_8g_rx_pcs_wa_clk_slip_spacing),
        .hssi_8g_rx_pcs_wa_det_latency_sync_status_beh (hssi_8g_rx_pcs_wa_det_latency_sync_status_beh),
        .hssi_8g_rx_pcs_wa_disp_err_flag (hssi_8g_rx_pcs_wa_disp_err_flag),
        .hssi_8g_rx_pcs_wa_kchar (hssi_8g_rx_pcs_wa_kchar),
        .hssi_8g_rx_pcs_wa_pd (hssi_8g_rx_pcs_wa_pd),
        .hssi_8g_rx_pcs_wa_pd_polarity (hssi_8g_rx_pcs_wa_pd_polarity),
        .hssi_8g_rx_pcs_wa_pld_controlled (hssi_8g_rx_pcs_wa_pld_controlled),
        .hssi_8g_rx_pcs_wa_renumber_data (hssi_8g_rx_pcs_wa_renumber_data),
        .hssi_8g_rx_pcs_wa_rgnumber_data (hssi_8g_rx_pcs_wa_rgnumber_data),
        .hssi_8g_rx_pcs_wa_rknumber_data (hssi_8g_rx_pcs_wa_rknumber_data),
        .hssi_8g_rx_pcs_wa_rosnumber_data (hssi_8g_rx_pcs_wa_rosnumber_data),
        .hssi_8g_rx_pcs_wa_rvnumber_data (hssi_8g_rx_pcs_wa_rvnumber_data),
        .hssi_8g_rx_pcs_wa_sync_sm_ctrl (hssi_8g_rx_pcs_wa_sync_sm_ctrl),
        .hssi_8g_rx_pcs_wait_cnt (hssi_8g_rx_pcs_wait_cnt),
        .hssi_8g_tx_pcs_bit_reversal (hssi_8g_tx_pcs_bit_reversal),
        .hssi_8g_tx_pcs_bonding_dft_en (hssi_8g_tx_pcs_bonding_dft_en),
        .hssi_8g_tx_pcs_bonding_dft_val (hssi_8g_tx_pcs_bonding_dft_val),
        .hssi_8g_tx_pcs_bypass_pipeline_reg (hssi_8g_tx_pcs_bypass_pipeline_reg),
        .hssi_8g_tx_pcs_byte_serializer (hssi_8g_tx_pcs_byte_serializer),
        .hssi_8g_tx_pcs_clock_gate_bs_enc (hssi_8g_tx_pcs_clock_gate_bs_enc),
        .hssi_8g_tx_pcs_clock_gate_dw_fifowr (hssi_8g_tx_pcs_clock_gate_dw_fifowr),
        .hssi_8g_tx_pcs_clock_gate_fiford (hssi_8g_tx_pcs_clock_gate_fiford),
        .hssi_8g_tx_pcs_clock_gate_sw_fifowr (hssi_8g_tx_pcs_clock_gate_sw_fifowr),
        .hssi_8g_tx_pcs_clock_observation_in_pld_core (hssi_8g_tx_pcs_clock_observation_in_pld_core),
        .hssi_8g_tx_pcs_data_selection_8b10b_encoder_input (hssi_8g_tx_pcs_data_selection_8b10b_encoder_input),
        .hssi_8g_tx_pcs_dynamic_clk_switch (hssi_8g_tx_pcs_dynamic_clk_switch),
        .hssi_8g_tx_pcs_eightb_tenb_disp_ctrl (hssi_8g_tx_pcs_eightb_tenb_disp_ctrl),
        .hssi_8g_tx_pcs_eightb_tenb_encoder (hssi_8g_tx_pcs_eightb_tenb_encoder),
        .hssi_8g_tx_pcs_force_echar (hssi_8g_tx_pcs_force_echar),
        .hssi_8g_tx_pcs_force_kchar (hssi_8g_tx_pcs_force_kchar),
        .hssi_8g_tx_pcs_gen3_tx_clk_sel (hssi_8g_tx_pcs_gen3_tx_clk_sel),
        .hssi_8g_tx_pcs_gen3_tx_pipe_clk_sel (hssi_8g_tx_pcs_gen3_tx_pipe_clk_sel),
        .hssi_8g_tx_pcs_hip_mode (hssi_8g_tx_pcs_hip_mode),
        .hssi_8g_tx_pcs_pcs_bypass (hssi_8g_tx_pcs_pcs_bypass),
        .hssi_8g_tx_pcs_phase_comp_rdptr (hssi_8g_tx_pcs_phase_comp_rdptr),
        .hssi_8g_tx_pcs_phase_compensation_fifo (hssi_8g_tx_pcs_phase_compensation_fifo),
        .hssi_8g_tx_pcs_phfifo_write_clk_sel (hssi_8g_tx_pcs_phfifo_write_clk_sel),
        .hssi_8g_tx_pcs_pma_dw (hssi_8g_tx_pcs_pma_dw),
        .hssi_8g_tx_pcs_prot_mode (hssi_8g_tx_pcs_prot_mode),
        .hssi_8g_tx_pcs_refclk_b_clk_sel (hssi_8g_tx_pcs_refclk_b_clk_sel),
        .hssi_8g_tx_pcs_revloop_back_rm (hssi_8g_tx_pcs_revloop_back_rm),
        .hssi_8g_tx_pcs_silicon_rev (hssi_8g_tx_pcs_silicon_rev),
        .hssi_8g_tx_pcs_sup_mode (hssi_8g_tx_pcs_sup_mode),
        .hssi_8g_tx_pcs_symbol_swap (hssi_8g_tx_pcs_symbol_swap),
        .hssi_8g_tx_pcs_tx_bitslip (hssi_8g_tx_pcs_tx_bitslip),
        .hssi_8g_tx_pcs_tx_compliance_controlled_disparity (hssi_8g_tx_pcs_tx_compliance_controlled_disparity),
        .hssi_8g_tx_pcs_tx_fast_pld_reg (hssi_8g_tx_pcs_tx_fast_pld_reg),
        .hssi_8g_tx_pcs_txclk_freerun (hssi_8g_tx_pcs_txclk_freerun),
        .hssi_8g_tx_pcs_txpcs_urst (hssi_8g_tx_pcs_txpcs_urst),
        .hssi_10g_rx_pcs_advanced_user_mode (hssi_10g_rx_pcs_advanced_user_mode),
        .hssi_10g_rx_pcs_align_del (hssi_10g_rx_pcs_align_del),
        .hssi_10g_rx_pcs_ber_bit_err_total_cnt (hssi_10g_rx_pcs_ber_bit_err_total_cnt),
        .hssi_10g_rx_pcs_ber_clken (hssi_10g_rx_pcs_ber_clken),
        .hssi_10g_rx_pcs_ber_xus_timer_window (hssi_10g_rx_pcs_ber_xus_timer_window),
        .hssi_10g_rx_pcs_bitslip_mode (hssi_10g_rx_pcs_bitslip_mode),
        .hssi_10g_rx_pcs_blksync_bitslip_type (hssi_10g_rx_pcs_blksync_bitslip_type),
        .hssi_10g_rx_pcs_blksync_bitslip_wait_cnt (hssi_10g_rx_pcs_blksync_bitslip_wait_cnt),
        .hssi_10g_rx_pcs_blksync_bitslip_wait_type (hssi_10g_rx_pcs_blksync_bitslip_wait_type),
        .hssi_10g_rx_pcs_blksync_bypass (hssi_10g_rx_pcs_blksync_bypass),
        .hssi_10g_rx_pcs_blksync_clken (hssi_10g_rx_pcs_blksync_clken),
        .hssi_10g_rx_pcs_blksync_enum_invalid_sh_cnt (hssi_10g_rx_pcs_blksync_enum_invalid_sh_cnt),
        .hssi_10g_rx_pcs_blksync_knum_sh_cnt_postlock (hssi_10g_rx_pcs_blksync_knum_sh_cnt_postlock),
        .hssi_10g_rx_pcs_blksync_knum_sh_cnt_prelock (hssi_10g_rx_pcs_blksync_knum_sh_cnt_prelock),
        .hssi_10g_rx_pcs_blksync_pipeln (hssi_10g_rx_pcs_blksync_pipeln),
        .hssi_10g_rx_pcs_clr_errblk_cnt_en (hssi_10g_rx_pcs_clr_errblk_cnt_en),
        .hssi_10g_rx_pcs_control_del (hssi_10g_rx_pcs_control_del),
        .hssi_10g_rx_pcs_crcchk_bypass (hssi_10g_rx_pcs_crcchk_bypass),
        .hssi_10g_rx_pcs_crcchk_clken (hssi_10g_rx_pcs_crcchk_clken),
        .hssi_10g_rx_pcs_crcchk_inv (hssi_10g_rx_pcs_crcchk_inv),
        .hssi_10g_rx_pcs_crcchk_pipeln (hssi_10g_rx_pcs_crcchk_pipeln),
        .hssi_10g_rx_pcs_crcflag_pipeln (hssi_10g_rx_pcs_crcflag_pipeln),
        .hssi_10g_rx_pcs_ctrl_bit_reverse (hssi_10g_rx_pcs_ctrl_bit_reverse),
        .hssi_10g_rx_pcs_data_bit_reverse (hssi_10g_rx_pcs_data_bit_reverse),
        .hssi_10g_rx_pcs_dec64b66b_clken (hssi_10g_rx_pcs_dec64b66b_clken),
        .hssi_10g_rx_pcs_dec_64b66b_rxsm_bypass (hssi_10g_rx_pcs_dec_64b66b_rxsm_bypass),
        .hssi_10g_rx_pcs_descrm_bypass (hssi_10g_rx_pcs_descrm_bypass),
        .hssi_10g_rx_pcs_descrm_clken (hssi_10g_rx_pcs_descrm_clken),
        .hssi_10g_rx_pcs_descrm_mode (hssi_10g_rx_pcs_descrm_mode),
        .hssi_10g_rx_pcs_descrm_pipeln (hssi_10g_rx_pcs_descrm_pipeln),
        .hssi_10g_rx_pcs_dft_clk_out_sel (hssi_10g_rx_pcs_dft_clk_out_sel),
        .hssi_10g_rx_pcs_dis_signal_ok (hssi_10g_rx_pcs_dis_signal_ok),
        .hssi_10g_rx_pcs_dispchk_bypass (hssi_10g_rx_pcs_dispchk_bypass),
        .hssi_10g_rx_pcs_empty_flag_type (hssi_10g_rx_pcs_empty_flag_type),
        .hssi_10g_rx_pcs_fast_path (hssi_10g_rx_pcs_fast_path),
        .hssi_10g_rx_pcs_fec_clken (hssi_10g_rx_pcs_fec_clken),
        .hssi_10g_rx_pcs_fec_enable (hssi_10g_rx_pcs_fec_enable),
        .hssi_10g_rx_pcs_fifo_double_read (hssi_10g_rx_pcs_fifo_double_read),
        .hssi_10g_rx_pcs_fifo_stop_rd (hssi_10g_rx_pcs_fifo_stop_rd),
        .hssi_10g_rx_pcs_fifo_stop_wr (hssi_10g_rx_pcs_fifo_stop_wr),
        .hssi_10g_rx_pcs_force_align (hssi_10g_rx_pcs_force_align),
        .hssi_10g_rx_pcs_frmsync_bypass (hssi_10g_rx_pcs_frmsync_bypass),
        .hssi_10g_rx_pcs_frmsync_clken (hssi_10g_rx_pcs_frmsync_clken),
        .hssi_10g_rx_pcs_frmsync_enum_scrm (hssi_10g_rx_pcs_frmsync_enum_scrm),
        .hssi_10g_rx_pcs_frmsync_enum_sync (hssi_10g_rx_pcs_frmsync_enum_sync),
        .hssi_10g_rx_pcs_frmsync_flag_type (hssi_10g_rx_pcs_frmsync_flag_type),
        .hssi_10g_rx_pcs_frmsync_knum_sync (hssi_10g_rx_pcs_frmsync_knum_sync),
        .hssi_10g_rx_pcs_frmsync_mfrm_length (hssi_10g_rx_pcs_frmsync_mfrm_length),
        .hssi_10g_rx_pcs_frmsync_pipeln (hssi_10g_rx_pcs_frmsync_pipeln),
        .hssi_10g_rx_pcs_full_flag_type (hssi_10g_rx_pcs_full_flag_type),
        .hssi_10g_rx_pcs_gb_rx_idwidth (hssi_10g_rx_pcs_gb_rx_idwidth),
        .hssi_10g_rx_pcs_gb_rx_odwidth (hssi_10g_rx_pcs_gb_rx_odwidth),
        .hssi_10g_rx_pcs_gbexp_clken (hssi_10g_rx_pcs_gbexp_clken),
        .hssi_10g_rx_pcs_low_latency_en (hssi_10g_rx_pcs_low_latency_en),
        .hssi_10g_rx_pcs_lpbk_mode (hssi_10g_rx_pcs_lpbk_mode),
        .hssi_10g_rx_pcs_master_clk_sel (hssi_10g_rx_pcs_master_clk_sel),
        .hssi_10g_rx_pcs_pempty_flag_type (hssi_10g_rx_pcs_pempty_flag_type),
        .hssi_10g_rx_pcs_pfull_flag_type (hssi_10g_rx_pcs_pfull_flag_type),
        .hssi_10g_rx_pcs_phcomp_rd_del (hssi_10g_rx_pcs_phcomp_rd_del),
        .hssi_10g_rx_pcs_pld_if_type (hssi_10g_rx_pcs_pld_if_type),
        .hssi_10g_rx_pcs_prot_mode (hssi_10g_rx_pcs_prot_mode),
        .hssi_10g_rx_pcs_rand_clken (hssi_10g_rx_pcs_rand_clken),
        .hssi_10g_rx_pcs_rd_clk_sel (hssi_10g_rx_pcs_rd_clk_sel),
        .hssi_10g_rx_pcs_rdfifo_clken (hssi_10g_rx_pcs_rdfifo_clken),
        .hssi_10g_rx_pcs_rx_fifo_write_ctrl (hssi_10g_rx_pcs_rx_fifo_write_ctrl),
        .hssi_10g_rx_pcs_rx_scrm_width (hssi_10g_rx_pcs_rx_scrm_width),
        .hssi_10g_rx_pcs_rx_sh_location (hssi_10g_rx_pcs_rx_sh_location),
        .hssi_10g_rx_pcs_rx_signal_ok_sel (hssi_10g_rx_pcs_rx_signal_ok_sel),
        .hssi_10g_rx_pcs_rx_sm_bypass (hssi_10g_rx_pcs_rx_sm_bypass),
        .hssi_10g_rx_pcs_rx_sm_hiber (hssi_10g_rx_pcs_rx_sm_hiber),
        .hssi_10g_rx_pcs_rx_sm_pipeln (hssi_10g_rx_pcs_rx_sm_pipeln),
        .hssi_10g_rx_pcs_rx_testbus_sel (hssi_10g_rx_pcs_rx_testbus_sel),
        .hssi_10g_rx_pcs_rx_true_b2b (hssi_10g_rx_pcs_rx_true_b2b),
        .hssi_10g_rx_pcs_rxfifo_empty (hssi_10g_rx_pcs_rxfifo_empty),
        .hssi_10g_rx_pcs_rxfifo_full (hssi_10g_rx_pcs_rxfifo_full),
        .hssi_10g_rx_pcs_rxfifo_mode (hssi_10g_rx_pcs_rxfifo_mode),
        .hssi_10g_rx_pcs_rxfifo_pempty (hssi_10g_rx_pcs_rxfifo_pempty),
        .hssi_10g_rx_pcs_rxfifo_pfull (hssi_10g_rx_pcs_rxfifo_pfull),
        .hssi_10g_rx_pcs_silicon_rev (hssi_10g_rx_pcs_silicon_rev),
        .hssi_10g_rx_pcs_stretch_num_stages (hssi_10g_rx_pcs_stretch_num_stages),
        .hssi_10g_rx_pcs_sup_mode (hssi_10g_rx_pcs_sup_mode),
        .hssi_10g_rx_pcs_test_mode (hssi_10g_rx_pcs_test_mode),
        .hssi_10g_rx_pcs_wrfifo_clken (hssi_10g_rx_pcs_wrfifo_clken),
        .hssi_10g_tx_pcs_advanced_user_mode (hssi_10g_tx_pcs_advanced_user_mode),
        .hssi_10g_tx_pcs_bitslip_en (hssi_10g_tx_pcs_bitslip_en),
        .hssi_10g_tx_pcs_bonding_dft_en (hssi_10g_tx_pcs_bonding_dft_en),
        .hssi_10g_tx_pcs_bonding_dft_val (hssi_10g_tx_pcs_bonding_dft_val),
        .hssi_10g_tx_pcs_crcgen_bypass (hssi_10g_tx_pcs_crcgen_bypass),
        .hssi_10g_tx_pcs_crcgen_clken (hssi_10g_tx_pcs_crcgen_clken),
        .hssi_10g_tx_pcs_crcgen_err (hssi_10g_tx_pcs_crcgen_err),
        .hssi_10g_tx_pcs_crcgen_inv (hssi_10g_tx_pcs_crcgen_inv),
        .hssi_10g_tx_pcs_ctrl_bit_reverse (hssi_10g_tx_pcs_ctrl_bit_reverse),
        .hssi_10g_tx_pcs_data_bit_reverse (hssi_10g_tx_pcs_data_bit_reverse),
        .hssi_10g_tx_pcs_dft_clk_out_sel (hssi_10g_tx_pcs_dft_clk_out_sel),
        .hssi_10g_tx_pcs_dispgen_bypass (hssi_10g_tx_pcs_dispgen_bypass),
        .hssi_10g_tx_pcs_dispgen_clken (hssi_10g_tx_pcs_dispgen_clken),
        .hssi_10g_tx_pcs_dispgen_err (hssi_10g_tx_pcs_dispgen_err),
        .hssi_10g_tx_pcs_dispgen_pipeln (hssi_10g_tx_pcs_dispgen_pipeln),
        .hssi_10g_tx_pcs_distdwn_bypass_pipeln (hssi_10g_tx_pcs_distdwn_bypass_pipeln),
        .hssi_10g_tx_pcs_distup_bypass_pipeln (hssi_10g_tx_pcs_distup_bypass_pipeln),
        .hssi_10g_tx_pcs_dv_bond (hssi_10g_tx_pcs_dv_bond),
        .hssi_10g_tx_pcs_empty_flag_type (hssi_10g_tx_pcs_empty_flag_type),
        .hssi_10g_tx_pcs_enc64b66b_txsm_clken (hssi_10g_tx_pcs_enc64b66b_txsm_clken),
        .hssi_10g_tx_pcs_enc_64b66b_txsm_bypass (hssi_10g_tx_pcs_enc_64b66b_txsm_bypass),
        .hssi_10g_tx_pcs_fastpath (hssi_10g_tx_pcs_fastpath),
        .hssi_10g_tx_pcs_fec_clken (hssi_10g_tx_pcs_fec_clken),
        .hssi_10g_tx_pcs_fec_enable (hssi_10g_tx_pcs_fec_enable),
        .hssi_10g_tx_pcs_fifo_double_write (hssi_10g_tx_pcs_fifo_double_write),
        .hssi_10g_tx_pcs_fifo_reg_fast (hssi_10g_tx_pcs_fifo_reg_fast),
        .hssi_10g_tx_pcs_fifo_stop_rd (hssi_10g_tx_pcs_fifo_stop_rd),
        .hssi_10g_tx_pcs_fifo_stop_wr (hssi_10g_tx_pcs_fifo_stop_wr),
        .hssi_10g_tx_pcs_frmgen_burst (hssi_10g_tx_pcs_frmgen_burst),
        .hssi_10g_tx_pcs_frmgen_bypass (hssi_10g_tx_pcs_frmgen_bypass),
        .hssi_10g_tx_pcs_frmgen_clken (hssi_10g_tx_pcs_frmgen_clken),
        .hssi_10g_tx_pcs_frmgen_mfrm_length (hssi_10g_tx_pcs_frmgen_mfrm_length),
        .hssi_10g_tx_pcs_frmgen_pipeln (hssi_10g_tx_pcs_frmgen_pipeln),
        .hssi_10g_tx_pcs_frmgen_pyld_ins (hssi_10g_tx_pcs_frmgen_pyld_ins),
        .hssi_10g_tx_pcs_frmgen_wordslip (hssi_10g_tx_pcs_frmgen_wordslip),
        .hssi_10g_tx_pcs_full_flag_type (hssi_10g_tx_pcs_full_flag_type),
        .hssi_10g_tx_pcs_gb_pipeln_bypass (hssi_10g_tx_pcs_gb_pipeln_bypass),
        .hssi_10g_tx_pcs_gb_tx_idwidth (hssi_10g_tx_pcs_gb_tx_idwidth),
        .hssi_10g_tx_pcs_gb_tx_odwidth (hssi_10g_tx_pcs_gb_tx_odwidth),
        .hssi_10g_tx_pcs_gbred_clken (hssi_10g_tx_pcs_gbred_clken),
        .hssi_10g_tx_pcs_indv (hssi_10g_tx_pcs_indv),
        .hssi_10g_tx_pcs_low_latency_en (hssi_10g_tx_pcs_low_latency_en),
        .hssi_10g_tx_pcs_master_clk_sel (hssi_10g_tx_pcs_master_clk_sel),
        .hssi_10g_tx_pcs_pempty_flag_type (hssi_10g_tx_pcs_pempty_flag_type),
        .hssi_10g_tx_pcs_pfull_flag_type (hssi_10g_tx_pcs_pfull_flag_type),
        .hssi_10g_tx_pcs_phcomp_rd_del (hssi_10g_tx_pcs_phcomp_rd_del),
        .hssi_10g_tx_pcs_pld_if_type (hssi_10g_tx_pcs_pld_if_type),
        .hssi_10g_tx_pcs_prot_mode (hssi_10g_tx_pcs_prot_mode),
        .hssi_10g_tx_pcs_pseudo_random (hssi_10g_tx_pcs_pseudo_random),
        .hssi_10g_tx_pcs_random_disp (hssi_10g_tx_pcs_random_disp),
        .hssi_10g_tx_pcs_rdfifo_clken (hssi_10g_tx_pcs_rdfifo_clken),
        .hssi_10g_tx_pcs_scrm_bypass (hssi_10g_tx_pcs_scrm_bypass),
        .hssi_10g_tx_pcs_scrm_clken (hssi_10g_tx_pcs_scrm_clken),
        .hssi_10g_tx_pcs_scrm_mode (hssi_10g_tx_pcs_scrm_mode),
        .hssi_10g_tx_pcs_scrm_pipeln (hssi_10g_tx_pcs_scrm_pipeln),
        .hssi_10g_tx_pcs_sh_err (hssi_10g_tx_pcs_sh_err),
        .hssi_10g_tx_pcs_silicon_rev (hssi_10g_tx_pcs_silicon_rev),
        .hssi_10g_tx_pcs_sop_mark (hssi_10g_tx_pcs_sop_mark),
        .hssi_10g_tx_pcs_stretch_num_stages (hssi_10g_tx_pcs_stretch_num_stages),
        .hssi_10g_tx_pcs_sup_mode (hssi_10g_tx_pcs_sup_mode),
        .hssi_10g_tx_pcs_test_mode (hssi_10g_tx_pcs_test_mode),
        .hssi_10g_tx_pcs_tx_scrm_err (hssi_10g_tx_pcs_tx_scrm_err),
        .hssi_10g_tx_pcs_tx_scrm_width (hssi_10g_tx_pcs_tx_scrm_width),
        .hssi_10g_tx_pcs_tx_sh_location (hssi_10g_tx_pcs_tx_sh_location),
        .hssi_10g_tx_pcs_tx_sm_bypass (hssi_10g_tx_pcs_tx_sm_bypass),
        .hssi_10g_tx_pcs_tx_sm_pipeln (hssi_10g_tx_pcs_tx_sm_pipeln),
        .hssi_10g_tx_pcs_tx_testbus_sel (hssi_10g_tx_pcs_tx_testbus_sel),
        .hssi_10g_tx_pcs_txfifo_empty (hssi_10g_tx_pcs_txfifo_empty),
        .hssi_10g_tx_pcs_txfifo_full (hssi_10g_tx_pcs_txfifo_full),
        .hssi_10g_tx_pcs_txfifo_mode (hssi_10g_tx_pcs_txfifo_mode),
        .hssi_10g_tx_pcs_txfifo_pempty (hssi_10g_tx_pcs_txfifo_pempty),
        .hssi_10g_tx_pcs_txfifo_pfull (hssi_10g_tx_pcs_txfifo_pfull),
        .hssi_10g_tx_pcs_wr_clk_sel (hssi_10g_tx_pcs_wr_clk_sel),
        .hssi_10g_tx_pcs_wrfifo_clken (hssi_10g_tx_pcs_wrfifo_clken),
        .hssi_adapt_rx_adapter_lpbk_mode (hssi_adapt_rx_adapter_lpbk_mode),
        .hssi_adapt_rx_aib_lpbk_mode (hssi_adapt_rx_aib_lpbk_mode),
        .hssi_adapt_rx_align_del (hssi_adapt_rx_align_del),
        .hssi_adapt_rx_asn_bypass_clock_gate (hssi_adapt_rx_asn_bypass_clock_gate),
        .hssi_adapt_rx_asn_bypass_pma_pcie_sw_done (hssi_adapt_rx_asn_bypass_pma_pcie_sw_done),
        .hssi_adapt_rx_asn_wait_for_clock_gate_cnt (hssi_adapt_rx_asn_wait_for_clock_gate_cnt),
        .hssi_adapt_rx_asn_wait_for_dll_reset_cnt (hssi_adapt_rx_asn_wait_for_dll_reset_cnt),
        .hssi_adapt_rx_asn_wait_for_fifo_flush_cnt (hssi_adapt_rx_asn_wait_for_fifo_flush_cnt),
        .hssi_adapt_rx_asn_wait_for_pma_pcie_sw_done_cnt (hssi_adapt_rx_asn_wait_for_pma_pcie_sw_done_cnt),
        .hssi_adapt_rx_async_direct_hip_en (hssi_adapt_rx_async_direct_hip_en),
        .hssi_adapt_rx_bonding_dft_en (hssi_adapt_rx_bonding_dft_en),
        .hssi_adapt_rx_bonding_dft_val (hssi_adapt_rx_bonding_dft_val),
        .hssi_adapt_rx_chnl_bonding (hssi_adapt_rx_chnl_bonding),
        .hssi_adapt_rx_clock_del_measure_enable (hssi_adapt_rx_clock_del_measure_enable),
        .hssi_adapt_rx_control_del (hssi_adapt_rx_control_del),
        .hssi_adapt_rx_datapath_mapping_mode (hssi_adapt_rx_datapath_mapping_mode),
        .hssi_adapt_rx_ds_bypass_pipeln (hssi_adapt_rx_ds_bypass_pipeln),
        .hssi_adapt_rx_duplex_mode (hssi_adapt_rx_duplex_mode),
        .hssi_adapt_rx_dyn_clk_sw_en (hssi_adapt_rx_dyn_clk_sw_en),
        .hssi_adapt_rx_fifo_double_write (hssi_adapt_rx_fifo_double_write),
        .hssi_adapt_rx_fifo_mode (hssi_adapt_rx_fifo_mode),
        .hssi_adapt_rx_fifo_rd_clk_scg_en (hssi_adapt_rx_fifo_rd_clk_scg_en),
        .hssi_adapt_rx_fifo_rd_clk_sel (hssi_adapt_rx_fifo_rd_clk_sel),
        .hssi_adapt_rx_fifo_stop_rd (hssi_adapt_rx_fifo_stop_rd),
        .hssi_adapt_rx_fifo_stop_wr (hssi_adapt_rx_fifo_stop_wr),
        .hssi_adapt_rx_fifo_width (hssi_adapt_rx_fifo_width),
        .hssi_adapt_rx_fifo_wr_clk_scg_en (hssi_adapt_rx_fifo_wr_clk_scg_en),
        .hssi_adapt_rx_fifo_wr_clk_sel (hssi_adapt_rx_fifo_wr_clk_sel),
        .hssi_adapt_rx_force_align (hssi_adapt_rx_force_align),
        .hssi_adapt_rx_free_run_div_clk (hssi_adapt_rx_free_run_div_clk),
        .hssi_adapt_rx_fsr_pld_8g_sigdet_out_rst_val (hssi_adapt_rx_fsr_pld_8g_sigdet_out_rst_val),
        .hssi_adapt_rx_fsr_pld_10g_rx_crc32_err_rst_val (hssi_adapt_rx_fsr_pld_10g_rx_crc32_err_rst_val),
        .hssi_adapt_rx_fsr_pld_ltd_b_rst_val (hssi_adapt_rx_fsr_pld_ltd_b_rst_val),
        .hssi_adapt_rx_fsr_pld_ltr_rst_val (hssi_adapt_rx_fsr_pld_ltr_rst_val),
        .hssi_adapt_rx_fsr_pld_rx_fifo_align_clr_rst_val (hssi_adapt_rx_fsr_pld_rx_fifo_align_clr_rst_val),
        .hssi_adapt_rx_hd_hssiadapt_aib_hssi_pld_sclk_hz (hssi_adapt_rx_hd_hssiadapt_aib_hssi_pld_sclk_hz),
        .hssi_adapt_rx_hd_hssiadapt_aib_hssi_rx_sr_clk_in_hz (hssi_adapt_rx_hd_hssiadapt_aib_hssi_rx_sr_clk_in_hz),
        .hssi_adapt_rx_hd_hssiadapt_csr_clk_hz (hssi_adapt_rx_hd_hssiadapt_csr_clk_hz),
        .hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_2x_hz (hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_2x_hz),
        .hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_hz (hssi_adapt_rx_hd_hssiadapt_hip_aib_clk_hz),
        .hssi_adapt_rx_hd_hssiadapt_pld_pcs_rx_clk_out_hz (hssi_adapt_rx_hd_hssiadapt_pld_pcs_rx_clk_out_hz),
        .hssi_adapt_rx_hd_hssiadapt_pld_pma_hclk_hz (hssi_adapt_rx_hd_hssiadapt_pld_pma_hclk_hz),
        .hssi_adapt_rx_hd_hssiadapt_pma_aib_rx_clk_hz (hssi_adapt_rx_hd_hssiadapt_pma_aib_rx_clk_hz),
        .hssi_adapt_rx_hd_hssiadapt_speed_grade (hssi_adapt_rx_hd_hssiadapt_speed_grade),
        .hssi_adapt_rx_hip_mode (hssi_adapt_rx_hip_mode),
        .hssi_adapt_rx_hrdrst_dcd_cal_done_bypass (hssi_adapt_rx_hrdrst_dcd_cal_done_bypass),
        .hssi_adapt_rx_hrdrst_rx_osc_clk_scg_en (hssi_adapt_rx_hrdrst_rx_osc_clk_scg_en),
        .hssi_adapt_rx_hrdrst_user_ctl_en (hssi_adapt_rx_hrdrst_user_ctl_en),
        .hssi_adapt_rx_indv (hssi_adapt_rx_indv),
        .hssi_adapt_rx_internal_clk1_sel (hssi_adapt_rx_internal_clk1_sel),
        .hssi_adapt_rx_internal_clk1_sel0 (hssi_adapt_rx_internal_clk1_sel0),
        .hssi_adapt_rx_internal_clk1_sel1 (hssi_adapt_rx_internal_clk1_sel1),
        .hssi_adapt_rx_internal_clk1_sel2 (hssi_adapt_rx_internal_clk1_sel2),
        .hssi_adapt_rx_internal_clk1_sel3 (hssi_adapt_rx_internal_clk1_sel3),
        .hssi_adapt_rx_internal_clk2_sel (hssi_adapt_rx_internal_clk2_sel),
        .hssi_adapt_rx_internal_clk2_sel0 (hssi_adapt_rx_internal_clk2_sel0),
        .hssi_adapt_rx_internal_clk2_sel1 (hssi_adapt_rx_internal_clk2_sel1),
        .hssi_adapt_rx_internal_clk2_sel2 (hssi_adapt_rx_internal_clk2_sel2),
        .hssi_adapt_rx_internal_clk2_sel3 (hssi_adapt_rx_internal_clk2_sel3),
        .hssi_adapt_rx_loopback_mode (hssi_adapt_rx_loopback_mode),
        .hssi_adapt_rx_osc_clk_scg_en (hssi_adapt_rx_osc_clk_scg_en),
        .hssi_adapt_rx_phcomp_rd_del (hssi_adapt_rx_phcomp_rd_del),
        .hssi_adapt_rx_pipe_mode (hssi_adapt_rx_pipe_mode),
        .hssi_adapt_rx_pma_aib_rx_clk_expected_setting (hssi_adapt_rx_pma_aib_rx_clk_expected_setting),
        .hssi_adapt_rx_pma_coreclkin_sel (hssi_adapt_rx_pma_coreclkin_sel),
        .hssi_adapt_rx_pma_hclk_scg_en (hssi_adapt_rx_pma_hclk_scg_en),
        .hssi_adapt_rx_powerdown_mode (hssi_adapt_rx_powerdown_mode),
        .hssi_adapt_rx_rx_10g_krfec_rx_diag_data_status_polling_bypass (hssi_adapt_rx_rx_10g_krfec_rx_diag_data_status_polling_bypass),
        .hssi_adapt_rx_rx_adp_go_b4txeq_en (hssi_adapt_rx_rx_adp_go_b4txeq_en),
        .hssi_adapt_rx_rx_datapath_tb_sel (hssi_adapt_rx_rx_datapath_tb_sel),
        .hssi_adapt_rx_rx_eq_iteration (hssi_adapt_rx_rx_eq_iteration),
        .hssi_adapt_rx_rx_fifo_power_mode (hssi_adapt_rx_rx_fifo_power_mode),
        .hssi_adapt_rx_rx_fifo_read_latency_adjust (hssi_adapt_rx_rx_fifo_read_latency_adjust),
        .hssi_adapt_rx_rx_fifo_write_latency_adjust (hssi_adapt_rx_rx_fifo_write_latency_adjust),
        .hssi_adapt_rx_rx_invalid_no_change (hssi_adapt_rx_rx_invalid_no_change),
        .hssi_adapt_rx_rx_osc_clock_setting (hssi_adapt_rx_rx_osc_clock_setting),
        .hssi_adapt_rx_rx_parity_sel (hssi_adapt_rx_rx_parity_sel),
        .hssi_adapt_rx_rx_pcs_testbus_sel (hssi_adapt_rx_rx_pcs_testbus_sel),
        .hssi_adapt_rx_rx_pcspma_testbus_sel (hssi_adapt_rx_rx_pcspma_testbus_sel),
        .hssi_adapt_rx_rx_pld_8g_a1a2_k1k2_flag_polling_bypass (hssi_adapt_rx_rx_pld_8g_a1a2_k1k2_flag_polling_bypass),
        .hssi_adapt_rx_rx_pld_8g_wa_boundary_polling_bypass (hssi_adapt_rx_rx_pld_8g_wa_boundary_polling_bypass),
        .hssi_adapt_rx_rx_pld_pma_pcie_sw_done_polling_bypass (hssi_adapt_rx_rx_pld_pma_pcie_sw_done_polling_bypass),
        .hssi_adapt_rx_rx_pld_pma_reser_in_polling_bypass (hssi_adapt_rx_rx_pld_pma_reser_in_polling_bypass),
        .hssi_adapt_rx_rx_pld_pma_testbus_polling_bypass (hssi_adapt_rx_rx_pld_pma_testbus_polling_bypass),
        .hssi_adapt_rx_rx_pld_test_data_polling_bypass (hssi_adapt_rx_rx_pld_test_data_polling_bypass),
        .hssi_adapt_rx_rx_pma_rstn_cycles (hssi_adapt_rx_rx_pma_rstn_cycles),
        .hssi_adapt_rx_rx_pma_rstn_en (hssi_adapt_rx_rx_pma_rstn_en),
        .hssi_adapt_rx_rx_post_cursor_en (hssi_adapt_rx_rx_post_cursor_en),
        .hssi_adapt_rx_rx_pre_cursor_en (hssi_adapt_rx_rx_pre_cursor_en),
        .hssi_adapt_rx_rx_rmfflag_stretch_enable (hssi_adapt_rx_rx_rmfflag_stretch_enable),
        .hssi_adapt_rx_rx_rmfflag_stretch_num_stages (hssi_adapt_rx_rx_rmfflag_stretch_num_stages),
        .hssi_adapt_rx_rx_rxeq_en (hssi_adapt_rx_rx_rxeq_en),
        .hssi_adapt_rx_rx_txeq_en (hssi_adapt_rx_rx_txeq_en),
        .hssi_adapt_rx_rx_txeq_time (hssi_adapt_rx_rx_txeq_time),
        .hssi_adapt_rx_rx_use_rxvalid_for_rxeq (hssi_adapt_rx_rx_use_rxvalid_for_rxeq),
        .hssi_adapt_rx_rx_usertest_sel (hssi_adapt_rx_rx_usertest_sel),
        .hssi_adapt_rx_rxfifo_empty (hssi_adapt_rx_rxfifo_empty),
        .hssi_adapt_rx_rxfifo_full (hssi_adapt_rx_rxfifo_full),
        .hssi_adapt_rx_rxfifo_mode (hssi_adapt_rx_rxfifo_mode),
        .hssi_adapt_rx_rxfifo_pempty (hssi_adapt_rx_rxfifo_pempty),
        .hssi_adapt_rx_rxfifo_pfull (hssi_adapt_rx_rxfifo_pfull),
        .hssi_adapt_rx_rxfiford_post_ct_sel (hssi_adapt_rx_rxfiford_post_ct_sel),
        .hssi_adapt_rx_rxfiford_to_aib_sel (hssi_adapt_rx_rxfiford_to_aib_sel),
        .hssi_adapt_rx_rxfifowr_post_ct_sel (hssi_adapt_rx_rxfifowr_post_ct_sel),
        .hssi_adapt_rx_rxfifowr_pre_ct_sel (hssi_adapt_rx_rxfifowr_pre_ct_sel),
        .hssi_adapt_rx_silicon_rev (hssi_adapt_rx_silicon_rev),
        .hssi_adapt_rx_stretch_num_stages (hssi_adapt_rx_stretch_num_stages),
        .hssi_adapt_rx_sup_mode (hssi_adapt_rx_sup_mode),
        .hssi_adapt_rx_txeq_clk_scg_en (hssi_adapt_rx_txeq_clk_scg_en),
        .hssi_adapt_rx_txeq_clk_sel (hssi_adapt_rx_txeq_clk_sel),
        .hssi_adapt_rx_txeq_mode (hssi_adapt_rx_txeq_mode),
        .hssi_adapt_rx_txeq_rst_sel (hssi_adapt_rx_txeq_rst_sel),
        .hssi_adapt_rx_txfiford_post_ct_sel (hssi_adapt_rx_txfiford_post_ct_sel),
        .hssi_adapt_rx_txfiford_pre_ct_sel (hssi_adapt_rx_txfiford_pre_ct_sel),
        .hssi_adapt_rx_txfifowr_from_aib_sel (hssi_adapt_rx_txfifowr_from_aib_sel),
        .hssi_adapt_rx_txfifowr_post_ct_sel (hssi_adapt_rx_txfifowr_post_ct_sel),
        .hssi_adapt_rx_us_bypass_pipeln (hssi_adapt_rx_us_bypass_pipeln),
        .hssi_adapt_rx_word_align_enable (hssi_adapt_rx_word_align_enable),
        .hssi_adapt_rx_word_mark (hssi_adapt_rx_word_mark),
        .hssi_adapt_tx_aib_clk_sel (hssi_adapt_tx_aib_clk_sel),
        .hssi_adapt_tx_bonding_dft_en (hssi_adapt_tx_bonding_dft_en),
        .hssi_adapt_tx_bonding_dft_val (hssi_adapt_tx_bonding_dft_val),
        .hssi_adapt_tx_chnl_bonding (hssi_adapt_tx_chnl_bonding),
        .hssi_adapt_tx_datapath_mapping_mode (hssi_adapt_tx_datapath_mapping_mode),
        .hssi_adapt_tx_ds_bypass_pipeln (hssi_adapt_tx_ds_bypass_pipeln),
        .hssi_adapt_tx_duplex_mode (hssi_adapt_tx_duplex_mode),
        .hssi_adapt_tx_dv_gating (hssi_adapt_tx_dv_gating),
        .hssi_adapt_tx_dyn_clk_sw_en (hssi_adapt_tx_dyn_clk_sw_en),
        .hssi_adapt_tx_fifo_double_read (hssi_adapt_tx_fifo_double_read),
        .hssi_adapt_tx_fifo_mode (hssi_adapt_tx_fifo_mode),
        .hssi_adapt_tx_fifo_rd_clk_scg_en (hssi_adapt_tx_fifo_rd_clk_scg_en),
        .hssi_adapt_tx_fifo_rd_clk_sel (hssi_adapt_tx_fifo_rd_clk_sel),
        .hssi_adapt_tx_fifo_ready_bypass (hssi_adapt_tx_fifo_ready_bypass),
        .hssi_adapt_tx_fifo_stop_rd (hssi_adapt_tx_fifo_stop_rd),
        .hssi_adapt_tx_fifo_stop_wr (hssi_adapt_tx_fifo_stop_wr),
        .hssi_adapt_tx_fifo_width (hssi_adapt_tx_fifo_width),
        .hssi_adapt_tx_fifo_wr_clk_scg_en (hssi_adapt_tx_fifo_wr_clk_scg_en),
        .hssi_adapt_tx_free_run_div_clk (hssi_adapt_tx_free_run_div_clk),
        .hssi_adapt_tx_fsr_hip_fsr_in_bit0_rst_val (hssi_adapt_tx_fsr_hip_fsr_in_bit0_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_in_bit1_rst_val (hssi_adapt_tx_fsr_hip_fsr_in_bit1_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_in_bit2_rst_val (hssi_adapt_tx_fsr_hip_fsr_in_bit2_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_in_bit3_rst_val (hssi_adapt_tx_fsr_hip_fsr_in_bit3_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_out_bit0_rst_val (hssi_adapt_tx_fsr_hip_fsr_out_bit0_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_out_bit1_rst_val (hssi_adapt_tx_fsr_hip_fsr_out_bit1_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_out_bit2_rst_val (hssi_adapt_tx_fsr_hip_fsr_out_bit2_rst_val),
        .hssi_adapt_tx_fsr_hip_fsr_out_bit3_rst_val (hssi_adapt_tx_fsr_hip_fsr_out_bit3_rst_val),
        .hssi_adapt_tx_fsr_mask_tx_pll_rst_val (hssi_adapt_tx_fsr_mask_tx_pll_rst_val),
        .hssi_adapt_tx_fsr_pld_txelecidle_rst_val (hssi_adapt_tx_fsr_pld_txelecidle_rst_val),
        .hssi_adapt_tx_hd_hssiadapt_aib_hssi_pld_sclk_hz (hssi_adapt_tx_hd_hssiadapt_aib_hssi_pld_sclk_hz),
        .hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_sr_clk_in_hz (hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_sr_clk_in_hz),
        .hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_transfer_clk_hz (hssi_adapt_tx_hd_hssiadapt_aib_hssi_tx_transfer_clk_hz),
        .hssi_adapt_tx_hd_hssiadapt_csr_clk_hz (hssi_adapt_tx_hd_hssiadapt_csr_clk_hz),
        .hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_2x_hz (hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_2x_hz),
        .hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_hz (hssi_adapt_tx_hd_hssiadapt_hip_aib_clk_hz),
        .hssi_adapt_tx_hd_hssiadapt_hip_aib_txeq_clk_out_hz (hssi_adapt_tx_hd_hssiadapt_hip_aib_txeq_clk_out_hz),
        .hssi_adapt_tx_hd_hssiadapt_pld_pcs_tx_clk_out_hz (hssi_adapt_tx_hd_hssiadapt_pld_pcs_tx_clk_out_hz),
        .hssi_adapt_tx_hd_hssiadapt_pld_pma_hclk_hz (hssi_adapt_tx_hd_hssiadapt_pld_pma_hclk_hz),
        .hssi_adapt_tx_hd_hssiadapt_pma_aib_tx_clk_hz (hssi_adapt_tx_hd_hssiadapt_pma_aib_tx_clk_hz),
        .hssi_adapt_tx_hd_hssiadapt_speed_grade (hssi_adapt_tx_hd_hssiadapt_speed_grade),
        .hssi_adapt_tx_hip_mode (hssi_adapt_tx_hip_mode),
        .hssi_adapt_tx_hip_osc_clk_scg_en (hssi_adapt_tx_hip_osc_clk_scg_en),
        .hssi_adapt_tx_hrdrst_align_bypass (hssi_adapt_tx_hrdrst_align_bypass),
        .hssi_adapt_tx_hrdrst_dcd_cal_done_bypass (hssi_adapt_tx_hrdrst_dcd_cal_done_bypass),
        .hssi_adapt_tx_hrdrst_dll_lock_bypass (hssi_adapt_tx_hrdrst_dll_lock_bypass),
        .hssi_adapt_tx_hrdrst_rx_osc_clk_scg_en (hssi_adapt_tx_hrdrst_rx_osc_clk_scg_en),
        .hssi_adapt_tx_hrdrst_user_ctl_en (hssi_adapt_tx_hrdrst_user_ctl_en),
        .hssi_adapt_tx_indv (hssi_adapt_tx_indv),
        .hssi_adapt_tx_loopback_mode (hssi_adapt_tx_loopback_mode),
        .hssi_adapt_tx_osc_clk_scg_en (hssi_adapt_tx_osc_clk_scg_en),
        .hssi_adapt_tx_phcomp_rd_del (hssi_adapt_tx_phcomp_rd_del),
        .hssi_adapt_tx_pipe_mode (hssi_adapt_tx_pipe_mode),
        .hssi_adapt_tx_pma_aib_tx_clk_expected_setting (hssi_adapt_tx_pma_aib_tx_clk_expected_setting),
        .hssi_adapt_tx_powerdown_mode (hssi_adapt_tx_powerdown_mode),
        .hssi_adapt_tx_presethint_bypass (hssi_adapt_tx_presethint_bypass),
        .hssi_adapt_tx_qpi_sr_enable (hssi_adapt_tx_qpi_sr_enable),
        .hssi_adapt_tx_rxqpi_pullup_rst_val (hssi_adapt_tx_rxqpi_pullup_rst_val),
        .hssi_adapt_tx_silicon_rev (hssi_adapt_tx_silicon_rev),
        .hssi_adapt_tx_stretch_num_stages (hssi_adapt_tx_stretch_num_stages),
        .hssi_adapt_tx_sup_mode (hssi_adapt_tx_sup_mode),
        .hssi_adapt_tx_tx_datapath_tb_sel (hssi_adapt_tx_tx_datapath_tb_sel),
        .hssi_adapt_tx_tx_fastbond_wren (hssi_adapt_tx_tx_fastbond_wren),
        .hssi_adapt_tx_tx_fifo_power_mode (hssi_adapt_tx_tx_fifo_power_mode),
        .hssi_adapt_tx_tx_fifo_read_latency_adjust (hssi_adapt_tx_tx_fifo_read_latency_adjust),
        .hssi_adapt_tx_tx_fifo_write_latency_adjust (hssi_adapt_tx_tx_fifo_write_latency_adjust),
        .hssi_adapt_tx_tx_osc_clock_setting (hssi_adapt_tx_tx_osc_clock_setting),
        .hssi_adapt_tx_tx_qpi_mode_en (hssi_adapt_tx_tx_qpi_mode_en),
        .hssi_adapt_tx_tx_rev_lpbk (hssi_adapt_tx_tx_rev_lpbk),
        .hssi_adapt_tx_tx_usertest_sel (hssi_adapt_tx_tx_usertest_sel),
        .hssi_adapt_tx_txfifo_empty (hssi_adapt_tx_txfifo_empty),
        .hssi_adapt_tx_txfifo_full (hssi_adapt_tx_txfifo_full),
        .hssi_adapt_tx_txfifo_mode (hssi_adapt_tx_txfifo_mode),
        .hssi_adapt_tx_txfifo_pempty (hssi_adapt_tx_txfifo_pempty),
        .hssi_adapt_tx_txfifo_pfull (hssi_adapt_tx_txfifo_pfull),
        .hssi_adapt_tx_txqpi_pulldn_rst_val (hssi_adapt_tx_txqpi_pulldn_rst_val),
        .hssi_adapt_tx_txqpi_pullup_rst_val (hssi_adapt_tx_txqpi_pullup_rst_val),
        .hssi_adapt_tx_word_align (hssi_adapt_tx_word_align),
        .hssi_adapt_tx_word_align_enable (hssi_adapt_tx_word_align_enable),
        .hssi_aibcr_rx_aib_datasel_gr0 (hssi_aibcr_rx_aib_datasel_gr0),
        .hssi_aibcr_rx_aib_datasel_gr1 (hssi_aibcr_rx_aib_datasel_gr1),
        .hssi_aibcr_rx_aib_datasel_gr2 (hssi_aibcr_rx_aib_datasel_gr2),
        .hssi_aibcr_rx_aib_ddrctrl_gr0 (hssi_aibcr_rx_aib_ddrctrl_gr0),
        .hssi_aibcr_rx_aib_ddrctrl_gr1 (hssi_aibcr_rx_aib_ddrctrl_gr1),
        .hssi_aibcr_rx_aib_iinasyncen (hssi_aibcr_rx_aib_iinasyncen),
        .hssi_aibcr_rx_aib_iinclken (hssi_aibcr_rx_aib_iinclken),
        .hssi_aibcr_rx_aib_outctrl_gr0 (hssi_aibcr_rx_aib_outctrl_gr0),
        .hssi_aibcr_rx_aib_outctrl_gr1 (hssi_aibcr_rx_aib_outctrl_gr1),
        .hssi_aibcr_rx_aib_outctrl_gr2 (hssi_aibcr_rx_aib_outctrl_gr2),
        .hssi_aibcr_rx_aib_outctrl_gr3 (hssi_aibcr_rx_aib_outctrl_gr3),
        .hssi_aibcr_rx_aib_outndrv_r12 (hssi_aibcr_rx_aib_outndrv_r12),
        .hssi_aibcr_rx_aib_outndrv_r56 (hssi_aibcr_rx_aib_outndrv_r56),
        .hssi_aibcr_rx_aib_outndrv_r78 (hssi_aibcr_rx_aib_outndrv_r78),
        .hssi_aibcr_rx_aib_outpdrv_r12 (hssi_aibcr_rx_aib_outpdrv_r12),
        .hssi_aibcr_rx_aib_outpdrv_r56 (hssi_aibcr_rx_aib_outpdrv_r56),
        .hssi_aibcr_rx_aib_outpdrv_r78 (hssi_aibcr_rx_aib_outpdrv_r78),
        .hssi_aibcr_rx_aib_red_rx_shiften (hssi_aibcr_rx_aib_red_rx_shiften),
        .hssi_aibcr_rx_aib_rx_clkdiv (hssi_aibcr_rx_aib_rx_clkdiv),
        .hssi_aibcr_rx_aib_rx_dcc_byp (hssi_aibcr_rx_aib_rx_dcc_byp),
        .hssi_aibcr_rx_aib_rx_dcc_byp_iocsr_unused (hssi_aibcr_rx_aib_rx_dcc_byp_iocsr_unused),
        .hssi_aibcr_rx_aib_rx_dcc_cont_cal (hssi_aibcr_rx_aib_rx_dcc_cont_cal),
        .hssi_aibcr_rx_aib_rx_dcc_cont_cal_iocsr_unused (hssi_aibcr_rx_aib_rx_dcc_cont_cal_iocsr_unused),
        .hssi_aibcr_rx_aib_rx_dcc_dft (hssi_aibcr_rx_aib_rx_dcc_dft),
        .hssi_aibcr_rx_aib_rx_dcc_dft_sel (hssi_aibcr_rx_aib_rx_dcc_dft_sel),
        .hssi_aibcr_rx_aib_rx_dcc_dll_entest (hssi_aibcr_rx_aib_rx_dcc_dll_entest),
        .hssi_aibcr_rx_aib_rx_dcc_dy_ctl_static (hssi_aibcr_rx_aib_rx_dcc_dy_ctl_static),
        .hssi_aibcr_rx_aib_rx_dcc_dy_ctlsel (hssi_aibcr_rx_aib_rx_dcc_dy_ctlsel),
        .hssi_aibcr_rx_aib_rx_dcc_en (hssi_aibcr_rx_aib_rx_dcc_en),
        .hssi_aibcr_rx_aib_rx_dcc_en_iocsr_unused (hssi_aibcr_rx_aib_rx_dcc_en_iocsr_unused),
        .hssi_aibcr_rx_aib_rx_dcc_manual_dn (hssi_aibcr_rx_aib_rx_dcc_manual_dn),
        .hssi_aibcr_rx_aib_rx_dcc_manual_up (hssi_aibcr_rx_aib_rx_dcc_manual_up),
        .hssi_aibcr_rx_aib_rx_dcc_rst_prgmnvrt (hssi_aibcr_rx_aib_rx_dcc_rst_prgmnvrt),
        .hssi_aibcr_rx_aib_rx_dcc_st_core_dn_prgmnvrt (hssi_aibcr_rx_aib_rx_dcc_st_core_dn_prgmnvrt),
        .hssi_aibcr_rx_aib_rx_dcc_st_core_up_prgmnvrt (hssi_aibcr_rx_aib_rx_dcc_st_core_up_prgmnvrt),
        .hssi_aibcr_rx_aib_rx_dcc_st_core_updnen (hssi_aibcr_rx_aib_rx_dcc_st_core_updnen),
        .hssi_aibcr_rx_aib_rx_dcc_st_dftmuxsel (hssi_aibcr_rx_aib_rx_dcc_st_dftmuxsel),
        .hssi_aibcr_rx_aib_rx_dcc_st_dly_pst (hssi_aibcr_rx_aib_rx_dcc_st_dly_pst),
        .hssi_aibcr_rx_aib_rx_dcc_st_en (hssi_aibcr_rx_aib_rx_dcc_st_en),
        .hssi_aibcr_rx_aib_rx_dcc_st_lockreq_muxsel (hssi_aibcr_rx_aib_rx_dcc_st_lockreq_muxsel),
        .hssi_aibcr_rx_aib_rx_dcc_st_new_dll (hssi_aibcr_rx_aib_rx_dcc_st_new_dll),
        .hssi_aibcr_rx_aib_rx_dcc_st_new_dll2 (hssi_aibcr_rx_aib_rx_dcc_st_new_dll2),
        .hssi_aibcr_rx_aib_rx_dcc_st_rst (hssi_aibcr_rx_aib_rx_dcc_st_rst),
        .hssi_aibcr_rx_aib_rx_dcc_test_clk_pll_en_n (hssi_aibcr_rx_aib_rx_dcc_test_clk_pll_en_n),
        .hssi_aibcr_rx_aib_rx_halfcode (hssi_aibcr_rx_aib_rx_halfcode),
        .hssi_aibcr_rx_aib_rx_selflock (hssi_aibcr_rx_aib_rx_selflock),
        .hssi_aibcr_rx_dft_hssitestip_dll_dcc_en (hssi_aibcr_rx_dft_hssitestip_dll_dcc_en),
        .hssi_aibcr_rx_op_mode (hssi_aibcr_rx_op_mode),
        .hssi_aibcr_rx_powermode_ac (hssi_aibcr_rx_powermode_ac),
        .hssi_aibcr_rx_powermode_dc (hssi_aibcr_rx_powermode_dc),
        .hssi_aibcr_rx_redundancy_en (hssi_aibcr_rx_redundancy_en),
        .hssi_aibcr_rx_silicon_rev (hssi_aibcr_rx_silicon_rev),
        .hssi_aibcr_rx_sup_mode (hssi_aibcr_rx_sup_mode),
        .hssi_aibcr_tx_aib_datasel_gr0 (hssi_aibcr_tx_aib_datasel_gr0),
        .hssi_aibcr_tx_aib_datasel_gr1 (hssi_aibcr_tx_aib_datasel_gr1),
        .hssi_aibcr_tx_aib_datasel_gr2 (hssi_aibcr_tx_aib_datasel_gr2),
        .hssi_aibcr_tx_aib_dllstr_align_clkdiv (hssi_aibcr_tx_aib_dllstr_align_clkdiv),
        .hssi_aibcr_tx_aib_dllstr_align_dcc_dll_dft_sel (hssi_aibcr_tx_aib_dllstr_align_dcc_dll_dft_sel),
        .hssi_aibcr_tx_aib_dllstr_align_dft_ch_muxsel (hssi_aibcr_tx_aib_dllstr_align_dft_ch_muxsel),
        .hssi_aibcr_tx_aib_dllstr_align_dly_pst (hssi_aibcr_tx_aib_dllstr_align_dly_pst),
        .hssi_aibcr_tx_aib_dllstr_align_dy_ctl_static (hssi_aibcr_tx_aib_dllstr_align_dy_ctl_static),
        .hssi_aibcr_tx_aib_dllstr_align_dy_ctlsel (hssi_aibcr_tx_aib_dllstr_align_dy_ctlsel),
        .hssi_aibcr_tx_aib_dllstr_align_entest (hssi_aibcr_tx_aib_dllstr_align_entest),
        .hssi_aibcr_tx_aib_dllstr_align_halfcode (hssi_aibcr_tx_aib_dllstr_align_halfcode),
        .hssi_aibcr_tx_aib_dllstr_align_selflock (hssi_aibcr_tx_aib_dllstr_align_selflock),
        .hssi_aibcr_tx_aib_dllstr_align_st_core_dn_prgmnvrt (hssi_aibcr_tx_aib_dllstr_align_st_core_dn_prgmnvrt),
        .hssi_aibcr_tx_aib_dllstr_align_st_core_up_prgmnvrt (hssi_aibcr_tx_aib_dllstr_align_st_core_up_prgmnvrt),
        .hssi_aibcr_tx_aib_dllstr_align_st_core_updnen (hssi_aibcr_tx_aib_dllstr_align_st_core_updnen),
        .hssi_aibcr_tx_aib_dllstr_align_st_dftmuxsel (hssi_aibcr_tx_aib_dllstr_align_st_dftmuxsel),
        .hssi_aibcr_tx_aib_dllstr_align_st_en (hssi_aibcr_tx_aib_dllstr_align_st_en),
        .hssi_aibcr_tx_aib_dllstr_align_st_lockreq_muxsel (hssi_aibcr_tx_aib_dllstr_align_st_lockreq_muxsel),
        .hssi_aibcr_tx_aib_dllstr_align_st_new_dll (hssi_aibcr_tx_aib_dllstr_align_st_new_dll),
        .hssi_aibcr_tx_aib_dllstr_align_st_new_dll2 (hssi_aibcr_tx_aib_dllstr_align_st_new_dll2),
        .hssi_aibcr_tx_aib_dllstr_align_st_rst (hssi_aibcr_tx_aib_dllstr_align_st_rst),
        .hssi_aibcr_tx_aib_dllstr_align_st_rst_prgmnvrt (hssi_aibcr_tx_aib_dllstr_align_st_rst_prgmnvrt),
        .hssi_aibcr_tx_aib_dllstr_align_test_clk_pll_en_n (hssi_aibcr_tx_aib_dllstr_align_test_clk_pll_en_n),
        .hssi_aibcr_tx_aib_inctrl_gr0 (hssi_aibcr_tx_aib_inctrl_gr0),
        .hssi_aibcr_tx_aib_inctrl_gr1 (hssi_aibcr_tx_aib_inctrl_gr1),
        .hssi_aibcr_tx_aib_inctrl_gr2 (hssi_aibcr_tx_aib_inctrl_gr2),
        .hssi_aibcr_tx_aib_inctrl_gr3 (hssi_aibcr_tx_aib_inctrl_gr3),
        .hssi_aibcr_tx_aib_outctrl_gr0 (hssi_aibcr_tx_aib_outctrl_gr0),
        .hssi_aibcr_tx_aib_outctrl_gr1 (hssi_aibcr_tx_aib_outctrl_gr1),
        .hssi_aibcr_tx_aib_outctrl_gr2 (hssi_aibcr_tx_aib_outctrl_gr2),
        .hssi_aibcr_tx_aib_outndrv_r12 (hssi_aibcr_tx_aib_outndrv_r12),
        .hssi_aibcr_tx_aib_outndrv_r34 (hssi_aibcr_tx_aib_outndrv_r34),
        .hssi_aibcr_tx_aib_outndrv_r56 (hssi_aibcr_tx_aib_outndrv_r56),
        .hssi_aibcr_tx_aib_outndrv_r78 (hssi_aibcr_tx_aib_outndrv_r78),
        .hssi_aibcr_tx_aib_outpdrv_r12 (hssi_aibcr_tx_aib_outpdrv_r12),
        .hssi_aibcr_tx_aib_outpdrv_r34 (hssi_aibcr_tx_aib_outpdrv_r34),
        .hssi_aibcr_tx_aib_outpdrv_r56 (hssi_aibcr_tx_aib_outpdrv_r56),
        .hssi_aibcr_tx_aib_outpdrv_r78 (hssi_aibcr_tx_aib_outpdrv_r78),
        .hssi_aibcr_tx_aib_red_dirclkn_shiften (hssi_aibcr_tx_aib_red_dirclkn_shiften),
        .hssi_aibcr_tx_aib_red_dirclkp_shiften (hssi_aibcr_tx_aib_red_dirclkp_shiften),
        .hssi_aibcr_tx_aib_red_drx_shiften (hssi_aibcr_tx_aib_red_drx_shiften),
        .hssi_aibcr_tx_aib_red_dtx_shiften (hssi_aibcr_tx_aib_red_dtx_shiften),
        .hssi_aibcr_tx_aib_red_pinp_shiften (hssi_aibcr_tx_aib_red_pinp_shiften),
        .hssi_aibcr_tx_aib_red_rx_shiften (hssi_aibcr_tx_aib_red_rx_shiften),
        .hssi_aibcr_tx_aib_red_tx_shiften (hssi_aibcr_tx_aib_red_tx_shiften),
        .hssi_aibcr_tx_aib_red_txferclkout_shiften (hssi_aibcr_tx_aib_red_txferclkout_shiften),
        .hssi_aibcr_tx_aib_red_txferclkoutn_shiften (hssi_aibcr_tx_aib_red_txferclkoutn_shiften),
        .hssi_aibcr_tx_dfd_dll_dcc_en (hssi_aibcr_tx_dfd_dll_dcc_en),
        .hssi_aibcr_tx_dft_hssitestip_dll_dcc_en (hssi_aibcr_tx_dft_hssitestip_dll_dcc_en),
        .hssi_aibcr_tx_op_mode (hssi_aibcr_tx_op_mode),
        .hssi_aibcr_tx_powermode_ac (hssi_aibcr_tx_powermode_ac),
        .hssi_aibcr_tx_powermode_dc (hssi_aibcr_tx_powermode_dc),
        .hssi_aibcr_tx_redundancy_en (hssi_aibcr_tx_redundancy_en),
        .hssi_aibcr_tx_silicon_rev (hssi_aibcr_tx_silicon_rev),
        .hssi_aibcr_tx_sup_mode (hssi_aibcr_tx_sup_mode),
        .hssi_aibnd_rx_aib_datasel_gr0 (hssi_aibnd_rx_aib_datasel_gr0),
        .hssi_aibnd_rx_aib_datasel_gr1 (hssi_aibnd_rx_aib_datasel_gr1),
        .hssi_aibnd_rx_aib_datasel_gr2 (hssi_aibnd_rx_aib_datasel_gr2),
        .hssi_aibnd_rx_aib_dllstr_align_clkdiv (hssi_aibnd_rx_aib_dllstr_align_clkdiv),
        .hssi_aibnd_rx_aib_dllstr_align_dly_pst (hssi_aibnd_rx_aib_dllstr_align_dly_pst),
        .hssi_aibnd_rx_aib_dllstr_align_dy_ctl_static (hssi_aibnd_rx_aib_dllstr_align_dy_ctl_static),
        .hssi_aibnd_rx_aib_dllstr_align_dy_ctlsel (hssi_aibnd_rx_aib_dllstr_align_dy_ctlsel),
        .hssi_aibnd_rx_aib_dllstr_align_entest (hssi_aibnd_rx_aib_dllstr_align_entest),
        .hssi_aibnd_rx_aib_dllstr_align_halfcode (hssi_aibnd_rx_aib_dllstr_align_halfcode),
        .hssi_aibnd_rx_aib_dllstr_align_selflock (hssi_aibnd_rx_aib_dllstr_align_selflock),
        .hssi_aibnd_rx_aib_dllstr_align_st_core_dn_prgmnvrt (hssi_aibnd_rx_aib_dllstr_align_st_core_dn_prgmnvrt),
        .hssi_aibnd_rx_aib_dllstr_align_st_core_up_prgmnvrt (hssi_aibnd_rx_aib_dllstr_align_st_core_up_prgmnvrt),
        .hssi_aibnd_rx_aib_dllstr_align_st_core_updnen (hssi_aibnd_rx_aib_dllstr_align_st_core_updnen),
        .hssi_aibnd_rx_aib_dllstr_align_st_dftmuxsel (hssi_aibnd_rx_aib_dllstr_align_st_dftmuxsel),
        .hssi_aibnd_rx_aib_dllstr_align_st_en (hssi_aibnd_rx_aib_dllstr_align_st_en),
        .hssi_aibnd_rx_aib_dllstr_align_st_hps_ctrl_en (hssi_aibnd_rx_aib_dllstr_align_st_hps_ctrl_en),
        .hssi_aibnd_rx_aib_dllstr_align_st_lockreq_muxsel (hssi_aibnd_rx_aib_dllstr_align_st_lockreq_muxsel),
        .hssi_aibnd_rx_aib_dllstr_align_st_new_dll (hssi_aibnd_rx_aib_dllstr_align_st_new_dll),
        .hssi_aibnd_rx_aib_dllstr_align_st_rst (hssi_aibnd_rx_aib_dllstr_align_st_rst),
        .hssi_aibnd_rx_aib_dllstr_align_st_rst_prgmnvrt (hssi_aibnd_rx_aib_dllstr_align_st_rst_prgmnvrt),
        .hssi_aibnd_rx_aib_dllstr_align_test_clk_pll_en_n (hssi_aibnd_rx_aib_dllstr_align_test_clk_pll_en_n),
        .hssi_aibnd_rx_aib_inctrl_gr0 (hssi_aibnd_rx_aib_inctrl_gr0),
        .hssi_aibnd_rx_aib_inctrl_gr1 (hssi_aibnd_rx_aib_inctrl_gr1),
        .hssi_aibnd_rx_aib_inctrl_gr2 (hssi_aibnd_rx_aib_inctrl_gr2),
        .hssi_aibnd_rx_aib_inctrl_gr3 (hssi_aibnd_rx_aib_inctrl_gr3),
        .hssi_aibnd_rx_aib_outctrl_gr0 (hssi_aibnd_rx_aib_outctrl_gr0),
        .hssi_aibnd_rx_aib_outctrl_gr1 (hssi_aibnd_rx_aib_outctrl_gr1),
        .hssi_aibnd_rx_aib_outctrl_gr2 (hssi_aibnd_rx_aib_outctrl_gr2),
        .hssi_aibnd_rx_aib_outndrv_r12 (hssi_aibnd_rx_aib_outndrv_r12),
        .hssi_aibnd_rx_aib_outndrv_r34 (hssi_aibnd_rx_aib_outndrv_r34),
        .hssi_aibnd_rx_aib_outndrv_r56 (hssi_aibnd_rx_aib_outndrv_r56),
        .hssi_aibnd_rx_aib_outndrv_r78 (hssi_aibnd_rx_aib_outndrv_r78),
        .hssi_aibnd_rx_aib_outpdrv_r12 (hssi_aibnd_rx_aib_outpdrv_r12),
        .hssi_aibnd_rx_aib_outpdrv_r34 (hssi_aibnd_rx_aib_outpdrv_r34),
        .hssi_aibnd_rx_aib_outpdrv_r56 (hssi_aibnd_rx_aib_outpdrv_r56),
        .hssi_aibnd_rx_aib_outpdrv_r78 (hssi_aibnd_rx_aib_outpdrv_r78),
        .hssi_aibnd_rx_aib_red_shift_en (hssi_aibnd_rx_aib_red_shift_en),
        .hssi_aibnd_rx_dft_hssitestip_dll_dcc_en (hssi_aibnd_rx_dft_hssitestip_dll_dcc_en),
        .hssi_aibnd_rx_op_mode (hssi_aibnd_rx_op_mode),
        .hssi_aibnd_rx_powermode_ac (hssi_aibnd_rx_powermode_ac),
        .hssi_aibnd_rx_powermode_dc (hssi_aibnd_rx_powermode_dc),
        .hssi_aibnd_rx_redundancy_en (hssi_aibnd_rx_redundancy_en),
        .hssi_aibnd_rx_silicon_rev (hssi_aibnd_rx_silicon_rev),
        .hssi_aibnd_rx_sup_mode (hssi_aibnd_rx_sup_mode),
        .hssi_aibnd_tx_aib_datasel_gr0 (hssi_aibnd_tx_aib_datasel_gr0),
        .hssi_aibnd_tx_aib_datasel_gr1 (hssi_aibnd_tx_aib_datasel_gr1),
        .hssi_aibnd_tx_aib_datasel_gr2 (hssi_aibnd_tx_aib_datasel_gr2),
        .hssi_aibnd_tx_aib_datasel_gr3 (hssi_aibnd_tx_aib_datasel_gr3),
        .hssi_aibnd_tx_aib_ddrctrl_gr0 (hssi_aibnd_tx_aib_ddrctrl_gr0),
        .hssi_aibnd_tx_aib_iinasyncen (hssi_aibnd_tx_aib_iinasyncen),
        .hssi_aibnd_tx_aib_iinclken (hssi_aibnd_tx_aib_iinclken),
        .hssi_aibnd_tx_aib_outctrl_gr0 (hssi_aibnd_tx_aib_outctrl_gr0),
        .hssi_aibnd_tx_aib_outctrl_gr1 (hssi_aibnd_tx_aib_outctrl_gr1),
        .hssi_aibnd_tx_aib_outctrl_gr2 (hssi_aibnd_tx_aib_outctrl_gr2),
        .hssi_aibnd_tx_aib_outctrl_gr3 (hssi_aibnd_tx_aib_outctrl_gr3),
        .hssi_aibnd_tx_aib_outndrv_r34 (hssi_aibnd_tx_aib_outndrv_r34),
        .hssi_aibnd_tx_aib_outndrv_r56 (hssi_aibnd_tx_aib_outndrv_r56),
        .hssi_aibnd_tx_aib_outpdrv_r34 (hssi_aibnd_tx_aib_outpdrv_r34),
        .hssi_aibnd_tx_aib_outpdrv_r56 (hssi_aibnd_tx_aib_outpdrv_r56),
        .hssi_aibnd_tx_aib_red_dirclkn_shiften (hssi_aibnd_tx_aib_red_dirclkn_shiften),
        .hssi_aibnd_tx_aib_red_dirclkp_shiften (hssi_aibnd_tx_aib_red_dirclkp_shiften),
        .hssi_aibnd_tx_aib_red_drx_shiften (hssi_aibnd_tx_aib_red_drx_shiften),
        .hssi_aibnd_tx_aib_red_dtx_shiften (hssi_aibnd_tx_aib_red_dtx_shiften),
        .hssi_aibnd_tx_aib_red_pout_shiften (hssi_aibnd_tx_aib_red_pout_shiften),
        .hssi_aibnd_tx_aib_red_rx_shiften (hssi_aibnd_tx_aib_red_rx_shiften),
        .hssi_aibnd_tx_aib_red_tx_shiften (hssi_aibnd_tx_aib_red_tx_shiften),
        .hssi_aibnd_tx_aib_red_txferclkout_shiften (hssi_aibnd_tx_aib_red_txferclkout_shiften),
        .hssi_aibnd_tx_aib_red_txferclkoutn_shiften (hssi_aibnd_tx_aib_red_txferclkoutn_shiften),
        .hssi_aibnd_tx_aib_tx_clkdiv (hssi_aibnd_tx_aib_tx_clkdiv),
        .hssi_aibnd_tx_aib_tx_dcc_byp (hssi_aibnd_tx_aib_tx_dcc_byp),
        .hssi_aibnd_tx_aib_tx_dcc_byp_iocsr_unused (hssi_aibnd_tx_aib_tx_dcc_byp_iocsr_unused),
        .hssi_aibnd_tx_aib_tx_dcc_cont_cal (hssi_aibnd_tx_aib_tx_dcc_cont_cal),
        .hssi_aibnd_tx_aib_tx_dcc_cont_cal_iocsr_unused (hssi_aibnd_tx_aib_tx_dcc_cont_cal_iocsr_unused),
        .hssi_aibnd_tx_aib_tx_dcc_dft (hssi_aibnd_tx_aib_tx_dcc_dft),
        .hssi_aibnd_tx_aib_tx_dcc_dft_sel (hssi_aibnd_tx_aib_tx_dcc_dft_sel),
        .hssi_aibnd_tx_aib_tx_dcc_dll_dft_sel (hssi_aibnd_tx_aib_tx_dcc_dll_dft_sel),
        .hssi_aibnd_tx_aib_tx_dcc_dll_entest (hssi_aibnd_tx_aib_tx_dcc_dll_entest),
        .hssi_aibnd_tx_aib_tx_dcc_dy_ctl_static (hssi_aibnd_tx_aib_tx_dcc_dy_ctl_static),
        .hssi_aibnd_tx_aib_tx_dcc_dy_ctlsel (hssi_aibnd_tx_aib_tx_dcc_dy_ctlsel),
        .hssi_aibnd_tx_aib_tx_dcc_en (hssi_aibnd_tx_aib_tx_dcc_en),
        .hssi_aibnd_tx_aib_tx_dcc_en_iocsr_unused (hssi_aibnd_tx_aib_tx_dcc_en_iocsr_unused),
        .hssi_aibnd_tx_aib_tx_dcc_manual_dn (hssi_aibnd_tx_aib_tx_dcc_manual_dn),
        .hssi_aibnd_tx_aib_tx_dcc_manual_up (hssi_aibnd_tx_aib_tx_dcc_manual_up),
        .hssi_aibnd_tx_aib_tx_dcc_rst_prgmnvrt (hssi_aibnd_tx_aib_tx_dcc_rst_prgmnvrt),
        .hssi_aibnd_tx_aib_tx_dcc_st_core_dn_prgmnvrt (hssi_aibnd_tx_aib_tx_dcc_st_core_dn_prgmnvrt),
        .hssi_aibnd_tx_aib_tx_dcc_st_core_up_prgmnvrt (hssi_aibnd_tx_aib_tx_dcc_st_core_up_prgmnvrt),
        .hssi_aibnd_tx_aib_tx_dcc_st_core_updnen (hssi_aibnd_tx_aib_tx_dcc_st_core_updnen),
        .hssi_aibnd_tx_aib_tx_dcc_st_dftmuxsel (hssi_aibnd_tx_aib_tx_dcc_st_dftmuxsel),
        .hssi_aibnd_tx_aib_tx_dcc_st_dly_pst (hssi_aibnd_tx_aib_tx_dcc_st_dly_pst),
        .hssi_aibnd_tx_aib_tx_dcc_st_en (hssi_aibnd_tx_aib_tx_dcc_st_en),
        .hssi_aibnd_tx_aib_tx_dcc_st_hps_ctrl_en (hssi_aibnd_tx_aib_tx_dcc_st_hps_ctrl_en),
        .hssi_aibnd_tx_aib_tx_dcc_st_lockreq_muxsel (hssi_aibnd_tx_aib_tx_dcc_st_lockreq_muxsel),
        .hssi_aibnd_tx_aib_tx_dcc_st_new_dll (hssi_aibnd_tx_aib_tx_dcc_st_new_dll),
        .hssi_aibnd_tx_aib_tx_dcc_st_rst (hssi_aibnd_tx_aib_tx_dcc_st_rst),
        .hssi_aibnd_tx_aib_tx_dcc_test_clk_pll_en_n (hssi_aibnd_tx_aib_tx_dcc_test_clk_pll_en_n),
        .hssi_aibnd_tx_aib_tx_halfcode (hssi_aibnd_tx_aib_tx_halfcode),
        .hssi_aibnd_tx_aib_tx_selflock (hssi_aibnd_tx_aib_tx_selflock),
        .hssi_aibnd_tx_dfd_dll_dcc_en (hssi_aibnd_tx_dfd_dll_dcc_en),
        .hssi_aibnd_tx_dft_hssitestip_dll_dcc_en (hssi_aibnd_tx_dft_hssitestip_dll_dcc_en),
        .hssi_aibnd_tx_op_mode (hssi_aibnd_tx_op_mode),
        .hssi_aibnd_tx_powermode_ac (hssi_aibnd_tx_powermode_ac),
        .hssi_aibnd_tx_powermode_dc (hssi_aibnd_tx_powermode_dc),
        .hssi_aibnd_tx_redundancy_en (hssi_aibnd_tx_redundancy_en),
        .hssi_aibnd_tx_silicon_rev (hssi_aibnd_tx_silicon_rev),
        .hssi_aibnd_tx_sup_mode (hssi_aibnd_tx_sup_mode),
        .hssi_avmm1_if_calibration_type (hssi_avmm1_if_calibration_type),
        .hssi_avmm1_if_hssiadapt_avmm_osc_clock_setting (hssi_avmm1_if_hssiadapt_avmm_osc_clock_setting),
        .hssi_avmm1_if_hssiadapt_avmm_testbus_sel (hssi_avmm1_if_hssiadapt_avmm_testbus_sel),
        .hssi_avmm1_if_hssiadapt_hip_mode (hssi_avmm1_if_hssiadapt_hip_mode),
        .hssi_avmm1_if_hssiadapt_nfhssi_calibratio_feature_en (hssi_avmm1_if_hssiadapt_nfhssi_calibratio_feature_en),
        .hssi_avmm1_if_hssiadapt_read_blocking_enable (hssi_avmm1_if_hssiadapt_read_blocking_enable),
        .hssi_avmm1_if_hssiadapt_uc_blocking_enable (hssi_avmm1_if_hssiadapt_uc_blocking_enable),
        .hssi_avmm1_if_pcs_arbiter_ctrl (hssi_avmm1_if_pcs_arbiter_ctrl),
        .hssi_avmm1_if_pcs_cal_done (hssi_avmm1_if_pcs_cal_done),
        .hssi_avmm1_if_pcs_cal_reserved (hssi_avmm1_if_pcs_cal_reserved),
        .hssi_avmm1_if_pcs_calibration_feature_en (hssi_avmm1_if_pcs_calibration_feature_en),
        .hssi_avmm1_if_pcs_hip_cal_en (hssi_avmm1_if_pcs_hip_cal_en),
        .hssi_avmm1_if_pldadapt_avmm_osc_clock_setting (hssi_avmm1_if_pldadapt_avmm_osc_clock_setting),
        .hssi_avmm1_if_pldadapt_avmm_testbus_sel (hssi_avmm1_if_pldadapt_avmm_testbus_sel),
        .hssi_avmm1_if_pldadapt_gate_dis (hssi_avmm1_if_pldadapt_gate_dis),
        .hssi_avmm1_if_pldadapt_hip_mode (hssi_avmm1_if_pldadapt_hip_mode),
        .hssi_avmm1_if_pldadapt_nfhssi_calibratio_feature_en (hssi_avmm1_if_pldadapt_nfhssi_calibratio_feature_en),
        .hssi_avmm1_if_pldadapt_read_blocking_enable (hssi_avmm1_if_pldadapt_read_blocking_enable),
        .hssi_avmm1_if_pldadapt_uc_blocking_enable (hssi_avmm1_if_pldadapt_uc_blocking_enable),
        .hssi_avmm1_if_silicon_rev (hssi_avmm1_if_silicon_rev),
        .hssi_common_pcs_pma_interface_asn_clk_enable (hssi_common_pcs_pma_interface_asn_clk_enable),
        .hssi_common_pcs_pma_interface_asn_enable (hssi_common_pcs_pma_interface_asn_enable),
        .hssi_common_pcs_pma_interface_block_sel (hssi_common_pcs_pma_interface_block_sel),
        .hssi_common_pcs_pma_interface_bypass_early_eios (hssi_common_pcs_pma_interface_bypass_early_eios),
        .hssi_common_pcs_pma_interface_bypass_pcie_switch (hssi_common_pcs_pma_interface_bypass_pcie_switch),
        .hssi_common_pcs_pma_interface_bypass_pma_ltr (hssi_common_pcs_pma_interface_bypass_pma_ltr),
//        .hssi_common_pcs_pma_interface_bypass_pma_sw_done (hssi_common_pcs_pma_interface_bypass_pma_sw_done),
        .hssi_common_pcs_pma_interface_bypass_ppm_lock (hssi_common_pcs_pma_interface_bypass_ppm_lock),
        .hssi_common_pcs_pma_interface_bypass_send_syncp_fbkp (hssi_common_pcs_pma_interface_bypass_send_syncp_fbkp),
        .hssi_common_pcs_pma_interface_bypass_txdetectrx (hssi_common_pcs_pma_interface_bypass_txdetectrx),
        .hssi_common_pcs_pma_interface_cdr_control (hssi_common_pcs_pma_interface_cdr_control),
        .hssi_common_pcs_pma_interface_cid_enable (hssi_common_pcs_pma_interface_cid_enable),
        .hssi_common_pcs_pma_interface_data_mask_count (hssi_common_pcs_pma_interface_data_mask_count),
        .hssi_common_pcs_pma_interface_data_mask_count_multi (hssi_common_pcs_pma_interface_data_mask_count_multi),
        .hssi_common_pcs_pma_interface_dft_observation_clock_selection (hssi_common_pcs_pma_interface_dft_observation_clock_selection),
        .hssi_common_pcs_pma_interface_early_eios_counter (hssi_common_pcs_pma_interface_early_eios_counter),
        .hssi_common_pcs_pma_interface_force_freqdet (hssi_common_pcs_pma_interface_force_freqdet),
        .hssi_common_pcs_pma_interface_free_run_clk_enable (hssi_common_pcs_pma_interface_free_run_clk_enable),
        .hssi_common_pcs_pma_interface_ignore_sigdet_g23 (hssi_common_pcs_pma_interface_ignore_sigdet_g23),
        .hssi_common_pcs_pma_interface_pc_en_counter (hssi_common_pcs_pma_interface_pc_en_counter),
        .hssi_common_pcs_pma_interface_pc_rst_counter (hssi_common_pcs_pma_interface_pc_rst_counter),
        .hssi_common_pcs_pma_interface_pcie_hip_mode (hssi_common_pcs_pma_interface_pcie_hip_mode),
        .hssi_common_pcs_pma_interface_ph_fifo_reg_mode (hssi_common_pcs_pma_interface_ph_fifo_reg_mode),
        .hssi_common_pcs_pma_interface_phfifo_flush_wait (hssi_common_pcs_pma_interface_phfifo_flush_wait),
        .hssi_common_pcs_pma_interface_pipe_if_g3pcs (hssi_common_pcs_pma_interface_pipe_if_g3pcs),
        .hssi_common_pcs_pma_interface_pma_done_counter (hssi_common_pcs_pma_interface_pma_done_counter),
        .hssi_common_pcs_pma_interface_pma_if_dft_en (hssi_common_pcs_pma_interface_pma_if_dft_en),
        .hssi_common_pcs_pma_interface_pma_if_dft_val (hssi_common_pcs_pma_interface_pma_if_dft_val),
        .hssi_common_pcs_pma_interface_ppm_cnt_rst (hssi_common_pcs_pma_interface_ppm_cnt_rst),
        .hssi_common_pcs_pma_interface_ppm_deassert_early (hssi_common_pcs_pma_interface_ppm_deassert_early),
        .hssi_common_pcs_pma_interface_ppm_det_buckets (hssi_common_pcs_pma_interface_ppm_det_buckets),
        .hssi_common_pcs_pma_interface_ppm_gen1_2_cnt (hssi_common_pcs_pma_interface_ppm_gen1_2_cnt),
        .hssi_common_pcs_pma_interface_ppm_post_eidle_delay (hssi_common_pcs_pma_interface_ppm_post_eidle_delay),
        .hssi_common_pcs_pma_interface_ppmsel (hssi_common_pcs_pma_interface_ppmsel),
        .hssi_common_pcs_pma_interface_prot_mode (hssi_common_pcs_pma_interface_prot_mode),
        .hssi_common_pcs_pma_interface_rxvalid_mask (hssi_common_pcs_pma_interface_rxvalid_mask),
        .hssi_common_pcs_pma_interface_sigdet_wait_counter (hssi_common_pcs_pma_interface_sigdet_wait_counter),
        .hssi_common_pcs_pma_interface_sigdet_wait_counter_multi (hssi_common_pcs_pma_interface_sigdet_wait_counter_multi),
        .hssi_common_pcs_pma_interface_silicon_rev (hssi_common_pcs_pma_interface_silicon_rev),
        .hssi_common_pcs_pma_interface_sim_mode (hssi_common_pcs_pma_interface_sim_mode),
        .hssi_common_pcs_pma_interface_spd_chg_rst_wait_cnt_en (hssi_common_pcs_pma_interface_spd_chg_rst_wait_cnt_en),
        .hssi_common_pcs_pma_interface_sup_mode (hssi_common_pcs_pma_interface_sup_mode),
        .hssi_common_pcs_pma_interface_testout_sel (hssi_common_pcs_pma_interface_testout_sel),
        .hssi_common_pcs_pma_interface_wait_clk_on_off_timer (hssi_common_pcs_pma_interface_wait_clk_on_off_timer),
        .hssi_common_pcs_pma_interface_wait_pipe_synchronizing (hssi_common_pcs_pma_interface_wait_pipe_synchronizing),
        .hssi_common_pcs_pma_interface_wait_send_syncp_fbkp (hssi_common_pcs_pma_interface_wait_send_syncp_fbkp),
        .hssi_common_pld_pcs_interface_dft_clk_out_en (hssi_common_pld_pcs_interface_dft_clk_out_en),
        .hssi_common_pld_pcs_interface_dft_clk_out_sel (hssi_common_pld_pcs_interface_dft_clk_out_sel),
        .hssi_common_pld_pcs_interface_hrdrstctrl_en (hssi_common_pld_pcs_interface_hrdrstctrl_en),
        .hssi_common_pld_pcs_interface_pcs_testbus_block_sel (hssi_common_pld_pcs_interface_pcs_testbus_block_sel),
        .hssi_common_pld_pcs_interface_silicon_rev (hssi_common_pld_pcs_interface_silicon_rev),
        .hssi_fifo_rx_pcs_double_read_mode (hssi_fifo_rx_pcs_double_read_mode),
        .hssi_fifo_rx_pcs_prot_mode (hssi_fifo_rx_pcs_prot_mode),
        .hssi_fifo_rx_pcs_silicon_rev (hssi_fifo_rx_pcs_silicon_rev),
        .hssi_fifo_tx_pcs_double_write_mode (hssi_fifo_tx_pcs_double_write_mode),
        .hssi_fifo_tx_pcs_prot_mode (hssi_fifo_tx_pcs_prot_mode),
        .hssi_fifo_tx_pcs_silicon_rev (hssi_fifo_tx_pcs_silicon_rev),
        .hssi_gen3_rx_pcs_block_sync (hssi_gen3_rx_pcs_block_sync),
        .hssi_gen3_rx_pcs_block_sync_sm (hssi_gen3_rx_pcs_block_sync_sm),
        .hssi_gen3_rx_pcs_cdr_ctrl_force_unalgn (hssi_gen3_rx_pcs_cdr_ctrl_force_unalgn),
        .hssi_gen3_rx_pcs_lpbk_force (hssi_gen3_rx_pcs_lpbk_force),
        .hssi_gen3_rx_pcs_mode (hssi_gen3_rx_pcs_mode),
        .hssi_gen3_rx_pcs_rate_match_fifo (hssi_gen3_rx_pcs_rate_match_fifo),
        .hssi_gen3_rx_pcs_rate_match_fifo_latency (hssi_gen3_rx_pcs_rate_match_fifo_latency),
        .hssi_gen3_rx_pcs_reverse_lpbk (hssi_gen3_rx_pcs_reverse_lpbk),
        .hssi_gen3_rx_pcs_rx_b4gb_par_lpbk (hssi_gen3_rx_pcs_rx_b4gb_par_lpbk),
        .hssi_gen3_rx_pcs_rx_force_balign (hssi_gen3_rx_pcs_rx_force_balign),
        .hssi_gen3_rx_pcs_rx_ins_del_one_skip (hssi_gen3_rx_pcs_rx_ins_del_one_skip),
        .hssi_gen3_rx_pcs_rx_num_fixed_pat (hssi_gen3_rx_pcs_rx_num_fixed_pat),
        .hssi_gen3_rx_pcs_rx_test_out_sel (hssi_gen3_rx_pcs_rx_test_out_sel),
        .hssi_gen3_rx_pcs_silicon_rev (hssi_gen3_rx_pcs_silicon_rev),
        .hssi_gen3_rx_pcs_sup_mode (hssi_gen3_rx_pcs_sup_mode),
        .hssi_gen3_tx_pcs_mode (hssi_gen3_tx_pcs_mode),
        .hssi_gen3_tx_pcs_reverse_lpbk (hssi_gen3_tx_pcs_reverse_lpbk),
        .hssi_gen3_tx_pcs_silicon_rev (hssi_gen3_tx_pcs_silicon_rev),
        .hssi_gen3_tx_pcs_sup_mode (hssi_gen3_tx_pcs_sup_mode),
        .hssi_gen3_tx_pcs_tx_bitslip (hssi_gen3_tx_pcs_tx_bitslip),
        .hssi_gen3_tx_pcs_tx_gbox_byp (hssi_gen3_tx_pcs_tx_gbox_byp),
        .hssi_krfec_rx_pcs_blksync_cor_en (hssi_krfec_rx_pcs_blksync_cor_en),
        .hssi_krfec_rx_pcs_bypass_gb (hssi_krfec_rx_pcs_bypass_gb),
        .hssi_krfec_rx_pcs_clr_ctrl (hssi_krfec_rx_pcs_clr_ctrl),
        .hssi_krfec_rx_pcs_ctrl_bit_reverse (hssi_krfec_rx_pcs_ctrl_bit_reverse),
        .hssi_krfec_rx_pcs_data_bit_reverse (hssi_krfec_rx_pcs_data_bit_reverse),
        .hssi_krfec_rx_pcs_dv_start (hssi_krfec_rx_pcs_dv_start),
        .hssi_krfec_rx_pcs_err_mark_type (hssi_krfec_rx_pcs_err_mark_type),
        .hssi_krfec_rx_pcs_error_marking_en (hssi_krfec_rx_pcs_error_marking_en),
        .hssi_krfec_rx_pcs_low_latency_en (hssi_krfec_rx_pcs_low_latency_en),
        .hssi_krfec_rx_pcs_lpbk_mode (hssi_krfec_rx_pcs_lpbk_mode),
        .hssi_krfec_rx_pcs_parity_invalid_enum (hssi_krfec_rx_pcs_parity_invalid_enum),
        .hssi_krfec_rx_pcs_parity_valid_num (hssi_krfec_rx_pcs_parity_valid_num),
        .hssi_krfec_rx_pcs_pipeln_blksync (hssi_krfec_rx_pcs_pipeln_blksync),
        .hssi_krfec_rx_pcs_pipeln_descrm (hssi_krfec_rx_pcs_pipeln_descrm),
        .hssi_krfec_rx_pcs_pipeln_errcorrect (hssi_krfec_rx_pcs_pipeln_errcorrect),
        .hssi_krfec_rx_pcs_pipeln_errtrap_ind (hssi_krfec_rx_pcs_pipeln_errtrap_ind),
        .hssi_krfec_rx_pcs_pipeln_errtrap_lfsr (hssi_krfec_rx_pcs_pipeln_errtrap_lfsr),
        .hssi_krfec_rx_pcs_pipeln_errtrap_loc (hssi_krfec_rx_pcs_pipeln_errtrap_loc),
        .hssi_krfec_rx_pcs_pipeln_errtrap_pat (hssi_krfec_rx_pcs_pipeln_errtrap_pat),
        .hssi_krfec_rx_pcs_pipeln_gearbox (hssi_krfec_rx_pcs_pipeln_gearbox),
        .hssi_krfec_rx_pcs_pipeln_syndrm (hssi_krfec_rx_pcs_pipeln_syndrm),
        .hssi_krfec_rx_pcs_pipeln_trans_dec (hssi_krfec_rx_pcs_pipeln_trans_dec),
        .hssi_krfec_rx_pcs_prot_mode (hssi_krfec_rx_pcs_prot_mode),
        .hssi_krfec_rx_pcs_receive_order (hssi_krfec_rx_pcs_receive_order),
        .hssi_krfec_rx_pcs_rx_testbus_sel (hssi_krfec_rx_pcs_rx_testbus_sel),
        .hssi_krfec_rx_pcs_signal_ok_en (hssi_krfec_rx_pcs_signal_ok_en),
        .hssi_krfec_rx_pcs_silicon_rev (hssi_krfec_rx_pcs_silicon_rev),
        .hssi_krfec_rx_pcs_sup_mode (hssi_krfec_rx_pcs_sup_mode),
        .hssi_krfec_tx_pcs_burst_err (hssi_krfec_tx_pcs_burst_err),
        .hssi_krfec_tx_pcs_burst_err_len (hssi_krfec_tx_pcs_burst_err_len),
        .hssi_krfec_tx_pcs_ctrl_bit_reverse (hssi_krfec_tx_pcs_ctrl_bit_reverse),
        .hssi_krfec_tx_pcs_data_bit_reverse (hssi_krfec_tx_pcs_data_bit_reverse),
        .hssi_krfec_tx_pcs_enc_frame_query (hssi_krfec_tx_pcs_enc_frame_query),
        .hssi_krfec_tx_pcs_low_latency_en (hssi_krfec_tx_pcs_low_latency_en),
        .hssi_krfec_tx_pcs_pipeln_encoder (hssi_krfec_tx_pcs_pipeln_encoder),
        .hssi_krfec_tx_pcs_pipeln_scrambler (hssi_krfec_tx_pcs_pipeln_scrambler),
        .hssi_krfec_tx_pcs_prot_mode (hssi_krfec_tx_pcs_prot_mode),
        .hssi_krfec_tx_pcs_silicon_rev (hssi_krfec_tx_pcs_silicon_rev),
        .hssi_krfec_tx_pcs_sup_mode (hssi_krfec_tx_pcs_sup_mode),
        .hssi_krfec_tx_pcs_transcode_err (hssi_krfec_tx_pcs_transcode_err),
        .hssi_krfec_tx_pcs_transmit_order (hssi_krfec_tx_pcs_transmit_order),
        .hssi_krfec_tx_pcs_tx_testbus_sel (hssi_krfec_tx_pcs_tx_testbus_sel),
        .hssi_pipe_gen1_2_elec_idle_delay_val (hssi_pipe_gen1_2_elec_idle_delay_val),
        .hssi_pipe_gen1_2_error_replace_pad (hssi_pipe_gen1_2_error_replace_pad),
        .hssi_pipe_gen1_2_hip_mode (hssi_pipe_gen1_2_hip_mode),
        .hssi_pipe_gen1_2_ind_error_reporting (hssi_pipe_gen1_2_ind_error_reporting),
        .hssi_pipe_gen1_2_phystatus_delay_val (hssi_pipe_gen1_2_phystatus_delay_val),
        .hssi_pipe_gen1_2_phystatus_rst_toggle (hssi_pipe_gen1_2_phystatus_rst_toggle),
        .hssi_pipe_gen1_2_pipe_byte_de_serializer_en (hssi_pipe_gen1_2_pipe_byte_de_serializer_en),
        .hssi_pipe_gen1_2_prot_mode (hssi_pipe_gen1_2_prot_mode),
        .hssi_pipe_gen1_2_rpre_emph_a_val (hssi_pipe_gen1_2_rpre_emph_a_val),
        .hssi_pipe_gen1_2_rpre_emph_b_val (hssi_pipe_gen1_2_rpre_emph_b_val),
        .hssi_pipe_gen1_2_rpre_emph_c_val (hssi_pipe_gen1_2_rpre_emph_c_val),
        .hssi_pipe_gen1_2_rpre_emph_d_val (hssi_pipe_gen1_2_rpre_emph_d_val),
        .hssi_pipe_gen1_2_rpre_emph_e_val (hssi_pipe_gen1_2_rpre_emph_e_val),
        .hssi_pipe_gen1_2_rvod_sel_a_val (hssi_pipe_gen1_2_rvod_sel_a_val),
        .hssi_pipe_gen1_2_rvod_sel_b_val (hssi_pipe_gen1_2_rvod_sel_b_val),
        .hssi_pipe_gen1_2_rvod_sel_c_val (hssi_pipe_gen1_2_rvod_sel_c_val),
        .hssi_pipe_gen1_2_rvod_sel_d_val (hssi_pipe_gen1_2_rvod_sel_d_val),
        .hssi_pipe_gen1_2_rvod_sel_e_val (hssi_pipe_gen1_2_rvod_sel_e_val),
        .hssi_pipe_gen1_2_rx_pipe_enable (hssi_pipe_gen1_2_rx_pipe_enable),
        .hssi_pipe_gen1_2_rxdetect_bypass (hssi_pipe_gen1_2_rxdetect_bypass),
        .hssi_pipe_gen1_2_silicon_rev (hssi_pipe_gen1_2_silicon_rev),
        .hssi_pipe_gen1_2_sup_mode (hssi_pipe_gen1_2_sup_mode),
        .hssi_pipe_gen1_2_tx_pipe_enable (hssi_pipe_gen1_2_tx_pipe_enable),
        .hssi_pipe_gen1_2_txswing (hssi_pipe_gen1_2_txswing),
        .hssi_pipe_gen3_bypass_rx_detection_enable (hssi_pipe_gen3_bypass_rx_detection_enable),
        .hssi_pipe_gen3_bypass_rx_preset (hssi_pipe_gen3_bypass_rx_preset),
        .hssi_pipe_gen3_bypass_rx_preset_enable (hssi_pipe_gen3_bypass_rx_preset_enable),
        .hssi_pipe_gen3_bypass_tx_coefficent (hssi_pipe_gen3_bypass_tx_coefficent),
        .hssi_pipe_gen3_bypass_tx_coefficent_enable (hssi_pipe_gen3_bypass_tx_coefficent_enable),
        .hssi_pipe_gen3_elecidle_delay_g3 (hssi_pipe_gen3_elecidle_delay_g3),
        .hssi_pipe_gen3_ind_error_reporting (hssi_pipe_gen3_ind_error_reporting),
        .hssi_pipe_gen3_mode (hssi_pipe_gen3_mode),
        .hssi_pipe_gen3_phy_status_delay_g3 (hssi_pipe_gen3_phy_status_delay_g3),
        .hssi_pipe_gen3_phy_status_delay_g12 (hssi_pipe_gen3_phy_status_delay_g12),
        .hssi_pipe_gen3_phystatus_rst_toggle_g3 (hssi_pipe_gen3_phystatus_rst_toggle_g3),
        .hssi_pipe_gen3_phystatus_rst_toggle_g12 (hssi_pipe_gen3_phystatus_rst_toggle_g12),
        .hssi_pipe_gen3_rate_match_pad_insertion (hssi_pipe_gen3_rate_match_pad_insertion),
        .hssi_pipe_gen3_silicon_rev (hssi_pipe_gen3_silicon_rev),
        .hssi_pipe_gen3_sup_mode (hssi_pipe_gen3_sup_mode),
        .hssi_pipe_gen3_test_out_sel (hssi_pipe_gen3_test_out_sel),
        .hssi_pldadapt_rx_aib_clk1_sel (hssi_pldadapt_rx_aib_clk1_sel),
        .hssi_pldadapt_rx_aib_clk2_sel (hssi_pldadapt_rx_aib_clk2_sel),
        .hssi_pldadapt_rx_asn_bypass_pma_pcie_sw_done (hssi_pldadapt_rx_asn_bypass_pma_pcie_sw_done),
        .hssi_pldadapt_rx_asn_wait_for_dll_reset_cnt (hssi_pldadapt_rx_asn_wait_for_dll_reset_cnt),
        .hssi_pldadapt_rx_asn_wait_for_fifo_flush_cnt (hssi_pldadapt_rx_asn_wait_for_fifo_flush_cnt),
        .hssi_pldadapt_rx_asn_wait_for_pma_pcie_sw_done_cnt (hssi_pldadapt_rx_asn_wait_for_pma_pcie_sw_done_cnt),
        .hssi_pldadapt_rx_bonding_dft_en (hssi_pldadapt_rx_bonding_dft_en),
        .hssi_pldadapt_rx_bonding_dft_val (hssi_pldadapt_rx_bonding_dft_val),
        .hssi_pldadapt_rx_chnl_bonding (hssi_pldadapt_rx_chnl_bonding),
        .hssi_pldadapt_rx_clock_del_measure_enable (hssi_pldadapt_rx_clock_del_measure_enable),
        .hssi_pldadapt_rx_ds_bypass_pipeln (hssi_pldadapt_rx_ds_bypass_pipeln),
        .hssi_pldadapt_rx_duplex_mode (hssi_pldadapt_rx_duplex_mode),
        .hssi_pldadapt_rx_dv_mode (hssi_pldadapt_rx_dv_mode),
        .hssi_pldadapt_rx_fifo_double_read (hssi_pldadapt_rx_fifo_double_read),
        .hssi_pldadapt_rx_fifo_mode (hssi_pldadapt_rx_fifo_mode),
        .hssi_pldadapt_rx_fifo_rd_clk_ins_sm_scg_en (hssi_pldadapt_rx_fifo_rd_clk_ins_sm_scg_en),
        .hssi_pldadapt_rx_fifo_rd_clk_scg_en (hssi_pldadapt_rx_fifo_rd_clk_scg_en),
        .hssi_pldadapt_rx_fifo_rd_clk_sel (hssi_pldadapt_rx_fifo_rd_clk_sel),
        .hssi_pldadapt_rx_fifo_stop_rd (hssi_pldadapt_rx_fifo_stop_rd),
        .hssi_pldadapt_rx_fifo_stop_wr (hssi_pldadapt_rx_fifo_stop_wr),
        .hssi_pldadapt_rx_fifo_width (hssi_pldadapt_rx_fifo_width),
        .hssi_pldadapt_rx_fifo_wr_clk_del_sm_scg_en (hssi_pldadapt_rx_fifo_wr_clk_del_sm_scg_en),
        .hssi_pldadapt_rx_fifo_wr_clk_scg_en (hssi_pldadapt_rx_fifo_wr_clk_scg_en),
        .hssi_pldadapt_rx_fifo_wr_clk_sel (hssi_pldadapt_rx_fifo_wr_clk_sel),
        .hssi_pldadapt_rx_free_run_div_clk (hssi_pldadapt_rx_free_run_div_clk),
        .hssi_pldadapt_rx_fsr_pld_8g_sigdet_out_rst_val (hssi_pldadapt_rx_fsr_pld_8g_sigdet_out_rst_val),
        .hssi_pldadapt_rx_fsr_pld_10g_rx_crc32_err_rst_val (hssi_pldadapt_rx_fsr_pld_10g_rx_crc32_err_rst_val),
        .hssi_pldadapt_rx_fsr_pld_ltd_b_rst_val (hssi_pldadapt_rx_fsr_pld_ltd_b_rst_val),
        .hssi_pldadapt_rx_fsr_pld_ltr_rst_val (hssi_pldadapt_rx_fsr_pld_ltr_rst_val),
        .hssi_pldadapt_rx_fsr_pld_rx_fifo_align_clr_rst_val (hssi_pldadapt_rx_fsr_pld_rx_fifo_align_clr_rst_val),
        .hssi_pldadapt_rx_gb_rx_idwidth (hssi_pldadapt_rx_gb_rx_idwidth),
        .hssi_pldadapt_rx_gb_rx_odwidth (hssi_pldadapt_rx_gb_rx_odwidth),
        .hssi_pldadapt_rx_hdpldadapt_aib_fabric_pld_pma_hclk_hz (hssi_pldadapt_rx_hdpldadapt_aib_fabric_pld_pma_hclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_sr_clk_in_hz (hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_sr_clk_in_hz),
        .hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_transfer_clk_hz (hssi_pldadapt_rx_hdpldadapt_aib_fabric_rx_transfer_clk_hz),
        .hssi_pldadapt_rx_hdpldadapt_csr_clk_hz (hssi_pldadapt_rx_hdpldadapt_csr_clk_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_avmm1_clk_rowclk_hz (hssi_pldadapt_rx_hdpldadapt_pld_avmm1_clk_rowclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_avmm2_clk_rowclk_hz (hssi_pldadapt_rx_hdpldadapt_pld_avmm2_clk_rowclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_dcm_hz (hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_dcm_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_rowclk_hz (hssi_pldadapt_rx_hdpldadapt_pld_rx_clk1_rowclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_sclk1_rowclk_hz (hssi_pldadapt_rx_hdpldadapt_pld_sclk1_rowclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_pld_sclk2_rowclk_hz (hssi_pldadapt_rx_hdpldadapt_pld_sclk2_rowclk_hz),
        .hssi_pldadapt_rx_hdpldadapt_speed_grade (hssi_pldadapt_rx_hdpldadapt_speed_grade),
        .hssi_pldadapt_rx_hip_mode (hssi_pldadapt_rx_hip_mode),
        .hssi_pldadapt_rx_hrdrst_align_bypass (hssi_pldadapt_rx_hrdrst_align_bypass),
        .hssi_pldadapt_rx_hrdrst_dll_lock_bypass (hssi_pldadapt_rx_hrdrst_dll_lock_bypass),
        .hssi_pldadapt_rx_hrdrst_rx_osc_clk_scg_en (hssi_pldadapt_rx_hrdrst_rx_osc_clk_scg_en),
        .hssi_pldadapt_rx_hrdrst_user_ctl_en (hssi_pldadapt_rx_hrdrst_user_ctl_en),
        .hssi_pldadapt_rx_indv (hssi_pldadapt_rx_indv),
        .hssi_pldadapt_rx_internal_clk1_sel1 (hssi_pldadapt_rx_internal_clk1_sel1),
        .hssi_pldadapt_rx_internal_clk1_sel2 (hssi_pldadapt_rx_internal_clk1_sel2),
        .hssi_pldadapt_rx_internal_clk2_sel1 (hssi_pldadapt_rx_internal_clk2_sel1),
        .hssi_pldadapt_rx_internal_clk2_sel2 (hssi_pldadapt_rx_internal_clk2_sel2),
        .hssi_pldadapt_rx_loopback_mode (hssi_pldadapt_rx_loopback_mode),
        .hssi_pldadapt_rx_low_latency_en (hssi_pldadapt_rx_low_latency_en),
        .hssi_pldadapt_rx_lpbk_mode (hssi_pldadapt_rx_lpbk_mode),
        .hssi_pldadapt_rx_osc_clk_scg_en (hssi_pldadapt_rx_osc_clk_scg_en),
        .hssi_pldadapt_rx_phcomp_rd_del (hssi_pldadapt_rx_phcomp_rd_del),
        .hssi_pldadapt_rx_pipe_enable (hssi_pldadapt_rx_pipe_enable),
        .hssi_pldadapt_rx_pipe_mode (hssi_pldadapt_rx_pipe_mode),
        .hssi_pldadapt_rx_pld_clk1_delay_en (hssi_pldadapt_rx_pld_clk1_delay_en),
        .hssi_pldadapt_rx_pld_clk1_delay_sel (hssi_pldadapt_rx_pld_clk1_delay_sel),
        .hssi_pldadapt_rx_pld_clk1_inv_en (hssi_pldadapt_rx_pld_clk1_inv_en),
        .hssi_pldadapt_rx_pld_clk1_sel (hssi_pldadapt_rx_pld_clk1_sel),
        .hssi_pldadapt_rx_powerdown_mode (hssi_pldadapt_rx_powerdown_mode),
        .hssi_pldadapt_rx_rx_datapath_tb_sel (hssi_pldadapt_rx_rx_datapath_tb_sel),
        .hssi_pldadapt_rx_rx_fastbond_rden (hssi_pldadapt_rx_rx_fastbond_rden),
        .hssi_pldadapt_rx_rx_fastbond_wren (hssi_pldadapt_rx_rx_fastbond_wren),
        .hssi_pldadapt_rx_rx_fifo_power_mode (hssi_pldadapt_rx_rx_fifo_power_mode),
        .hssi_pldadapt_rx_rx_fifo_read_latency_adjust (hssi_pldadapt_rx_rx_fifo_read_latency_adjust),
        .hssi_pldadapt_rx_rx_fifo_write_ctrl (hssi_pldadapt_rx_rx_fifo_write_ctrl),
        .hssi_pldadapt_rx_rx_fifo_write_latency_adjust (hssi_pldadapt_rx_rx_fifo_write_latency_adjust),
        .hssi_pldadapt_rx_rx_osc_clock_setting (hssi_pldadapt_rx_rx_osc_clock_setting),
        .hssi_pldadapt_rx_rx_pld_8g_eidleinfersel_polling_bypass (hssi_pldadapt_rx_rx_pld_8g_eidleinfersel_polling_bypass),
        .hssi_pldadapt_rx_rx_pld_pma_eye_monitor_polling_bypass (hssi_pldadapt_rx_rx_pld_pma_eye_monitor_polling_bypass),
        .hssi_pldadapt_rx_rx_pld_pma_pcie_switch_polling_bypass (hssi_pldadapt_rx_rx_pld_pma_pcie_switch_polling_bypass),
        .hssi_pldadapt_rx_rx_pld_pma_reser_out_polling_bypass (hssi_pldadapt_rx_rx_pld_pma_reser_out_polling_bypass),
        .hssi_pldadapt_rx_rx_prbs_flags_sr_enable (hssi_pldadapt_rx_rx_prbs_flags_sr_enable),
        .hssi_pldadapt_rx_rx_true_b2b (hssi_pldadapt_rx_rx_true_b2b),
        .hssi_pldadapt_rx_rx_usertest_sel (hssi_pldadapt_rx_rx_usertest_sel),
        .hssi_pldadapt_rx_rxfifo_empty (hssi_pldadapt_rx_rxfifo_empty),
        .hssi_pldadapt_rx_rxfifo_full (hssi_pldadapt_rx_rxfifo_full),
        .hssi_pldadapt_rx_rxfifo_mode (hssi_pldadapt_rx_rxfifo_mode),
        .hssi_pldadapt_rx_rxfifo_pempty (hssi_pldadapt_rx_rxfifo_pempty),
        .hssi_pldadapt_rx_rxfifo_pfull (hssi_pldadapt_rx_rxfifo_pfull),
        .hssi_pldadapt_rx_rxfiford_post_ct_sel (hssi_pldadapt_rx_rxfiford_post_ct_sel),
        .hssi_pldadapt_rx_rxfifowr_post_ct_sel (hssi_pldadapt_rx_rxfifowr_post_ct_sel),
        .hssi_pldadapt_rx_sclk_sel (hssi_pldadapt_rx_sclk_sel),
        .hssi_pldadapt_rx_silicon_rev (hssi_pldadapt_rx_silicon_rev),
        .hssi_pldadapt_rx_stretch_num_stages (hssi_pldadapt_rx_stretch_num_stages),
        .hssi_pldadapt_rx_sup_mode (hssi_pldadapt_rx_sup_mode),
        .hssi_pldadapt_rx_txfiford_post_ct_sel (hssi_pldadapt_rx_txfiford_post_ct_sel),
        .hssi_pldadapt_rx_txfifowr_post_ct_sel (hssi_pldadapt_rx_txfifowr_post_ct_sel),
        .hssi_pldadapt_rx_us_bypass_pipeln (hssi_pldadapt_rx_us_bypass_pipeln),
        .hssi_pldadapt_rx_word_align (hssi_pldadapt_rx_word_align),
        .hssi_pldadapt_rx_word_align_enable (hssi_pldadapt_rx_word_align_enable),
        .hssi_pldadapt_tx_aib_clk1_sel (hssi_pldadapt_tx_aib_clk1_sel),
        .hssi_pldadapt_tx_aib_clk2_sel (hssi_pldadapt_tx_aib_clk2_sel),
        .hssi_pldadapt_tx_bonding_dft_en (hssi_pldadapt_tx_bonding_dft_en),
        .hssi_pldadapt_tx_bonding_dft_val (hssi_pldadapt_tx_bonding_dft_val),
        .hssi_pldadapt_tx_chnl_bonding (hssi_pldadapt_tx_chnl_bonding),
        .hssi_pldadapt_tx_ds_bypass_pipeln (hssi_pldadapt_tx_ds_bypass_pipeln),
        .hssi_pldadapt_tx_duplex_mode (hssi_pldadapt_tx_duplex_mode),
        .hssi_pldadapt_tx_dv_bond (hssi_pldadapt_tx_dv_bond),
        .hssi_pldadapt_tx_dv_gen (hssi_pldadapt_tx_dv_gen),
        .hssi_pldadapt_tx_fifo_double_write (hssi_pldadapt_tx_fifo_double_write),
        .hssi_pldadapt_tx_fifo_mode (hssi_pldadapt_tx_fifo_mode),
        .hssi_pldadapt_tx_fifo_rd_clk_frm_gen_scg_en (hssi_pldadapt_tx_fifo_rd_clk_frm_gen_scg_en),
        .hssi_pldadapt_tx_fifo_rd_clk_scg_en (hssi_pldadapt_tx_fifo_rd_clk_scg_en),
        .hssi_pldadapt_tx_fifo_rd_clk_sel (hssi_pldadapt_tx_fifo_rd_clk_sel),
        .hssi_pldadapt_tx_fifo_stop_rd (hssi_pldadapt_tx_fifo_stop_rd),
        .hssi_pldadapt_tx_fifo_stop_wr (hssi_pldadapt_tx_fifo_stop_wr),
        .hssi_pldadapt_tx_fifo_width (hssi_pldadapt_tx_fifo_width),
        .hssi_pldadapt_tx_fifo_wr_clk_scg_en (hssi_pldadapt_tx_fifo_wr_clk_scg_en),
        .hssi_pldadapt_tx_fpll_shared_direct_async_in_sel (hssi_pldadapt_tx_fpll_shared_direct_async_in_sel),
        .hssi_pldadapt_tx_frmgen_burst (hssi_pldadapt_tx_frmgen_burst),
        .hssi_pldadapt_tx_frmgen_bypass (hssi_pldadapt_tx_frmgen_bypass),
        .hssi_pldadapt_tx_frmgen_mfrm_length (hssi_pldadapt_tx_frmgen_mfrm_length),
        .hssi_pldadapt_tx_frmgen_pipeln (hssi_pldadapt_tx_frmgen_pipeln),
        .hssi_pldadapt_tx_frmgen_pyld_ins (hssi_pldadapt_tx_frmgen_pyld_ins),
        .hssi_pldadapt_tx_frmgen_wordslip (hssi_pldadapt_tx_frmgen_wordslip),
        .hssi_pldadapt_tx_fsr_hip_fsr_in_bit0_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_in_bit0_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_in_bit1_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_in_bit1_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_in_bit2_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_in_bit2_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_in_bit3_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_in_bit3_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_out_bit0_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_out_bit0_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_out_bit1_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_out_bit1_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_out_bit2_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_out_bit2_rst_val),
        .hssi_pldadapt_tx_fsr_hip_fsr_out_bit3_rst_val (hssi_pldadapt_tx_fsr_hip_fsr_out_bit3_rst_val),
        .hssi_pldadapt_tx_fsr_mask_tx_pll_rst_val (hssi_pldadapt_tx_fsr_mask_tx_pll_rst_val),
        .hssi_pldadapt_tx_fsr_pld_txelecidle_rst_val (hssi_pldadapt_tx_fsr_pld_txelecidle_rst_val),
        .hssi_pldadapt_tx_gb_tx_idwidth (hssi_pldadapt_tx_gb_tx_idwidth),
        .hssi_pldadapt_tx_gb_tx_odwidth (hssi_pldadapt_tx_gb_tx_odwidth),
        .hssi_pldadapt_tx_hdpldadapt_aib_fabric_pld_pma_hclk_hz (hssi_pldadapt_tx_hdpldadapt_aib_fabric_pld_pma_hclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_aib_fabric_pma_aib_tx_clk_hz (hssi_pldadapt_tx_hdpldadapt_aib_fabric_pma_aib_tx_clk_hz),
        .hssi_pldadapt_tx_hdpldadapt_aib_fabric_tx_sr_clk_in_hz (hssi_pldadapt_tx_hdpldadapt_aib_fabric_tx_sr_clk_in_hz),
        .hssi_pldadapt_tx_hdpldadapt_csr_clk_hz (hssi_pldadapt_tx_hdpldadapt_csr_clk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_avmm1_clk_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_avmm1_clk_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_avmm2_clk_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_avmm2_clk_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_sclk1_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_sclk1_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_sclk2_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_sclk2_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_dcm_hz (hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_dcm_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_tx_clk1_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_dcm_hz (hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_dcm_hz),
        .hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_rowclk_hz (hssi_pldadapt_tx_hdpldadapt_pld_tx_clk2_rowclk_hz),
        .hssi_pldadapt_tx_hdpldadapt_speed_grade (hssi_pldadapt_tx_hdpldadapt_speed_grade),
        .hssi_pldadapt_tx_hip_mode (hssi_pldadapt_tx_hip_mode),
        .hssi_pldadapt_tx_hip_osc_clk_scg_en (hssi_pldadapt_tx_hip_osc_clk_scg_en),
        .hssi_pldadapt_tx_hrdrst_dcd_cal_done_bypass (hssi_pldadapt_tx_hrdrst_dcd_cal_done_bypass),
        .hssi_pldadapt_tx_hrdrst_rx_osc_clk_scg_en (hssi_pldadapt_tx_hrdrst_rx_osc_clk_scg_en),
        .hssi_pldadapt_tx_hrdrst_user_ctl_en (hssi_pldadapt_tx_hrdrst_user_ctl_en),
        .hssi_pldadapt_tx_indv (hssi_pldadapt_tx_indv),
        .hssi_pldadapt_tx_loopback_mode (hssi_pldadapt_tx_loopback_mode),
        .hssi_pldadapt_tx_low_latency_en (hssi_pldadapt_tx_low_latency_en),
        .hssi_pldadapt_tx_osc_clk_scg_en (hssi_pldadapt_tx_osc_clk_scg_en),
        .hssi_pldadapt_tx_phcomp_rd_del (hssi_pldadapt_tx_phcomp_rd_del),
        .hssi_pldadapt_tx_pipe_mode (hssi_pldadapt_tx_pipe_mode),
        .hssi_pldadapt_tx_pld_clk1_delay_en (hssi_pldadapt_tx_pld_clk1_delay_en),
        .hssi_pldadapt_tx_pld_clk1_delay_sel (hssi_pldadapt_tx_pld_clk1_delay_sel),
        .hssi_pldadapt_tx_pld_clk1_inv_en (hssi_pldadapt_tx_pld_clk1_inv_en),
        .hssi_pldadapt_tx_pld_clk1_sel (hssi_pldadapt_tx_pld_clk1_sel),
        .hssi_pldadapt_tx_pld_clk2_sel (hssi_pldadapt_tx_pld_clk2_sel),
        .hssi_pldadapt_tx_pma_aib_tx_clk_expected_setting (hssi_pldadapt_tx_pma_aib_tx_clk_expected_setting),
        .hssi_pldadapt_tx_powerdown_mode (hssi_pldadapt_tx_powerdown_mode),
        .hssi_pldadapt_tx_sh_err (hssi_pldadapt_tx_sh_err),
        .hssi_pldadapt_tx_silicon_rev (hssi_pldadapt_tx_silicon_rev),
        .hssi_pldadapt_tx_stretch_num_stages (hssi_pldadapt_tx_stretch_num_stages),
        .hssi_pldadapt_tx_sup_mode (hssi_pldadapt_tx_sup_mode),
        .hssi_pldadapt_tx_tx_datapath_tb_sel (hssi_pldadapt_tx_tx_datapath_tb_sel),
        .hssi_pldadapt_tx_tx_fastbond_rden (hssi_pldadapt_tx_tx_fastbond_rden),
        .hssi_pldadapt_tx_tx_fastbond_wren (hssi_pldadapt_tx_tx_fastbond_wren),
        .hssi_pldadapt_tx_tx_fifo_power_mode (hssi_pldadapt_tx_tx_fifo_power_mode),
        .hssi_pldadapt_tx_tx_fifo_read_latency_adjust (hssi_pldadapt_tx_tx_fifo_read_latency_adjust),
        .hssi_pldadapt_tx_tx_fifo_write_latency_adjust (hssi_pldadapt_tx_tx_fifo_write_latency_adjust),
        .hssi_pldadapt_tx_tx_hip_aib_ssr_in_polling_bypass (hssi_pldadapt_tx_tx_hip_aib_ssr_in_polling_bypass),
        .hssi_pldadapt_tx_tx_osc_clock_setting (hssi_pldadapt_tx_tx_osc_clock_setting),
        .hssi_pldadapt_tx_tx_pld_8g_tx_boundary_sel_polling_bypass (hssi_pldadapt_tx_tx_pld_8g_tx_boundary_sel_polling_bypass),
        .hssi_pldadapt_tx_tx_pld_10g_tx_bitslip_polling_bypass (hssi_pldadapt_tx_tx_pld_10g_tx_bitslip_polling_bypass),
        .hssi_pldadapt_tx_tx_pld_pma_fpll_cnt_sel_polling_bypass (hssi_pldadapt_tx_tx_pld_pma_fpll_cnt_sel_polling_bypass),
        .hssi_pldadapt_tx_tx_pld_pma_fpll_num_phase_shifts_polling_bypass (hssi_pldadapt_tx_tx_pld_pma_fpll_num_phase_shifts_polling_bypass),
        .hssi_pldadapt_tx_tx_usertest_sel (hssi_pldadapt_tx_tx_usertest_sel),
        .hssi_pldadapt_tx_txfifo_empty (hssi_pldadapt_tx_txfifo_empty),
        .hssi_pldadapt_tx_txfifo_full (hssi_pldadapt_tx_txfifo_full),
        .hssi_pldadapt_tx_txfifo_mode (hssi_pldadapt_tx_txfifo_mode),
        .hssi_pldadapt_tx_txfifo_pempty (hssi_pldadapt_tx_txfifo_pempty),
        .hssi_pldadapt_tx_txfifo_pfull (hssi_pldadapt_tx_txfifo_pfull),
        .hssi_pldadapt_tx_us_bypass_pipeln (hssi_pldadapt_tx_us_bypass_pipeln),
        .hssi_pldadapt_tx_word_align_enable (hssi_pldadapt_tx_word_align_enable),
        .hssi_pldadapt_tx_word_mark (hssi_pldadapt_tx_word_mark),
        .hssi_rx_pcs_pma_interface_block_sel (hssi_rx_pcs_pma_interface_block_sel),
        .hssi_rx_pcs_pma_interface_channel_operation_mode (hssi_rx_pcs_pma_interface_channel_operation_mode),
        .hssi_rx_pcs_pma_interface_clkslip_sel (hssi_rx_pcs_pma_interface_clkslip_sel),
        .hssi_rx_pcs_pma_interface_lpbk_en (hssi_rx_pcs_pma_interface_lpbk_en),
        .hssi_rx_pcs_pma_interface_master_clk_sel (hssi_rx_pcs_pma_interface_master_clk_sel),
        .hssi_rx_pcs_pma_interface_pldif_datawidth_mode (hssi_rx_pcs_pma_interface_pldif_datawidth_mode),
        .hssi_rx_pcs_pma_interface_pma_dw_rx (hssi_rx_pcs_pma_interface_pma_dw_rx),
        .hssi_rx_pcs_pma_interface_pma_if_dft_en (hssi_rx_pcs_pma_interface_pma_if_dft_en),
        .hssi_rx_pcs_pma_interface_pma_if_dft_val (hssi_rx_pcs_pma_interface_pma_if_dft_val),
        .hssi_rx_pcs_pma_interface_prbs9_dwidth (hssi_rx_pcs_pma_interface_prbs9_dwidth),
        .hssi_rx_pcs_pma_interface_prbs_clken (hssi_rx_pcs_pma_interface_prbs_clken),
        .hssi_rx_pcs_pma_interface_prbs_ver (hssi_rx_pcs_pma_interface_prbs_ver),
        .hssi_rx_pcs_pma_interface_prot_mode_rx (hssi_rx_pcs_pma_interface_prot_mode_rx),
        .hssi_rx_pcs_pma_interface_rx_dyn_polarity_inversion (hssi_rx_pcs_pma_interface_rx_dyn_polarity_inversion),
        .hssi_rx_pcs_pma_interface_rx_lpbk_en (hssi_rx_pcs_pma_interface_rx_lpbk_en),
        .hssi_rx_pcs_pma_interface_rx_prbs_force_signal_ok (hssi_rx_pcs_pma_interface_rx_prbs_force_signal_ok),
        .hssi_rx_pcs_pma_interface_rx_prbs_mask (hssi_rx_pcs_pma_interface_rx_prbs_mask),
        .hssi_rx_pcs_pma_interface_rx_prbs_mode (hssi_rx_pcs_pma_interface_rx_prbs_mode),
        .hssi_rx_pcs_pma_interface_rx_signalok_signaldet_sel (hssi_rx_pcs_pma_interface_rx_signalok_signaldet_sel),
        .hssi_rx_pcs_pma_interface_rx_static_polarity_inversion (hssi_rx_pcs_pma_interface_rx_static_polarity_inversion),
        .hssi_rx_pcs_pma_interface_rx_uhsif_lpbk_en (hssi_rx_pcs_pma_interface_rx_uhsif_lpbk_en),
        .hssi_rx_pcs_pma_interface_silicon_rev (hssi_rx_pcs_pma_interface_silicon_rev),
        .hssi_rx_pcs_pma_interface_sup_mode (hssi_rx_pcs_pma_interface_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_g3pcs_prot_mode (hssi_rx_pld_pcs_interface_hd_g3pcs_prot_mode),
        .hssi_rx_pld_pcs_interface_hd_g3pcs_sup_mode (hssi_rx_pld_pcs_interface_hd_g3pcs_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_krfec_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_krfec_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_krfec_low_latency_en_rx (hssi_rx_pld_pcs_interface_hd_krfec_low_latency_en_rx),
        .hssi_rx_pld_pcs_interface_hd_krfec_lpbk_en (hssi_rx_pld_pcs_interface_hd_krfec_lpbk_en),
        .hssi_rx_pld_pcs_interface_hd_krfec_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_krfec_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_krfec_sup_mode (hssi_rx_pld_pcs_interface_hd_krfec_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_krfec_test_bus_mode (hssi_rx_pld_pcs_interface_hd_krfec_test_bus_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_pcs8g_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_fifo_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs8g_fifo_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_hip_mode (hssi_rx_pld_pcs_interface_hd_pcs8g_hip_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_lpbk_en (hssi_rx_pld_pcs_interface_hd_pcs8g_lpbk_en),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_pma_dw_rx (hssi_rx_pld_pcs_interface_hd_pcs8g_pma_dw_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs8g_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs8g_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs8g_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_pcs10g_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_fifo_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_fifo_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_low_latency_en_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_low_latency_en_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_lpbk_en (hssi_rx_pld_pcs_interface_hd_pcs10g_lpbk_en),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_pma_dw_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_pma_dw_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_rx (hssi_rx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs10g_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs10g_test_bus_mode (hssi_rx_pld_pcs_interface_hd_pcs10g_test_bus_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_clklow_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_clklow_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_fref_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_fref_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_func_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_func_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_hip_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_hip_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_low_latency_en_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_low_latency_en_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_lpbk_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_lpbk_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_operating_voltage (hssi_rx_pld_pcs_interface_hd_pcs_channel_operating_voltage),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_ac_pwr_rules_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_ac_pwr_rules_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_pair_ac_pwr_uw_per_mhz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_pair_ac_pwr_uw_per_mhz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_ac_pwr_uw_per_mhz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_ac_pwr_uw_per_mhz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_pwr_scaling_clk (hssi_rx_pld_pcs_interface_hd_pcs_channel_pcs_rx_pwr_scaling_clk),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_rx_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pld_rx_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_dw_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_dw_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_rx_clk_hz (hssi_rx_pld_pcs_interface_hd_pcs_channel_pma_rx_clk_hz),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_rx),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_speed_grade (hssi_rx_pld_pcs_interface_hd_pcs_channel_speed_grade),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_sup_mode (hssi_rx_pld_pcs_interface_hd_pcs_channel_sup_mode),
        .hssi_rx_pld_pcs_interface_hd_pcs_channel_transparent_pcs_rx (hssi_rx_pld_pcs_interface_hd_pcs_channel_transparent_pcs_rx),
        .hssi_rx_pld_pcs_interface_pcs_rx_block_sel (hssi_rx_pld_pcs_interface_pcs_rx_block_sel),
        .hssi_rx_pld_pcs_interface_pcs_rx_clk_out_sel (hssi_rx_pld_pcs_interface_pcs_rx_clk_out_sel),
        .hssi_rx_pld_pcs_interface_pcs_rx_clk_sel (hssi_rx_pld_pcs_interface_pcs_rx_clk_sel),
        .hssi_rx_pld_pcs_interface_pcs_rx_hip_clk_en (hssi_rx_pld_pcs_interface_pcs_rx_hip_clk_en),
        .hssi_rx_pld_pcs_interface_pcs_rx_output_sel (hssi_rx_pld_pcs_interface_pcs_rx_output_sel),
        .hssi_rx_pld_pcs_interface_silicon_rev (hssi_rx_pld_pcs_interface_silicon_rev),
        .hssi_tx_pcs_pma_interface_bypass_pma_txelecidle (hssi_tx_pcs_pma_interface_bypass_pma_txelecidle),
        .hssi_tx_pcs_pma_interface_channel_operation_mode (hssi_tx_pcs_pma_interface_channel_operation_mode),
        .hssi_tx_pcs_pma_interface_lpbk_en (hssi_tx_pcs_pma_interface_lpbk_en),
        .hssi_tx_pcs_pma_interface_master_clk_sel (hssi_tx_pcs_pma_interface_master_clk_sel),
        .hssi_tx_pcs_pma_interface_pcie_sub_prot_mode_tx (hssi_tx_pcs_pma_interface_pcie_sub_prot_mode_tx),
        .hssi_tx_pcs_pma_interface_pldif_datawidth_mode (hssi_tx_pcs_pma_interface_pldif_datawidth_mode),
        .hssi_tx_pcs_pma_interface_pma_dw_tx (hssi_tx_pcs_pma_interface_pma_dw_tx),
        .hssi_tx_pcs_pma_interface_pma_if_dft_en (hssi_tx_pcs_pma_interface_pma_if_dft_en),
        .hssi_tx_pcs_pma_interface_pmagate_en (hssi_tx_pcs_pma_interface_pmagate_en),
        .hssi_tx_pcs_pma_interface_prbs9_dwidth (hssi_tx_pcs_pma_interface_prbs9_dwidth),
        .hssi_tx_pcs_pma_interface_prbs_clken (hssi_tx_pcs_pma_interface_prbs_clken),
        .hssi_tx_pcs_pma_interface_prbs_gen_pat (hssi_tx_pcs_pma_interface_prbs_gen_pat),
        .hssi_tx_pcs_pma_interface_prot_mode_tx (hssi_tx_pcs_pma_interface_prot_mode_tx),
        .hssi_tx_pcs_pma_interface_silicon_rev (hssi_tx_pcs_pma_interface_silicon_rev),
        .hssi_tx_pcs_pma_interface_sq_wave_num (hssi_tx_pcs_pma_interface_sq_wave_num),
        .hssi_tx_pcs_pma_interface_sqwgen_clken (hssi_tx_pcs_pma_interface_sqwgen_clken),
        .hssi_tx_pcs_pma_interface_sup_mode (hssi_tx_pcs_pma_interface_sup_mode),
        .hssi_tx_pcs_pma_interface_tx_dyn_polarity_inversion (hssi_tx_pcs_pma_interface_tx_dyn_polarity_inversion),
        .hssi_tx_pcs_pma_interface_tx_pma_data_sel (hssi_tx_pcs_pma_interface_tx_pma_data_sel),
        .hssi_tx_pcs_pma_interface_tx_static_polarity_inversion (hssi_tx_pcs_pma_interface_tx_static_polarity_inversion),
        .hssi_tx_pcs_pma_interface_uhsif_cnt_step_filt_before_lock (hssi_tx_pcs_pma_interface_uhsif_cnt_step_filt_before_lock),
        .hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_after_lock_value (hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_after_lock_value),
        .hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_before_lock (hssi_tx_pcs_pma_interface_uhsif_cnt_thresh_filt_before_lock),
        .hssi_tx_pcs_pma_interface_uhsif_dcn_test_update_period (hssi_tx_pcs_pma_interface_uhsif_dcn_test_update_period),
        .hssi_tx_pcs_pma_interface_uhsif_dcn_testmode_enable (hssi_tx_pcs_pma_interface_uhsif_dcn_testmode_enable),
        .hssi_tx_pcs_pma_interface_uhsif_dead_zone_count_thresh (hssi_tx_pcs_pma_interface_uhsif_dead_zone_count_thresh),
        .hssi_tx_pcs_pma_interface_uhsif_dead_zone_detection_enable (hssi_tx_pcs_pma_interface_uhsif_dead_zone_detection_enable),
        .hssi_tx_pcs_pma_interface_uhsif_dead_zone_obser_window (hssi_tx_pcs_pma_interface_uhsif_dead_zone_obser_window),
        .hssi_tx_pcs_pma_interface_uhsif_dead_zone_skip_size (hssi_tx_pcs_pma_interface_uhsif_dead_zone_skip_size),
        .hssi_tx_pcs_pma_interface_uhsif_delay_cell_index_sel (hssi_tx_pcs_pma_interface_uhsif_delay_cell_index_sel),
        .hssi_tx_pcs_pma_interface_uhsif_delay_cell_margin (hssi_tx_pcs_pma_interface_uhsif_delay_cell_margin),
        .hssi_tx_pcs_pma_interface_uhsif_delay_cell_static_index_value (hssi_tx_pcs_pma_interface_uhsif_delay_cell_static_index_value),
        .hssi_tx_pcs_pma_interface_uhsif_dft_dead_zone_control (hssi_tx_pcs_pma_interface_uhsif_dft_dead_zone_control),
        .hssi_tx_pcs_pma_interface_uhsif_dft_up_filt_control (hssi_tx_pcs_pma_interface_uhsif_dft_up_filt_control),
        .hssi_tx_pcs_pma_interface_uhsif_enable (hssi_tx_pcs_pma_interface_uhsif_enable),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_after_lock (hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_after_lock),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_before_lock (hssi_tx_pcs_pma_interface_uhsif_lock_det_segsz_before_lock),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_after_lock_value (hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_after_lock_value),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_before_lock_value (hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_cnt_before_lock_value),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_after_lock_value (hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_after_lock_value),
        .hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_before_lock_value (hssi_tx_pcs_pma_interface_uhsif_lock_det_thresh_diff_before_lock_value),
        .hssi_tx_pld_pcs_interface_hd_g3pcs_prot_mode (hssi_tx_pld_pcs_interface_hd_g3pcs_prot_mode),
        .hssi_tx_pld_pcs_interface_hd_g3pcs_sup_mode (hssi_tx_pld_pcs_interface_hd_g3pcs_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_krfec_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_krfec_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_krfec_low_latency_en_tx (hssi_tx_pld_pcs_interface_hd_krfec_low_latency_en_tx),
        .hssi_tx_pld_pcs_interface_hd_krfec_lpbk_en (hssi_tx_pld_pcs_interface_hd_krfec_lpbk_en),
        .hssi_tx_pld_pcs_interface_hd_krfec_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_krfec_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_krfec_sup_mode (hssi_tx_pld_pcs_interface_hd_krfec_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_pcs8g_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_fifo_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs8g_fifo_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_hip_mode (hssi_tx_pld_pcs_interface_hd_pcs8g_hip_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_lpbk_en (hssi_tx_pld_pcs_interface_hd_pcs8g_lpbk_en),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_pma_dw_tx (hssi_tx_pld_pcs_interface_hd_pcs8g_pma_dw_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs8g_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs8g_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs8g_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_advanced_user_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_pcs10g_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_fifo_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_fifo_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_low_latency_en_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_low_latency_en_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_lpbk_en (hssi_tx_pld_pcs_interface_hd_pcs10g_lpbk_en),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_pma_dw_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_pma_dw_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_tx (hssi_tx_pld_pcs_interface_hd_pcs10g_shared_fifo_width_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs10g_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs10g_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_frequency_rules_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_func_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_func_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_hclk_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_hip_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_hip_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_hrdrstctl_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_low_latency_en_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_low_latency_en_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_lpbk_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_lpbk_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_ac_pwr_uw_per_mhz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_ac_pwr_uw_per_mhz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_pwr_scaling_clk (hssi_tx_pld_pcs_interface_hd_pcs_channel_pcs_tx_pwr_scaling_clk),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_8g_refclk_dig_nonatpg_mode_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_fifo_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_hrdrstctl_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_if_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_pcs_refclk_dig_nonatpg_mode_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_tx_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_tx_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_uhsif_tx_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pld_uhsif_tx_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_dw_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_dw_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_lpbk_en),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_pma_dw_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sim_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_if_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_tx_clk_hz (hssi_tx_pld_pcs_interface_hd_pcs_channel_pma_tx_clk_hz),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_channel_operation_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_prot_mode_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_shared_fifo_width_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_share_fifo_mem_sup_mode),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_tx (hssi_tx_pld_pcs_interface_hd_pcs_channel_shared_fifo_width_tx),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_speed_grade (hssi_tx_pld_pcs_interface_hd_pcs_channel_speed_grade),
        .hssi_tx_pld_pcs_interface_hd_pcs_channel_sup_mode (hssi_tx_pld_pcs_interface_hd_pcs_channel_sup_mode),
        .hssi_tx_pld_pcs_interface_pcs_tx_clk_out_sel (hssi_tx_pld_pcs_interface_pcs_tx_clk_out_sel),
        .hssi_tx_pld_pcs_interface_pcs_tx_clk_source (hssi_tx_pld_pcs_interface_pcs_tx_clk_source),
        .hssi_tx_pld_pcs_interface_pcs_tx_data_source (hssi_tx_pld_pcs_interface_pcs_tx_data_source),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_en (hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_en),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_sel (hssi_tx_pld_pcs_interface_pcs_tx_delay1_clk_sel),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay1_ctrl (hssi_tx_pld_pcs_interface_pcs_tx_delay1_ctrl),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay1_data_sel (hssi_tx_pld_pcs_interface_pcs_tx_delay1_data_sel),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay2_clk_en (hssi_tx_pld_pcs_interface_pcs_tx_delay2_clk_en),
        .hssi_tx_pld_pcs_interface_pcs_tx_delay2_ctrl (hssi_tx_pld_pcs_interface_pcs_tx_delay2_ctrl),
        .hssi_tx_pld_pcs_interface_pcs_tx_output_sel (hssi_tx_pld_pcs_interface_pcs_tx_output_sel),
        .hssi_tx_pld_pcs_interface_silicon_rev (hssi_tx_pld_pcs_interface_silicon_rev),
        .pma_adapt_adapt_mode (pma_adapt_adapt_mode),
        .pma_adapt_adp_ac_ctle_cal_win (pma_adapt_adp_ac_ctle_cal_win),
        .pma_adapt_adp_ac_ctle_cocurrent_mode_sel (pma_adapt_adp_ac_ctle_cocurrent_mode_sel),
        .pma_adapt_adp_ac_ctle_en (pma_adapt_adp_ac_ctle_en),
        .pma_adapt_adp_ac_ctle_hold_en (pma_adapt_adp_ac_ctle_hold_en),
        .pma_adapt_adp_ac_ctle_initial_load (pma_adapt_adp_ac_ctle_initial_load),
        .pma_adapt_adp_ac_ctle_initial_value (pma_adapt_adp_ac_ctle_initial_value),
        .pma_adapt_adp_ac_ctle_mode_sel (pma_adapt_adp_ac_ctle_mode_sel),
        .pma_adapt_adp_ac_ctle_ph1_win (pma_adapt_adp_ac_ctle_ph1_win),
        .pma_adapt_adp_adapt_control_sel (pma_adapt_adp_adapt_control_sel),
        .pma_adapt_adp_adapt_start (pma_adapt_adp_adapt_start),
        .pma_adapt_adp_bist_datapath_en (pma_adapt_adp_bist_datapath_en),
        .pma_adapt_adp_bist_errcount_rstn (pma_adapt_adp_bist_errcount_rstn),
        .pma_adapt_adp_bist_mode_sel (pma_adapt_adp_bist_mode_sel),
        .pma_adapt_adp_clkgate_enb (pma_adapt_adp_clkgate_enb),
        .pma_adapt_adp_clkout_div_sel (pma_adapt_adp_clkout_div_sel),
        .pma_adapt_adp_ctle_bypass_ac (pma_adapt_adp_ctle_bypass_ac),
        .pma_adapt_adp_ctle_bypass_dc (pma_adapt_adp_ctle_bypass_dc),
        .pma_adapt_adp_dc_ctle_accum_depth (pma_adapt_adp_dc_ctle_accum_depth),
        .pma_adapt_adp_dc_ctle_en (pma_adapt_adp_dc_ctle_en),
        .pma_adapt_adp_dc_ctle_hold_en (pma_adapt_adp_dc_ctle_hold_en),
        .pma_adapt_adp_dc_ctle_initial_load (pma_adapt_adp_dc_ctle_initial_load),
        .pma_adapt_adp_dc_ctle_initial_value (pma_adapt_adp_dc_ctle_initial_value),
        .pma_adapt_adp_dc_ctle_mode0_win_size (pma_adapt_adp_dc_ctle_mode0_win_size),
        .pma_adapt_adp_dc_ctle_mode0_win_start (pma_adapt_adp_dc_ctle_mode0_win_start),
        .pma_adapt_adp_dc_ctle_mode1_h1_ratio (pma_adapt_adp_dc_ctle_mode1_h1_ratio),
        .pma_adapt_adp_dc_ctle_mode2_h2_limit (pma_adapt_adp_dc_ctle_mode2_h2_limit),
        .pma_adapt_adp_dc_ctle_mode_sel (pma_adapt_adp_dc_ctle_mode_sel),
        .pma_adapt_adp_dc_ctle_onetime (pma_adapt_adp_dc_ctle_onetime),
        .pma_adapt_adp_dc_ctle_onetime_threshold (pma_adapt_adp_dc_ctle_onetime_threshold),
        .pma_adapt_adp_dfe_accum_depth (pma_adapt_adp_dfe_accum_depth),
        .pma_adapt_adp_dfe_en (pma_adapt_adp_dfe_en),
        .pma_adapt_adp_dfe_fxtap_bypass (pma_adapt_adp_dfe_fxtap_bypass),
        .pma_adapt_adp_dfe_hold_en (pma_adapt_adp_dfe_hold_en),
        .pma_adapt_adp_dfe_hold_sel (pma_adapt_adp_dfe_hold_sel),
        .pma_adapt_adp_dfe_onetime (pma_adapt_adp_dfe_onetime),
        .pma_adapt_adp_dfe_onetime_threshold (pma_adapt_adp_dfe_onetime_threshold),
        .pma_adapt_adp_dfe_tap1_initial_load (pma_adapt_adp_dfe_tap1_initial_load),
        .pma_adapt_adp_dfe_tap1_initial_value (pma_adapt_adp_dfe_tap1_initial_value),
        .pma_adapt_adp_dfe_tap_sel_en (pma_adapt_adp_dfe_tap_sel_en),
        .pma_adapt_adp_dlev_accum_depth (pma_adapt_adp_dlev_accum_depth),
        .pma_adapt_adp_dlev_bypass (pma_adapt_adp_dlev_bypass),
        .pma_adapt_adp_dlev_en (pma_adapt_adp_dlev_en),
        .pma_adapt_adp_dlev_hold_en (pma_adapt_adp_dlev_hold_en),
        .pma_adapt_adp_dlev_initial_load (pma_adapt_adp_dlev_initial_load),
        .pma_adapt_adp_dlev_initial_value (pma_adapt_adp_dlev_initial_value),
        .pma_adapt_adp_dlev_onetime (pma_adapt_adp_dlev_onetime),
        .pma_adapt_adp_dlev_onetime_threshold (pma_adapt_adp_dlev_onetime_threshold),
        .pma_adapt_adp_dlev_sel (pma_adapt_adp_dlev_sel),
        .pma_adapt_adp_force_freqlock (pma_adapt_adp_force_freqlock),
        .pma_adapt_adp_frame_capture (pma_adapt_adp_frame_capture),
        .pma_adapt_adp_frame_en (pma_adapt_adp_frame_en),
        .pma_adapt_adp_frame_odi_sel (pma_adapt_adp_frame_odi_sel),
        .pma_adapt_adp_frame_out_sel (pma_adapt_adp_frame_out_sel),
        .pma_adapt_adp_load_sig_sel (pma_adapt_adp_load_sig_sel),
        .pma_adapt_adp_oc_accum_depth (pma_adapt_adp_oc_accum_depth),
        .pma_adapt_adp_oc_bypass (pma_adapt_adp_oc_bypass),
        .pma_adapt_adp_oc_en (pma_adapt_adp_oc_en),
        .pma_adapt_adp_oc_hold_en (pma_adapt_adp_oc_hold_en),
        .pma_adapt_adp_oc_initial_load (pma_adapt_adp_oc_initial_load),
        .pma_adapt_adp_oc_initial_sign (pma_adapt_adp_oc_initial_sign),
        .pma_adapt_adp_oc_onetime (pma_adapt_adp_oc_onetime),
        .pma_adapt_adp_oc_onetime_threshold (pma_adapt_adp_oc_onetime_threshold),
        .pma_adapt_adp_odi_bit_sel (pma_adapt_adp_odi_bit_sel),
        .pma_adapt_adp_odi_control_sel (pma_adapt_adp_odi_control_sel),
        .pma_adapt_adp_odi_count_threshold (pma_adapt_adp_odi_count_threshold),
        .pma_adapt_adp_odi_dfe_spec_en (pma_adapt_adp_odi_dfe_spec_en),
        .pma_adapt_adp_odi_dlev_sel (pma_adapt_adp_odi_dlev_sel),
        .pma_adapt_adp_odi_en (pma_adapt_adp_odi_en),
        .pma_adapt_adp_odi_mode (pma_adapt_adp_odi_mode),
        .pma_adapt_adp_odi_rstn (pma_adapt_adp_odi_rstn),
        .pma_adapt_adp_odi_spec_sel (pma_adapt_adp_odi_spec_sel),
        .pma_adapt_adp_odi_start (pma_adapt_adp_odi_start),
        .pma_adapt_adp_pat_dlev_sign_avg_win (pma_adapt_adp_pat_dlev_sign_avg_win),
        .pma_adapt_adp_pat_dlev_sign_force (pma_adapt_adp_pat_dlev_sign_force),
        .pma_adapt_adp_pat_dlev_sign_value (pma_adapt_adp_pat_dlev_sign_value),
        .pma_adapt_adp_pat_spec_sign_avg_win (pma_adapt_adp_pat_spec_sign_avg_win),
        .pma_adapt_adp_pat_spec_sign_force (pma_adapt_adp_pat_spec_sign_force),
        .pma_adapt_adp_pat_spec_sign_value (pma_adapt_adp_pat_spec_sign_value),
        .pma_adapt_adp_pat_trans_filter (pma_adapt_adp_pat_trans_filter),
        .pma_adapt_adp_pat_trans_only_en (pma_adapt_adp_pat_trans_only_en),
        .pma_adapt_adp_pcie_adp_bypass (pma_adapt_adp_pcie_adp_bypass),
        .pma_adapt_adp_pcie_eqz (pma_adapt_adp_pcie_eqz),
        .pma_adapt_adp_pcie_hold_sel (pma_adapt_adp_pcie_hold_sel),
        .pma_adapt_adp_pcs_option (pma_adapt_adp_pcs_option),
        .pma_adapt_adp_po_actslp_ratio (pma_adapt_adp_po_actslp_ratio),
        .pma_adapt_adp_po_en (pma_adapt_adp_po_en),
        .pma_adapt_adp_po_gb_act2slp (pma_adapt_adp_po_gb_act2slp),
        .pma_adapt_adp_po_gb_slp2act (pma_adapt_adp_po_gb_slp2act),
        .pma_adapt_adp_po_initwait (pma_adapt_adp_po_initwait),
        .pma_adapt_adp_po_sleep_win (pma_adapt_adp_po_sleep_win),
        .pma_adapt_adp_reserved (pma_adapt_adp_reserved),
        .pma_adapt_adp_rstn (pma_adapt_adp_rstn),
        .pma_adapt_adp_status_sel (pma_adapt_adp_status_sel),
        .pma_adapt_adp_tx_accum_depth (pma_adapt_adp_tx_accum_depth),
        .pma_adapt_adp_tx_adp_accumulate (pma_adapt_adp_tx_adp_accumulate),
        .pma_adapt_adp_tx_adp_en (pma_adapt_adp_tx_adp_en),
        .pma_adapt_adp_tx_up_dn_flip (pma_adapt_adp_tx_up_dn_flip),
        .pma_adapt_adp_vga_accum_depth (pma_adapt_adp_vga_accum_depth),
        .pma_adapt_adp_vga_bypass (pma_adapt_adp_vga_bypass),
        .pma_adapt_adp_vga_ctle_low_limit (pma_adapt_adp_vga_ctle_low_limit),
        .pma_adapt_adp_vga_dlev_offset (pma_adapt_adp_vga_dlev_offset),
        .pma_adapt_adp_vga_dlev_target (pma_adapt_adp_vga_dlev_target),
        .pma_adapt_adp_vga_en (pma_adapt_adp_vga_en),
        .pma_adapt_adp_vga_hold_en (pma_adapt_adp_vga_hold_en),
        .pma_adapt_adp_vga_initial_load (pma_adapt_adp_vga_initial_load),
        .pma_adapt_adp_vga_initial_value (pma_adapt_adp_vga_initial_value),
        .pma_adapt_adp_vga_onetime (pma_adapt_adp_vga_onetime),
        .pma_adapt_adp_vga_onetime_threshold (pma_adapt_adp_vga_onetime_threshold),
//        .pma_adapt_advanced_mode (pma_adapt_advanced_mode),
        .pma_adapt_initial_settings (pma_adapt_initial_settings),
        .pma_adapt_odi_mode (pma_adapt_odi_mode),
        .pma_adapt_optimal (pma_adapt_optimal),
        .pma_adapt_power_mode (pma_adapt_power_mode),
//        .pma_adapt_powermode_ac_adaptation (pma_adapt_powermode_ac_adaptation),
//        .pma_adapt_powermode_ac_deser_adapt (pma_adapt_powermode_ac_deser_adapt),
//        .pma_adapt_powermode_ac_dfe_adapt (pma_adapt_powermode_ac_dfe_adapt),
//        .pma_adapt_powermode_dc_adaptation (pma_adapt_powermode_dc_adaptation),
//        .pma_adapt_powermode_dc_deser_adapt (pma_adapt_powermode_dc_deser_adapt),
//        .pma_adapt_powermode_dc_dfe_adapt (pma_adapt_powermode_dc_dfe_adapt),
        .pma_adapt_prot_mode (pma_adapt_prot_mode),
        .pma_adapt_sequencer_rx_path_rstn_overrideb (pma_adapt_sequencer_rx_path_rstn_overrideb),
        .pma_adapt_sequencer_silicon_rev (pma_adapt_sequencer_silicon_rev),
        .pma_adapt_silicon_rev (pma_adapt_silicon_rev),
        .pma_adapt_sup_mode (pma_adapt_sup_mode),
        .pma_cdr_refclk_powerdown_mode (pma_cdr_refclk_powerdown_mode),
        .pma_cdr_refclk_receiver_detect_src (pma_cdr_refclk_receiver_detect_src),
        .pma_cdr_refclk_refclk_select (pma_cdr_refclk_refclk_select),
        .pma_cdr_refclk_silicon_rev (pma_cdr_refclk_silicon_rev),
        .pma_cgb_bitslip_enable (pma_cgb_bitslip_enable),
        .pma_cgb_bti_protected (pma_cgb_bti_protected),
        .pma_cgb_cgb_bti_en (pma_cgb_cgb_bti_en),
        .pma_cgb_cgb_power_down (pma_cgb_cgb_power_down),
        .pma_cgb_initial_settings (pma_cgb_initial_settings),
        .pma_cgb_input_select_gen3 (pma_cgb_input_select_gen3),
        .pma_cgb_input_select_x1 (pma_cgb_input_select_x1),
        .pma_cgb_input_select_xn (pma_cgb_input_select_xn),
        .pma_cgb_observe_cgb_clocks (pma_cgb_observe_cgb_clocks),
        .pma_cgb_pcie_gen (pma_cgb_pcie_gen),
        .pma_cgb_pcie_gen3_bitwidth (pma_cgb_pcie_gen3_bitwidth),
        .pma_cgb_power_rail_er (pma_cgb_power_rail_er),
        .pma_cgb_powermode_ac_cgb (pma_cgb_powermode_ac_cgb),
        .pma_cgb_powermode_dc_cgb (pma_cgb_powermode_dc_cgb),
        .pma_cgb_prot_mode (pma_cgb_prot_mode),
        .pma_cgb_ser_mode (pma_cgb_ser_mode),
        .pma_cgb_ser_powerdown (pma_cgb_ser_powerdown),
        .pma_cgb_silicon_rev (pma_cgb_silicon_rev),
        .pma_cgb_sup_mode (pma_cgb_sup_mode),
        .pma_cgb_tx_ucontrol_en (pma_cgb_tx_ucontrol_en),
        .pma_cgb_tx_ucontrol_pcie (pma_cgb_tx_ucontrol_pcie),
        .pma_cgb_tx_ucontrol_reset (pma_cgb_tx_ucontrol_reset),
        .pma_cgb_uc_cgb_vreg_boost (pma_cgb_uc_cgb_vreg_boost),
        .pma_cgb_uc_vcc_setting (pma_cgb_uc_vcc_setting),
        .pma_cgb_vccdreg_output (pma_cgb_vccdreg_output),
        .pma_cgb_vreg_sel_ref (pma_cgb_vreg_sel_ref),
        .pma_cgb_x1_div_m_sel (pma_cgb_x1_div_m_sel),
        .pma_pcie_gen_switch_silicon_rev (pma_pcie_gen_switch_silicon_rev),
        .pma_reset_sequencer_rx_path_rstn_overrideb (pma_reset_sequencer_rx_path_rstn_overrideb),
        .pma_reset_sequencer_silicon_rev (pma_reset_sequencer_silicon_rev),
        .pma_reset_sequencer_xrx_path_uc_cal_clk_bypass (pma_reset_sequencer_xrx_path_uc_cal_clk_bypass),
        .pma_reset_sequencer_xrx_path_uc_cal_enable (pma_reset_sequencer_xrx_path_uc_cal_enable),
        .pma_rx_buf_act_isource_disable (pma_rx_buf_act_isource_disable),
        .pma_rx_buf_advanced_mode (pma_rx_buf_advanced_mode),
        .pma_rx_buf_bodybias_enable (pma_rx_buf_bodybias_enable),
        .pma_rx_buf_bodybias_select (pma_rx_buf_bodybias_select),
        .pma_rx_buf_bypass_ctle_rf_cal (pma_rx_buf_bypass_ctle_rf_cal),
        .pma_rx_buf_clk_divrx_en (pma_rx_buf_clk_divrx_en),
        .pma_rx_buf_const_gm_en (pma_rx_buf_const_gm_en),
        .pma_rx_buf_ctle_ac_gain (pma_rx_buf_ctle_ac_gain),
        .pma_rx_buf_ctle_eq_gain (pma_rx_buf_ctle_eq_gain),
        .pma_rx_buf_ctle_hires_bypass (pma_rx_buf_ctle_hires_bypass),
        .pma_rx_buf_ctle_oc_ib_sel (pma_rx_buf_ctle_oc_ib_sel),
        .pma_rx_buf_ctle_oc_sign (pma_rx_buf_ctle_oc_sign),
        .pma_rx_buf_ctle_rf_cal (pma_rx_buf_ctle_rf_cal),
        .pma_rx_buf_ctle_tia_isel (pma_rx_buf_ctle_tia_isel),
        .pma_rx_buf_diag_lp_en (pma_rx_buf_diag_lp_en),
        .pma_rx_buf_eq_bw_sel (pma_rx_buf_eq_bw_sel),
        .pma_rx_buf_eq_cdgen_sel (pma_rx_buf_eq_cdgen_sel),
        .pma_rx_buf_eq_isel (pma_rx_buf_eq_isel),
        .pma_rx_buf_eq_sel (pma_rx_buf_eq_sel),
        .pma_rx_buf_initial_settings (pma_rx_buf_initial_settings),
//        .pma_rx_buf_link (pma_rx_buf_link),
        .pma_rx_buf_loopback_modes (pma_rx_buf_loopback_modes),
        .pma_rx_buf_offset_cancellation_coarse (pma_rx_buf_offset_cancellation_coarse),
        .pma_rx_buf_offset_rx_cal_en (pma_rx_buf_offset_rx_cal_en),
        .pma_rx_buf_optimal (pma_rx_buf_optimal),
        .pma_rx_buf_pdb_rx (pma_rx_buf_pdb_rx),
        .pma_rx_buf_pm_cr2_rx_path_analog_mode (pma_rx_buf_pm_cr2_rx_path_analog_mode),
        .pma_rx_buf_pm_cr2_rx_path_datawidth (pma_rx_buf_pm_cr2_rx_path_datawidth),
        .pma_rx_buf_pm_cr2_rx_path_gt_enabled (pma_rx_buf_pm_cr2_rx_path_gt_enabled),
        .pma_rx_buf_pm_cr2_rx_path_initial_settings (pma_rx_buf_pm_cr2_rx_path_initial_settings),
        .pma_rx_buf_pm_cr2_rx_path_jtag_hys (pma_rx_buf_pm_cr2_rx_path_jtag_hys),
        .pma_rx_buf_pm_cr2_rx_path_jtag_lp (pma_rx_buf_pm_cr2_rx_path_jtag_lp),
        .pma_rx_buf_pm_cr2_rx_path_link (pma_rx_buf_pm_cr2_rx_path_link),
        .pma_rx_buf_pm_cr2_rx_path_optimal (pma_rx_buf_pm_cr2_rx_path_optimal),
        .pma_rx_buf_pm_cr2_rx_path_power_mode (pma_rx_buf_pm_cr2_rx_path_power_mode),
        .pma_rx_buf_pm_cr2_rx_path_power_rail_eht (pma_rx_buf_pm_cr2_rx_path_power_rail_eht),
        .pma_rx_buf_pm_cr2_rx_path_power_rail_er (pma_rx_buf_pm_cr2_rx_path_power_rail_er),
        .pma_rx_buf_pm_cr2_rx_path_prot_mode (pma_rx_buf_pm_cr2_rx_path_prot_mode),
        .pma_rx_buf_pm_cr2_rx_path_speed_grade (pma_rx_buf_pm_cr2_rx_path_speed_grade),
        .pma_rx_buf_pm_cr2_rx_path_sup_mode (pma_rx_buf_pm_cr2_rx_path_sup_mode),
        .pma_rx_buf_pm_cr2_rx_path_uc_cal_clk_bypass (pma_rx_buf_pm_cr2_rx_path_uc_cal_clk_bypass),
        .pma_rx_buf_pm_cr2_rx_path_uc_cal_enable (pma_rx_buf_pm_cr2_rx_path_uc_cal_enable),
        .pma_rx_buf_pm_cr2_rx_path_uc_pcie_sw (pma_rx_buf_pm_cr2_rx_path_uc_pcie_sw),
        .pma_rx_buf_pm_cr2_rx_path_uc_rx_rstb (pma_rx_buf_pm_cr2_rx_path_uc_rx_rstb),
        .pma_rx_buf_pm_cr2_rx_path_tile_type(pma_rx_buf_pm_cr2_rx_path_tile_type),
        .pma_rx_buf_pm_cr2_tx_rx_cvp_mode (pma_rx_buf_pm_cr2_tx_rx_cvp_mode),
        .pma_rx_buf_pm_cr2_tx_rx_pcie_gen (pma_rx_buf_pm_cr2_tx_rx_pcie_gen),
        .pma_rx_buf_pm_cr2_tx_rx_pcie_gen_bitwidth (pma_rx_buf_pm_cr2_tx_rx_pcie_gen_bitwidth),
        .pma_rx_buf_pm_cr2_tx_rx_testmux_select (pma_rx_buf_pm_cr2_tx_rx_testmux_select),
        .pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_left (pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_left),
        .pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_right (pma_rx_buf_pm_cr2_tx_rx_uc_odi_eye_right),
        .pma_rx_buf_pm_cr2_tx_rx_uc_rx_cal (pma_rx_buf_pm_cr2_tx_rx_uc_rx_cal),
        .pma_rx_buf_power_mode (pma_rx_buf_power_mode),
        .pma_rx_buf_power_rail_er (pma_rx_buf_power_rail_er),
        .pma_rx_buf_powermode_ac_ctle (pma_rx_buf_powermode_ac_ctle),
        .pma_rx_buf_powermode_ac_vcm (pma_rx_buf_powermode_ac_vcm),
        .pma_rx_buf_powermode_ac_vga (pma_rx_buf_powermode_ac_vga),
        .pma_rx_buf_powermode_dc_ctle (pma_rx_buf_powermode_dc_ctle),
        .pma_rx_buf_powermode_dc_vcm (pma_rx_buf_powermode_dc_vcm),
        .pma_rx_buf_powermode_dc_vga (pma_rx_buf_powermode_dc_vga),
        .pma_rx_buf_prot_mode (pma_rx_buf_prot_mode),
        .pma_rx_buf_qpi_afe_en (pma_rx_buf_qpi_afe_en),
        .pma_rx_buf_qpi_enable (pma_rx_buf_qpi_enable),
        .pma_rx_buf_refclk_en (pma_rx_buf_refclk_en),
        .pma_rx_buf_rx_atb_select (pma_rx_buf_rx_atb_select),
        .pma_rx_buf_rx_vga_oc_en (pma_rx_buf_rx_vga_oc_en),
        .pma_rx_buf_sel_vcm_ctle (pma_rx_buf_sel_vcm_ctle),
        .pma_rx_buf_sel_vcm_tia (pma_rx_buf_sel_vcm_tia),
        .pma_rx_buf_silicon_rev (pma_rx_buf_silicon_rev),
        .pma_rx_buf_sup_mode (pma_rx_buf_sup_mode),
        .pma_rx_buf_term_sel (pma_rx_buf_term_sel),
        .pma_rx_buf_term_sync_bypass (pma_rx_buf_term_sync_bypass),
        .pma_rx_buf_term_tri_enable (pma_rx_buf_term_tri_enable),
        .pma_rx_buf_tia_sel (pma_rx_buf_tia_sel),
        .pma_rx_buf_vcm_cal_i (pma_rx_buf_vcm_cal_i),
        .pma_rx_buf_vcm_current_add (pma_rx_buf_vcm_current_add),
        .pma_rx_buf_vcm_sel (pma_rx_buf_vcm_sel),
        .pma_rx_buf_vcm_sel_vccref (pma_rx_buf_vcm_sel_vccref),
        .pma_rx_buf_vga_dc_gain (pma_rx_buf_vga_dc_gain),
        .pma_rx_buf_vga_halfbw_en (pma_rx_buf_vga_halfbw_en),
        .pma_rx_buf_vga_ib_max_en (pma_rx_buf_vga_ib_max_en),
        .pma_rx_buf_vga_mode (pma_rx_buf_vga_mode),
        .pma_rx_buf_xrx_path_xcdr_deser_xcdr_loopback_mode (pma_rx_buf_xrx_path_xcdr_deser_xcdr_loopback_mode),
        .pma_rx_buf_dfe_h1_cal_en (pma_rx_buf_dfe_h1_cal_en),
        .pma_rx_buf_dfe_h1_sw_togg (pma_rx_buf_dfe_h1_sw_togg),
        .pma_rx_buf_rx_lfeq_enable (pma_rx_buf_rx_lfeq_enable),
        .pma_rx_buf_rx_ltr_load_init (pma_rx_buf_rx_ltr_load_init),
        .pma_rx_buf_rx_oc_or_lfeq_coeff (pma_rx_buf_rx_oc_or_lfeq_coeff),
        .pma_rx_deser_bitslip_bypass (pma_rx_deser_bitslip_bypass),
        .pma_rx_deser_bti_protected (pma_rx_deser_bti_protected),
        .pma_rx_deser_clkdiv_source (pma_rx_deser_clkdiv_source),
        .pma_rx_deser_clkdivrx_user_mode (pma_rx_deser_clkdivrx_user_mode),
        .pma_rx_deser_deser_aib_dftppm_en (pma_rx_deser_deser_aib_dftppm_en),
        .pma_rx_deser_deser_aibck_en (pma_rx_deser_deser_aibck_en),
        .pma_rx_deser_deser_aibck_x1 (pma_rx_deser_deser_aibck_x1),
        .pma_rx_deser_deser_factor (pma_rx_deser_deser_factor),
        .pma_rx_deser_deser_powerdown (pma_rx_deser_deser_powerdown),
        .pma_rx_deser_force_adaptation_outputs (pma_rx_deser_force_adaptation_outputs),
        .pma_rx_deser_force_clkdiv_for_testing (pma_rx_deser_force_clkdiv_for_testing),
        .pma_rx_deser_odi_adapt_bti_en (pma_rx_deser_odi_adapt_bti_en),
        .pma_rx_deser_optimal (pma_rx_deser_optimal),
        .pma_rx_deser_pcie_g3_hclk_en (pma_rx_deser_pcie_g3_hclk_en),
        .pma_rx_deser_pm_cr2_tx_rx_pcie_gen (pma_rx_deser_pm_cr2_tx_rx_pcie_gen),
        .pma_rx_deser_pm_cr2_tx_rx_pcie_gen_bitwidth (pma_rx_deser_pm_cr2_tx_rx_pcie_gen_bitwidth),
        .pma_rx_deser_powermode_ac_deser (pma_rx_deser_powermode_ac_deser),
        .pma_rx_deser_powermode_ac_deser_bs (pma_rx_deser_powermode_ac_deser_bs),
        .pma_rx_deser_powermode_dc_deser (pma_rx_deser_powermode_dc_deser),
        .pma_rx_deser_powermode_dc_deser_bs (pma_rx_deser_powermode_dc_deser_bs),
        .pma_rx_deser_prot_mode (pma_rx_deser_prot_mode),
        .pma_rx_deser_rst_n_adapt_odi (pma_rx_deser_rst_n_adapt_odi),
        .pma_rx_deser_sd_clk (pma_rx_deser_sd_clk),
        .pma_rx_deser_silicon_rev (pma_rx_deser_silicon_rev),
        .pma_rx_deser_sup_mode (pma_rx_deser_sup_mode),
        .pma_rx_deser_tdr_mode (pma_rx_deser_tdr_mode),
        .pma_rx_dfe_adapt_bti_en (pma_rx_dfe_adapt_bti_en),
        .pma_rx_dfe_atb_select (pma_rx_dfe_atb_select),
        .pma_rx_dfe_bti_protected (pma_rx_dfe_bti_protected),
        .pma_rx_dfe_dfe_bti_en (pma_rx_dfe_dfe_bti_en),
        .pma_rx_dfe_dfe_mode (pma_rx_dfe_dfe_mode),
        .pma_rx_dfe_dft_en (pma_rx_dfe_dft_en),
        .pma_rx_dfe_dft_hilospeed_sel (pma_rx_dfe_dft_hilospeed_sel),
        .pma_rx_dfe_dft_osc_sel (pma_rx_dfe_dft_osc_sel),
        .pma_rx_dfe_h1edge_bti_en (pma_rx_dfe_h1edge_bti_en),
        .pma_rx_dfe_initial_settings (pma_rx_dfe_initial_settings),
        .pma_rx_dfe_latch_xcouple_disable (pma_rx_dfe_latch_xcouple_disable),
        .pma_rx_dfe_oc_sa_cdr0e (pma_rx_dfe_oc_sa_cdr0e),
        .pma_rx_dfe_oc_sa_cdr0e_sgn (pma_rx_dfe_oc_sa_cdr0e_sgn),
        .pma_rx_dfe_oc_sa_cdr0o (pma_rx_dfe_oc_sa_cdr0o),
        .pma_rx_dfe_oc_sa_cdr0o_sgn (pma_rx_dfe_oc_sa_cdr0o_sgn),
        .pma_rx_dfe_oc_sa_cdrne (pma_rx_dfe_oc_sa_cdrne),
        .pma_rx_dfe_oc_sa_cdrne_sgn (pma_rx_dfe_oc_sa_cdrne_sgn),
        .pma_rx_dfe_oc_sa_cdrno (pma_rx_dfe_oc_sa_cdrno),
        .pma_rx_dfe_oc_sa_cdrno_sgn (pma_rx_dfe_oc_sa_cdrno_sgn),
        .pma_rx_dfe_oc_sa_cdrpe (pma_rx_dfe_oc_sa_cdrpe),
        .pma_rx_dfe_oc_sa_cdrpe_sgn (pma_rx_dfe_oc_sa_cdrpe_sgn),
        .pma_rx_dfe_oc_sa_cdrpo (pma_rx_dfe_oc_sa_cdrpo),
        .pma_rx_dfe_oc_sa_cdrpo_sgn (pma_rx_dfe_oc_sa_cdrpo_sgn),
        .pma_rx_dfe_oc_sa_dne (pma_rx_dfe_oc_sa_dne),
        .pma_rx_dfe_oc_sa_dne_sgn (pma_rx_dfe_oc_sa_dne_sgn),
        .pma_rx_dfe_oc_sa_dno (pma_rx_dfe_oc_sa_dno),
        .pma_rx_dfe_oc_sa_dno_sgn (pma_rx_dfe_oc_sa_dno_sgn),
        .pma_rx_dfe_oc_sa_dpe (pma_rx_dfe_oc_sa_dpe),
        .pma_rx_dfe_oc_sa_dpe_sgn (pma_rx_dfe_oc_sa_dpe_sgn),
        .pma_rx_dfe_oc_sa_dpo (pma_rx_dfe_oc_sa_dpo),
        .pma_rx_dfe_oc_sa_dpo_sgn (pma_rx_dfe_oc_sa_dpo_sgn),
        .pma_rx_dfe_oc_sa_odie (pma_rx_dfe_oc_sa_odie),
        .pma_rx_dfe_oc_sa_odie_sgn (pma_rx_dfe_oc_sa_odie_sgn),
        .pma_rx_dfe_oc_sa_odio (pma_rx_dfe_oc_sa_odio),
        .pma_rx_dfe_oc_sa_odio_sgn (pma_rx_dfe_oc_sa_odio_sgn),
        .pma_rx_dfe_oc_sa_vrefe (pma_rx_dfe_oc_sa_vrefe),
        .pma_rx_dfe_oc_sa_vrefe_sgn (pma_rx_dfe_oc_sa_vrefe_sgn),
        .pma_rx_dfe_oc_sa_vrefo (pma_rx_dfe_oc_sa_vrefo),
        .pma_rx_dfe_oc_sa_vrefo_sgn (pma_rx_dfe_oc_sa_vrefo_sgn),
        .pma_rx_dfe_odi_bti_en (pma_rx_dfe_odi_bti_en),
        .pma_rx_dfe_odi_dlev_sign (pma_rx_dfe_odi_dlev_sign),
        .pma_rx_dfe_odi_h1_sign (pma_rx_dfe_odi_h1_sign),
        .pma_rx_dfe_optimal (pma_rx_dfe_optimal),
        .pma_rx_dfe_pdb (pma_rx_dfe_pdb),
        .pma_rx_dfe_pdb_edge_pre_h1 (pma_rx_dfe_pdb_edge_pre_h1),
        .pma_rx_dfe_pdb_edge_pst_h1 (pma_rx_dfe_pdb_edge_pst_h1),
        .pma_rx_dfe_pdb_tap_4t9 (pma_rx_dfe_pdb_tap_4t9),
        .pma_rx_dfe_pdb_tap_10t15 (pma_rx_dfe_pdb_tap_10t15),
        .pma_rx_dfe_pdb_tapsum (pma_rx_dfe_pdb_tapsum),
        .pma_rx_dfe_power_mode (pma_rx_dfe_power_mode),
        .pma_rx_dfe_powermode_ac_dfe (pma_rx_dfe_powermode_ac_dfe),
        .pma_rx_dfe_powermode_dc_dfe (pma_rx_dfe_powermode_dc_dfe),
        .pma_rx_dfe_prot_mode (pma_rx_dfe_prot_mode),
        .pma_rx_dfe_sel_oc_en (pma_rx_dfe_sel_oc_en),
        .pma_rx_dfe_sel_probe_tstmx (pma_rx_dfe_sel_probe_tstmx),
        .pma_rx_dfe_silicon_rev (pma_rx_dfe_silicon_rev),
        .pma_rx_dfe_sup_mode (pma_rx_dfe_sup_mode),
        .pma_rx_dfe_tap1_coeff (pma_rx_dfe_tap1_coeff),
        .pma_rx_dfe_tap1_sgn (pma_rx_dfe_tap1_sgn),
        .pma_rx_dfe_tap2_coeff (pma_rx_dfe_tap2_coeff),
        .pma_rx_dfe_tap2_sgn (pma_rx_dfe_tap2_sgn),
        .pma_rx_dfe_tap3_coeff (pma_rx_dfe_tap3_coeff),
        .pma_rx_dfe_tap3_sgn (pma_rx_dfe_tap3_sgn),
        .pma_rx_dfe_tap4_coeff (pma_rx_dfe_tap4_coeff),
        .pma_rx_dfe_tap4_sgn (pma_rx_dfe_tap4_sgn),
        .pma_rx_dfe_tap5_coeff (pma_rx_dfe_tap5_coeff),
        .pma_rx_dfe_tap5_sgn (pma_rx_dfe_tap5_sgn),
        .pma_rx_dfe_tap6_coeff (pma_rx_dfe_tap6_coeff),
        .pma_rx_dfe_tap6_sgn (pma_rx_dfe_tap6_sgn),
        .pma_rx_dfe_tap7_coeff (pma_rx_dfe_tap7_coeff),
        .pma_rx_dfe_tap7_sgn (pma_rx_dfe_tap7_sgn),
        .pma_rx_dfe_tap8_coeff (pma_rx_dfe_tap8_coeff),
        .pma_rx_dfe_tap8_sgn (pma_rx_dfe_tap8_sgn),
        .pma_rx_dfe_tap9_coeff (pma_rx_dfe_tap9_coeff),
        .pma_rx_dfe_tap9_sgn (pma_rx_dfe_tap9_sgn),
        .pma_rx_dfe_tap10_coeff (pma_rx_dfe_tap10_coeff),
        .pma_rx_dfe_tap10_sgn (pma_rx_dfe_tap10_sgn),
        .pma_rx_dfe_tap11_coeff (pma_rx_dfe_tap11_coeff),
        .pma_rx_dfe_tap11_sgn (pma_rx_dfe_tap11_sgn),
        .pma_rx_dfe_tap12_coeff (pma_rx_dfe_tap12_coeff),
        .pma_rx_dfe_tap12_sgn (pma_rx_dfe_tap12_sgn),
        .pma_rx_dfe_tap13_coeff (pma_rx_dfe_tap13_coeff),
        .pma_rx_dfe_tap13_sgn (pma_rx_dfe_tap13_sgn),
        .pma_rx_dfe_tap14_coeff (pma_rx_dfe_tap14_coeff),
        .pma_rx_dfe_tap14_sgn (pma_rx_dfe_tap14_sgn),
        .pma_rx_dfe_tap15_coeff (pma_rx_dfe_tap15_coeff),
        .pma_rx_dfe_tap15_sgn (pma_rx_dfe_tap15_sgn),
        .pma_rx_dfe_tapsum_bw_sel (pma_rx_dfe_tapsum_bw_sel),
        .pma_rx_dfe_vref_coeff (pma_rx_dfe_vref_coeff),
        .pma_rx_odi_enable_cdr_lpbk (pma_rx_odi_enable_cdr_lpbk),
        .pma_rx_odi_initial_settings (pma_rx_odi_initial_settings),
        .pma_rx_odi_monitor_bw_sel (pma_rx_odi_monitor_bw_sel),
        .pma_rx_odi_optimal (pma_rx_odi_optimal),
        .pma_rx_odi_phase_steps_64_vs_128 (pma_rx_odi_phase_steps_64_vs_128),
        .pma_rx_odi_phase_steps_sel (pma_rx_odi_phase_steps_sel),
        .pma_rx_odi_power_mode (pma_rx_odi_power_mode),
        .pma_rx_odi_prot_mode (pma_rx_odi_prot_mode),
        .pma_rx_odi_silicon_rev (pma_rx_odi_silicon_rev),
        .pma_rx_odi_step_ctrl_sel (pma_rx_odi_step_ctrl_sel),
        .pma_rx_odi_sup_mode (pma_rx_odi_sup_mode),
        .pma_rx_odi_vert_threshold (pma_rx_odi_vert_threshold),
        .pma_rx_odi_vreg_voltage_sel (pma_rx_odi_vreg_voltage_sel),
        .pma_rx_odi_xrx_path_x119_rx_path_rstn_overrideb (pma_rx_odi_xrx_path_x119_rx_path_rstn_overrideb),
        .pma_rx_sd_link (pma_rx_sd_link),
        .pma_rx_sd_optimal (pma_rx_sd_optimal),
        .pma_rx_sd_power_mode (pma_rx_sd_power_mode),
        .pma_rx_sd_prot_mode (pma_rx_sd_prot_mode),
        .pma_rx_sd_sd_output_off (pma_rx_sd_sd_output_off),
        .pma_rx_sd_sd_output_on (pma_rx_sd_sd_output_on),
        .pma_rx_sd_sd_pdb (pma_rx_sd_sd_pdb),
        .pma_rx_sd_sd_threshold (pma_rx_sd_sd_threshold),
        .pma_rx_sd_silicon_rev (pma_rx_sd_silicon_rev),
        .pma_rx_sd_sup_mode (pma_rx_sd_sup_mode),
        .pma_tx_buf_bti_protected (pma_tx_buf_bti_protected),
        .pma_tx_buf_calibration_en (pma_tx_buf_calibration_en),
        .pma_tx_buf_calibration_resistor_value (pma_tx_buf_calibration_resistor_value),
        .pma_tx_buf_cdr_cp_calibration_en (pma_tx_buf_cdr_cp_calibration_en),
        .pma_tx_buf_chgpmp_current_dn_trim (pma_tx_buf_chgpmp_current_dn_trim),
        .pma_tx_buf_chgpmp_current_up_trim (pma_tx_buf_chgpmp_current_up_trim),
        .pma_tx_buf_chgpmp_dn_trim_double (pma_tx_buf_chgpmp_dn_trim_double),
        .pma_tx_buf_chgpmp_up_trim_double (pma_tx_buf_chgpmp_up_trim_double),
        .pma_tx_buf_compensation_en (pma_tx_buf_compensation_en),
        .pma_tx_buf_compensation_posttap_en (pma_tx_buf_compensation_posttap_en),
        .pma_tx_buf_cpen_ctrl (pma_tx_buf_cpen_ctrl),
        .pma_tx_buf_dcc_finestep_enin (pma_tx_buf_dcc_finestep_enin),
        .pma_tx_buf_dcd_clk_div_ctrl (pma_tx_buf_dcd_clk_div_ctrl),
        .pma_tx_buf_dcd_detection_en (pma_tx_buf_dcd_detection_en),
        .pma_tx_buf_dft_sel (pma_tx_buf_dft_sel),
        .pma_tx_buf_duty_cycle_correction_bandwidth (pma_tx_buf_duty_cycle_correction_bandwidth),
        .pma_tx_buf_duty_cycle_correction_bandwidth_dn (pma_tx_buf_duty_cycle_correction_bandwidth_dn),
        .pma_tx_buf_duty_cycle_correction_reference1 (pma_tx_buf_duty_cycle_correction_reference1),
        .pma_tx_buf_duty_cycle_correction_reference2 (pma_tx_buf_duty_cycle_correction_reference2),
        .pma_tx_buf_duty_cycle_correction_reset_n (pma_tx_buf_duty_cycle_correction_reset_n),
        .pma_tx_buf_duty_cycle_cp_comp_en (pma_tx_buf_duty_cycle_cp_comp_en),
        .pma_tx_buf_duty_cycle_detector_cp_cal (pma_tx_buf_duty_cycle_detector_cp_cal),
        .pma_tx_buf_duty_cycle_detector_sa_cal (pma_tx_buf_duty_cycle_detector_sa_cal),
        .pma_tx_buf_duty_cycle_input_polarity (pma_tx_buf_duty_cycle_input_polarity),
        .pma_tx_buf_duty_cycle_setting (pma_tx_buf_duty_cycle_setting),
        .pma_tx_buf_duty_cycle_setting_aux (pma_tx_buf_duty_cycle_setting_aux),
        .pma_tx_buf_initial_settings (pma_tx_buf_initial_settings),
        .pma_tx_buf_jtag_drv_sel (pma_tx_buf_jtag_drv_sel),
        .pma_tx_buf_jtag_lp (pma_tx_buf_jtag_lp),
//        .pma_tx_buf_link (pma_tx_buf_link),
        .pma_tx_buf_low_power_en (pma_tx_buf_low_power_en),
        .pma_tx_buf_lst (pma_tx_buf_lst),
        .pma_tx_buf_optimal (pma_tx_buf_optimal),
        .pma_tx_buf_pcie_gen (pma_tx_buf_pcie_gen),
        .pma_tx_buf_pm_cr2_tx_path_analog_mode (pma_tx_buf_pm_cr2_tx_path_analog_mode),
        .pma_tx_buf_pm_cr2_tx_path_calibration_en (pma_tx_buf_pm_cr2_tx_path_calibration_en),
        .pma_tx_buf_pm_cr2_tx_path_clock_divider_ratio (pma_tx_buf_pm_cr2_tx_path_clock_divider_ratio),
        .pma_tx_buf_pm_cr2_tx_path_datawidth (pma_tx_buf_pm_cr2_tx_path_datawidth),
        .pma_tx_buf_pm_cr2_tx_path_gt_enabled (pma_tx_buf_pm_cr2_tx_path_gt_enabled),
        .pma_tx_buf_idle_ctrl (pma_tx_buf_idle_ctrl),
        .pma_tx_buf_pm_cr2_tx_path_initial_settings (pma_tx_buf_pm_cr2_tx_path_initial_settings),
        .pma_tx_buf_pm_cr2_tx_path_link (pma_tx_buf_pm_cr2_tx_path_link),
        .pma_tx_buf_pm_cr2_tx_path_optimal (pma_tx_buf_pm_cr2_tx_path_optimal),
        .pma_tx_buf_pm_cr2_tx_path_power_mode (pma_tx_buf_pm_cr2_tx_path_power_mode),
        .pma_tx_buf_pm_cr2_tx_path_power_rail_eht (pma_tx_buf_pm_cr2_tx_path_power_rail_eht),
        .pma_tx_buf_pm_cr2_tx_path_power_rail_et (pma_tx_buf_pm_cr2_tx_path_power_rail_et),
        .pma_tx_buf_pm_cr2_tx_path_prot_mode (pma_tx_buf_pm_cr2_tx_path_prot_mode),
        .pma_tx_buf_pm_cr2_tx_path_speed_grade (pma_tx_buf_pm_cr2_tx_path_speed_grade),
        .pma_tx_buf_pm_cr2_tx_path_sup_mode (pma_tx_buf_pm_cr2_tx_path_sup_mode),
        .pma_tx_buf_pm_cr2_tx_path_swing_level (pma_tx_buf_pm_cr2_tx_path_swing_level),
        .pma_tx_buf_pm_cr2_tx_path_tile_type(pma_tx_buf_pm_cr2_tx_path_tile_type),
        .pma_tx_buf_power_rail_er (pma_tx_buf_power_rail_er),
        .pma_tx_buf_powermode_ac_post_tap (pma_tx_buf_powermode_ac_post_tap),
        .pma_tx_buf_powermode_ac_pre_tap (pma_tx_buf_powermode_ac_pre_tap),
        .pma_tx_buf_powermode_ac_tx_vod_no_jitcomp (pma_tx_buf_powermode_ac_tx_vod_no_jitcomp),
        .pma_tx_buf_powermode_ac_tx_vod_w_jitcomp (pma_tx_buf_powermode_ac_tx_vod_w_jitcomp),
        .pma_tx_buf_powermode_dc_post_tap (pma_tx_buf_powermode_dc_post_tap),
        .pma_tx_buf_powermode_dc_pre_tap (pma_tx_buf_powermode_dc_pre_tap),
        .pma_tx_buf_powermode_dc_tx_vod_no_jitcomp (pma_tx_buf_powermode_dc_tx_vod_no_jitcomp),
        .pma_tx_buf_powermode_dc_tx_vod_w_jitcomp (pma_tx_buf_powermode_dc_tx_vod_w_jitcomp),
        .pma_tx_buf_pre_emp_sign_1st_post_tap (pma_tx_buf_pre_emp_sign_1st_post_tap),
        .pma_tx_buf_pre_emp_sign_pre_tap_1t (pma_tx_buf_pre_emp_sign_pre_tap_1t),
        .pma_tx_buf_pre_emp_switching_ctrl_1st_post_tap (pma_tx_buf_pre_emp_switching_ctrl_1st_post_tap),
        .pma_tx_buf_pre_emp_switching_ctrl_pre_tap_1t (pma_tx_buf_pre_emp_switching_ctrl_pre_tap_1t),
        .pma_tx_buf_prot_mode (pma_tx_buf_prot_mode),
        .pma_tx_buf_res_cal_local (pma_tx_buf_res_cal_local),
        .pma_tx_buf_rx_det (pma_tx_buf_rx_det),
        .pma_tx_buf_rx_det_output_sel (pma_tx_buf_rx_det_output_sel),
        .pma_tx_buf_rx_det_pdb (pma_tx_buf_rx_det_pdb),
        .pma_tx_buf_sense_amp_offset_cal_curr_n (pma_tx_buf_sense_amp_offset_cal_curr_n),
        .pma_tx_buf_sense_amp_offset_cal_curr_p (pma_tx_buf_sense_amp_offset_cal_curr_p),
        .pma_tx_buf_ser_powerdown (pma_tx_buf_ser_powerdown),
        .pma_tx_buf_silicon_rev (pma_tx_buf_silicon_rev),
        .pma_tx_buf_slew_rate_ctrl (pma_tx_buf_slew_rate_ctrl),
        .pma_tx_buf_sup_mode (pma_tx_buf_sup_mode),
        .pma_tx_buf_swing_level (pma_tx_buf_swing_level),
        .pma_tx_buf_term_code (pma_tx_buf_term_code),
        .pma_tx_buf_term_n_tune (pma_tx_buf_term_n_tune),
        .pma_tx_buf_term_p_tune (pma_tx_buf_term_p_tune),
        .pma_tx_buf_term_sel (pma_tx_buf_term_sel),
        .pma_tx_buf_tri_driver (pma_tx_buf_tri_driver),
        .pma_tx_buf_tx_powerdown (pma_tx_buf_tx_powerdown),
        .pma_tx_buf_tx_rst_enable (pma_tx_buf_tx_rst_enable),
        .pma_tx_buf_uc_gen3 (pma_tx_buf_uc_gen3),
        .pma_tx_buf_uc_gen4 (pma_tx_buf_uc_gen4),
        .pma_tx_buf_uc_tx_cal (pma_tx_buf_uc_tx_cal),
        .pma_tx_buf_uc_vcc_setting (pma_tx_buf_uc_vcc_setting),
        .pma_tx_buf_user_fir_coeff_ctrl_sel (pma_tx_buf_user_fir_coeff_ctrl_sel),
        .pma_tx_buf_vod_output_swing_ctrl (pma_tx_buf_vod_output_swing_ctrl),
        .pma_tx_buf_vreg_output (pma_tx_buf_vreg_output),
        .pma_tx_buf_xtx_path_xcgb_tx_ucontrol_en (pma_tx_buf_xtx_path_xcgb_tx_ucontrol_en),
        .pma_tx_sequencer_silicon_rev (pma_tx_sequencer_silicon_rev),
        .pma_tx_sequencer_tx_path_rstn_overrideb (pma_tx_sequencer_tx_path_rstn_overrideb),
        .pma_tx_sequencer_xrx_path_uc_cal_clk_bypass (pma_tx_sequencer_xrx_path_uc_cal_clk_bypass),
        .pma_tx_sequencer_xtx_path_xcgb_tx_ucontrol_en (pma_tx_sequencer_xtx_path_xcgb_tx_ucontrol_en),
        .pma_tx_ser_bti_protected (pma_tx_ser_bti_protected),
        .pma_tx_ser_control_clks_divtx_aibtx (pma_tx_ser_control_clks_divtx_aibtx),
        .pma_tx_ser_duty_cycle_correction_mode_ctrl (pma_tx_ser_duty_cycle_correction_mode_ctrl),
        .pma_tx_ser_initial_settings (pma_tx_ser_initial_settings),
        .pma_tx_ser_pcie_gen (pma_tx_ser_pcie_gen),
        .pma_tx_ser_power_rail_er (pma_tx_ser_power_rail_er),
        .pma_tx_ser_powermode_ac_ser (pma_tx_ser_powermode_ac_ser),
        .pma_tx_ser_powermode_dc_ser (pma_tx_ser_powermode_dc_ser),
        .pma_tx_ser_prot_mode (pma_tx_ser_prot_mode),
        .pma_tx_ser_ser_aibck_enable (pma_tx_ser_ser_aibck_enable),
        .pma_tx_ser_ser_aibck_x1_override (pma_tx_ser_ser_aibck_x1_override),
        .pma_tx_ser_ser_clk_divtx_user_sel (pma_tx_ser_ser_clk_divtx_user_sel),
        .pma_tx_ser_ser_clk_mon (pma_tx_ser_ser_clk_mon),
        .pma_tx_ser_ser_dftppm_clkselect (pma_tx_ser_ser_dftppm_clkselect),
        .pma_tx_ser_ser_in_jitcomp (pma_tx_ser_ser_in_jitcomp),
        .pma_tx_ser_ser_powerdown (pma_tx_ser_ser_powerdown),
        .pma_tx_ser_ser_preset_bti_en (pma_tx_ser_ser_preset_bti_en),
        .pma_tx_ser_silicon_rev (pma_tx_ser_silicon_rev),
        .pma_tx_ser_sup_mode (pma_tx_ser_sup_mode),
        .pma_tx_ser_uc_vcc_setting (pma_tx_ser_uc_vcc_setting),
        .pma_txpath_chnsequencer_pcie_gen (pma_txpath_chnsequencer_pcie_gen),
        .pma_txpath_chnsequencer_prot_mode (pma_txpath_chnsequencer_prot_mode),
        .pma_txpath_chnsequencer_silicon_rev (pma_txpath_chnsequencer_silicon_rev),
        .pma_txpath_chnsequencer_sup_mode (pma_txpath_chnsequencer_sup_mode),
        .pma_txpath_chnsequencer_txpath_chnseq_enable (pma_txpath_chnsequencer_txpath_chnseq_enable),
        .pma_txpath_chnsequencer_txpath_chnseq_idle_direct_on (pma_txpath_chnsequencer_txpath_chnseq_idle_direct_on),
        .pma_txpath_chnsequencer_txpath_chnseq_stage_select (pma_txpath_chnsequencer_txpath_chnseq_stage_select),
        .pma_txpath_chnsequencer_txpath_chnseq_wakeup_bypass (pma_txpath_chnsequencer_txpath_chnseq_wakeup_bypass)
  ) ct2_xcvr_native_inst (
      
     /* input                              */.in_pcs_pld_10g_tx_data_valid                      ( pcs_tx_data_valid              ),
     /* input  [17:0]                      */.in_pcs_pld_tx_control                             ( pcs_tx_control[8:0]            ),
     /* input  [127:0]                     */.in_pcs_pld_tx_data                                ( pcs_tx_data[63:0]              ),
     /* output                             */.out_aibhssi_pld_10g_tx_data_valid                 ( aib_tx_data_valid              ),
     /* output  [17:0]                     */.out_aibhssi_pld_tx_control                        ( aib_tx_control                 ),
     /* output  [127:0]                    */.out_aibhssi_pld_tx_data                           ( aib_tx_data                    ),
     /* output                             */.out_pcs_pld_10g_rx_data_valid                     ( pcs_rx_data_valid              ),
     /* output  [19:0]                     */.out_pcs_pld_rx_control                            ( pcs_rx_control                 ),
     /* output  [127:0]                    */.out_pcs_pld_rx_data                               ( pcs_rx_data                    ),
     /* input   wire                       */.in_aibhssi_pld_10g_rx_data_valid                  ( pcs_rx_data_valid              ),
     /* input   wire  [9:0]                */.in_aibhssi_pld_rx_control                         ( pcs_rx_control[9:0]            ),
     /* input   wire  [76:0]               */.in_aibhssi_pld_rx_data                            ( pcs_rx_data[76:0]              ),

     /* output                             */.out_clkdiv_tx_aib                                 ( out_pma_aib_tx_clk[ig]         ),
     /* output                             */.out_pld_pcs_tx_clk_out                            ( tx_pldpcs_clkout[ig]           ),
     /* output                             */.out_pld_pcs_rx_clk_out                            ( rx_pldpcs_clkout[ig]           ),

     /* input                              */.in_aibhssi_adapter_scan_mode_n                    ( int_adapter_scan_mode_n        ),
     /* input                              */.in_aibhssi_adapter_scan_shift_n                   ( int_adapter_scan_shift_n       ),
     /* input                              */.in_iatpg_scan_mode_n                              ( int_adapter_scan_mode_n        ),
     /* input                              */.in_iatpg_scan_shift_n                             ( int_adapter_scan_shift_n       ),
     /* input                              */.in_adapter_clk_sel_n                              ( int_adapter_clk_sel_n          ),

     /* input  [4:0]                       */.in_bond_pcs10g_in_bot                             ( bond_pcs10g_in_bot[ig]         ),
     /* input  [4:0]                       */.in_bond_pcs10g_in_top                             ( bond_pcs10g_in_top[ig]         ),
     /* input  [12:0]                      */.in_bond_pcs8g_in_bot                              ( bond_pcs8g_in_bot [ig]         ),
     /* input  [12:0]                      */.in_bond_pcs8g_in_top                              ( bond_pcs8g_in_top [ig]         ),
     /* input  [11:0]                      */.in_bond_pmaif_in_bot                              ( bond_pmaif_in_bot [ig]         ),
     /* input  [11:0]                      */.in_bond_pmaif_in_top                              ( bond_pmaif_in_top [ig]         ), 
     /* input                              */.in_aibhssi_bond_rx_asn_ds_in_fifo_hold            ( int_aibhssi_bond_rx_ds_in [7]  ),      
     /* input                              */.in_aibhssi_bond_rx_fifo_ds_in_rden                ( int_aibhssi_bond_rx_ds_in [6]  ),
     /* input                              */.in_aibhssi_bond_rx_fifo_ds_in_wren                ( int_aibhssi_bond_rx_ds_in [5]  ),   
     /* input                              */.in_bond_rx_asn_ds_in_clk_en                       ( int_aibhssi_bond_rx_ds_in [4]  ),
     /* input                              */.in_bond_rx_asn_ds_in_gen3_sel                     ( int_aibhssi_bond_rx_ds_in [3]  ),
     /* input                              */.in_bond_rx_clock_ds_in_div2                       ( int_aibhssi_bond_rx_ds_in [2]  ),	  
     /* input                              */.in_bond_rx_hrdrst_ds_in_hssi_rx_dcd_cal_done      ( int_aibhssi_bond_rx_ds_in [1]  ),
     /* input                              */.in_bond_rx_hrdrst_ds_in_hssi_rx_dcd_cal_req       ( int_aibhssi_bond_rx_ds_in [0]  ),
     /* input                              */.in_aibhssi_bond_rx_asn_us_in_fifo_hold            ( int_aibhssi_bond_rx_us_in [7]  ),
     /* input                              */.in_aibhssi_bond_rx_fifo_us_in_rden                ( int_aibhssi_bond_rx_us_in [6]  ),
	   /* input                              */.in_aibhssi_bond_rx_fifo_us_in_wren                ( int_aibhssi_bond_rx_us_in [5]  ),      	        
     /* input                              */.in_bond_rx_asn_us_in_clk_en                       ( int_aibhssi_bond_rx_us_in [4]  ),
     /* input                              */.in_bond_rx_asn_us_in_gen3_sel                     ( int_aibhssi_bond_rx_us_in [3]  ),      
     /* input                              */.in_bond_rx_clock_us_in_div2                       ( int_aibhssi_bond_rx_us_in [2]  ),            
     /* input                              */.in_bond_rx_hrdrst_us_in_hssi_rx_dcd_cal_done      ( int_aibhssi_bond_rx_us_in [1]  ),
     /* input                              */.in_bond_rx_hrdrst_us_in_hssi_rx_dcd_cal_req       ( int_aibhssi_bond_rx_us_in [0]  ),
	   /* input                              */.in_aibhssi_bond_tx_fifo_ds_in_rden                ( int_aibhssi_bond_tx_ds_in [6]  ),
     /* input                              */.in_aibhssi_bond_tx_fifo_ds_in_wren                ( int_aibhssi_bond_tx_ds_in [5]  ),      
	   /* input                              */.in_bond_tx_clock_ds_in_div2                       ( int_aibhssi_bond_tx_ds_in [4]  ),  
     /* input                              */.in_bond_tx_hrdrst_ds_in_hssi_tx_dcd_cal_done      ( int_aibhssi_bond_tx_ds_in [3]  ),
     /* input                              */.in_bond_tx_hrdrst_ds_in_hssi_tx_dcd_cal_req       ( int_aibhssi_bond_tx_ds_in [2]  ),
     /* input                              */.in_bond_tx_hrdrst_ds_in_hssi_tx_dll_lock          ( int_aibhssi_bond_tx_ds_in [1]  ),
     /* input                              */.in_bond_tx_hrdrst_ds_in_hssi_tx_dll_lock_req      ( int_aibhssi_bond_tx_ds_in [0]  ),
     /* input                              */.in_aibhssi_bond_tx_fifo_us_in_rden                ( int_aibhssi_bond_tx_us_in [6]  ),
     /* input                              */.in_aibhssi_bond_tx_fifo_us_in_wren                ( int_aibhssi_bond_tx_us_in [5]  ),        
     /* input                              */.in_bond_tx_clock_us_in_div2                       ( int_aibhssi_bond_tx_us_in [4]  ),        
     /* input                              */.in_bond_tx_hrdrst_us_in_hssi_tx_dcd_cal_done      ( int_aibhssi_bond_tx_us_in [3]  ),
     /* input                              */.in_bond_tx_hrdrst_us_in_hssi_tx_dcd_cal_req       ( int_aibhssi_bond_tx_us_in [2]  ),
     /* input                              */.in_bond_tx_hrdrst_us_in_hssi_tx_dll_lock          ( int_aibhssi_bond_tx_us_in [1]  ),
     /* input                              */.in_bond_tx_hrdrst_us_in_hssi_tx_dll_lock_req      ( int_aibhssi_bond_tx_us_in [0]  ),     
     /* input                              */.in_hdpldadapt_adapter_scan_mode_n                 ( int_adapter_scan_mode_n        ),
     /* input                              */.in_hdpldadapt_adapter_scan_shift_n                ( int_adapter_scan_shift_n       ),
     /* input                              */.in_hdpldadapt_bond_rx_asn_ds_in_fifo_hold         ( int_hdpldadapt_bond_rx_ds_in	[4]  ),      
     /* input                              */.in_hdpldadapt_bond_rx_fifo_ds_in_rden             ( int_hdpldadapt_bond_rx_ds_in	[3]  ),     
     /* input                              */.in_hdpldadapt_bond_rx_fifo_ds_in_wren             ( int_hdpldadapt_bond_rx_ds_in	[2]  ),     
	   /* input                              */.in_bond_rx_hrdrst_ds_in_fabric_rx_dll_lock        ( int_hdpldadapt_bond_rx_ds_in	[1]  ),     
     /* input                              */.in_bond_rx_hrdrst_ds_in_fabric_rx_dll_lock_req    ( int_hdpldadapt_bond_rx_ds_in	[0]  ),     
	   /* input                              */.in_hdpldadapt_bond_rx_asn_us_in_fifo_hold         ( int_hdpldadapt_bond_rx_us_in	[4]  ),     
     /* input                              */.in_hdpldadapt_bond_rx_fifo_us_in_rden             ( int_hdpldadapt_bond_rx_us_in	[3]  ),  
     /* input                              */.in_hdpldadapt_bond_rx_fifo_us_in_wren             ( int_hdpldadapt_bond_rx_us_in	[2]  ),  
	   /* input                              */.in_bond_rx_hrdrst_us_in_fabric_rx_dll_lock        ( int_hdpldadapt_bond_rx_us_in	[1]  ),  
     /* input                              */.in_bond_rx_hrdrst_us_in_fabric_rx_dll_lock_req    ( int_hdpldadapt_bond_rx_us_in	[0]  ),  
     /* input                              */.in_hdpldadapt_bond_tx_fifo_ds_in_rden             ( int_hdpldadapt_bond_tx_ds_in	[4]  ), 
     /* input                              */.in_hdpldadapt_bond_tx_fifo_ds_in_wren             ( int_hdpldadapt_bond_tx_ds_in	[3]  ), 
	   /* input                              */.in_bond_tx_fifo_ds_in_dv                          ( int_hdpldadapt_bond_tx_ds_in	[2]  ), 
	   /* input                              */.in_bond_tx_hrdrst_ds_in_fabric_tx_dcd_cal_done    ( int_hdpldadapt_bond_tx_ds_in	[1]  ), 
     /* input                              */.in_bond_tx_hrdrst_ds_in_fabric_tx_dcd_cal_req     ( int_hdpldadapt_bond_tx_ds_in	[0]  ), 
     /* input                              */.in_hdpldadapt_bond_tx_fifo_us_in_rden             ( int_hdpldadapt_bond_tx_us_in	[4]  ), 
     /* input                              */.in_hdpldadapt_bond_tx_fifo_us_in_wren             ( int_hdpldadapt_bond_tx_us_in	[3]  ), 
	   /* input                              */.in_bond_tx_fifo_us_in_dv                          ( int_hdpldadapt_bond_tx_us_in	[2]  ), 
	   /* input                              */.in_bond_tx_hrdrst_us_in_fabric_tx_dcd_cal_done    ( int_hdpldadapt_bond_tx_us_in	[1]  ), 
     /* input                              */.in_bond_tx_hrdrst_us_in_fabric_tx_dcd_cal_req     ( int_hdpldadapt_bond_tx_us_in	[0]  ), 												
     /* input                              */.in_hdpldadapt_pld_pma_rxpma_rstb                  ( ~int_pld_pma_rxpma_rst	[ig]  ),			
     /* input                              */.in_hdpldadapt_pld_pma_txdetectrx                  ( tx_pma_txdetectrx   [ig]	),
     /* input                              */.in_hdpldadapt_pld_pma_txpma_rstb                  ( ~int_pld_pma_txpma_rst [ig]  ),						
     /* input                              */.in_pld_adapter_rx_pld_rst_n                       ( ~int_pld_adapter_rx_pld_rst [ig]  ),
     /* input                              */.in_pld_adapter_tx_pld_rst_n                       ( ~int_pld_adapter_tx_pld_rst [ig]  ),
     /* input                              */.in_pld_aib_fabric_rx_dll_lock_req                 ( 1'b0  ),	// Fallback mode reset signal
     /* input                              */.in_pld_aib_fabric_tx_dcd_cal_req                  ( 1'b0  ),	// Fallback mode reset signal
     /* input                              */.in_pld_aib_hssi_rx_dcd_cal_req                    ( 1'b0  ),	// Fallback mode reset signal
     /* input                              */.in_pld_aib_hssi_tx_dcd_cal_req                    ( 1'b0  ),	// Fallback mode reset signal
     /* input                              */.in_pld_aib_hssi_tx_dll_lock_req                   ( 1'b0  ),	// Fallback mode reset signal      
     /* input                              */.in_pld_partial_reconfig                           ( 1'b1  ),
     /* input                              */.in_pld_pcs_rx_pld_rst_n                           ( ~int_pld_pcs_rx_pld_rst [ig]  ),
     /* input                              */.in_pld_pcs_tx_pld_rst_n                           ( ~int_pld_pcs_tx_pld_rst [ig]  ),
     /* input                              */.in_pld_pma_coreclkin_rowclk                       ( 1'b0  ),      
     /* input                              */.in_pld_rx_clk1_dcm                                ( int_rx_coreclkin_dclk	),
     /* input                              */.in_pld_rx_clk1_rowclk                             ( int_rx_coreclkin_rowclk  ),
     /* input                              */.in_pld_rx_clk2_rowclk                             ( 1'b0  ),
     /* input                              */.in_pld_rx_dll_lock_req                            ( ~int_pld_adapter_rx_pld_rst [ig]  ),
     /* input                              */.in_pld_rx_fabric_fifo_align_clr                   ( rx_fifo_align_clr		[ig]  ),
     /* input                              */.in_pld_rx_fabric_fifo_rd_en                       ( rx_fifo_rd_en			[ig]  ),
     /* input                              */.in_pld_rx_fifo_latency_adj_en                     ( rx_fifo_latency_adj_ena	[ig]  ),
     /* input                              */.in_pld_sclk1_rowclk                               ( latency_sclk		[ig]  ),
     /* input                              */.in_pld_sclk2_rowclk                               ( clk_delay_sclk	[ig]  ),
     /* input                              */.in_pld_tx_clk1_dcm                                ( int_tx_coreclkin_dclk		),
     /* input                              */.in_pld_tx_clk1_rowclk                             ( int_tx_coreclkin_rowclk		),
     /* input                              */.in_pld_tx_clk2_dcm                                ( int_tx_x2_coreclkin_dclk		),
     /* input                              */.in_pld_tx_clk2_rowclk                             ( int_tx_x2_coreclkin_rowclk	),
     /* input                              */.in_pld_tx_dll_lock_req                            ( ~int_pld_adapter_tx_pld_rst [ig]		),
     /* input  [79:0]                      */.in_pld_tx_fabric_data_in                          ( int_tx_parallel_data	[ig*80+:80]		),
     /* input                              */.in_pld_tx_fifo_latency_adj_en                     ( tx_fifo_latency_adj_ena	[ig]  ),
	   /* input                              */.in_clk_cdr_b                                      ( 1'b0  ),
     /* input                              */.in_clk_cdr_t                                      ( 1'b0  ),
     /* input                              */.in_clk_fpll_b                                     ( tx_serial_clk0	[ig]  ),
     /* input                              */.in_clk_fpll_t                                     ( tx_serial_clk2	[ig]  ),
	   /* input                              */.in_clk_lc_hs                                      ( 1'b0  ),
     /* input                              */.in_clk_lc_b                                       ( tx_serial_clk1	[ig]  ),      
     /* input                              */.in_clk_lc_t                                       ( tx_serial_clk3	[ig]  ),	  
	   /* input                              */.in_clkb_cdr_b                                     ( 1'b0  ),
     /* input                              */.in_clkb_cdr_t                                     ( 1'b0  ),
`ifndef ALTERA_RESERVED_QIS
	   /* input                              */.in_clkb_fpll_b                                    ( ~tx_serial_clk0	[ig]  ),
     /* input                              */.in_clkb_fpll_t                                    ( ~tx_serial_clk2	[ig]  ),
     /* input                              */.in_clkb_lc_b                                      ( ~tx_serial_clk1	[ig]  ),
	   /* input                              */.in_clkb_lc_t                                      ( ~tx_serial_clk3	[ig]  ),
`else
	   /* input                              */.in_clkb_fpll_b                                    ( 1'b0  ),
     /* input                              */.in_clkb_fpll_t                                    ( 1'b0  ),
     /* input                              */.in_clkb_lc_b                                      ( 1'b0  ),
	   /* input                              */.in_clkb_lc_t                                      ( 1'b0  ),
`endif
     /* input                              */.in_clkb_lc_hs                                     ( 1'b0  ),      
     /* input  [5:0]                       */.in_cpulse_x6_dn_bus                               ( tx_bonding_clocks	[ig*6+:6]	),
     /* input  [5:0]                       */.in_cpulse_x6_up_bus                               ( tx_bonding_clocks1	[ig*6+:6]	),
     /* input  [5:0]                       */.in_cpulse_xn_dn_bus                               ( tx_bonding_clocks2	[ig*6+:6]	),
     /* input  [5:0]                       */.in_cpulse_xn_up_bus                               ( tx_bonding_clocks3	[ig*6+:6]	),      
     /*	input  [10:0]                      */.in_ref_iqclk                                      (	{6'd0,rx_cdr_refclk4,rx_cdr_refclk3,rx_cdr_refclk2,rx_cdr_refclk1,rx_cdr_refclk0}	),
`ifndef ALTERA_RESERVED_QIS
     /* input                              */.in_rx_n                                           ( ~rx_serial_data	[ig]  ),
`else
	   /* input                              */.in_rx_n                                           ( 1'b0  ),
`endif
     /* input                              */.in_rx_p                                           ( rx_serial_data	[ig]  ),            
	   /* output  [4:0]                      */.out_bond_pcs10g_out_bot                           ( bond_pcs10g_out_bot	[ig]  ),
     /* output  [4:0]                      */.out_bond_pcs10g_out_top                           ( bond_pcs10g_out_top	[ig]  ),
     /* output  [12:0]                     */.out_bond_pcs8g_out_bot                            ( bond_pcs8g_out_bot	[ig]  ),
     /* output  [12:0]                     */.out_bond_pcs8g_out_top                            ( bond_pcs8g_out_top	[ig]  ),
     /* output  [11:0]                     */.out_bond_pmaif_out_bot                            ( bond_pmaif_out_bot	[ig]  ),
     /* output  [11:0]                     */.out_bond_pmaif_out_top                            ( bond_pmaif_out_top	[ig]  ),
     /* output                             */.out_aibhssi_bond_rx_asn_ds_out_fifo_hold          ( int_aibhssi_bond_rx_ds_out [7]  ),       
     /* output                             */.out_aibhssi_bond_rx_fifo_ds_out_rden              ( int_aibhssi_bond_rx_ds_out [6]  ),  
     /* output                             */.out_aibhssi_bond_rx_fifo_ds_out_wren              ( int_aibhssi_bond_rx_ds_out [5]  ),  
	   /* output                             */.out_bond_rx_asn_ds_out_clk_en                     ( int_aibhssi_bond_rx_ds_out [4]  ),  
     /* output                             */.out_bond_rx_asn_ds_out_gen3_sel                   ( int_aibhssi_bond_rx_ds_out [3]  ),  
	   /* output                             */.out_bond_rx_clock_ds_out_div2                     ( int_aibhssi_bond_rx_ds_out [2]  ),  	  
     /* output                             */.out_bond_rx_hrdrst_ds_out_hssi_rx_dcd_cal_done    ( int_aibhssi_bond_rx_ds_out [1]  ),  
     /* output                             */.out_bond_rx_hrdrst_ds_out_hssi_rx_dcd_cal_req     ( int_aibhssi_bond_rx_ds_out [0]  ),  
	   /* output                             */.out_aibhssi_bond_rx_asn_us_out_fifo_hold          ( int_aibhssi_bond_rx_us_out [7]  ),  
     /* output                             */.out_aibhssi_bond_rx_fifo_us_out_rden              ( int_aibhssi_bond_rx_us_out [6]  ),  
     /* output                             */.out_aibhssi_bond_rx_fifo_us_out_wren              ( int_aibhssi_bond_rx_us_out [5]  ),  
	   /* output                             */.out_bond_rx_asn_us_out_clk_en                     ( int_aibhssi_bond_rx_us_out [4]  ),  
     /* output                             */.out_bond_rx_asn_us_out_gen3_sel                   ( int_aibhssi_bond_rx_us_out [3]  ),  
	   /* output                             */.out_bond_rx_clock_us_out_div2                     ( int_aibhssi_bond_rx_us_out [2]  ),    
     /* output                             */.out_bond_rx_hrdrst_us_out_hssi_rx_dcd_cal_done    ( int_aibhssi_bond_rx_us_out [1]  ),  
     /* output                             */.out_bond_rx_hrdrst_us_out_hssi_rx_dcd_cal_req     ( int_aibhssi_bond_rx_us_out [0]  ),  
     /* output                             */.out_aibhssi_bond_tx_fifo_ds_out_rden              ( int_aibhssi_bond_tx_ds_out [6]  ),  
     /* output                             */.out_aibhssi_bond_tx_fifo_ds_out_wren              ( int_aibhssi_bond_tx_ds_out [5]  ),  
	   /* output                             */.out_bond_tx_clock_ds_out_div2                     ( int_aibhssi_bond_tx_ds_out [4]  ),    
     /* output                             */.out_bond_tx_hrdrst_ds_out_hssi_tx_dcd_cal_done    ( int_aibhssi_bond_tx_ds_out [3]  ),  
     /* output                             */.out_bond_tx_hrdrst_ds_out_hssi_tx_dcd_cal_req     ( int_aibhssi_bond_tx_ds_out [2]  ),  
     /* output                             */.out_bond_tx_hrdrst_ds_out_hssi_tx_dll_lock        ( int_aibhssi_bond_tx_ds_out [1]  ),  
     /* output                             */.out_bond_tx_hrdrst_ds_out_hssi_tx_dll_lock_req    ( int_aibhssi_bond_tx_ds_out [0]  ),  
     /* output                             */.out_aibhssi_bond_tx_fifo_us_out_rden              ( int_aibhssi_bond_tx_us_out [6]  ),  
     /* output                             */.out_aibhssi_bond_tx_fifo_us_out_wren              ( int_aibhssi_bond_tx_us_out [5]  ),                              
     /* output                             */.out_bond_tx_clock_us_out_div2                     ( int_aibhssi_bond_tx_us_out [4]  ),    
     /* output                             */.out_bond_tx_hrdrst_us_out_hssi_tx_dcd_cal_done    ( int_aibhssi_bond_tx_us_out [3]  ),  
     /* output                             */.out_bond_tx_hrdrst_us_out_hssi_tx_dcd_cal_req     ( int_aibhssi_bond_tx_us_out [2]  ),  
     /* output                             */.out_bond_tx_hrdrst_us_out_hssi_tx_dll_lock        ( int_aibhssi_bond_tx_us_out [1]  ),  
     /* output                             */.out_bond_tx_hrdrst_us_out_hssi_tx_dll_lock_req    ( int_aibhssi_bond_tx_us_out [0]  ),  
     /* output                             */.out_hdpldadapt_bond_rx_asn_ds_out_fifo_hold       ( int_hdpldadapt_bond_rx_ds_out [4]  ),  
     /* output                             */.out_hdpldadapt_bond_rx_fifo_ds_out_rden           ( int_hdpldadapt_bond_rx_ds_out [3]  ),  
     /* output                             */.out_hdpldadapt_bond_rx_fifo_ds_out_wren           ( int_hdpldadapt_bond_rx_ds_out [2]  ),  
	   /* output                             */.out_bond_rx_hrdrst_ds_out_fabric_rx_dll_lock      ( int_hdpldadapt_bond_rx_ds_out [1]  ),  
     /* output                             */.out_bond_rx_hrdrst_ds_out_fabric_rx_dll_lock_req  ( int_hdpldadapt_bond_rx_ds_out [0]  ),  
	   /* output                             */.out_hdpldadapt_bond_rx_asn_us_out_fifo_hold       ( int_hdpldadapt_bond_rx_us_out [4]  ),  
     /* output                             */.out_hdpldadapt_bond_rx_fifo_us_out_rden           ( int_hdpldadapt_bond_rx_us_out [3]  ), 
     /* output                             */.out_hdpldadapt_bond_rx_fifo_us_out_wren           ( int_hdpldadapt_bond_rx_us_out [2]  ), 
	   /* output                             */.out_bond_rx_hrdrst_us_out_fabric_rx_dll_lock      ( int_hdpldadapt_bond_rx_us_out [1]  ), 
     /* output                             */.out_bond_rx_hrdrst_us_out_fabric_rx_dll_lock_req  ( int_hdpldadapt_bond_rx_us_out [0]  ), 
     /* output                             */.out_hdpldadapt_bond_tx_fifo_ds_out_rden           ( int_hdpldadapt_bond_tx_ds_out [4]  ), 
     /* output                             */.out_hdpldadapt_bond_tx_fifo_ds_out_wren           ( int_hdpldadapt_bond_tx_ds_out [3]  ), 
	   /* output                             */.out_bond_tx_fifo_ds_out_dv                        ( int_hdpldadapt_bond_tx_ds_out [2]  ),   
	   /* output                             */.out_bond_tx_hrdrst_ds_out_fabric_tx_dcd_cal_done  ( int_hdpldadapt_bond_tx_ds_out [1]  ), 
     /* output                             */.out_bond_tx_hrdrst_ds_out_fabric_tx_dcd_cal_req   ( int_hdpldadapt_bond_tx_ds_out [0]  ), 
     /* output                             */.out_hdpldadapt_bond_tx_fifo_us_out_rden           ( int_hdpldadapt_bond_tx_us_out [4]  ), 
     /* output                             */.out_hdpldadapt_bond_tx_fifo_us_out_wren           ( int_hdpldadapt_bond_tx_us_out [3]  ), 
	   /* output                             */.out_bond_tx_fifo_us_out_dv                        ( int_hdpldadapt_bond_tx_us_out [2]  ),    
	   /* output                             */.out_bond_tx_hrdrst_us_out_fabric_tx_dcd_cal_done  ( int_hdpldadapt_bond_tx_us_out [1]  ), 
     /* output                             */.out_bond_tx_hrdrst_us_out_fabric_tx_dcd_cal_req   ( int_hdpldadapt_bond_tx_us_out [0]  ), 
	   /* output                             */.out_pld_pcs_rx_clk_out1_dcm                       ( rx_clkout[ig]   ),
     /* output                             */.out_pld_pcs_rx_clk_out1_hioint                    ( rx_clkout_hioint[ig]  ),
     /* output                             */.out_pld_pcs_rx_clk_out2_dcm                       ( rx_clkout2[ig]  ),
     /* output                             */.out_pld_pcs_rx_clk_out2_hioint                    ( rx_clkout2_hioint[ig]  ),
     /* output                             */.out_pld_pcs_tx_clk_out1_dcm                       ( tx_clkout[ig]   ),
     /* output                             */.out_pld_pcs_tx_clk_out1_hioint                    ( tx_clkout_hioint[ig]  ),
     /* output                             */.out_pld_pcs_tx_clk_out2_dcm                       ( tx_clkout2[ig]  ),
     /* output                             */.out_pld_pcs_tx_clk_out2_hioint                    ( tx_clkout2_hioint[ig]  ),												
     /* output                             */.out_hdpldadapt_pld_8g_signal_detect_out           ( rx_std_signaldetect      [ig]  ),			
     /* output                             */.out_hdpldadapt_pld_pma_pfdmode_lock               ( rx_is_lockedtoref [ig]	),
     ///* output  [4:0]                      */.out_hdpldadapt_pld_pma_reserved_in                ( pma_reserved_in[ig*5+:5]), 
     /* output                             */.out_hdpldadapt_pld_pma_rx_found                   ( tx_pma_rxfound		[ig]	),		
     `ifdef ALTERA_XCVR_S10_PRBS_STATUS_SSRPATH
     /* output                             */.out_hdpldadapt_pld_rx_prbs_done                   ( rx_prbs_done_int			[ig]	),
     /* output                             */.out_hdpldadapt_pld_rx_prbs_err                    ( rx_prbs_err_int			[ig]  ),
     `else
     /* output                             */.out_hdpldadapt_pld_rx_prbs_done                   ( /*unused*/                 ),
     /* output                             */.out_hdpldadapt_pld_rx_prbs_err                    ( /*unused*/                 ),
     `endif
     /* output  [19:0]                     */.out_hdpldadapt_pld_test_data                      ( int_pldadapt_out_test_data ),
     /* output                             */.out_pld_pmaif_mask_tx_pll                         ( int_pld_pmaif_mask_tx_pll  ),
     /* output                             */.out_pld_aib_hssi_tx_dll_lock                      ( tx_dll_lock			[ig]  ),
     /* output                             */.out_pld_fabric_tx_transfer_en                     ( int_tx_transfer_ready	[ig]  ),      
     /* output                             */.out_pld_hssi_rx_transfer_en                       ( int_rx_transfer_ready	[ig]  ),
     /* output                             */.out_pld_pma_hclk_hioint                           ( int_pipe_hclk_out  ),
     /* output                             */.out_pld_pma_internal_clk1_hioint                  ( delay_measurement_clkout		[ig]	),
     /* output                             */.out_pld_pma_internal_clk2_hioint                  ( delay_measurement_clkout2	[ig]	),
     /* output  [79:0]                     */.out_pld_rx_fabric_data_out                        ( int_rx_parallel_data			[ig*80+:80]	),
     /* output                             */.out_pld_rx_fabric_fifo_del                        ( rx_fifo_del				[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_empty                      ( rx_fifo_empty			[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_full                       ( rx_fifo_full				[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_insert                     ( rx_fifo_insert			[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_latency_pulse              ( rx_fifo_latency_pulse	[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_pempty                     ( rx_fifo_pempty			[ig]	),
     /* output                             */.out_pld_rx_fabric_fifo_pfull                      ( rx_fifo_pfull			[ig]	),
     /* output                             */.out_pld_rx_hssi_fifo_empty                        ( rx_pcs_fifo_empty		[ig]	),
     /* output                             */.out_pld_rx_hssi_fifo_full                         ( rx_pcs_fifo_full			[ig]	),
     /* output                             */.out_pld_rx_hssi_fifo_latency_pulse                ( rx_pcs_fifo_latency_pulse	[ig]  ),      
     /* output                             */.out_pld_tx_fabric_fifo_empty                      ( tx_fifo_empty				[ig]	),
     /* output                             */.out_pld_tx_fabric_fifo_full                       ( tx_fifo_full					[ig]	),
     /* output                             */.out_pld_tx_fabric_fifo_latency_pulse              ( tx_fifo_latency_pulse		[ig]	),
     /* output                             */.out_pld_tx_fabric_fifo_pempty                     ( tx_fifo_pempty				[ig]	),
     /* output                             */.out_pld_tx_fabric_fifo_pfull                      ( tx_fifo_pfull				[ig]	),
     /* output                             */.out_pld_tx_hssi_fifo_empty                        ( tx_pcs_fifo_empty			[ig]	),
     /* output                             */.out_pld_tx_hssi_fifo_full                         ( tx_pcs_fifo_full				[ig]	),
     /* output                             */.out_pld_tx_hssi_fifo_latency_pulse                ( tx_pcs_fifo_latency_pulse	[ig]	),      
     /* output                             */.out_tx_n                                          ( /*unused*/  ),
     /* output                             */.out_tx_p                                          ( tx_serial_data	[ig]  ),
     /* input  [avmm_interfaces-1     :0]  */.avmm_clk                                          ( avmm_clk         [ig]                    ),
     /* input  [avmm_interfaces-1     :0]  */.avmm_reset                                        ( avmm_reset       [ig]                    ),
     /* input  [avmm_interfaces*8-1   :0]  */.avmm_writedata                                    ( avmm_writedata   [ig*8+:8]               ),
     /* input	 [avmm_interfaces*10-1  :0]	 */.avmm_address                                      ( avmm_address     [ig*RCFG_ADDR_BITS+:10] ),
     /* input  [avmm_interfaces-1     :0]  */.avmm_write                                        ( avmm_write       [ig]                    ),
     /* input  [avmm_interfaces-1     :0]  */.avmm_read                                         ( avmm_read        [ig]                    ),
     /* output [avmm_interfaces*8-1   :0]  */.avmm_readdata                                     ( avmm_readdata    [ig*8+:8]               ),
     /* output [avmm_interfaces-1     :0]  */.avmm_waitrequest                                  ( avmm_waitrequest [ig]                    ),
     /* output                             */.out_pld_avmm1_busy                                ( int_avmm_busy        [ig]                    ),
     /* output                             */.out_pld_chnl_cal_done                             ( pld_cal_done	   [ig]                    ),
     /* output  [avmm_interfaces-1     :0] */.avmm_request                                      ( avmm_request_int [ig]                    ), //Output from AVMM1 soft logic
     /* input                              */.in_hdpldadapt_pld_avmm1_request                   ( avmm_request_int [ig]                    ), //Input to AVMM1 atom
     /* input  [8:0]                       */.in_pld_avmm1_reserved_in                          ( 9'b0                                     ), //Not used. Tie-off.
     /* input  [1:0]						           */.in_pcie_sw_done_master_in                         ( int_pipe_sw_done  ),
     /* output [1:0]						           */.out_pcie_sw_master								                ( int_pipe_sw		 ),      
     /* input                              */.in_hip_aib_async_out                              ( int_in_hip_aib_async_out			),
     /* input                              */.in_hip_aib_clk                                    ( int_in_hip_aib_clk				),
     /* input                              */.in_hip_aib_clk_2x                                 ( int_in_hip_aib_clk_2x			),
     /* input  [77:0]                      */.in_hip_aib_sync_data_out                          ( int_in_hip_aib_sync_data_out		),
     /* input                              */.in_hip_aib_txeq_clk_out                           ( int_in_hip_aib_txeq_clk_out		),
     /* input  [9:0]                       */.in_hip_aib_txeq_out                               ( int_in_hip_aib_txeq_out			),
     /* input                              */.in_hip_aib_txeq_rst_n                             ( int_in_hip_aib_txeq_rst_n		),
     /* input  [63:0]                      */.in_hip_tx_data                                    ( int_in_hip_tx_data				),
     /* input  [3:0]                       */.in_aibhssi_hip_aib_fsr_out                        ( int_in_aibhssi_hip_aib_fsr_out	),
     /* input	 [7:0]		                   */.in_aibhssi_hip_aib_ssr_out                        ( int_in_aibhssi_hip_aib_ssr_out	),
     /* input                              */.in_hclk_in                                        ( pipe_hclk_in						),
     /* input  [3:0]                       */.in_hdpldadapt_hip_aib_fsr_in                      ( hip_aib_fsr_in	[ig*4+:4]		),
     /* input  [39:0]                      */.in_hdpldadapt_hip_aib_ssr_in                      ( hip_aib_ssr_in	[ig*40+:40]		),
     /* output  [3:0]                      */.out_aibhssi_hip_aib_fsr_in                        ( int_out_aibhssi_hip_aib_fsr_in	),
     /* output  [39:0]                     */.out_aibhssi_hip_aib_ssr_in                        ( int_out_aibhssi_hip_aib_ssr_in	),
     /* output                             */.out_aibhssi_pld_pma_rxpma_rstb                    ( int_out_aibhssi_pld_pma_rxpma_rstb		),
     /* output                             */.out_aibhssi_pld_pma_txpma_rstb                    ( int_out_aibhssi_pld_pma_txpma_rstb		),  
     /* output  [23:0]                     */.out_aib_hip_ctrl_out                              ( int_out_aib_hip_ctrl_out			),
     /* output  [6:0]                      */.out_aib_hip_txeq_in                               ( int_out_aib_hip_txeq_in			),
     /* output  [3:0]                      */.out_hdpldadapt_hip_aib_fsr_out                    ( hip_aib_fsr_out	[ig*4+:4]		),
     /* output  [7:0]                      */.out_hdpldadapt_hip_aib_ssr_out                    ( hip_aib_ssr_out	[ig*8+:8]		),   	
     /* output  [2:0]                      */.out_hip_aib_status                                ( int_out_hip_aib_status			),
     /* output  [77:0]                     */.out_hip_aib_sync_data_in                          ( int_out_hip_aib_sync_data_in		),
     /* output  [2:0]                      */.out_hip_clk_out                                   ( int_out_hip_clk_out				),
     /* output	[7:0]						           */.out_hip_ctrl_out                                  ( int_out_hip_ctrl_out				),
     /* output  [50:0]                     */.out_hip_rx_data                                   ( int_out_hip_rx_data				),
     /* input                              */.in_pcs_pld_8g_g3_rx_pld_rst_n                     ( int_in_pcs_pld_8g_g3_rx_pld_rst_n		),
     /* input                              */.in_pcs_pld_8g_g3_tx_pld_rst_n                     ( int_in_pcs_pld_8g_g3_tx_pld_rst_n		),
     /* input                              */.in_pcs_pld_pma_rxpma_rstb                         ( int_in_pld_pma_rxpma_rstb				),
     /* input                              */.in_pcs_pld_pma_txpma_rstb                         ( int_in_pld_pma_txpma_rstb				),
     /* input                              */.in_pld_8g_rxpolarity                              ( int_in_pld_8g_rxpolarity					),
     /* input  [17:0]                      */.in_pld_g3_current_coeff                           ( int_in_pld_g3_current_coeff				),
     /* input  [2:0]                       */.in_pld_g3_current_rxpreset                        ( int_in_pld_g3_current_rxpreset			),
     /* input  [1:0]                       */.in_pld_rate                                       ( int_in_pld_rate							),
     /* output                             */.out_aibhssi_pld_8g_g3_rx_pld_rst_n                ( int_out_aibhssi_pld_8g_g3_rx_pld_rst_n	),
     /* output                             */.out_aibhssi_pld_8g_g3_tx_pld_rst_n                ( int_out_aibhssi_pld_8g_g3_tx_pld_rst_n	),      
     /* output  [1:0]                      */.out_pld_avmm2_reserved_out                        ( {rx_fifo_ready[ig], tx_fifo_ready[ig]}	) , // For debugging and fallback mode [1:0] = {pld_rx_fifo_ready, pld_tx_fifo_ready}
     /* output                             */.out_clkdiv_rx                                     ( rx_pma_iqtxrx_clkout[ig]  ),
     /* output                             */.out_clkdiv_tx                                     ( tx_pma_iqtxrx_clkout[ig]  ),		            
     /* input                              */.in_pld_10g_krfec_rx_clr_errblk_cnt                ( rx_enh_clr_errblk_count  [ig]		),
     /* input                              */.in_pld_10g_rx_clr_ber_count                       ( rx_enh_highber_clr_cnt   [ig]		),
     /* input  [6:0]                       */.in_pld_10g_tx_bitslip                             ( tx_enh_bitslip           [ig*7+:7]	),
     /* input                              */.in_pld_10g_tx_burst_en                            ( tx_enh_frame_burst_en    [ig]		),
     /* input  [1:0]                       */.in_pld_10g_tx_diag_status                         ( tx_enh_frame_diag_status [ig*2+:2]	),
     /* input                              */.in_pld_10g_tx_wordslip                            ( 1'b0									),	// engineering mode only
     /* input                              */.in_pld_8g_a1a2_size                               ( rx_std_wa_a1a2size       [ig]		),
     /* input                              */.in_pld_8g_bitloc_rev_en                           ( rx_std_bitrev_ena        [ig]		),
     /* input                              */.in_pld_8g_byte_rev_en                             ( rx_std_byterev_ena       [ig]		),
     /* input  [2:0]                       */.in_pld_8g_eidleinfersel                           ( pipe_rx_eidleinfersel    [ig*3+:3]	),
     /* input                              */.in_pld_8g_encdt                                   ( rx_std_wa_patternalign   [ig]		),
     /* input  [4:0]                       */.in_pld_8g_tx_boundary_sel                         ( tx_std_bitslipboundarysel[ig*5+:5]	),
     /* input                              */.in_pld_bitslip                                    ( rx_bitslip				[ig]		),
     /* input                              */.in_pld_ltr                                        ( int_rx_set_locktoref		[ig]		),
     /* input                              */.in_pld_pma_adapt_start                            ( rx_adapt_start			[ig]		),
     /* input                              */.in_pld_pma_csr_test_dis                           ( 1'b1									),
     /* input                              */.in_pld_pma_early_eios                             ( 1'b0									),
     /* input  [5:0]                       */.in_pld_pma_eye_monitor                            ( 6'b0									),
     /* input                              */.in_pld_pma_ltd_b                                  ( ~int_rx_set_locktodata	[ig]		),
     /* input  [1:0]                       */.in_pld_pma_pcie_switch                            ( 2'd0									),
     /* input                              */.in_pld_pma_ppm_lock                               ( 1'b1									),	// Default to 1 given soft PPM detector is not supported
     /* input  [4:0]                       */.in_pld_pma_reserved_out                           ( { ~rx_adapt_reset[ig], 2'd0, int_hip_in_reserved_out[ig*2+:2] } ),
     /* input                              */.in_pld_pma_rs_lpbk_b                              ( ~int_rx_seriallpbken		[ig]		),
     /* input                              */.in_pld_pma_rx_qpi_pullup                          ( ~rx_pma_qpipulldn		[ig]		),
     /* input                              */.in_pld_pma_tx_bitslip                             ( 1'b0									),	// Deprecated
     /* input                              */.in_pld_pma_tx_qpi_pulldn                          ( ~tx_pma_qpipulldn		[ig]		),
     /* input                              */.in_pld_pma_tx_qpi_pullup                          ( ~tx_pma_qpipullup		[ig]		),
     /* input                              */.in_pld_pmaif_rxclkslip                            ( rx_pma_clkslip			[ig]		),
     /* input                              */.in_pld_polinv_rx                                  ( rx_polinv				[ig]		),
     /* input                              */.in_pld_polinv_tx                                  ( tx_polinv				[ig]		),
     /* input                              */.in_pld_rx_prbs_err_clr                            ( int_rx_prbs_err_clr		[ig]		),
     /* input                              */.in_pld_syncsm_en                                  ( 1'b1									),
     /* input                              */.in_pld_txelecidle                                 ( tx_pma_elecidle			[ig]		),                  
     /* output                             */.out_hdpldadapt_pld_pma_rxpll_lock                 ( rx_is_lockedtodata		[ig]		),                                     
     /* output                             */.out_pld_10g_krfec_rx_blk_lock                     ( rx_enh_blk_lock			[ig]		),
     /* output  [1:0]                      */.out_pld_10g_krfec_rx_diag_data_status             ( rx_enh_frame_diag_status	[ig*2+:2]	),
     /* output                             */.out_pld_10g_krfec_rx_frame                        ( rx_enh_frame				[ig]		),
     /* output                             */.out_pld_10g_krfec_tx_frame                        ( tx_enh_frame				[ig]		),      
     /* output                             */.out_pld_10g_rx_crc32_err                          ( rx_enh_crc32_err			[ig]		),      
     /* output                             */.out_pld_10g_rx_frame_lock                         ( rx_enh_frame_lock		[ig]		),
     /* output                             */.out_pld_10g_rx_hi_ber                             ( rx_enh_highber			[ig]		),      
     /* output                             */.out_pld_8g_empty_rmf                              ( rx_std_rmfifo_empty      [ig]		),      
     /* output                             */.out_pld_8g_full_rmf                               ( rx_std_rmfifo_full       [ig]		),      
     /* output                             */.out_pld_8g_rxelecidle                             ( pipe_rx_elecidle         [ig]		),
     /* output  [4:0]                      */.out_pld_8g_wa_boundary                            ( rx_std_bitslipboundarysel[ig*5+:5]	),      
     /* output                             */.out_pld_hssi_osc_transfer_en                      ( osc_transfer_en[ig]  ) // internal use only
  );
 
  //hip_cal_done (from AVMM1 atom) is wired to out_hip_ctrl_out[6] for every channel in ct2_xcvr_channel.sv
  assign hip_cal_done[ig] = int_out_hip_ctrl_out[6];

end
endgenerate

endmodule // altera_xcvr_native_s10

