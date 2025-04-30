# (C) 2001-2019 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# ---------------------------------------------------------------- #
# -                                                              - #
# --- THIS IS AN AUTO-GENERATED FILE!                          --- #
# --- Do not change the contents of this file.                 --- # 
# --- Your changes will be lost once the IP is regenerated!    --- #
# ---                                                          --- #
# --- This file contains the global timing constraints for     --- #
# --- Native PHY IP                                            --- #
# ---    * Clock creation and other constraints are contained  --- #
# ---      ${ip_name}_alt_xcvr_native_qufrg4q.sdc              --- #
# -                                                              - # 
# ---------------------------------------------------------------- #

set script_dir [file dirname [info script]] 
set split_qsys_output_name [split ex_100g_altera_xcvr_native_s10_htile_191_qufrg4q "_"]
set xcvr_nphy_index [lsearch $split_qsys_output_name "altera"]
if {$xcvr_nphy_index < 0} {
  set list_top_inst_name $split_qsys_output_name
} else {
  set list_top_inst_name [lreplace $split_qsys_output_name $xcvr_nphy_index end]
}
set top_inst_name [join $list_top_inst_name "_"]
source "${script_dir}/${top_inst_name}_ip_parameters_qufrg4q.tcl"

# Find the current Native PHY instance name in the design
set instance_name [get_current_instance]


#-------------------------------------------------- #
#---                                            --- #
#--- SET_FALSE_PATH for TX BONDING              --- #
#---                                            --- #
#-------------------------------------------------- #

set pld_tx_clk_dcm_pin_col [get_pins -compat -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_clk*_dcm]

# Remove all paths for TX bonding signals
if {[dict get $native_phy_ip_params bonded_mode_profile0] == "pma_pcs" && [get_collection_size $pld_tx_clk_dcm_pin_col] > 0 } {

  # Cutting fake paths between continguously placed, but separately bonded Native PHY IP instances
  set pld_clk_dcm_reg_col    [get_registers -nowarn *|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_clk*_dcm.reg]

  if {[get_collection_size $pld_clk_dcm_reg_col] > 0} {
    set_false_path -through $pld_tx_clk_dcm_pin_col -to $pld_clk_dcm_reg_col
  }
}

#-------------------------------------------------- #
#---                                            --- #
#--- Internal loopback path                     --- #
#---                                            --- #
#-------------------------------------------------- #

set duplex_mode     [dict get $native_phy_ip_params duplex_mode_profile0]

# Cut internal loopback paths from TX instance when simplex is enabled and merging TX and RX simplex into same channel
if { $duplex_mode == "tx" } {
  set tx_fabric_data_out_col            [get_pins -compat -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|aib_fabric_tx_data_out*]
  set tx_aibnd_idata_col                [get_pins -compat -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_aibnd_tx.inst_ct1_hssi_aibnd_tx|idat*]
  set rx_transfer_clk_reg_col           [get_registers -nowarn    *g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_fabric_rx_transfer_clk.reg]
  set aib_tx_internal_div_reg_col       [get_registers -nowarn    $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_tx_internal_div.reg]
  set aib_fabric_pma_aib_tx_clk_col     [get_registers -nowarn    $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_fabric_pma_aib_tx_clk.reg]
  set aib_fabric_pma_aib_tx_clk_pin_col [get_pins -compat -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|aib_fabric_pma_aib_tx_clk]

  if {[get_collection_size $pld_tx_clk_dcm_pin_col] > 0  &&  [get_collection_size $rx_transfer_clk_reg_col] > 0} {
    set_false_path -through $pld_tx_clk_dcm_pin_col -to $rx_transfer_clk_reg_col
    if {[get_collection_size $tx_fabric_data_out_col] > 0 && [get_collection_size $tx_aibnd_idata_col] > 0} {
      set_false_path -from $pld_tx_clk_dcm_pin_col -through $tx_fabric_data_out_col -through $tx_aibnd_idata_col -to $rx_transfer_clk_reg_col
    }
  }

  if {[get_collection_size $aib_fabric_pma_aib_tx_clk_pin_col] > 0 && [get_collection_size $tx_fabric_data_out_col] > 0 && [get_collection_size $tx_aibnd_idata_col] > 0 && [get_collection_size $rx_transfer_clk_reg_col] > 0} {
    set_false_path -from $aib_fabric_pma_aib_tx_clk_pin_col -through $tx_fabric_data_out_col -through $tx_aibnd_idata_col -to $rx_transfer_clk_reg_col
  }

  if {[get_collection_size $aib_fabric_pma_aib_tx_clk_col] > 0 && [get_collection_size $tx_fabric_data_out_col] > 0 && [get_collection_size $tx_aibnd_idata_col] > 0 && [get_collection_size $rx_transfer_clk_reg_col] > 0} {
    set_false_path -from $aib_fabric_pma_aib_tx_clk_col -through $tx_fabric_data_out_col -through $tx_aibnd_idata_col -to $rx_transfer_clk_reg_col
  }

  if {[get_collection_size $aib_tx_internal_div_reg_col] > 0 && [get_collection_size $aib_fabric_pma_aib_tx_clk_pin_col] > 0 && [get_collection_size $rx_transfer_clk_reg_col] > 0} {
    set_false_path -from $aib_tx_internal_div_reg_col -through $aib_fabric_pma_aib_tx_clk_pin_col -to $rx_transfer_clk_reg_col
  }
}

  # -------------------------------------------------------------------------------------------------- #
  # --- set false path for physical adjacent channel transfer clock connections to other phy IPs   --- #
  # -------------------------------------------------------------------------------------------------- #
  set aib_tx_internal_div_reg_col [get_registers -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_tx_internal_div.reg]
  set my_aib_fabric_transfer_clk_col [get_registers -nowarn $instance_name|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~*aib_fabric_tx_transfer_clk.reg]
  set oth_aib_fabric_transfer_clk_col [get_registers -nowarn *|g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~*aib_fabric_tx_transfer_clk.reg]
  if { [get_collection_size $my_aib_fabric_transfer_clk_col] > 0 } {
    set oth_aib_fabric_transfer_clk_col [remove_from_collection $oth_aib_fabric_transfer_clk_col $my_aib_fabric_transfer_clk_col]
  }
  if { [get_collection_size $aib_tx_internal_div_reg_col] > 0 && [get_collection_size $oth_aib_fabric_transfer_clk_col] > 0 } {
    set_false_path -from $aib_tx_internal_div_reg_col -to $oth_aib_fabric_transfer_clk_col 
  }
 
#-------------------------------------------------- #
#---                                            --- #
#--- DISABLE MIN_PULSE_WIDTH CHECK on fPLL      --- #
#---                                            --- #
#-------------------------------------------------- #

# Disable min_width_pulse for fPLL counter nodes
set all_ports_list [get_ports *]
foreach_in_collection port $all_ports_list {

  set fpll_counter_nodes_list [get_nodes -nowarn [get_node_info -name $port]~inputFITTER_INSERTED_FITTER_INSERTED~fpll_c?_div]

  if {[get_collection_size $fpll_counter_nodes_list] > 0} {
    foreach_in_collection fpll_counter_node $fpll_counter_nodes_list {
      disable_min_pulse_width [get_node_info -name $fpll_counter_node]
    }
  }
}


