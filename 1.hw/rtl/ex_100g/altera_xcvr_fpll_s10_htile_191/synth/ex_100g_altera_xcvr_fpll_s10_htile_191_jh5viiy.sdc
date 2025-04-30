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


# ------------------------------------------------ #
# -
# --- This is an auto generated file. Do not   --- # 
# --- change the contents of this file         --- #
# --- The changes will be lost once the IP     --- #
# --- is regenerated                           --- #
# - 
# ------------------------------------------------ #


# ------------------------------------------- #
# -                                         - #
# --- Some useful functions and variables --- #
# -                                         - #
# ------------------------------------------- #
set script_dir [file dirname [info script]] 
set split_qsys_output_name [split ex_100g_altera_xcvr_fpll_s10_htile_191_jh5viiy "_"]
set xcvr_nphy_index [lsearch $split_qsys_output_name "altera"]
if {$xcvr_nphy_index < 0} {
  set list_top_inst_name $split_qsys_output_name
} else {
  set list_top_inst_name [lreplace $split_qsys_output_name $xcvr_nphy_index end]
}
set top_inst_name [join $list_top_inst_name "_"]
source "${script_dir}/${top_inst_name}_ip_parameters_jh5viiy.tcl"
source "${script_dir}/alt_xcvr_fpll_helper_functions_jh5viiy.tcl"

# Debug switch. Change to 1 to get more run-time debug information
if {![info exists fpll_sdc_debug]} {
  global ::fpll_sdc_debug
}

# ---------------------------------------------------------------- #
# -                                                              - #
# --- Build cache for all pins and registers required to apply --- #
# --- timing constraints                                       --- #
# -                                                              - #
# ---------------------------------------------------------------- #
fpll_initialize_db_jh5viiy fpll_db_jh5viiy

# ---------------------------------------------------------------- #
# --- Set all the instances of this core                       --- #
# ---------------------------------------------------------------- #
set alt_xcvr_fpll_s10_instances [ dict keys $fpll_db_jh5viiy ]

if {[info exists alt_xcvr_fpll_s10_pins]} {
   unset alt_xcvr_fpll_s10_pins
}
set alt_xcvr_fpll_s10_pins [dict create]

