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
# -                                                              - # 
# ---------------------------------------------------------------- #

#set current_inst [get_current_instance]

#-----------------------------------#
#-- Async user reset synchronizer --#
#-----------------------------------#
set resync_reset_din_s1 [get_registers -nowarn alt_xcvr_resync_reset|resync_chains[0].synchronizer_nocut|din_s1]
set resync_reset_dreg [get_registers -nowarn alt_xcvr_resync_reset|resync_chains[0].synchronizer_nocut|dreg[0]]
set resync_din_s1_clrn_pin [get_pins -compat -nowarn alt_xcvr_resync_reset|resync_chains[0].synchronizer_nocut|din_s1|clrn]
set resync_dreg_clrn_pin [get_pins -compat -nowarn alt_xcvr_resync_reset|resync_chains[0].synchronizer_nocut|dreg[0]|clrn]

if {[get_collection_size $resync_reset_din_s1] > 0 } {
  foreach_in_collection reg $resync_reset_din_s1 {
    foreach_in_collection pin $resync_din_s1_clrn_pin {
      set_false_path -to $reg -through $pin
    }
  }
}

if {[get_collection_size $resync_reset_dreg] > 0 } {
  foreach_in_collection reg $resync_reset_dreg {
    foreach_in_collection pin $resync_dreg_clrn_pin {
      set_false_path -to $reg -through $pin
    }
  }
}

#-----------------------------------#
#-- TX async signals synchronizer --#
#-----------------------------------#
set resync_tx_signals [get_keepers -nowarn g_tx.g_tx[*].g_tx.resync_tx_cal_busy|resync_chains[?].synchronizer_nocut|din_s1]
if {[get_collection_size $resync_tx_signals] > 0 } {
  foreach_in_collection kpr $resync_tx_signals {
    set_false_path -to $kpr
  }
}

#-----------------------------------#
#-- RX async signals synchronizer --#
#-----------------------------------#
set resync_rx_signals [get_keepers -nowarn g_rx.g_rx[*].g_rx.resync_rx_cal_busy|resync_chains[?].synchronizer_nocut|din_s1]
if {[get_collection_size $resync_rx_signals] > 0 } {
  foreach_in_collection kpr $resync_rx_signals {
    set_false_path -to $kpr
  }
}
