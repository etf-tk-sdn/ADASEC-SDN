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


# -------------------------------------------------------------------------- #
# - 
# --- This file contains helper functions for fpll PHY SDC file
# -
# -------------------------------------------------------------------------- #
set script_dir [file dirname [info script]]

load_package sdc_ext
load_package design

if {![info exists fpll_sdc_debug]} {
  global ::fpll_sdc_debug
}

set fpll_sdc_debug 0

# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to initialize the database of all required pins and      --- #
# --- registers to create clocks                                         --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc fpll_initialize_db_jh5viiy { fpll_db } {

  # upvar links one variable to another variable at specified level of execution
  upvar $fpll_db local_fpll_db

  # Set the GLOBAL_corename in ip_parameters.tcl 
  global ::GLOBAL_corename
  global ::fpll_sdc_debug

  # Delete the database if it exists
  if [info exists local_fpll_db] {
    msg_vdebug "IP SDC: Database existed before, deleting it now"
    unset local_fpll_db
  } 

  set local_fpll_db [dict create]

  msg_vdebug "IP SDC: Initializing S10 fPLL database for CORE $::GLOBAL_corename"

  # Find the current fPLL IP instance name in the design
  set instance_name [get_current_instance]

  # Create dictionary of pins
  msg_vdebug "IP SDC: Finding port-to-pin mapping for CORE: $::GLOBAL_corename INSTANCE: $instance_name"
  set all_pins [dict create]
  fpll_get_pins_jh5viiy $instance_name $all_pins
  
  # Set the associative array
  dict set local_fpll_db $instance_name $all_pins

}


# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to find all the pins and registers for nodes of interest --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc fpll_get_pins_jh5viiy { instance all_pins } {

  global ::fpll_sdc_debug

  # We need to make a local copy of the allpins associative array
  upvar all_pins fpll_pins

  # ------------------------------------------------------------------------- #
  # Define the pins here 

  # fPLL refclk and counter nodes
  set fpll_c0_div_reg_list   [fpll_get_fpll_counter_div_reg_node_jh5viiy]
  set fpll_refclk_port_list  [fpll_get_refclk_port_jh5viiy $instance $fpll_c0_div_reg_list]

  # DCM clock divider pins
  set clkdiv_inclk_pin       clk_divider_inst|inclk
  set clkdiv_output_div1_pin clk_divider_inst|clock_div1
  set clkdiv_output_div2_pin clk_divider_inst|clock_div2
  set clkdiv_output_div4_pin clk_divider_inst|clock_div4


  # ------------------------------------------------------------------------- #
  # Create a dictionary for each clock pin 
  set fpll_pins [dict create]

  # ------------------------------------------------------------------------- #
  if {[llength $fpll_refclk_port_list] > 0} {
    foreach refclk_port $fpll_refclk_port_list {
       dict lappend fpll_pins fpll_refclk_port $refclk_port
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting refclk port info: [dict get $fpll_pins fpll_refclk_port]"
    }

    dict set fpll_pins fpll_refclk_port [join [lsort -dictionary [dict get $fpll_pins fpll_refclk_port]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type warning "IP SDC: Could not find ports for fPLL refclk"
    }
  }

  # ------------------------------------------------------------------------- #
  if {[llength $fpll_c0_div_reg_list] > 0} {
    foreach fpll_c0_div_reg $fpll_c0_div_reg_list {
       dict lappend fpll_pins fpll_c0_div_reg $fpll_c0_div_reg
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting fpll_c0_div.reg info: [dict get $fpll_pins fpll_c0_div_reg]"
    }

    dict set fpll_pins fpll_c0_div_reg [join [lsort -dictionary [dict get $fpll_pins fpll_c0_div_reg]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type warning "IP SDC: Could not find ports for ~FPLL_C0_DIV.REG"
    }
  }

  # ------------------------------------------------------------------------- #
  set clkdiv_inclk_id [get_pins -compatibility_mode -nowarn $clkdiv_inclk_pin]

  if {[get_collection_size $clkdiv_inclk_id] > 0} {
    foreach_in_collection clk $clkdiv_inclk_id {
      dict lappend fpll_pins clkdiv_inclk [get_pin_info -name $clk]
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting CLKDIV_INCLK node info: [dict get $fpll_pins clkdiv_inclk]"
    }

    dict set fpll_pins clkdiv_inclk [join [lsort -dictionary [dict get $fpll_pins clkdiv_inclk]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type warning "IP SDC: Could not find pins for CLKDIV_INCLK"
    }
  }

  # ------------------------------------------------------------------------- #
  set clkdiv_output_div1_id [get_pins -compatibility_mode -nowarn $clkdiv_output_div1_pin]

  if {[get_collection_size $clkdiv_output_div1_id] > 0} {
    foreach_in_collection clk $clkdiv_output_div1_id {
      dict lappend fpll_pins clkdiv_output_div1 [get_pin_info -name $clk]
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting CLOCK_DIV1 node info: [dict get $fpll_pins clkdiv_output_div1]"
    }

    dict set fpll_pins clkdiv_output_div1 [join [lsort -dictionary [dict get $fpll_pins clkdiv_output_div1]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type warning "IP SDC: Could not find pins for CLOCK_DIV1"
    }
  }

  # ------------------------------------------------------------------------- #
  set clkdiv_output_div2_id [get_pins -compatibility_mode -nowarn $clkdiv_output_div2_pin]

  if {[get_collection_size $clkdiv_output_div2_id] > 0} {
    foreach_in_collection clk $clkdiv_output_div2_id {
      dict lappend fpll_pins clkdiv_output_div2 [get_pin_info -name $clk]
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting CLOCK_DIV2 node info: [dict get $fpll_pins clkdiv_output_div2]"
    }

    dict set fpll_pins clkdiv_output_div2 [join [lsort -dictionary [dict get $fpll_pins clkdiv_output_div2]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for CLOCK_DIV2"
    }
  }

  # ------------------------------------------------------------------------- #
  set clkdiv_output_div4_id [get_pins -compatibility_mode -nowarn $clkdiv_output_div4_pin]

  if {[get_collection_size $clkdiv_output_div4_id] > 0} {
    foreach_in_collection clk $clkdiv_output_div4_id {
      dict lappend fpll_pins clkdiv_output_div4 [get_pin_info -name $clk]
    }

    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: After getting CLOCK_DIV4 node info: [dict get $fpll_pins clkdiv_output_div4]"
    }

    dict set fpll_pins clkdiv_output_div4 [join [lsort -dictionary [dict get $fpll_pins clkdiv_output_div4]]]

  } else {
    if {$fpll_sdc_debug == 1} {
      post_message -type info "IP SDC: Could not find pins for CLOCK_DIV4"
    }
  }

}


# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to find the port name of the refclk feeding fPLL         --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc fpll_get_fpll_counter_div_reg_node_jh5viiy { } {
  global ::fpll_sdc_debug

  set fpll_c0_div_reg_list [list]

  set fpll_int_pllcout_col [get_pins -nowarn -compat cmu_fpll_pld_adapt_inst|int_pllcout*]

  if {[get_collection_size $fpll_int_pllcout_col] > 0} {
    set fanin_col [get_fanins -clock -stop_at_clocks $fpll_int_pllcout_col]

    if {[get_collection_size $fanin_col] > 0} {
      foreach_in_collection fanin_pin $fanin_col {
        lappend fpll_c0_div_reg_list [get_node_info -name $fanin_pin]
      }
    } else {
      post_message -type warning "IP SDC: Could not find any fanins for ~fpll_int_pllcout"
    }

  } else {
    post_message -type warning "IP SDC: Could not find pins for *cmu_fpll_pld_adapt_inst|int_pllcout*"
  }

  return $fpll_c0_div_reg_list

}


# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to find the port name of the refclk feeding fPLL         --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc fpll_get_refclk_port_jh5viiy { instance fpll_c0_div_reg_list } {
  global ::fpll_sdc_debug

  set fpll_refclk_port_list [list]

  if {[llength $fpll_c0_div_reg_list] > 0} {

    set no_inst_fpll_c0_div_reg_list [list]
    foreach fpll_c0_div_reg $fpll_c0_div_reg_list {
      # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY
      lappend no_inst_fpll_c0_div_reg_list [string replace $fpll_c0_div_reg 0 [string length $instance]]
    }

    # Grab all the fanins to the fpll_c?_div.reg nodes
    set fanin_col [get_fanins -clock -stop_at_clocks $no_inst_fpll_c0_div_reg_list]

    # Take only the fanins that are ports (should only be one)
    if {[get_collection_size $fanin_col] > 0} {
      foreach_in_collection fanin_port $fanin_col {
        if {[get_node_info -type $fanin_port] == "port"} {
          lappend fpll_refclk_port_list [get_node_info -name $fanin_port]
        } else {
          if {$fpll_sdc_debug == 1} {
            post_message -type warning "IP SDC: Fanin $fanin_port feeding ~fpll_c0_div.reg is NOT a port"
          }
        }
      }
    } else {
      post_message -type warning "IP SDC: Could not find any fanins for ~fpll_c0_div.reg"
    }

  } else {
    post_message -type warning "IP SDC: Could not find register for ~fpll_c0_div.reg"
  }

  return $fpll_refclk_port_list

}


# -------------------------------------------------------------------------------- #
# ---                                                                          --- #
# --- Procedure to call procedure to create clocks all channels in an instance --- #
# ---                                                                          --- #
# -------------------------------------------------------------------------------- #
proc fpll_prepare_to_create_clocks_jh5viiy { instance mode mode_clks profile_cnt profile alt_xcvr_fpll_s10_pins multiply_factor_dict divide_factor_dict all_profile_clocks_names } {
  global ::fpll_sdc_debug

  set list_of_clk_names [list]

  foreach clk_group $mode_clks { # Each mode can have multiple clocks; iterate over them
    if { $fpll_sdc_debug } {
      post_message -type info "IP SDC: Clock group in mode_clks is: $clk_group"
    }

    if { $mode == "refclk" } {
      # Append the clock name of the reference clock to list of clock names
      lappend list_of_clk_names $clk_group

    } else {
      if { [dict exists $alt_xcvr_fpll_s10_pins $instance $clk_group] } {

        set clk_pins [dict get $alt_xcvr_fpll_s10_pins $instance $clk_group]

        if { $fpll_sdc_debug } {
          post_message -type info "IP SDC: Pins for $clk_group: $clk_pins"
        }

        if { [llength $clk_pins] > 0 } { # Check to see if the corresponding pins exists 
          set channel_number 0

          # Remap any backward slashes '' in the pins
          set clk_pins [string map {\\ \\\\} $clk_pins] 

          set source_node ""
          set master_clock ""
          set multiply_factor [dict get $multiply_factor_dict $clk_group]
          set divide_factor   [dict get $divide_factor_dict   $clk_group]

          if { $clk_group == "fpll_c0_div_reg" } {
            set source_node  [dict get $alt_xcvr_fpll_s10_pins $instance fpll_refclk_port]

          } elseif { $clk_group == "clkdiv_inclk" } {
            set source_node  [dict get $alt_xcvr_fpll_s10_pins $instance fpll_c0_div_reg]
            set master_clock [dict get $all_profile_clocks_names $profile fpll_c0_div_reg]

          } elseif { $clk_group == "clkdiv_output_div1" } {
            set source_node  [dict get $alt_xcvr_fpll_s10_pins $instance clkdiv_inclk]
            set master_clock [dict get $all_profile_clocks_names $profile inclk]

          } elseif { $clk_group == "clkdiv_output_div2" } {
            set source_node  [dict get $alt_xcvr_fpll_s10_pins $instance clkdiv_inclk]
            set master_clock [dict get $all_profile_clocks_names $profile inclk]

          } elseif { $clk_group == "clkdiv_output_div4" } {
            set source_node  [dict get $alt_xcvr_fpll_s10_pins $instance clkdiv_inclk]
            set master_clock [dict get $all_profile_clocks_names $profile inclk]

          } else {
            post_message -type warning "IP SDC Warning: Clock group $clk_group key in group $mode did not match any expected clocks groups ..."
          }

          # Flatten source_node and master_clock from lists to strings
          set source_node  [string map {\\ \\\\} $source_node] 
          set source_node  [join $source_node]
          set master_clock [string map {\\ \\\\} $master_clock] 
          set master_clock [join $master_clock]

          # Remove the instance name from the clock source node due to auto promotion in SDC_ENTITY for INCLK and output clocks
          if { $clk_group != "fpll_c0_div_reg" } {
            set source_node [string replace $source_node 0 [string length $instance]]
          }

          # Create clks for all channels for a clk group in mode clk
          lappend list_of_clk_names [fpll_create_clocks_jh5viiy $instance $clk_group $clk_pins $profile_cnt $profile $source_node $master_clock $multiply_factor $divide_factor]
        }
      } else {
        if {$fpll_sdc_debug == 1} {
          post_message -type warning "IP SDC Warning: $clk_group key does not exist in pins dictionary"
        }
      }
    }; # if mode == "refclk"
  } ; # foreach clk_group in mode_clks

  return $list_of_clk_names

}


# -------------------------------------------------------------------------- #
# ---                                                                    --- #
# --- Procedure to create clocks in an instance                          --- #
# ---                                                                    --- #
# -------------------------------------------------------------------------- #
proc fpll_create_clocks_jh5viiy { instance clk_group clk_list profile_cnt profile source_node master_clock multiply_factor divide_factor } {
  global ::fpll_sdc_debug

  set clock_name_list [list]

  # Remove the 'xcvr_fpll_s10_0' from each full instance name
  set full_instance_split [ split $instance | ]  
  set full_instance_split [lreplace $full_instance_split end end]
  set short_inst_name [join $full_instance_split "|"]

  foreach clk_node $clk_list {

    # Remove the instance name from the clock node due to auto promotion in SDC_ENTITY
    set no_inst_clk_node [string replace $clk_node 0 [string length $instance]]

    # Shorten the clock name if multiple profiles are not used
    if { $profile_cnt > 1 } { 
      set clock_name ${short_inst_name}|profile$profile|$clk_group
    } else {
      set clock_name ${short_inst_name}|$clk_group      
    }
    # Add the clock name to the list 
    lappend clock_name_list $clock_name

    # Check if clock with same name already exists, if so skip clock creation
    set matching_clocks [get_clocks -nowarn $clock_name]
    if {[get_collection_size $matching_clocks] > 0} {
      if { $fpll_sdc_debug == 1 } {
        foreach_in_collection clk $matching_clocks {
          post_message -type warning "Clock already exists with name $clock_name with period [get_clock_info $clock_name -period]ns on node [get_object_info -name [get_clock_info $clock_name -targets]]"
        }
      }
    # Create clock if no clock exists already with same name
    } else {

      if { $fpll_sdc_debug == 1 } {
        post_message -type info "IP SDC: Clock name = $clock_name"
      }

      # Create the clock constraint
      if {$master_clock == ""} {
        create_generated_clock \
          -name $clock_name \
          -source $source_node \
          -multiply_by $multiply_factor \
          -divide_by   $divide_factor \
          $no_inst_clk_node -add
      } else {
        create_generated_clock \
          -name $clock_name \
          -source $source_node \
          -master_clock $master_clock \
          -multiply_by $multiply_factor \
          -divide_by   $divide_factor \
          $no_inst_clk_node -add
      }
    }
  }
  # Return the list of clock names  
  return $clock_name_list

}


