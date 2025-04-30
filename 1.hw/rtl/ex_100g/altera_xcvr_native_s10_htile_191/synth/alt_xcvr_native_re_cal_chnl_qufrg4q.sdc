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
# --- This file contains the clock creation constraints for    --- #
# --- recalibration soft IP                                    --- #
# -                                                              - # 
# ---------------------------------------------------------------- #

# Source the IP parameters Tcl file
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

# Get the number of channels in the Native PHY IP
set num_channels [dict get $native_phy_ip_params channels_profile0]

# Find the current Native PHY instance name in the design
set instance_name [get_current_instance]

# Grab the entity name for the XCVR reset sequencer (needed because the recal clocks are derived 
# from the internal oscillator clock which feeds the XCVR reset sequencer)
set alt_xcvr_reset_seq_entity_inst [get_entity_instances {altera_xcvr_reset_sequencer_s10}]
set alt_xcvr_reset_seq_entity_inst_list [split $alt_xcvr_reset_seq_entity_inst |]
set alt_xcvr_reset_seq_entity_inst_list  [lreplace $alt_xcvr_reset_seq_entity_inst_list end end]
set alt_xcvr_reset_seq_entity_inst_final_name [join $alt_xcvr_reset_seq_entity_inst_list |]

#-------------------------------------------------- #
#---                                            --- #
#--- CLOCK CREATION                             --- #
#---                                            --- #
#-------------------------------------------------- #

# For each channel
for {set i 0} {$i < $num_channels} {incr i} {

  # Get the clk_div8 registers
  set recal_clk_div8_col [get_registers -nowarn $instance_name|g_recal[$i].alt_xcvr_recal|clk_div8]
  if { [get_collection_size $recal_clk_div8_col] > 0 } {
  
    # Get the internal oscillator fanin to the clk_div2 register
    set clk_div8_fanin_col [get_fanins -stop_at_clocks $recal_clk_div8_col]
  
    set int_osc_clk_name ""
    foreach_in_collection fanin $clk_div8_fanin_col {
      set temp_fanin_name [get_node_info -name $fanin]
      if {[string match *$alt_xcvr_reset_seq_entity_inst_final_name*_divided_osc_clk|q $temp_fanin_name]} {
        set int_osc_clk_name $temp_fanin_name
        break
      }
    }
  
    # -------------------------------------------------- #
    # --- CLK_DIV2 CREATION                          --- #
    # -------------------------------------------------- #
    foreach_in_collection clk_div8 $recal_clk_div8_col {
  
      set clk_div8_node_name [get_node_info -name $clk_div8]
  
      if {$int_osc_clk_name != ""} {
  
        create_generated_clock \
          -name $instance_name|recal_clk_div8|ch$i \
          -divide_by 8 \
          -source $int_osc_clk_name \
          $clk_div8_node_name
      }; # if statement
     }; #foreach in recal_clk_div8_col
  }; #if clk_div8
}; #for i < num_channels


#-------------------------------------------------- #
#---                                            --- #
#--- SET FALSE PATHS TO SYNCHRONIZERS           --- #
#---                                            --- #
#-------------------------------------------------- #

# start_synchronizer
set start_synchronizer_col [get_registers -nowarn $instance_name|g_recal[*].alt_xcvr_recal|start_synchronizer|resync_chains[*].synchronizer_nocut|din_s1]
if {[get_collection_size $start_synchronizer_col] > 0} {
  foreach_in_collection resync_reg $start_synchronizer_col {
    set_false_path -to $resync_reg
  }
}

# alt_xcvr_resync_avmm1_busy
set alt_xcvr_resync_avmm1_busy_col [get_registers -nowarn $instance_name|g_recal[*].alt_xcvr_recal|alt_xcvr_resync_avmm1_busy|resync_chains[*].synchronizer_nocut|din_s1]
if {[get_collection_size $alt_xcvr_resync_avmm1_busy_col] > 0} {
  foreach_in_collection resync_reg $alt_xcvr_resync_avmm1_busy_col {
    set_false_path -to $resync_reg
  }
}

# alt_xcvr_resync_bg_en
set alt_xcvr_resync_bg_en_col [get_registers -nowarn $instance_name|g_recal[*].alt_xcvr_recal|alt_xcvr_resync_bg_en|resync_chains[*].synchronizer_nocut|din_s1]
if {[get_collection_size $alt_xcvr_resync_bg_en_col] > 0} {
  foreach_in_collection resync_reg $alt_xcvr_resync_bg_en_col {
    set_false_path -to $resync_reg
  }
}

# alt_xcvr_resync_recal_waitrequest
set alt_xcvr_resync_recal_waitrequest_col [get_registers -nowarn $instance_name|g_recal[*].alt_xcvr_recal|recal_wreq_synchronizer|resync_chains[*].synchronizer_nocut|din_s1]
if {[get_collection_size $alt_xcvr_resync_recal_waitrequest_col] > 0} {
  foreach_in_collection resync_reg $alt_xcvr_resync_recal_waitrequest_col {
    set_false_path -to $resync_reg
  }
}
# alt_xcvr_resync_reset
set alt_xcvr_resync_reset_col [get_pins -nowarn $instance_name|g_recal[*].alt_xcvr_recal|alt_xcvr_resync_reset*|resync_chains[*].synchronizer_nocut|d*|clrn]
if {[get_collection_size $alt_xcvr_resync_reset_col] > 0} {
  foreach_in_collection resync_reg $alt_xcvr_resync_reset_col {
    set_false_path -through $resync_reg
  }
}



