if {0} {
   unset native_phy_ip_params
}

set native_phy_ip_params [dict create]

dict set native_phy_ip_params profile_cnt "1"
set ::GLOBAL_corename ex_100g_altera_xcvr_native_s10_htile_191_qufrg4q
# -------------------------------- #
# --- Default Profile settings --- #
# -------------------------------- #
dict set native_phy_ip_params channels_profile0 "4"
dict set native_phy_ip_params set_data_rate_profile0 "25781.25"
dict set native_phy_ip_params bonded_mode_profile0 "not_bonded"
dict set native_phy_ip_params tx_enable_profile0 "1"
dict set native_phy_ip_params rx_enable_profile0 "1"
dict set native_phy_ip_params rcfg_enable_profile0 "1"
dict set native_phy_ip_params set_prbs_soft_logic_enable_profile0 "0"
dict set native_phy_ip_params l_tx_fifo_transfer_mode_profile0 "x2"
dict set native_phy_ip_params l_rx_fifo_transfer_mode_profile0 "x2"
dict set native_phy_ip_params std_pcs_pma_width_profile0 "10"
dict set native_phy_ip_params enh_pcs_pma_width_profile0 "64"
dict set native_phy_ip_params pcs_direct_width_profile0 "8"
dict set native_phy_ip_params datapath_select_profile0 "Enhanced"
dict set native_phy_ip_params protocol_mode_profile0 "basic_enh"
dict set native_phy_ip_params tx_fifo_mode_profile0 "Basic"
dict set native_phy_ip_params rx_fifo_mode_profile0 "Phase compensation-Basic"
dict set native_phy_ip_params std_tx_byte_ser_mode_profile0 "Disabled"
dict set native_phy_ip_params std_rx_byte_deser_mode_profile0 "Disabled"
dict set native_phy_ip_params duplex_mode_profile0 "duplex"
dict set native_phy_ip_params enable_hip_profile0 "0"
dict set native_phy_ip_params tx_clkout_sel_profile0 "pcs_clkout"
dict set native_phy_ip_params rx_clkout_sel_profile0 "pcs_clkout"
dict set native_phy_ip_params enable_port_tx_clkout2_profile0 "1"
dict set native_phy_ip_params enable_port_rx_clkout2_profile0 "1"
dict set native_phy_ip_params tx_clkout2_sel_profile0 "pma_div_clkout"
dict set native_phy_ip_params rx_clkout2_sel_profile0 "pma_div_clkout"
dict set native_phy_ip_params tx_pma_div_clkout_divider_profile0 "33"
dict set native_phy_ip_params rx_pma_div_clkout_divider_profile0 "33"