# ---------------------------------------------------------------- #
# -                                                              - #
# --- Iterate through each instance and apply the necessary    --- #
# --- timing constraints                                       --- #
# -                                                              - #
# ---------------------------------------------------------------- #
foreach inst $alt_xcvr_fpll_s10_instances {

  if { [ dict exists $alt_xcvr_fpll_s10_pins $inst ] } {
    dict unset alt_xcvr_fpll_s10_pins $inst
    
    if { $fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: Array pins for instance $inst existed before, unsetting them"
    }

  } 
  dict set alt_xcvr_fpll_s10_pins $inst [dict get $fpll_db_jh5viiy $inst]

  # Delete the clock names array if it exists 
  if [info exists all_fpll_profile_clocks_names] {
    unset all_fpll_profile_clocks_names
  }
  set all_fpll_profile_clocks_names [dict create]

  # -------------------------------------------------------------- #
  # --- Iterate over the profiles                              --- #
  # -------------------------------------------------------------- #
  set profile_cnt [dict get $fpll_ip_params profile_cnt]

  for {set i 0} {$i < $profile_cnt} {incr i} {

    if {$fpll_sdc_debug == 1} {
      post_message -type info "========================================================================================"
      post_message -type info "IP SDC: PROFILE $i"
    }

    set fpll_output_freq [dict get $fpll_ip_params set_output_clock_frequency_profile$i]
    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: fPLL output frequency = $fpll_output_freq"
    }

    # ----------------------------------------------------------------------------- #
    # --- Unset the profile_clocks dictionary if it exists                      --- #
    # ----------------------------------------------------------------------------- #
    if {[info exists profile_clocks]} {
      unset profile_clocks
    }
    set profile_clocks [dict create]

    if {[info exists multiply_factor_dict] } {
      unset multiply_factor_dict
    }
    set multiply_factor_dict [dict create]

    if {[info exists divide_factor_dict] } {
      unset divide_factor_dict
    }
    set divide_factor_dict [dict create]


    # ----------------------------------------------------------------------------- #
    # --- Create fPLL CLKDIV clocks and clock frequencies                       --- #
    # ----------------------------------------------------------------------------- #

    #REFCLK PORT
    if {[dict exists $alt_xcvr_fpll_s10_pins $inst fpll_refclk_port]} {

      set refclk_port [dict get $alt_xcvr_fpll_s10_pins $inst fpll_refclk_port]
      #declare_clock $refclk_name
      set refclk_freq [dict get $fpll_ip_params final_reference_clock_frequency_profile$i]

      msg_vdebug "IP SDC: The fPLL IP reference clock frequency is set to $refclk_freq"

      # Find the maximum precision of between the refclk and output frequency
      set refclk_split      [split $refclk_freq "."]
      set fpll_output_split [split $fpll_output_freq "."]
      set max_precision     [expr max([string length [lindex $refclk_split end]], [string length [lindex $fpll_output_split end]])]

      # Ensure that multiply and divide factors are less than 999999999
      if {[llength $refclk_split] > 1 && [string length $refclk_freq ] > 10} {
        set max_precision [expr $max_precision - [string length [lindex $refclk_split 0]]]
      } elseif {[llength $fpll_output_split] > 1 && [string length $fpll_output_freq ] > 10} {
        set max_precision [expr $max_precision - [string length [lindex $fpll_output_split 0]]]
      }

      set fpll_c0_div_reg_multiply_factor [expr round($fpll_output_freq * (10 ** $max_precision))]
      set fpll_c0_div_reg_divide_factor   [expr round($refclk_freq * (10 ** $max_precision))]        

      if {$fpll_sdc_debug == 1} {
        post_message -type info "IP SDC: Multiply factor for fpll_c0_div.reg node = $fpll_c0_div_reg_multiply_factor"
        post_message -type info "IP SDC: Divide   factor for fpll_c0_div.reg node = $fpll_c0_div_reg_divide_factor"
      }

      #fPLL_C0_DIV.REG
      dict set profile_clocks fpll_c0_div_reg fpll_c0_div_reg
      dict set multiply_factor_dict fpll_c0_div_reg $fpll_c0_div_reg_multiply_factor
      dict set divide_factor_dict   fpll_c0_div_reg $fpll_c0_div_reg_divide_factor

      #INCLK
      dict set profile_clocks inclk clkdiv_inclk
      dict set multiply_factor_dict clkdiv_inclk 1
      dict set divide_factor_dict   clkdiv_inclk 1
  
      #CLOCK_DIV OUTPUTS
      if {[dict get $fpll_ip_params set_x1_core_clock_profile$i]} {
        dict set profile_clocks clkdiv_output_clks clkdiv_output_div1
        dict set multiply_factor_dict clkdiv_output_div1 1
        dict set divide_factor_dict   clkdiv_output_div1 1

      } else {
        post_message -type error "IP SDC Error: Divide by 1 output core clock is not enabled. Check the Phase aligned core outputs."
    
      }

      if {[dict get $fpll_ip_params set_x2_core_clock_profile$i]} {
        dict lappend profile_clocks clkdiv_output_clks clkdiv_output_div2
        dict set multiply_factor_dict clkdiv_output_div2 1
        dict set divide_factor_dict   clkdiv_output_div2 2
      }

      if {[dict get $fpll_ip_params set_x4_core_clock_profile$i]} {
        dict lappend profile_clocks clkdiv_output_clks clkdiv_output_div4
        dict set multiply_factor_dict clkdiv_output_div4 1
        dict set divide_factor_dict   clkdiv_output_div4 4
      }


      # ----------------------------------------------------------------------------- #
      # --- Create clocks for each mode                                           --- #
      # ----------------------------------------------------------------------------- #
      if {$fpll_sdc_debug == 1} {
        post_message -type info "========================================================================================"
        post_message -type info "IP SDC: Creating clocks for fPLL IP in core mode"
      }

      dict for {mode mode_clks} $profile_clocks {
        set list_of_clk_names [list]

        if {$fpll_sdc_debug == 1} {
          post_message -type info "----------------------------------------------------------------------------------------"
          post_message -type info "IP SDC: Creating clocks for $mode group"
        }

        set list_of_clk_names [fpll_prepare_to_create_clocks_jh5viiy $inst $mode $mode_clks $profile_cnt $i $alt_xcvr_fpll_s10_pins $multiply_factor_dict $divide_factor_dict $all_fpll_profile_clocks_names]
        dict set all_fpll_profile_clocks_names $i $mode [join [lsort -dictionary $list_of_clk_names]]

        if {$fpll_sdc_debug == 1} {
          post_message -type info "IP SDC: All Profile $i clocks for $mode: [dict get $all_fpll_profile_clocks_names $i $mode]"
        }
      } ; # dict for {mode mode_clks}

    } else {
      post_message -type warning "IP SDC: No nodes associated with fPLL IP $inst were found in the design. Please check your design and ensure 1) reference clock is created prior to reading fPLL IP SDC 2) fPLL IP $inst is properly connected to inputs and outputs 3) $inst is actually driving logic."
    }


    #-------------------------------------------------- #
    #---                                            --- #
    #--- DISABLE MIN_PULSE_WIDTH CHECK              --- #
    #---                                            --- #
    #-------------------------------------------------- #
    # Disable min_width_pulse for fPLL counter nodes
    set fpll_counter_nodes_list [get_nodes -nowarn *cmu_fpll_pld_adapt*~fpll_c?_div]
    if {[get_collection_size $fpll_counter_nodes_list] > 0} {
      foreach_in_collection fpll_counter_node $fpll_counter_nodes_list {

        # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY
        set fpll_counter_node_name [get_node_info -name $fpll_counter_node]
        set no_inst_fpll_counter_name_node [string replace $fpll_counter_node_name 0 [string length $inst]]

        disable_min_pulse_width $no_inst_fpll_counter_name_node
      }
    }

  } ; # foreach profile

}


msg_vdebug "IP SDC: End of fPLL IP SDC file!"


