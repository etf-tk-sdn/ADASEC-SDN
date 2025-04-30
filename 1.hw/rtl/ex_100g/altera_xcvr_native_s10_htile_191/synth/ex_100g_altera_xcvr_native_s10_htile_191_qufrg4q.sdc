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
# --- This file contains the timing constraints for Native PHY --- #
# ---    * The helper functions are defined in                 --- #
# ---      alt_xcvr_native_helper_functions_qufrg4q.tcl        --- #
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
source "${script_dir}/alt_xcvr_native_helper_functions_qufrg4q.tcl"

# Debug switch. Change to 1 in alt_xcvr_native_helper_functions_qufrg4q.tcl to get more run-time debug information
if {![info exists native_debug]} {
  global ::native_debug
}

# ---------------------------------------------------------------- #
# -                                                              - #
# --- Build cache for all pins and registers required to apply --- #
# --- timing constraints                                       --- #
# -                                                              - #
# ---------------------------------------------------------------- #
native_initialize_db_qufrg4q nativedb_qufrg4q

# ---------------------------------------------------------------- #
# --- Set all the instances of this core                       --- #
# ---------------------------------------------------------------- #
set alt_xcvr_native_s10_instances [ dict keys $nativedb_qufrg4q ]

if {[info exists alt_xcvr_native_s10_pins]} {
   unset alt_xcvr_native_s10_pins
}
set alt_xcvr_native_s10_pins [dict create]

