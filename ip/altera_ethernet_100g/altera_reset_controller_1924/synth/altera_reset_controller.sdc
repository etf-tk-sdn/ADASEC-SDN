# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License Subscription 
# Agreement, Altera IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# +---------------------------------------------------
# | Cut the async clear paths
# +---------------------------------------------------
set aclr_counter 0
set clrn_counter 0
if { [expr ![info exists show_hpath_of_all_reset_controller_inst]] } {
   set show_hpath_of_all_reset_controller_inst 0
}
if {[get_current_instance] == ""} {set hpath ""} else {set hpath "[get_current_instance]|*"}
if {$show_hpath_of_all_reset_controller_inst == 1} { 
    post_message -type info "Following instance found in the design -  $hpath"
} 
set aclr_collection [get_pins -compatibility_mode -nocase -nowarn ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|aclr]
set clrn_collection [get_pins -compatibility_mode -nocase -nowarn ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn]
set num_sync_stage [get_registers -nocase -nowarn ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[*]]
set num_sync_count [get_collection_size $num_sync_stage]   
set aclr_counter [get_collection_size $aclr_collection]
set clrn_counter [get_collection_size $clrn_collection]

if {$aclr_counter == 0 &&  $clrn_counter == 0 && $num_sync_count > 0} {
    set_max_delay  -to [get_registers ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[[expr $num_sync_count-1]]] 100
    set_min_delay  -to [get_registers ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain[[expr $num_sync_count-1]]] -100
}

if {$aclr_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|aclr]
}

if {$clrn_counter > 0} {
    set_false_path -to [get_pins -compatibility_mode -nocase ${hpath}alt_rst_sync_uq1|altera_reset_synchronizer_int_chain*|clrn]
}
