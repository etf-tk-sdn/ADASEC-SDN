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


#Create base clock with 100 MHz targetted for internal clocks if paths listed below found in the design

#Stratix 10
#s10_user_rst_clkgate_0|s10_user_rst_clkgate_0|lsm_gpo_out_user_reset~internal_clock.reg
#s10_user_rst_clkgate_0|s10_user_rst_clkgate_0|lsm_gpo_out_user_reset~internal_clock.reg__nff

#set intrl_clk_reg_count 0

set intrl_clk_reg_collection [get_registers -nowarn "*\|*lsm_gpo_out_user_reset~internal_clock.*"]

set intrl_clk_reg_count [ get_collection_size $intrl_clk_reg_collection ]

set intrl_clock_count 0

post_message -type info "current_instance = [get_current_instance]"

if {$intrl_clk_reg_count > 0 && ![get_collection_size [get_clocks -nowarn {internal_clk}]]} {

	create_clock -name {internal_clk} -period 10.000 -waveform {0.000 5.000} [get_keepers {*|*lsm_gpo_out_user_reset~internal_clock.*}]

	set_clock_groups -asynchronous -group [get_clocks {internal_clk}]

	set intrl_clock_count [get_collection_size [get_clocks internal_clk]]
	
}