# ---------------------------------------------------------------- #
# -                                                              - #
# --- Iterate through each instance and apply the necessary    --- #
# --- timing constraints                                       --- #
# -                                                              - #
# ---------------------------------------------------------------- #
foreach inst $alt_xcvr_native_s10_instances {

  if { [ dict exists $alt_xcvr_native_s10_pins $inst ] } {
    dict unset alt_xcvr_native_s10_pins $inst
    
    if { $native_debug == 1} {
      post_message -type info "IP SDC: Array pins for instance $inst existed before, unsetting them"
    }

  } 
  dict set alt_xcvr_native_s10_pins $inst [dict get $nativedb_qufrg4q $inst]

  # Delete the clock names array if it exists 
  if [info exists all_profile_clocks_names] {
    unset all_profile_clocks_names
  }
  set all_profile_clocks_names [dict create]

  # -------------------------------------------------------------- #
  # --- Iterate over the profiles                              --- #
  # -------------------------------------------------------------- #
  set profile_cnt [dict get $native_phy_ip_params profile_cnt]
  set tx_enabled_on_any_profile    0
  set max_num_channels             0
  for {set i 0} {$i < $profile_cnt} {incr i} {

    if {$native_debug == 1} {
      post_message -type info "========================================================================================"
      post_message -type info "IP SDC: PROFILE $i"
    }

    set num_channels [dict get $native_phy_ip_params channels_profile$i]
    set max_num_channels  [expr { $num_channels > $max_num_channels? $num_channels : $max_num_channels} ]

    # ------------------------------------------------------------------------------- # 
    # --- Determine the FIFO operation mode (phase-compensation or register mode) --- #
    # ------------------------------------------------------------------------------- #
    if {[dict get $native_phy_ip_params tx_fifo_mode_profile$i] == "Register"} {
      set tx_fifo_mode "register"
    } else {
      set tx_fifo_mode "pc_fifo"
    }

    if {[dict get $native_phy_ip_params rx_fifo_mode_profile$i] == "Register" || [dict get $native_phy_ip_params rx_fifo_mode_profile$i] == "Phase compensation-Register" } {
      set rx_fifo_mode "register"
    } else {
      set rx_fifo_mode "pc_fifo"
    }

    if {$native_debug == 1} {
      post_message -type info "========================================================================================"
      post_message -type info "IP SDC: TX mode inferred in SDC is $tx_fifo_mode"
      post_message -type info "IP SDC: RX mode inferred in SDC is $rx_fifo_mode"
      post_message -type info "IP SDC: The procotol mode is [dict get $native_phy_ip_params protocol_mode_profile$i]"
      post_message -type info "IP SDC: The standard PCS-PMA interface width is [dict get $native_phy_ip_params std_pcs_pma_width_profile$i]"
      post_message -type info "IP SDC: The enhanced PCS-PMA interface width is [dict get $native_phy_ip_params enh_pcs_pma_width_profile$i]"
      post_message -type info "IP SDC: The data rate is [dict get $native_phy_ip_params set_data_rate_profile$i] Mbps."
    }

    set tx_fifo_transfer_mode [dict get $native_phy_ip_params l_tx_fifo_transfer_mode_profile$i]
    set rx_fifo_transfer_mode [dict get $native_phy_ip_params l_rx_fifo_transfer_mode_profile$i]

    # ----------------------------------------------------------------------------- #
    # --- Set the selected clock from mux for tx/rx_clkout and tx/rx_clkout2    --- #
    # ----------------------------------------------------------------------------- #
    set tx_clkout_sel [dict get $native_phy_ip_params tx_clkout_sel_profile$i]
    set tx_clkout2_sel [dict get $native_phy_ip_params tx_clkout2_sel_profile$i]

    set rx_clkout_sel [dict get $native_phy_ip_params rx_clkout_sel_profile$i]
    set rx_clkout2_sel [dict get $native_phy_ip_params rx_clkout2_sel_profile$i]

    if {$native_debug == 1} {
      post_message -type info "IP SDC: Clock output of tx_clkout is $tx_clkout_sel"
      post_message -type info "IP SDC: Clock output of tx_clkout2 is $tx_clkout2_sel"
      post_message -type info "IP SDC: Clock output of rx_clkout is $rx_clkout_sel"
      post_message -type info "IP SDC: Clock output of rx_clkout2 is $rx_clkout2_sel"
    }

    # ------------------------------------------------------------------------------ #
    # --- Determine the datapath based on the selected protocol mode             --- #
    # ------------------------------------------------------------------------------ #
    set datapath_select [dict get $native_phy_ip_params datapath_select_profile$i]
    set protocol_mode   [dict get $native_phy_ip_params protocol_mode_profile$i]
    set duplex_mode     [dict get $native_phy_ip_params duplex_mode_profile$i]

    # ----------------------------------------------------------------------------- #
    # --- Determine the PCS-PMA width based on which datapath was selected      --- #
    # ----------------------------------------------------------------------------- #
    if {$datapath_select == "Enhanced"} {
      set pcs_pma_width [dict get $native_phy_ip_params enh_pcs_pma_width_profile$i]
    } elseif {$datapath_select == "Standard"} {
      set pcs_pma_width [dict get $native_phy_ip_params std_pcs_pma_width_profile$i]
    } elseif {$datapath_select == "PCS Direct"} {
      set pcs_pma_width [dict get $native_phy_ip_params pcs_direct_width_profile$i]
    } else {
      post_message -type error "IP SDC: Datapath did not match any of the valid options (Standard, Enhanced, PCS Direct)."
    }
    
    # ----------------------------------------------------------------------------- #
    # --- Determine the pma_div_clkout factor                                   --- #
    # ----------------------------------------------------------------------------- #
    set tx_pma_div_clkout_divider [dict get $native_phy_ip_params tx_pma_div_clkout_divider_profile$i]
    set rx_pma_div_clkout_divider [dict get $native_phy_ip_params rx_pma_div_clkout_divider_profile$i]

    if {$tx_pma_div_clkout_divider == 0} {
      set tx_pma_div_clkout_divider 1
    }
    if {$rx_pma_div_clkout_divider == 0} {
      set rx_pma_div_clkout_divider 1
    }

    # ----------------------------------------------------------------------------- #
    # --- Byte serializer and byte deserializer                                 --- #
    # ----------------------------------------------------------------------------- #
    set std_tx_byte_ser_mode [dict get $native_phy_ip_params std_tx_byte_ser_mode_profile$i]
    if {$std_tx_byte_ser_mode == "Serialize x2" && $datapath_select == "Standard"} {
      set byte_ser 2
    } elseif {$std_tx_byte_ser_mode == "Serialize x4" && $datapath_select == "Standard"} {
      set byte_ser 4
    } else {
      set byte_ser 1
    }

    set std_rx_byte_deser_mode [dict get $native_phy_ip_params std_rx_byte_deser_mode_profile$i]
    if {$std_rx_byte_deser_mode == "Deserialize x2" && $datapath_select == "Standard"} {
      set byte_deser 2
    } elseif {$std_rx_byte_deser_mode == "Deserialize x4" && $datapath_select == "Standard"} {
      set byte_deser 4
    } else {
      set byte_deser 1
    }

    if {$native_debug == 1} {
      post_message -type info "IP SDC: Byte serializer is $byte_ser"
      post_message -type info "IP SDC: Byte deserializer is $byte_deser"
    }

    # ----------------------------------------------------------------------------- #
    # --- Calculate the parallel PMA clock frequency                            --- #
    # ----------------------------------------------------------------------------- #
    set data_rate [expr double([dict get $native_phy_ip_params set_data_rate_profile$i])]
    set pma_parallel_clock [ expr $data_rate / $pcs_pma_width ]

    set tx_transfer_clk_freq [expr double($data_rate / ($pcs_pma_width * $byte_ser)) ]
    set rx_transfer_clk_freq [expr double($data_rate / ($pcs_pma_width * $byte_deser)) ]

    if { $tx_fifo_transfer_mode != "x1" } {
        set tx_transfer_clk_freq [expr $tx_transfer_clk_freq * 2 ]
    }

    if { $rx_fifo_transfer_mode != "x1" } {
        set rx_transfer_clk_freq [expr $rx_transfer_clk_freq * 2 ]
    }

    if { $native_debug ==1 } {
      post_message -type info "IP SDC: PMA parallel CLK is $pma_parallel_clock MHz"
      post_message -type info "IP SDC: Clock output of TX transfer clock is $tx_transfer_clk_freq MHz"
      post_message -type info "IP SDC: Clock output of RX transfer clock is $rx_transfer_clk_freq MHz"
    }

    # ----------------------------------------------------------------------------- #
    # --- Unset the profile_clocks dictionary if it exists                      --- #
    # ----------------------------------------------------------------------------- #
    if [info exists profile_clocks] {
      unset profile_clocks
    }
    set profile_clocks [dict create]

    if {[info exists freq] } {
      unset freq
    }
    set freq [dict create]

    if {[info exists multiply_factor_dict] } {
      unset multiply_factor_dict
    }
    set multiply_factor_dict [dict create]

    if {[info exists divide_factor_dict] } {
      unset divide_factor_dict
    }
    set divide_factor_dict [dict create]

    # ----------------------------------------------------------------------------- #
    # --- Create TX mode clocks and clock frequencies                           --- #
    # ----------------------------------------------------------------------------- #
    # For each TX clock output (tx_clkout and tx_clkout2), the selected clock from
    # main adapter clock mux is checked.
    #
    # 1. PCS_CLKOUT     : frequency is PCS parallel clock (with serialization factor)
    #
    # 2. PCS_x2_CLKOUT  :
    #     - If transfer mode is x2 (full-rate) or x1x2 (double-rate): x2 parallel clock
    #           > Unless Standard PCS, PCS-PMA width == 20, and byte serializer is
    #             disabled: parallel clock
    #     - If transfer mode is x1 (half-rate): parallel clock
    #     - **NOTE** Native PHY parameter tx_transfer_clk_freq already accounts for 
    #                byte serializer and provides correct frequency based on transfer
    #                mode (except in case of Standard PCS, PMA-PLD = 20)
    #
    # 3. PMA_DIV_CLKOUT :
    #     - If tx_pma_div_clkout == 33, 40, 66: data rate / (pma_div * 2)
    #     - If tx_pma_div_clkout == 1, 2: parallel clock / pma_div
    #
    # **NOTE** Both FIFO (Phase-Compensation) and Register mode have the same nodes
    #          because TX Register mode is fed from the core (core_clkin)
    #
    if {[dict get $native_phy_ip_params tx_enable_profile$i]} {

      set tx_enabled_on_any_profile   1

      # -------------------------------------------------------------------------------
      # AIB TX CLK SOURCE - PMA parallel clock
      # -------------------------------------------------------------------------------
      dict set profile_clocks tx_source_clks tx_pma_parallel_clk
      dict set freq tx_pma_parallel_clk $pma_parallel_clock

      # -------------------------------------------------------------------------------
      # AIB TX INTERNAL DIV REG - transfer clock
      # -------------------------------------------------------------------------------
      dict set profile_clocks tx_internal_div_reg_clks tx_pcs_x2_clk
    
      if {$tx_fifo_transfer_mode != "x1"} {
         dict set multiply_factor_dict tx_pcs_x2_clk 2
         dict set divide_factor_dict   tx_pcs_x2_clk [expr 1*($byte_ser)]
      } else {
         dict set multiply_factor_dict tx_pcs_x2_clk 1
         dict set divide_factor_dict   tx_pcs_x2_clk [expr 1*($byte_ser)]
      }
      # -------------------------------------------------------------------------------
      # TX_CLKOUT - output clocks
      # -------------------------------------------------------------------------------
      if {$tx_clkout_sel == "pcs_clkout" } {
        dict set profile_clocks tx_mode_clks tx_clkout
        
        # If TX transfer mode is x1 then tx_transfer_clk is correct (parallel clock)
        # Otherwise for x2 or x1x2, tx_transfer_clk is twice parallel_clock
        if {$tx_fifo_transfer_mode == "x1"} {
          dict set multiply_factor_dict tx_clkout 1
          dict set divide_factor_dict   tx_clkout 1
        } else {
          dict set multiply_factor_dict tx_clkout 1
          dict set divide_factor_dict   tx_clkout 2
        }

      } elseif {$tx_clkout_sel == "pcs_x2_clkout" } {
        dict set profile_clocks tx_mode_clks tx_clkout

        # If TX transfer mode is x2/x1x2, Standard PCS, PCS-PMA width == 20, and byte serializer is disabled => parallel clock
        if {(($tx_fifo_transfer_mode == "x2" || $tx_fifo_transfer_mode == "x1x2") &&
              $datapath_select == "Standard" && $pcs_pma_width == 20 && $std_tx_byte_ser_mode == "Disabled") ||
             ($datapath_select == "PCS Direct" && $pcs_pma_width == 20)} {
          dict set multiply_factor_dict tx_clkout 1
          dict set divide_factor_dict   tx_clkout 2
        } else {
          dict set multiply_factor_dict tx_clkout 1
          dict set divide_factor_dict   tx_clkout 1
        }

      } elseif {$tx_clkout_sel == "pma_div_clkout" } {
        dict set profile_clocks tx_mode_clks tx_clkout

        if {$tx_pma_div_clkout_divider == 33 || $tx_pma_div_clkout_divider == 40 || $tx_pma_div_clkout_divider == 66 } {

          if {$tx_fifo_transfer_mode == "x1"} {
            dict set multiply_factor_dict tx_clkout [expr $byte_ser * $pcs_pma_width]
            dict set divide_factor_dict   tx_clkout [expr round($tx_pma_div_clkout_divider * 2)]
          } else {
            dict set multiply_factor_dict tx_clkout [expr $byte_ser * $pcs_pma_width]
            dict set divide_factor_dict   tx_clkout [expr round($tx_pma_div_clkout_divider * 2 * 2)]
          }

        } else {

          if {$tx_fifo_transfer_mode == "x1"} {
            dict set multiply_factor_dict tx_clkout 1
            dict set divide_factor_dict   tx_clkout $tx_pma_div_clkout_divider
          } else {
            dict set multiply_factor_dict tx_clkout 1
            dict set divide_factor_dict   tx_clkout [expr $tx_pma_div_clkout_divider * 2]
          }

        }
      } else {
        post_message -type error "IP SDC: TX CLKOUT did not match any of the valid clock options. Check the TX Clock Options."
      }

      # -------------------------------------------------------------------------------
      # TX_CLKOUT2 - output clocks
      # -------------------------------------------------------------------------------
      if {[dict get $native_phy_ip_params enable_port_tx_clkout2_profile$i] == 1} {
        if {$tx_clkout2_sel == "pcs_clkout" } {
          dict lappend profile_clocks tx_mode_clks tx_clkout2

          # If TX transfer mode is x1 then tx_transfer_clk is correct (parallel clock)
          # Otherwise for x2 or x1x2, tx_transfer_clk is twice parallel_clock
          if {$tx_fifo_transfer_mode == "x1"} {
            dict set multiply_factor_dict tx_clkout2 1
            dict set divide_factor_dict   tx_clkout2 1
          } else {
            dict set multiply_factor_dict tx_clkout2 1
            dict set divide_factor_dict   tx_clkout2 2
          }

        } elseif {$tx_clkout2_sel == "pcs_x2_clkout" } {
          dict lappend profile_clocks tx_mode_clks tx_clkout2

          # If TX transfer mode is x2/x1x2, Standard PCS, PCS-PMA width == 20, and byte serializer is disabled => parallel clock
          if {(($tx_fifo_transfer_mode == "x2" || $tx_fifo_transfer_mode == "x1x2") &&
                $datapath_select == "Standard" && $pcs_pma_width == 20 && $std_tx_byte_ser_mode == "Disabled") ||
               ($datapath_select == "PCS Direct" && $pcs_pma_width == 20)} {
            dict set multiply_factor_dict tx_clkout2 1
            dict set divide_factor_dict   tx_clkout2 2
          } else {
            dict set multiply_factor_dict tx_clkout2 1
            dict set divide_factor_dict   tx_clkout2 1
          }
           
        } elseif {$tx_clkout2_sel == "pma_div_clkout" } {
         dict lappend profile_clocks tx_mode_clks tx_clkout2

          if {$tx_pma_div_clkout_divider == 33 || $tx_pma_div_clkout_divider == 40 || $tx_pma_div_clkout_divider == 66 } {

            if {$tx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict tx_clkout2 [expr $byte_ser * $pcs_pma_width]
              dict set divide_factor_dict   tx_clkout2 [expr round($tx_pma_div_clkout_divider * 2)]
            } else {
              dict set multiply_factor_dict tx_clkout2 [expr $byte_ser * $pcs_pma_width]
              dict set divide_factor_dict   tx_clkout2 [expr round($tx_pma_div_clkout_divider * 2 * 2)]
            }

          } else {

            if {$tx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict tx_clkout2 1
              dict set divide_factor_dict   tx_clkout2 $tx_pma_div_clkout_divider
            } else {
              dict set multiply_factor_dict tx_clkout2 1
              dict set divide_factor_dict   tx_clkout2 [expr $tx_pma_div_clkout_divider * 2]
            }
          }

        } else {
          post_message -type error "IP SDC: TX CLKOUT2 did not match any of the valid clock options. Check the TX Clock Options."
        }
      } else {
        if {$native_debug == 1} {
          post_message -type info "IP SDC: TX CLKOUT2 port is not enabled"
        }
      }

    } ; # if tx_enable_profile

    # ----------------------------------------------------------------------------- #
    # --- Create RX mode clocks and clock frequencies                           --- #
    # ----------------------------------------------------------------------------- #
    # For each RX clock output (rx_clkout and rx_clkout2), the selected clock from
    # main adapter clock mux is checked.
    #
    # 1. PCS_CLKOUT     : frequency is PCS parallel clock (with deserialization factor)
    #
    # 2. PCS_x2_CLKOUT  :
    #     - If transfer mode is x2 (full-rate) or x1x2 (double-rate): x2 parallel clock
    #     - If transfer mode is x1 (half-rate): parallel clock
    #     - **NOTE** Native PHY parameter rx_transfer_clk_freq already accounts for 
    #                byte deserializer and provides correct frequency based on transfer
    #                mode.
    #
    # 3. PMA_DIV_CLKOUT :
    #     - If rx_pma_div_clkout == 33, 40, 66: data rate / (pma_div * 2)
    #     - If rx_pma_div_clkout == 1, 2: parallel clock / pma_div
    #
    # **NOTE** FIFO (Phase-Compensation) and Register mode have the different nodes
    #          when selected clock is pcs_x2_clock because RX transfer clock is fed to
    #          main adapter FIFO read and write before the clock mux in register mode
    #          (only ONE rx_transfer_clk is created).
    #
    if {[dict get $native_phy_ip_params rx_enable_profile$i]} {

      # -------------------------------------------------------------------------------
      # AIB RX CLK SOURCE - PMA parallel clock
      # -------------------------------------------------------------------------------
      dict set profile_clocks rx_source_clks rx_pma_parallel_clk
      dict set freq rx_pma_parallel_clk $pma_parallel_clock

      # -------------------------------------------------------------------------------
      # AIB RX INTERNAL DIV REG - transfer clock
      # -------------------------------------------------------------------------------
      dict set profile_clocks rx_internal_div_reg_clks rx_pcs_x2_clk
     
      if {$rx_fifo_transfer_mode != "x1"} {
         dict set multiply_factor_dict rx_pcs_x2_clk 2
         dict set divide_factor_dict   rx_pcs_x2_clk [expr 1*($byte_deser)]
      } else {
         dict set multiply_factor_dict rx_pcs_x2_clk 1
         dict set divide_factor_dict   rx_pcs_x2_clk [expr 1*($byte_deser)]
      }

      # -------------------------------------------------------------------------------
      # RX_CLKOUT - output clocks
      # -------------------------------------------------------------------------------
      if {$rx_fifo_mode == "pc_fifo"} {
        if {$rx_clkout_sel == "pcs_clkout" } {
          dict set profile_clocks rx_mode_clks rx_clkout

          if {$rx_fifo_transfer_mode == "x1"} {
            dict set multiply_factor_dict rx_clkout 1
            dict set divide_factor_dict   rx_clkout 1
          } else {
            dict set multiply_factor_dict rx_clkout 1
            dict set divide_factor_dict   rx_clkout 2
          }

        } elseif {$rx_clkout_sel == "pcs_x2_clkout" } {
          dict set profile_clocks rx_mode_clks rx_clkout
          dict set multiply_factor_dict rx_clkout 1
          dict set divide_factor_dict   rx_clkout 1
 
        } elseif {$rx_clkout_sel == "pma_div_clkout" } {
          dict set profile_clocks rx_mode_clks rx_clkout

          if {$rx_pma_div_clkout_divider == 33 || $rx_pma_div_clkout_divider == 40 || $rx_pma_div_clkout_divider == 66 } {

            if {$rx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict rx_clkout [expr $byte_deser * $pcs_pma_width]
              dict set divide_factor_dict   rx_clkout [expr round($rx_pma_div_clkout_divider * 2)]
            } else {
              dict set multiply_factor_dict rx_clkout [expr $byte_deser * $pcs_pma_width]
              dict set divide_factor_dict   rx_clkout [expr round($rx_pma_div_clkout_divider * 2 * 2)]
            }

          } else {

            if {$rx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict rx_clkout 1
              dict set divide_factor_dict   rx_clkout $rx_pma_div_clkout_divider
            } else {
              dict set multiply_factor_dict rx_clkout 1
              dict set divide_factor_dict   rx_clkout [expr $rx_pma_div_clkout_divider * 2]
            }
          }

        } else {
          post_message -type error "IP SDC: RX CLKOUT did not match any of the valid clock options. Check the RX Clock Options."
        }
      } else { # RX FIFO is in register mode
        if {$rx_clkout_sel == "pcs_x2_clkout" } {
          dict set profile_clocks rx_mode_clks rx_transfer_clk
          dict set multiply_factor_dict rx_transfer_clk 1
          dict set divide_factor_dict   rx_transfer_clk 1

        } else {
          post_message -type error "IP SDC: RX CLKOUT did not match any of the valid clock options. Check the RX Clock Options."
        }
      }

      # -------------------------------------------------------------------------------
      # RX_CLKOUT2 - output clocks
      # -------------------------------------------------------------------------------
      if {[dict get $native_phy_ip_params enable_port_rx_clkout2_profile$i] == 1} {
        if {$rx_clkout2_sel == "pcs_clkout" } {
          dict lappend profile_clocks rx_mode_clks rx_clkout2

          if {$rx_fifo_transfer_mode == "x1"} {
            dict set multiply_factor_dict rx_clkout2 1
            dict set divide_factor_dict   rx_clkout2 1
          } else {
            dict set multiply_factor_dict rx_clkout2 1
            dict set divide_factor_dict   rx_clkout2 2
          }

        } elseif {$rx_clkout2_sel == "pcs_x2_clkout" } {

          if {$rx_fifo_mode == "pc_fifo"} {
            dict lappend profile_clocks rx_mode_clks rx_clkout2
            dict set multiply_factor_dict rx_clkout2 1
            dict set divide_factor_dict   rx_clkout2 1
          } elseif {$rx_fifo_mode == "register" && $rx_clkout_sel != "pcs_x2_clkout"} {
            dict lappend profile_clocks rx_mode_clks rx_transfer_clk2      
            dict set multiply_factor_dict rx_transfer_clk2 1
            dict set divide_factor_dict   rx_transfer_clk2 1
          }

        } elseif {$rx_clkout2_sel == "pma_div_clkout" } {
          dict lappend profile_clocks rx_mode_clks rx_clkout2

          if {$rx_pma_div_clkout_divider == 33 || $rx_pma_div_clkout_divider == 40 || $rx_pma_div_clkout_divider == 66 } {

            if {$rx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict rx_clkout2 [expr $byte_deser * $pcs_pma_width]
              dict set divide_factor_dict   rx_clkout2 [expr round($rx_pma_div_clkout_divider * 2)]
            } else {
              dict set multiply_factor_dict rx_clkout2 [expr $byte_deser * $pcs_pma_width]
              dict set divide_factor_dict   rx_clkout2 [expr round($rx_pma_div_clkout_divider * 2 * 2)]
            }

          } else {

            if {$rx_fifo_transfer_mode == "x1"} {
              dict set multiply_factor_dict rx_clkout2 1
              dict set divide_factor_dict   rx_clkout2 $rx_pma_div_clkout_divider
            } else {
              dict set multiply_factor_dict rx_clkout2 1
              dict set divide_factor_dict   rx_clkout2 [expr $rx_pma_div_clkout_divider * 2]
            }
          }

        } else {
          post_message -type error "IP SDC: RX CLKOUT2 did not match any of the valid clock options. Check the RX Clock Options"
        }

      } else {
        if {$native_debug == 1} {
          post_message -type info "IP SDC: RX CLKOUT2 port is not enabled"
        }
      }
    } ; # if rx_enable_profile

    # ----------------------------------------------------------------------------- #
    # --- Create PIPE clocks and clock frequencies                              --- #
    # ----------------------------------------------------------------------------- #

    # -------------------------------------------------------------------------------
    # HCLK
    # If we are in Gen 3 and we have hip... we have a 1Gig clock (might need to change for hip... as it comes out to the core...)
    #--------------------------------------------------------------------------------
    set hclk_freq ""
    if {[dict get $native_phy_ip_params enable_hip_profile$i] == 1} {
      set hclk_freq 1000
    } else {
      set hclk_freq 500
    }

    if {$protocol_mode == "pipe_g1" || $protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3"} {

      # Find the maximum precision of RX transfer clock frequency
      set rx_pma_parallel_clk_split [split $pma_parallel_clock "."]
      set rx_max_precision          [expr [string length [lindex $rx_pma_parallel_clk_split end]]]

      # Ensure that multiply and divide factors are less than 999999999
      if {[llength $rx_pma_parallel_clk_split] > 1 && [string length $pma_parallel_clock ] > 10} {
        set rx_max_precision [expr $rx_max_precision - [string length [lindex $rx_pma_parallel_clk_split 0]]]
      }

      dict set profile_clocks       hclk_internal_div_reg_clks hclk_internal_div_reg
      dict set multiply_factor_dict hclk_internal_div_reg [expr round($hclk_freq * (10 ** $rx_max_precision))]
      dict set divide_factor_dict   hclk_internal_div_reg [expr round($pma_parallel_clock * (10 ** $rx_max_precision))]

      dict set profile_clocks       hclk_mode hclk
      dict set multiply_factor_dict hclk 1
      dict set divide_factor_dict   hclk 1
    }

    # -------------------------------------------------------------------------------
    # PIPE Gen2
    # Create Gen2 and Gen1 clocks for PIPE Gen2 and PIPE Gen3
    # -------------------------------------------------------------------------------
    if {$protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3"} {

      # TX PIPE Gen2
      dict lappend profile_clocks tx_mode_clks tx_clkout_pipe_g2
      dict set multiply_factor_dict tx_clkout_pipe_g2 [dict get $multiply_factor_dict tx_clkout]
      dict set divide_factor_dict   tx_clkout_pipe_g2 [dict get $divide_factor_dict   tx_clkout]

      # TX PIPE Gen1
      dict lappend profile_clocks tx_mode_clks tx_clkout_pipe_g1
      dict set multiply_factor_dict tx_clkout_pipe_g1 [dict get $multiply_factor_dict tx_clkout_pipe_g2]
      dict set divide_factor_dict   tx_clkout_pipe_g1 [expr round([dict get $divide_factor_dict tx_clkout_pipe_g2] * 2)]

      # Remove original tx_clkout from profile_clocks and freq dictionaries
      set list_of_tx_clkouts [dict get $profile_clocks tx_mode_clks]
      set tx_clkout_index [lsearch $list_of_tx_clkouts tx_clkout]
      if {$tx_clkout_index < 0} {
        if {$native_debug == 1} {
          post_message -type warning "IP SDC: Cannot find key tx_clkout while creating PIPE clocks in list $list_of_tx_clkouts"
        }
      } else {
        dict set profile_clocks tx_mode_clks [lreplace $list_of_tx_clkouts $tx_clkout_index $tx_clkout_index]
      }

      set multiply_factor_dict [dict remove $multiply_factor_dict tx_clkout]
      set divide_factor_dict   [dict remove $divide_factor_dict   tx_clkout]

      # TX_CLKOUT2
      if {[dict get $native_phy_ip_params enable_port_tx_clkout2_profile$i] == 1} {

        # TX PIPE Gen2
        dict lappend profile_clocks tx_mode_clks tx_clkout2_pipe_g2
        dict set multiply_factor_dict tx_clkout2_pipe_g2 [dict get $multiply_factor_dict tx_clkout2]
        dict set divide_factor_dict   tx_clkout2_pipe_g2 [dict get $divide_factor_dict   tx_clkout2]

        # TX PIPE Gen1
        dict lappend profile_clocks tx_mode_clks tx_clkout2_pipe_g1
        dict set multiply_factor_dict tx_clkout2_pipe_g1 [dict get $multiply_factor_dict tx_clkout2_pipe_g2]
        dict set divide_factor_dict   tx_clkout2_pipe_g1 [expr round([dict get $divide_factor_dict tx_clkout2_pipe_g2] * 2)]

        # Remove original tx_clkout2 from profile_clocks and freq dictionaries
        set list_of_tx_clkouts [dict get $profile_clocks tx_mode_clks]
        set tx_clkout2_index [lsearch $list_of_tx_clkouts tx_clkout2]
        if {$tx_clkout2_index < 0} {
          if {$native_debug == 1} {
            post_message -type warning "IP SDC: Cannot find key tx_clkout2 while creating PIPE clocks in list $list_of_tx_clkouts"
          }
        } else {
          dict set profile_clocks tx_mode_clks [lreplace $list_of_tx_clkouts $tx_clkout2_index $tx_clkout2_index]
        }

        set multiply_factor_dict [dict remove $multiply_factor_dict tx_clkout2]
        set divide_factor_dict   [dict remove $divide_factor_dict   tx_clkout2]
 
      }

      if {$native_debug == 1} {
        post_message -type info "IP SDC: TX mode clocks - [dict get $profile_clocks tx_mode_clks]"
      }

      # RX PIPE
      if {[dict exists $profile_clocks rx_transfer_clk]} {

        # RX PIPE Gen2
        dict lappend profile_clocks rx_mode_clks rx_transfer_clk_pipe_g2
        dict set multiply_factor_dict rx_transfer_clk_pipe_g2 [dict get $multiply_factor_dict rx_transfer_clk]
        dict set divide_factor_dict   rx_transfer_clk_pipe_g2 [dict get $divide_factor_dict   rx_transfer_clk]

        # RX PIPE Gen1
        dict lappend profile_clocks rx_mode_clks rx_transfer_clk_pipe_g1
        dict set multiply_factor_dict rx_transfer_clk_pipe_g1 [dict get $multiply_factor_dict rx_transfer_clk_pipe_g2]
        dict set divide_factor_dict   rx_transfer_clk_pipe_g1 [expr round([dict get $divide_factor_dict rx_transfer_clk_pipe_g2] * 2)]

        # Remove original rx_transfer_clk from profile_clocks and freq dictionaries
        set list_of_rx_clkouts [dict get $profile_clocks rx_mode_clks]
        set rx_clkout_index [lsearch $list_of_rx_clkouts rx_transfer_clk]
        if {$rx_clkout_index < 0} {
          if {$native_debug == 1} {
            post_message -type warning "IP SDC: Cannot find key rx_transfer_clk while creating PIPE clocks in list $list_of_rx_clkouts"
          }
        } else {
          dict set profile_clocks rx_mode_clks [lreplace $list_of_rx_clkouts $rx_clkout_index $rx_clkout_index]
        }

        set multiply_factor_dict [dict remove $multiply_factor_dict rx_transfer_clk]
        set divide_factor_dict   [dict remove $divide_factor_dict   rx_transfer_clk]

      } else {
        # RX PIPE Gen2
        dict lappend profile_clocks rx_mode_clks rx_clkout_pipe_g2
        dict set multiply_factor_dict rx_clkout_pipe_g2 [dict get $multiply_factor_dict rx_clkout]
        dict set divide_factor_dict   rx_clkout_pipe_g2 [dict get $divide_factor_dict   rx_clkout]

        # RX PIPE Gen1
        dict lappend profile_clocks rx_mode_clks rx_clkout_pipe_g1
        dict set multiply_factor_dict rx_clkout_pipe_g1 [dict get $multiply_factor_dict rx_clkout_pipe_g2]
        dict set divide_factor_dict   rx_clkout_pipe_g1 [expr round([dict get $divide_factor_dict rx_clkout_pipe_g2] * 2)]

        # Remove original rx_clkout from profile_clocks and freq dictionaries
        set list_of_rx_clkouts [dict get $profile_clocks rx_mode_clks]
        set rx_clkout_index [lsearch $list_of_rx_clkouts rx_clkout]
        if {$rx_clkout_index < 0} {
          if {$native_debug == 1} {
            post_message -type warning "IP SDC: Cannot find key rx_clkout while creating PIPE clocks in list $list_of_rx_clkouts"
          }
        } else {
          dict set profile_clocks rx_mode_clks [lreplace $list_of_rx_clkouts $rx_clkout_index $rx_clkout_index]
        }
        #set freq [dict remove $freq rx_clkout]
        set multiply_factor_dict [dict remove $multiply_factor_dict rx_clkout]
        set divide_factor_dict   [dict remove $divide_factor_dict   rx_clkout]

      }

      # RX_CLKOUT2
      if {[dict get $native_phy_ip_params enable_port_rx_clkout2_profile$i] == 1} {
        if {[dict exists $profile_clocks rx_transfer_clk2]} {
          # RX PIPE Gen2
          dict lappend profile_clocks rx_mode_clks rx_transfer_clk2_pipe_g2
          dict set multiply_factor_dict rx_transfer_clk2_pipe_g2 [dict get $multiply_factor_dict rx_transfer_clk2]
          dict set divide_factor_dict   rx_transfer_clk2_pipe_g2 [dict get $divide_factor_dict   rx_transfer_clk2]

          # RX PIPE Gen1
          dict lappend profile_clocks rx_mode_clks rx_transfer_clk2_pipe_g1
          dict set multiply_factor_dict rx_transfer_clk2_pipe_g1 [dict get $multiply_factor_dict rx_transfer_clk2_pipe_g2]
          dict set divide_factor_dict   rx_transfer_clk2_pipe_g1 [expr round([dict get $divide_factor_dict rx_transfer_clk2_pipe_g2] * 2)]

          # Remove original rx_transfer_clk2 from profile_clocks and freq dictionaries
          set list_of_rx_clkouts [dict get $profile_clocks rx_mode_clks]
          set rx_clkout2_index [lsearch $list_of_rx_clkouts rx_transfer_clk2]
          if {$rx_clkout2_index < 0} {
            if {$native_debug == 1} {
              post_message -type warning "IP SDC: Cannot find key rx_transfer_clk2 while creating PIPE clocks in list $list_of_rx_clkouts"
            }
          } else {
            dict set profile_clocks rx_mode_clks [lreplace $list_of_rx_clkouts $rx_clkout_index $rx_clkout_index]
          }
          set multiply_factor_dict [dict remove $multiply_factor_dict rx_transfer_clk2]
          set divide_factor_dict   [dict remove $divide_factor_dict   rx_transfer_clk2]

        } else {
          # RX PIPE Gen2
          dict lappend profile_clocks rx_mode_clks rx_clkout2_pipe_g2
          dict set multiply_factor_dict rx_clkout2_pipe_g2 [dict get $multiply_factor_dict rx_clkout2]
          dict set divide_factor_dict   rx_clkout2_pipe_g2 [dict get $divide_factor_dict   rx_clkout2]

          # RX PIPE Gen1
          dict lappend profile_clocks rx_mode_clks rx_clkout2_pipe_g1
          dict set multiply_factor_dict rx_clkout2_pipe_g1 [dict get $multiply_factor_dict rx_clkout2_pipe_g2]
          dict set divide_factor_dict   rx_clkout2_pipe_g1 [expr round([dict get $divide_factor_dict rx_clkout2_pipe_g2] * 2)]

          # Remove original rx_clkout from profile_clocks and freq dictionaries
          set list_of_rx_clkouts [dict get $profile_clocks rx_mode_clks]
          set rx_clkout2_index [lsearch $list_of_rx_clkouts rx_clkout2]
          if {$rx_clkout2_index < 0} {
            if {$native_debug == 1} {
              post_message -type warning "IP SDC: Cannot find key rx_clkout2 while creating PIPE clocks in list $list_of_rx_clkouts"
            }
          } else {
            dict set profile_clocks rx_mode_clks [lreplace $list_of_rx_clkouts $rx_clkout2_index $rx_clkout2_index]
          }
          #set freq [dict remove $freq rx_clkout2]
          set multiply_factor_dict [dict remove $multiply_factor_dict rx_clkout2]
          set divide_factor_dict   [dict remove $divide_factor_dict   rx_clkout2]

        }
      }

      if {$native_debug == 1} {
        post_message -type info "IP SDC: RX mode clocks - [dict get $profile_clocks rx_mode_clks]"
      }

    } ; # if pipe_gen2 || pipe_gen3

    # -------------------------------------------------------------------------------
    # PIPE Gen3 clock
    # -------------------------------------------------------------------------------
    if {$protocol_mode == "pipe_g3"} {

      dict lappend profile_clocks tx_mode_clks tx_clkout_pipe_g3
      dict set multiply_factor_dict tx_clkout_pipe_g3 [expr round([dict get $multiply_factor_dict tx_clkout_pipe_g2] * 2)]
      dict set divide_factor_dict   tx_clkout_pipe_g3 [dict get $divide_factor_dict tx_clkout_pipe_g2]

      if {[dict get $native_phy_ip_params enable_port_tx_clkout2_profile$i] == 1} {
        dict lappend profile_clocks tx_mode_clks tx_clkout2_pipe_g3
        dict set multiply_factor_dict tx_clkout2_pipe_g3 [expr round([dict get $multiply_factor_dict tx_clkout2_pipe_g2] * 2)]
        dict set divide_factor_dict   tx_clkout2_pipe_g3 [dict get $divide_factor_dict tx_clkout2_pipe_g2]
      }

      if {[dict exists $profile_clocks rx_transfer_clk]} {
        dict lappend profile_clocks rx_mode_clks rx_transfer_clk_pipe_g3

      } else {
        dict lappend profile_clocks rx_mode_clks rx_clkout_pipe_g3
        dict set multiply_factor_dict rx_clkout_pipe_g3 [expr round([dict get $multiply_factor_dict rx_clkout_pipe_g2] * 2)]
        dict set divide_factor_dict   rx_clkout_pipe_g3 [dict get $divide_factor_dict rx_clkout_pipe_g2]
      }

      if {[dict get $native_phy_ip_params enable_port_rx_clkout2_profile$i] == 1} {
        if {[dict exists $profile_clocks rx_transfer_clk2]} {
          dict lappend profile_clocks rx_mode_clks rx_transfer_clk2_pipe_g3  
          dict set multiply_factor_dict rx_transfer_clk2_pipe_g3 [expr round([dict get $multiply_factor_dict rx_transfer_clk2_pipe_g2] * 2)]
          dict set divide_factor_dict   rx_transfer_clk2_pipe_g3 [dict get $divide_factor_dict rx_transfer_clk2_pipe_g2]

        } else {
          dict lappend profile_clocks rx_mode_clks rx_clkout2_pipe_g3
          dict set multiply_factor_dict rx_clkout2_pipe_g3 [expr round([dict get $multiply_factor_dict rx_clkout2_pipe_g2] * 2)]
          dict set divide_factor_dict   rx_clkout2_pipe_g3 [dict get $divide_factor_dict rx_clkout2_pipe_g2]

        }
      }
    }

    if { $native_debug == 1 } {
      dict for {key clocks} $profile_clocks {
        post_message -type info "IP SDC: Profile Clocks are $key: $clocks"
      }
    }

    # ----------------------------------------------------------------------------- #
    # --- Round the clock frequencies to 6 decimal places or less               --- #
    # ----------------------------------------------------------------------------- #
    dict for {clk freq_clk} $freq {
      dict set freq $clk [expr (round($freq_clk*1000000)/1000000.0)]
    }

    # ----------------------------------------------------------------------------- #
    # --- Create clocks for each mode                                           --- #
    # ----------------------------------------------------------------------------- #
    if {$native_debug == 1} {
      post_message -type info "========================================================================================"
      post_message -type info "IP SDC: Creating HSSI clocks for each channel"
    }

    dict for {mode mode_clks} $profile_clocks {
      set list_of_clk_names [list]

      if {$native_debug == 1} {
        post_message -type info "----------------------------------------------------------------------------------------"
        post_message -type info "IP SDC: Creating HSSI clocks for each channel in $mode group"
      }

      set list_of_clk_names [native_prepare_to_create_clocks_all_ch_qufrg4q $inst $num_channels $mode $mode_clks $profile_cnt $i $alt_xcvr_native_s10_pins $freq $multiply_factor_dict $divide_factor_dict $all_profile_clocks_names]
      dict set all_profile_clocks_names $i $mode [join [lsort -dictionary $list_of_clk_names]]

      if {$native_debug == 1} {
        post_message -type info "IP SDC: All Profile $i clocks for $mode: [dict get $all_profile_clocks_names $i $mode]"
      }
    } ; # dict for {mode mode_clks}


    # ----------------------------------------------------------------------------- #
    # --- Set async clock group for PIPE clocks                                 --- #
    # ----------------------------------------------------------------------------- #
    if {$protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3"} {
      if { $native_debug } {
        post_message -type info "========================================================================================"
        post_message -type info "IP SDC: Setting async clock groups for PIPE clocks"
      }

      set arg ""
      set curr_profile_clock_names [dict get $all_profile_clocks_names $i] 

      # Construct the arguments for set_clock_groups 
      # Template: set_clock_groups -asynchronous -group {<profile0 clks>} -group {<profile1 clks>} ... 
      for {set j 1} {$j < 3} {incr j} {
        set list_pipe_clk_names ""

        dict for {mode clk_mode_names} $curr_profile_clock_names {
          if {$mode == "tx_mode_clks" || $mode == "rx_mode_clks"} {

            set pipe_regexp "*_pipe_g$j*"
            set pipe_clk_names [lsearch -all -inline $clk_mode_names $pipe_regexp]

            if {$pipe_clk_names != ""} {
              set list_pipe_clk_names [concat $list_pipe_clk_names $pipe_clk_names]
            } else {
              if { $native_debug } {
                post_message -type warning "IP SDC: Cannot match regexp $pipe_regexp with clock names in list $clk_mode_names"
              }
            }
          }
        }
        set group "-group "
        set arg [concat $arg $group] 
        set arg [concat $arg "{$list_pipe_clk_names}"]
      }

      if {$protocol_mode == "pipe_g3"} {
        set list_pipe_clk_names ""

        dict for {mode clk_mode_names} $curr_profile_clock_names {
          if {$mode == "tx_mode_clks" || $mode == "rx_mode_clks"} {

            set pipe_regexp "*_pipe_g3*"
            set pipe_clk_names [lsearch -all -inline $clk_mode_names $pipe_regexp]

            if {$pipe_clk_names != ""} {
              set list_pipe_clk_names [concat $list_pipe_clk_names $pipe_clk_names]
            } else {
              if { $native_debug } {
                post_message -type warning "IP SDC: Cannot match regexp $pipe_regexp with clock names in list $clk_mode_names"
              }
            }
          }
        }
        set group "-group "
        set arg [concat $arg $group] 
        set arg [concat $arg "{$list_pipe_clk_names}"]
      }

      set cmd ""
      set cmd [concat $cmd "set_clock_groups -physically_exclusive "]
      set cmd [concat $cmd $arg]
      eval $cmd

      if { $native_debug } {
        post_message -type info "IP SDC: Setting async clock groups for PIPE clocks with command $cmd"
      }
    }

    #--------------------------------------------- #
    #---                                       --- #
    #--- MAX_SKEW_CONSTRAINT FOR BONDED MODE   --- #
    #---                                       --- #
    #--------------------------------------------- #
    if {[dict get $native_phy_ip_params bonded_mode_profile$i] == "pma_pcs"} {
      if { $native_debug } {
        post_message -type info "========================================================================================"
        post_message -type info "IP SDC: Setting max skew constraints for TX digital resets in PMA-PCS bonded mode"
      }

      # PMA and PCS resets need half the transfer clock period
      # Adapter resets need half the PMA parallel clock period
      set pma_parallel_clk_max_skew_value [expr ((1/($pma_parallel_clock / $byte_ser)) * 1000) / 2]
      set tx_transfer_clk_max_skew_value  [expr ((1/($tx_transfer_clk_freq / $byte_ser)) * 1000) / 2]
      set rx_transfer_clk_max_skew_value  [expr ((1/($rx_transfer_clk_freq / $byte_ser)) * 1000) / 2]

      # Round the clock frequencies to 6 decimal places or less
      set pma_parallel_clk_max_skew_value [expr (round($pma_parallel_clk_max_skew_value*1000)/1000.0)]
      set tx_transfer_clk_max_skew_value  [expr (round($tx_transfer_clk_max_skew_value*1000)/1000.0)]
      set rx_transfer_clk_max_skew_value  [expr (round($rx_transfer_clk_max_skew_value*1000)/1000.0)]

      # -------------------------------------------------------------------------------
      # TX set_max_skew
      # -------------------------------------------------------------------------------
      # Set max skew constraint for TX analog and digital resets when bonded
      set tx_analog_reset_reg_col         [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_anlg_reset_seq|reset_out_stage*]
      set tx_aib_reset_out_stage_reg_col  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|aib_reset_out_stage*]
      set tx_pcs_reset_out_stage_reg_col  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|pcs_reset_out_stage*]
      set tx_transfer_clk_reg_col         [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~*aibadpt__aib_fabric_tx_transfer_clk.reg]
      set tx_pld_adapter_tx_pld_rst_n_col [get_pins -nowarn -compat g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_adapter_tx_pld_rst_n]

      # TX PMA
      if {[get_collection_size $tx_analog_reset_reg_col] > 0 && [dict exist $all_profile_clocks_names $i tx_internal_div_reg_clks]} {
        set_max_skew -exclude to_clock -from $tx_analog_reset_reg_col -to $tx_transfer_clk_reg_col $tx_transfer_clk_max_skew_value -nowarn
      }

      # TX Adapter
      if {[get_collection_size $tx_aib_reset_out_stage_reg_col] > 0 && [get_collection_size $tx_pld_adapter_tx_pld_rst_n_col] > 0} {
        set_max_skew -exclude to_clock -from $tx_aib_reset_out_stage_reg_col -to $tx_pld_adapter_tx_pld_rst_n_col $pma_parallel_clk_max_skew_value -nowarn
      }

      # TX PCS
      if {[get_collection_size $tx_pcs_reset_out_stage_reg_col] > 0 && [dict exist $all_profile_clocks_names $i tx_internal_div_reg_clks]} {
        set_max_skew -exclude to_clock -from $tx_pcs_reset_out_stage_reg_col -to $tx_transfer_clk_reg_col $tx_transfer_clk_max_skew_value -nowarn
      }

      # -------------------------------------------------------------------------------
      # RX set_max_skew
      # -------------------------------------------------------------------------------
      # Set max skew constraint for RX analog and digital resets when bonded
      set rx_analog_reset_reg_col         [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_anlg_reset_seq|reset_out_stage*]
      set rx_aib_reset_out_stage_reg_col  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|aib_reset_out_stage*]
      set rx_pcs_reset_out_stage_reg_col  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|pcs_reset_out_stage*]
      set rx_transfer_clk_reg_col         [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~*aibadpt__aib_fabric_rx_transfer_clk.reg]
      set rx_pld_adapter_rx_pld_rst_n_col [get_pins -nowarn -compat g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_adapter_rx_pld_rst_n]

      # RX PMA
      if {[get_collection_size $rx_analog_reset_reg_col] > 0 && [dict exist $all_profile_clocks_names $i rx_internal_div_reg_clks]} {
        set_max_skew -exclude to_clock -from $rx_analog_reset_reg_col -to $rx_transfer_clk_reg_col $rx_transfer_clk_max_skew_value -nowarn
      }

      # RX Adapter
      if {[get_collection_size $rx_aib_reset_out_stage_reg_col] > 0 && [get_collection_size $rx_pld_adapter_rx_pld_rst_n_col] > 0} {
        set_max_skew -exclude to_clock -from $rx_aib_reset_out_stage_reg_col -to $rx_pld_adapter_rx_pld_rst_n_col $pma_parallel_clk_max_skew_value -nowarn
      }

      # RX PCS
      if {[get_collection_size $rx_pcs_reset_out_stage_reg_col] > 0 && [dict exist $all_profile_clocks_names $i rx_internal_div_reg_clks]} {
        set_max_skew -exclude to_clock -from $rx_pcs_reset_out_stage_reg_col -to $rx_transfer_clk_reg_col $rx_transfer_clk_max_skew_value -nowarn
      }

    }


    #-------------------------------------------------- #
    #---                                            --- #
    #--- DISABLE MIN_PULSE_WIDTH CHECK              --- #
    #---                                            --- #
    #-------------------------------------------------- #
    # Disable min_width_pulse for TX source clocks
    if {[dict exists $all_profile_clocks_names $i tx_source_clks]} {
      set tx_source_clks_list [dict get $all_profile_clocks_names $i tx_source_clks]
      foreach tx_src_clk $tx_source_clks_list {
        disable_min_pulse_width $tx_src_clk
      }
    }

    # Disable min_width_pulse for RX source clocks
    if {[dict exists $all_profile_clocks_names $i rx_source_clks]} {
      set rx_source_clks_list [dict get $all_profile_clocks_names $i rx_source_clks]
      foreach rx_src_clk $rx_source_clks_list {
        disable_min_pulse_width $rx_src_clk
      }
    }


    #-------------------------------------------------- #
    #---                                            --- #
    #--- CLOCK DISTORTION ALONG CLOCK PATH          --- #
    #---                                            --- #
    #-------------------------------------------------- #
  
    # (Cr IO Buffer+EMIB)(3%)+ Nadder IO Buffer)(3%) + (Nadder Adapter)(3%)
    # (Nadder Adapter)(3%) already distortion is accounted for in HSSI timing models
  
    # -------------------------------------------------------------------------------
    # TX clock uncertainty on output parallel XCVR clocks
    # -------------------------------------------------------------------------------
    if { [dict exists $all_profile_clocks_names $i tx_mode_clks] } {
      
      set tx_mode_clks_list [dict get $all_profile_clocks_names $i tx_mode_clks]
  
      foreach tx_clk_name $tx_mode_clks_list {
  
        set tx_clkout_period [get_clock_info -period $tx_clk_name]
  
        # (Cr IO Buffer+EMIB)(3%)+ Nadder IO Buffer)(3%)
        set tx_clkout_uncertainty_percent 0.06

        # Limit to 3 digits after the decimal to avoid warnings
        set tx_clkout_uncertainty_final_value [expr double($tx_clkout_uncertainty_percent*$tx_clkout_period)]
        set tx_clkout_uncertainty_final_value [expr round($tx_clkout_uncertainty_final_value  * 1000)]
        set tx_clkout_uncertainty_final_value [expr double($tx_clkout_uncertainty_final_value / 1000.0)]
  
        # (Cr IO Buffer+EMIB)(3%)+ Nadder IO Buffer)(3%) 
        # No need for rise_from/rise_to to other clocks since the rise edge should still be ideal, and it's only the fall edge that has uncertainty.
        # Distortion does not affect same-edge transfers. Only high-frequency jitter effects cause issues to same-edge transfers as common-clock-pessimism-removal would fix any issues.
        set tx_mode_other_clks     [remove_from_collection [get_clocks  $tx_mode_clks_list] [get_clocks $tx_clk_name]]
        if { [get_collection_size $tx_mode_other_clks] > 0} {
             set_clock_uncertainty -add -fall_from $tx_clk_name -to    $tx_mode_other_clks   $tx_clkout_uncertainty_final_value
             set_clock_uncertainty -add -fall_to   $tx_clk_name -from  $tx_mode_other_clks   $tx_clkout_uncertainty_final_value
        }
 
      }
    }
  
    # -------------------------------------------------------------------------------
    # RX clock uncertainty on output parallel XCVR clocks
    # -------------------------------------------------------------------------------
    if { [dict exists $all_profile_clocks_names $i rx_mode_clks] } {
      
      set rx_mode_clks_list [dict get $all_profile_clocks_names $i rx_mode_clks]
  
      foreach rx_clk_name $rx_mode_clks_list {
  
        set rx_clkout_period [get_clock_info -period $rx_clk_name]
  
        # (Cr IO Buffer+EMIB)(3%)+ Nadder IO Buffer)(3%)
        set rx_clkout_uncertainty_percent 0.06

        # Limit to 3 digits after the decimal to avoid warnings
        set rx_clkout_uncertainty_final_value [expr double($rx_clkout_uncertainty_percent*$rx_clkout_period)]
        set rx_clkout_uncertainty_final_value [expr round($rx_clkout_uncertainty_final_value  * 1000)]
        set rx_clkout_uncertainty_final_value [expr double($rx_clkout_uncertainty_final_value / 1000.0)]

        # Distortion from DCC circuit is only valid on opposite-edge transfers (i.e. rise-fall and fall-rise)
        set_clock_uncertainty -add -rise_from $rx_clk_name -fall_to $rx_clk_name $rx_clkout_uncertainty_final_value
        set_clock_uncertainty -add -fall_from $rx_clk_name -rise_to $rx_clk_name $rx_clkout_uncertainty_final_value
  
        # (Cr IO Buffer+EMIB)(3%)+ Nadder IO Buffer)(3%)
        # No need for rise_from/rise_to to other clocks since the rise edge should still be ideal, and it's only the fall edge that has uncertainty.
        # Distortion does not affect same-edge transfers. Only high-frequency jitter effects cause issues to same-edge transfers as common-clock-pessimism-removal would fix any issues. 
        set rx_mode_other_clks     [remove_from_collection [get_clocks  $rx_mode_clks_list] [get_clocks $rx_clk_name]]
        if { [get_collection_size $rx_mode_other_clks] > 0} {
             set_clock_uncertainty -add -fall_from $rx_clk_name -to    $rx_mode_other_clks   $rx_clkout_uncertainty_final_value
             set_clock_uncertainty -add -fall_to   $rx_clk_name -from  $rx_mode_other_clks   $rx_clkout_uncertainty_final_value
        }
  
      }
    }


    #-------------------------------------------------- #
    #---                                            --- #
    #--- SET_FALSE_PATH for TX and RX BONDING       --- #
    #---                                            --- #
    #-------------------------------------------------- #

    # Remove all paths for RX bonding signals if in PIPE mode (Native PCIe IP covers the case for PCIe)
    if {$protocol_mode == "pipe_g1" || $protocol_mode == "pipe_g2" || $protocol_mode == "pipe_g3"} {

      set aib_fabric_rx_transfer_clk_col [get_registers    -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_fabric_rx_transfer_clk.reg]
      set bond_rx_fifo_us_out_wren_col   [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_us_out_wren]
      set bond_rx_fifo_ds_in_wren_col    [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_ds_in_wren]
      set bond_rx_fifo_ds_out_wren_col   [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_ds_out_wren]
      set bond_rx_fifo_us_in_wren_col    [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_us_in_wren]

      set pld_rx_clk_dcm_reg_col       [get_registers    -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~pld_rx_clk*_dcm.reg]
      set bond_rx_fifo_us_out_rden_col [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_us_out_rden]
      set bond_rx_fifo_ds_in_rden_col  [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_ds_in_rden]
      set bond_rx_fifo_ds_out_rden_col [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_ds_out_rden]
      set bond_rx_fifo_us_in_rden_col  [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|bond_rx_fifo_us_in_rden]

      if {[get_collection_size $aib_fabric_rx_transfer_clk_col] > 0 &&  [get_collection_size $bond_rx_fifo_us_out_wren_col] > 0 && [get_collection_size $bond_rx_fifo_ds_in_wren_col] > 0} {    
        set_false_path -from $aib_fabric_rx_transfer_clk_col -through $bond_rx_fifo_us_out_wren_col -through $bond_rx_fifo_ds_in_wren_col -to $aib_fabric_rx_transfer_clk_col
      }

      if {[get_collection_size $aib_fabric_rx_transfer_clk_col] > 0 &&  [get_collection_size $bond_rx_fifo_ds_out_wren_col] > 0 && [get_collection_size $bond_rx_fifo_us_in_wren_col] > 0} {    
        set_false_path -from $aib_fabric_rx_transfer_clk_col -through $bond_rx_fifo_ds_out_wren_col -through $bond_rx_fifo_us_in_wren_col -to $aib_fabric_rx_transfer_clk_col
      }

      if {[get_collection_size $pld_rx_clk_dcm_reg_col] > 0 &&  [get_collection_size $bond_rx_fifo_us_out_rden_col] > 0 && [get_collection_size $bond_rx_fifo_ds_in_rden_col] > 0} {    
        set_false_path -from $pld_rx_clk_dcm_reg_col  -through $bond_rx_fifo_us_out_rden_col -through $bond_rx_fifo_ds_in_rden_col -to $pld_rx_clk_dcm_reg_col
      }

      if {[get_collection_size $pld_rx_clk_dcm_reg_col] > 0 &&  [get_collection_size $bond_rx_fifo_ds_out_rden_col] > 0 && [get_collection_size $bond_rx_fifo_us_in_rden_col] > 0} {    
        set_false_path -from  $pld_rx_clk_dcm_reg_col -through $bond_rx_fifo_ds_out_rden_col -through $bond_rx_fifo_us_in_rden_col -to $pld_rx_clk_dcm_reg_col
      }

    }

  } ; # foreach profile


  #--------------------------------------------- #
  #---                                       --- #
  #--- Adjusting the min pulse width for     --- #
  #--- coreclkin2 requirement to be          --- #
  #--- frequency-dependent                   --- #
  #---                                       --- #
  #--------------------------------------------- #
  
  # Create dictionary of all the clocks and their nodes
  set min_pulse_all_clocks_list [get_clock_list]
  set min_pulse_all_clocks_nodes_dict [dict create]
  
  foreach clk_name $min_pulse_all_clocks_list {

    # Check if clock is declared, but NOT defined (i.e. create_clock or create_generated_clock has NOT been used yet)
    if { [is_clock_defined $clk_name] == 1 } {
      set clk_node_col [get_clock_info -targets $clk_name]
	
      foreach_in_collection clk_node $clk_node_col {
        set clk_node_name [get_node_info -name $clk_node]
        dict set min_pulse_all_clocks_nodes_dict $clk_node_name $clk_name
      }
    }
  }
   
  # -------------------------------------------------------------------------------
  # TX coreclkin2
  # -------------------------------------------------------------------------------
  set tx_coreclkin2_col [get_pins -nowarn -compat g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_clk2_dcm]

  # Get fanins for tx_coreclkin2
  if {[get_collection_size $tx_coreclkin2_col] > 0} {
    set tx_coreclkin_fanin_col [get_fanins -clock -stop_at_clocks $tx_coreclkin2_col]
	
    # Find clock name on the fanin
    if {[get_collection_size $tx_coreclkin_fanin_col]} {
	
      foreach_in_collection fanin_node $tx_coreclkin_fanin_col {
        set fanin_node_name [get_node_info -name $fanin_node]

	      if {[dict exists $min_pulse_all_clocks_nodes_dict $fanin_node_name]} {
		      set fanin_clock_name [dict get $min_pulse_all_clocks_nodes_dict $fanin_node_name]
         set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $fanin_clock_name]]
  
          # Remap any backward slashes '' in the pins
          set fanin_clock_name [string map {\\ \\\\} $fanin_clock_name]

          # Adjust the min pulse width requirement based on frequency
          add_ddr_report_command "native_check_special_min_pulse_qufrg4q $fanin_clock_name"
        }
      }
    }
  }


  # -------------------------------------------------------------------------------
  # RX coreclkin2
  # -------------------------------------------------------------------------------
  set rx_coreclkin2_col [get_pins -nowarn -compat g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_rx_clk2_dcm]

  # Get fanins for rx_coreclkin2
  if {[get_collection_size $rx_coreclkin2_col] > 0} {
    set rx_coreclkin_fanin_col [get_fanins -clock -stop_at_clocks $rx_coreclkin2_col]
	
    # Find clock name on the fanin
    if {[get_collection_size $rx_coreclkin_fanin_col]} {
	
      foreach_in_collection fanin_node $rx_coreclkin_fanin_col {
        set fanin_node_name [get_node_info -name $fanin_node]

	      if {[dict exists $min_pulse_all_clocks_nodes_dict $fanin_node_name]} {
		      set fanin_clock_name [dict get $min_pulse_all_clocks_nodes_dict $fanin_node_name]
          set_active_clocks [remove_from_collection [get_active_clocks] [get_clocks $fanin_clock_name]]
          
          # Remap any backward slashes '' in the pins
          set fanin_clock_name [string map {\\ \\\\} $fanin_clock_name]

          # Adjust the min pulse width requirement based on frequency
          add_ddr_report_command "native_check_special_min_pulse_qufrg4q $fanin_clock_name"
        }
      }
    }
  }


  #--------------------------------------------- #
  #---                                       --- #
  #--- ASYNC CLOCK GROUP FOR RECONFIGURATION --- #
  #---                                       --- #
  #--------------------------------------------- #
  if {$profile_cnt > 1 } {
    if { $native_debug == 1 } {
      post_message -type info "========================================================================================"
      post_message -type info "IP SDC: Setting async clock groups for multi-profile"
    }

    set arg ""

    for {set i 0} {$i < $profile_cnt} {incr i} {
      set profile_clk_names ""

      dict for {mode clk_name} $profile_clocks {
        # Construct the arguments for set_clock_groups 
        # Template: set_clock_groups -asynchronous -group {<profile0 clks>} -group {<profile1 clks>} ...
        if {[dict exists $all_profile_clocks_names $i $mode]} {
          set profile_clk_names [concat $profile_clk_names [dict get $all_profile_clocks_names $i $mode]]
        }
      }

      set profile_clk_names [join $profile_clk_names]
      set group "-group "
      set arg [concat $arg $group] 
      set arg [concat $arg "{$profile_clk_names}"]

      if { $native_debug } {
        post_message -type info "IP SDC: Profile $i clocks: $profile_clk_names"
      }
    }

    set cmd ""
    set cmd [concat $cmd "set_clock_groups -physically_exclusive "]
    set cmd [concat $cmd $arg]
    eval $cmd

    if { $native_debug } {
      post_message -type info "IP SDC: Setting async clock groups for reconfiguration: $cmd"
    }

  }


  #-------------------------------------------------- #
  #---                                            --- #
  #--- Internal loopback path                     --- #
  #---                                            --- #
  #-------------------------------------------------- #
  set aib_fabric_pma_aib_tx_clk_col  [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_fabric_pma_aib_tx_clk.reg]
  set aib_fabric_tx_data_lpbk_col    [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|aib_fabric_tx_data_lpbk*]
  set aib_fabric_rx_transfer_clk_col [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx~aib_fabric_rx_transfer_clk.reg]
  set pld_tx_clk2_dcm_reg_col        [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~pld_tx_clk2_dcm.reg]
  set pld_tx_clk1_dcm_reg_col        [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~pld_tx_clk1_dcm.reg]

  # Cut the paths for the internal loopback paths
  if {[get_collection_size $aib_fabric_pma_aib_tx_clk_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
    set_false_path -from $aib_fabric_pma_aib_tx_clk_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
  }

  # Cut paths for internal loopback paths when bonding is enabled
  if {[get_collection_size $pld_tx_clk2_dcm_reg_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
    set_false_path -from $pld_tx_clk2_dcm_reg_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
  }
  if {[get_collection_size $pld_tx_clk1_dcm_reg_col] > 0 && [get_collection_size $aib_fabric_tx_data_lpbk_col] > 0 && [get_collection_size $aib_fabric_rx_transfer_clk_col] > 0} {
    set_false_path -from $pld_tx_clk1_dcm_reg_col -through $aib_fabric_tx_data_lpbk_col -to $aib_fabric_rx_transfer_clk_col
  }


    # -------------------------------------------------------------------------------------------------- #
    # --- set false path for adjacent channel connections introduced by clock skew control modeling  --- #
    # -------------------------------------------------------------------------------------------------- #
    if { $tx_enabled_on_any_profile && $max_num_channels > 1 } {
        set aib_pld_tx_clk_pin_col [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_clk?_dcm] 
        set aib_pld_tx_clk_pin_col  [add_to_collection $aib_pld_tx_clk_pin_col [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_tx_clk?_rowclk] ]
        set aib_tx_internal_div_reg_col [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~aib_tx_internal_div.reg]
        set aib_fabric_transfer_clk_col [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx~*aib_fabric_tx_transfer_clk.reg]
        if { [get_collection_size $aib_fabric_transfer_clk_col] > 0 } {
          if { [get_collection_size $aib_tx_internal_div_reg_col] > 0 } {
             set_false_path -from $aib_tx_internal_div_reg_col -to $aib_fabric_transfer_clk_col 
          }
          if { [get_collection_size $aib_pld_tx_clk_pin_col] > 0 } {
            set_false_path -through $aib_pld_tx_clk_pin_col -to $aib_fabric_transfer_clk_col
          }
        }
    } ; # tx_enabled_on_any_profile && max_num_channels > 1 
      


  #--------------------------------------------- #
  #---                                       --- #
  #--- SET_FALSE_PATH to reset synchronizers --- #
  #---                                       --- #
  #--------------------------------------------- #
  
  # TX and RX analog reset synchronizers
  set tx_analog_reset_resync_reg [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_anlg_reset_seq|g_anlg_trs_inst[*].reset_synchronizers|resync_chains[0].synchronizer_nocut|din_s1]                                                                                                      
  set tx_analog_reset_resync_reg [add_to_collection $tx_analog_reset_resync_reg [get_keepers -nowarn  g_ehip_reset.alt_xcvr_native_anlg_reset_seq_wrapper_inst|g_trs.tx_anlg_reset_seq|g_anlg_trs_inst[*].reset_synchronizers|resync_chains[0].synchronizer_nocut|din_s1] ]

  set rx_analog_reset_resync_reg [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_anlg_reset_seq|g_anlg_trs_inst[*].reset_synchronizers|resync_chains[0].synchronizer_nocut|din_s1]
  set rx_analog_reset_resync_reg [add_to_collection $rx_analog_reset_resync_reg [get_keepers -nowarn  g_ehip_reset.alt_xcvr_native_anlg_reset_seq_wrapper_inst|g_trs.rx_anlg_reset_seq|g_anlg_trs_inst[*].reset_synchronizers|resync_chains[0].synchronizer_nocut|din_s1] ]

  # TX and RX digital reset synchronizers
  set tx_digital_reset_resync_reg             [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|reset_synchronizers|resync_chains[*].synchronizer_nocut|din_s1]
  set tx_digital_transfer_ready_resync_reg    [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|transfer_ready_synchronizers|resync_chains[*].synchronizer_nocut|din_s1]
  set tx_digital_release_aib_first_resync_reg [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|release_aib_first_synchronizers|resync_chains[0].synchronizer_nocut|din_s1]
  set rx_digital_reset_resync_reg             [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|reset_synchronizers|resync_chains[*].synchronizer_nocut|din_s1]
  set rx_digital_transfer_ready_resync_reg    [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|transfer_ready_synchronizers|resync_chains[*].synchronizer_nocut|din_s1]
  set rx_digital_release_aib_first_resync_reg [get_keepers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|release_aib_first_synchronizers|resync_chains[0].synchronizer_nocut|din_s1]
    
  # TX reset synchronizers
  if {[dict get $native_phy_ip_params tx_enable_profile0]} {

    # TX analog resets
    if {[get_collection_size $tx_analog_reset_resync_reg] > 0} {
      foreach_in_collection resync_reg $tx_analog_reset_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    # TX digital resets
    if {[get_collection_size $tx_digital_reset_resync_reg] > 0} {
      foreach_in_collection resync_reg $tx_digital_reset_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    if {[get_collection_size $tx_digital_transfer_ready_resync_reg] > 0} {
      foreach_in_collection resync_reg $tx_digital_transfer_ready_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    if {[get_collection_size $tx_digital_release_aib_first_resync_reg] > 0} {
      foreach_in_collection resync_reg $tx_digital_release_aib_first_resync_reg {
        set_false_path -to $resync_reg
      }
    }
  }

  # RX reset synchronizers
  if {[dict get $native_phy_ip_params rx_enable_profile0]} {

    # RX analog resets
     if {[get_collection_size $rx_analog_reset_resync_reg] > 0} {
      foreach_in_collection resync_reg $rx_analog_reset_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    # RX digital resets
    if {[get_collection_size $rx_digital_reset_resync_reg] > 0} {
      foreach_in_collection resync_reg $rx_digital_reset_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    if {[get_collection_size $rx_digital_transfer_ready_resync_reg] > 0} {
      foreach_in_collection resync_reg $rx_digital_transfer_ready_resync_reg {
        set_false_path -to $resync_reg
      }
    }

    if {[get_collection_size $rx_digital_release_aib_first_resync_reg] > 0} {
      foreach_in_collection resync_reg $rx_digital_release_aib_first_resync_reg {
        set_false_path -to $resync_reg
      }
    }
  }


  # Early speed change reset synchronizers
  set early_spd_chng_reset_resync_reg [get_keepers -nowarn g_early_spd_chng_enable.pipe_early_spd_chng_inst|reset_n_synchronizers|resync_chains[0].synchronizer_nocut|din_s1]
  set early_spd_chng_reset_resync_reg [add_to_collection $early_spd_chng_reset_resync_reg [get_keepers -nowarn  g_early_spd_chng_enable.pipe_early_spd_chng_inst|reset_n_synchronizers|resync_chains[0].synchronizer_nocut|dreg*]]

  if {[get_collection_size $early_spd_chng_reset_resync_reg] > 0} {
    foreach_in_collection resync_reg $early_spd_chng_reset_resync_reg {
      set_false_path -to $resync_reg
    }
  }


  #--------------------------------------------- #
  #---                                       --- #
  #--- MIN & MAX DELAYS FOR RESETS           --- #
  #---                                       --- #
  #--------------------------------------------- #

  if {[dict get $native_phy_ip_params tx_enable_profile0]} {

    # TX PMA resets
    set tx_analog_reset_reg  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_anlg_reset_seq|reset_out_stage*]
    set tx_pld_pma_reset_pin [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_pma_txpma_rstb]
    
    if {[get_collection_size $tx_analog_reset_reg] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find registers for TX analog resets"
      }

    } elseif {[get_collection_size $tx_pld_pma_reset_pin] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find TX PMA reset atom"
      }

    } else {
      set_max_delay -from $tx_analog_reset_reg -through $tx_pld_pma_reset_pin  200
      set_min_delay -from $tx_analog_reset_reg -through $tx_pld_pma_reset_pin -200
    }

    # TX PCS resets
    set tx_digital_pcs_reset_reg [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|pcs_reset_out_stage*]
    set tx_pld_pcs_reset_pin     [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_pcs_tx_pld_rst_n]

    if {[get_collection_size $tx_digital_pcs_reset_reg] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find TX digital PCS resets"
      }

    } elseif {[get_collection_size $tx_pld_pcs_reset_pin] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find TX PCS reset atom"
      }

    } else {
      set_max_delay -from $tx_digital_pcs_reset_reg -through $tx_pld_pcs_reset_pin  200
      set_min_delay -from $tx_digital_pcs_reset_reg -through $tx_pld_pcs_reset_pin -200
    }

    # TX AIB/adapter resets
    set tx_digital_aib_reset_reg [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.tx_dig_reset_seq|aib_reset_out_stage*]
    set tx_pld_adapter_reset_pin [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_adapter_tx_pld_rst_n]

    if {[get_collection_size $tx_digital_aib_reset_reg] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find TX digital AIB/adapter resets"
      }

    } elseif {[get_collection_size $tx_pld_adapter_reset_pin] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find TX AIB/adapter reset atom"
      }

    } else {
      set_max_delay -from $tx_digital_aib_reset_reg -through $tx_pld_adapter_reset_pin  200
      set_min_delay -from $tx_digital_aib_reset_reg -through $tx_pld_adapter_reset_pin -200
    }
  }

  if {[dict get $native_phy_ip_params rx_enable_profile0]} {

    # RX PMA resets
    set rx_analog_reset_reg  [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_anlg_reset_seq|reset_out_stage*]
    set rx_pld_pma_reset_pin [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pma_rxpma_rstb]
    
    if {[get_collection_size $rx_analog_reset_reg] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find registers for RX analog resets"
      }

    } elseif {[get_collection_size $rx_pld_pma_reset_pin] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find RX PMA reset atom"
      }

    } else {
      set_max_delay -from $rx_analog_reset_reg -through $rx_pld_pma_reset_pin  200
      set_min_delay -from $rx_analog_reset_reg -through $rx_pld_pma_reset_pin -200
    }

    # RX PCS resets
    set rx_digital_pcs_reset_reg [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|pcs_reset_out_stage*]
    set rx_pld_pcs_reset_pin     [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_pcs_rx_pld_rst_n]
    
    if {[get_collection_size $rx_digital_pcs_reset_reg] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find RX digital PCS resets"
      }

    } elseif {[get_collection_size $rx_pld_pcs_reset_pin] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find RX PCS reset atom"
      }

    } else {
      set_max_delay -from $rx_digital_pcs_reset_reg -through $rx_pld_pcs_reset_pin  200
      set_min_delay -from $rx_digital_pcs_reset_reg -through $rx_pld_pcs_reset_pin -200
    }

    # RX AIB/adapter resets
    set rx_digital_aib_reset_reg [get_registers -nowarn g_non_hip_reset.alt_xcvr_native_reset_seq|g_trs.rx_dig_reset_seq|aib_reset_out_stage*]
    set rx_pld_adapter_reset_pin [get_pins -compat -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_rx.inst_ct1_hssi_pldadapt_rx|pld_adapter_rx_pld_rst_n]

    if {[get_collection_size $rx_digital_aib_reset_reg] == 0} {
       if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find RX digital AIB/adapter resets"
      }

    } elseif {[get_collection_size $rx_pld_adapter_reset_pin] == 0} {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Could not find RX AIB/adapter reset atom"
      }

    } else {
      set_max_delay -from $rx_digital_aib_reset_reg -through $rx_pld_adapter_reset_pin  200
      set_min_delay -from $rx_digital_aib_reset_reg -through $rx_pld_adapter_reset_pin -200
    }
  }

  #--------------------------------------------- #
  #---                                       --- #
  #--- PRBS constraints                      --- #
  #---                                       --- #
  #--------------------------------------------- # 
  # Check that reconfiguration is enabled and soft logic for doing prbs bit and error accumulation when using the hard prbs generator and checker is enabled
  if {[dict get $native_phy_ip_params rcfg_enable_profile0] && [dict get $native_phy_ip_params set_prbs_soft_logic_enable_profile0]} {

    set prbs_path  "g_recal_*_rcfg_opt_logic.alt_xcvr_native_optional_rcfg_logic|g_optional_chnl_reconfig_logic[*].g_prbs_accumulators_enable.prbs_soft_accumulators"

    set prbs_soft_accumulators_rx_prbs_err_snapshot_col [get_registers -nowarn $prbs_path|rx_prbs_err_snapshot*]

    if { [get_collection_size $prbs_soft_accumulators_rx_prbs_err_snapshot_col] > 0 } {
      
      # When using the PRBS Error Accumulation logic, set multicycle constraints to reduce routing effor and congestion.
      set prbs_soft_accumulators_avmm_prbs_err_count_col [get_registers -nowarn $prbs_path|avmm_prbs_err_count*]
      set_max_delay -from $prbs_soft_accumulators_rx_prbs_err_snapshot_col -to $prbs_soft_accumulators_avmm_prbs_err_count_col 200
      set_min_delay -from $prbs_soft_accumulators_rx_prbs_err_snapshot_col -to $prbs_soft_accumulators_avmm_prbs_err_count_col -200
  
      # Set false paths for the asynchronous resets no-cut synchronizers
      set_false_path -through [get_pins -nowarn -compat  $prbs_path|rx_clk_reset_sync|resync_chains[0].synchronizer_nocut|din_s1|clrn] -to [get_registers -nowarn $prbs_path|rx_clk_reset_sync|resync_chains[0].synchronizer_nocut|din_s1]
      set_false_path -through [get_pins -nowarn -compat  $prbs_path|rx_clk_reset_sync|resync_chains[0].synchronizer_nocut|dreg*|clrn]  -to [get_registers -nowarn $prbs_path|rx_clk_reset_sync|resync_chains[0].synchronizer_nocut|dreg[?]]
                                                                          
      set embedded_debug_soft_csr_col [get_registers -nowarn g_recal_*_rcfg_opt_logic.alt_xcvr_native_optional_rcfg_logic|g_optional_chnl_reconfig_logic[*].g_avmm_csr_enabled.embedded_debug_soft_csr|g_prbs_reg_en*]
      set_false_path -from $embedded_debug_soft_csr_col -to [get_registers -nowarn $prbs_path|rx_clk_prbs_reset_sync|resync_chains[0].synchronizer_nocut|din_s1]
      set_false_path -from $embedded_debug_soft_csr_col -to [get_registers -nowarn $prbs_path|rx_clk_prbs_reset_sync|resync_chains[0].synchronizer_nocut|dreg[?]]

      set_false_path -through [get_pins -nowarn -compat $prbs_path|rx_clk_prbs_err_sync|resync_chains[0].synchronizer_nocut|din_s1|clrn] -to [get_registers -nowarn $prbs_path|rx_clk_prbs_err_sync|resync_chains[0].synchronizer_nocut|din_s1]
      set_false_path -through [get_pins -nowarn -compat $prbs_path|rx_clk_prbs_err_sync|resync_chains[0].synchronizer_nocut|dreg*|clrn] -to  [get_registers -nowarn $prbs_path|rx_clk_prbs_err_sync|resync_chains[0].synchronizer_nocut|dreg[?]]
      
      set_false_path -through [get_pins -nowarn -compat $prbs_path|rx_clk_prbs_done_sync|resync_chains[0].synchronizer_nocut|din_s1|clrn] -to [get_registers -nowarn $prbs_path|rx_clk_prbs_done_sync|resync_chains[0].synchronizer_nocut|din_s1]
      set_false_path -through [get_pins -nowarn -compat $prbs_path|rx_clk_prbs_done_sync|resync_chains[0].synchronizer_nocut|dreg*|clrn]  -to [get_registers -nowarn $prbs_path|rx_clk_prbs_done_sync|resync_chains[0].synchronizer_nocut|dreg[?]]
            
      # Set false paths for data no-cut synchronizers
      set_false_path -to [get_registers -nowarn $prbs_path|avmm_clk_prbs_done_sync|resync_chains[0].synchronizer_nocut|din_s1]
      set_false_path -to [get_registers -nowarn $prbs_path|avmm_clk_bit_count_edge|resync_chains[0].synchronizer_nocut|din_s1]

    } else {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Reconfiguration and PRBS soft accumulators are enabled, but IP SDC is unable to find any matching registers for PRBS soft accumulators"
      }
    }
  }

  #--------------------------------------------- #
  #---                                       --- #
  #--- RX EIOS Protection  Constraints       --- #
  #---                                       --- #
  #--------------------------------------------- # 
  set eios_path  "g_recal_disable_rcfg_opt_logic.alt_xcvr_native_optional_rcfg_logic|g_eios_rp_enable.pcie_rx_eios_prot_inst"
  set eios_sync_din_col [get_registers -nowarn $eios_path|*_sync|din_s1]
  # Check if there are resync registers for EIOS
  if { [get_collection_size $eios_sync_din_col] > 0 } {
       # Set false paths for data no-cut synchronizers
       set_false_path -to $eios_sync_din_col    
  
    set eios_sync_nreset_col [get_registers -nowarn $eios_path|u_sync_nreset|din_s1]
    if { [get_collection_size $eios_sync_nreset_col] > 0 } {
      # Set false paths for the asynchronous resets no-cut synchronizers
      set_false_path -through [get_pins -nowarn -compat $eios_path|u_sync_nreset|din_s1|clrn] -to $eios_sync_nreset_col
      set_false_path -through [get_pins -nowarn -compat $eios_path|u_sync_nreset|dreg[?]|clrn] -to [get_registers -nowarn $eios_path|u_sync_nreset|dreg[?]]
    }                                                                        
  }


  #-------------------------------------------------- #
  #---                                            --- #
  #--- AVMM wrapper constraints                   --- #
  #---                                            --- #
  #-------------------------------------------------- #
  # Check that reconfiguration is enabled
  if {[dict get $native_phy_ip_params rcfg_enable_profile0]} {

    set ct2_xcvr_avmm_reset_clrn_col [get_pins -nowarn -compat g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct1_xcvr_avmm1|avmm_if_soft_logic[*].ct1_xcvr_avmm_soft_logic_inst|sync_r[?]|clrn]

    if { [get_collection_size $ct2_xcvr_avmm_reset_clrn_col] > 0 } {
      # Set false path to avmm_reset synchronizer
      set ct2_xcvr_avmm_reset_sync_reg_col [get_registers -nowarn g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct1_xcvr_avmm1|avmm_if_soft_logic[*].ct1_xcvr_avmm_soft_logic_inst|sync_r[?]]
      set_false_path -through $ct2_xcvr_avmm_reset_clrn_col -to $ct2_xcvr_avmm_reset_sync_reg_col
    } else {
      if {$native_debug == 1} {
        post_message -type warning "IP SDC: Reconfiguration is enabled, but IP SDC is unable to find any matching nodes for AVMM soft logic"
      }

    }
  }

  #-------------------------------------------------- #
  #---                                            --- #
  #--- SET_FALSE_PATH for MAIB ASYNC signals      --- #
  #---                                            --- #
  #-------------------------------------------------- #
  # Create a set of all asynchronous signals to be looped over for setting false paths
  # These signals are async input signals to Nadder Adapter
  set altera_xcvr_native_s10_async_signals {
    pld_pma_fpll_up_dn_lc_lf_rstn
    pld_pma_txdetectrx
    pld_ltr
    pld_pma_ltd_b
    pld_txelecidle
    pld_10g_krfec_rx_clr_errblk_cnt
    pld_10g_rx_clr_ber_count
    pld_10g_tx_bitslip
    pld_10g_tx_diag_status
    pld_8g_a1a2_size
    pld_8g_bitloc_rev_en
    pld_8g_byte_rev_en
    pld_8g_encdt
    pld_8g_tx_boundary_sel
    pld_bitslip
    pld_pma_adapt_start
    pld_pma_early_eios
    pld_pma_eye_monitor
    pld_pma_pcie_switch
    pld_pma_rs_lpbk_b
    pld_pmaif_rxclkslip
    pld_pma_tx_qpi_pulldn
    pld_pma_tx_qpi_pullup
    pld_pma_rx_qpi_pullup
    pld_polinv_rx
    pld_polinv_tx
    pld_syncsm_en
    pld_rx_prbs_err_clr
    pld_10g_tx_wordslip
    pld_pma_tx_bitslip
    pld_8g_eidleinfersel
    pld_tx_fifo_latency_adj_en
    pld_rx_fifo_latency_adj_en
  }

  if { [ info exists altera_xcvr_native_s10_async_xcvr_pins ] } {
    unset altera_xcvr_native_s10_async_xcvr_pins
  }

  # Set false paths for each item in the set
  foreach altera_xcvr_native_s10_async_signal_name $altera_xcvr_native_s10_async_signals {
    set altera_xcvr_native_s10_async_xcvr_pins [get_pins -nowarn -compatibility_mode g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_?x.inst_ct1_hssi_pldadapt_?x|${altera_xcvr_native_s10_async_signal_name}*]
    if { [get_collection_size $altera_xcvr_native_s10_async_xcvr_pins] > 0 } {
      set_false_path -to $altera_xcvr_native_s10_async_xcvr_pins
    }
  }


  #-------------------------------------------------- #
  #---                                            --- #
  #--- TX BURST ENABLE MIN/MAX CONSTRAINTS        --- #
  #---                                            --- #
  #-------------------------------------------------- #
  # For TX burst enable, even though its an asynchronous signal, set a bound, since we need the fitter to place it some-what close to the periphery for interlaken
  set altera_xcvr_native_s10_async_tx_burst_en_pins [get_pins -nowarn -compatibility_mode g_xcvr_native_insts[*].ct2_xcvr_native_inst|inst_ct2_xcvr_channel_multi|gen_rev.ct2_xcvr_channel_inst|gen_ct1_hssi_pldadapt_tx.inst_ct1_hssi_pldadapt_tx|pld_10g_tx_burst_en*]
  if { [get_collection_size $altera_xcvr_native_s10_async_tx_burst_en_pins] > 0 } {
    set_max_delay -to $altera_xcvr_native_s10_async_tx_burst_en_pins 200ns
    set_min_delay -to $altera_xcvr_native_s10_async_tx_burst_en_pins -200ns
  }
  
  # alt_xcvr_resync_reset
  set alt_xcvr_sync_aibreset_to_rx_parallel_data [get_registers -nowarn g_lf_conditions[*].g_enforce_local_fault.transfer_ready_synchronizers|resync_chains[*].synchronizer_nocut|dreg[*]]
  if {[get_collection_size $alt_xcvr_sync_aibreset_to_rx_parallel_data] > 0} {
    foreach_in_collection resync_reg $alt_xcvr_sync_aibreset_to_rx_parallel_data {
      set_false_path -to $resync_reg
    }
  }

  set alt_xcvr_sync_din_to_rx_parallel_data [get_registers -nowarn g_lf_conditions[*].g_enforce_local_fault.transfer_ready_synchronizers|resync_chains[*].synchronizer_nocut|din_s1]
  if {[get_collection_size $alt_xcvr_sync_din_to_rx_parallel_data] > 0} {
    foreach_in_collection resync_reg $alt_xcvr_sync_din_to_rx_parallel_data {
      set_false_path -to $resync_reg
    }
  }


}; #foreach inst

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

msg_vdebug "IP SDC: End of Native PHY IP SDC file!"


