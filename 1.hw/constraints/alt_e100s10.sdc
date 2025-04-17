# (C) 2001-2018 Intel Corporation. All rights reserved.
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


set added_uncertainty_312mhz 0.48ns
set added_uncertainty_390mhz 0.424ns


set TRS_DIVIDED_OSC_CLK [get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk]
set CLK100 [get_clocks u0|alt_e100s10_sys_pll_inst_outclk0]
create_clock -name {altera_reserved_tck} -period 40 [get_ports {altera_reserved_tck}]

set ethA_RX_CORE_CLK [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_clkout2|ch1]
set ethA_TX_CORE_CLK [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_clkout2|ch1]

set ethB_RX_CORE_CLK [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_clkout2|ch1]
set ethB_TX_CORE_CLK [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_clkout2|ch1]

set ethC_RX_CORE_CLK [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_clkout2|ch1]
set ethC_TX_CORE_CLK [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_clkout2|ch1]

set ethD_RX_CORE_CLK [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_clkout2|ch1]
set ethD_TX_CORE_CLK [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_clkout2|ch1]

set_clock_groups -exclusive -group $ethA_TX_CORE_CLK -group $ethA_RX_CORE_CLK -group $TRS_DIVIDED_OSC_CLK -group $CLK100 -group ethA_clk_ref_r

set_clock_groups -exclusive -group $ethB_TX_CORE_CLK -group $ethB_RX_CORE_CLK -group $TRS_DIVIDED_OSC_CLK -group $CLK100 -group ethB_clk_ref_r

set_clock_groups -exclusive -group $ethC_TX_CORE_CLK -group $ethC_RX_CORE_CLK -group $TRS_DIVIDED_OSC_CLK -group $CLK100 -group ethC_clk_ref_r

set_clock_groups -exclusive -group $ethD_TX_CORE_CLK -group $ethD_RX_CORE_CLK -group $TRS_DIVIDED_OSC_CLK -group $CLK100 -group ethD_clk_ref_r


#set_false_path -from [get_keepers {cpu_resetn}]
set_false_path -from [get_keepers {CPU_RESET_n}]
#set_clock_groups -exclusive -group clk50 -group  clk_ref_r
#set_false_path -to   [get_ports {user_led[*]}]
set_false_path -to   [get_ports {LED[*]}]


set LPMODE  [get_keepers qsfp_lowpwr]
set RESETL  [get_keepers qsfp_rstn]
#set LPMODE  [get_keepers QSFP28A_LP_MODE]
#set RESETL  [get_keepers QSFP28A_RST_n]
#set LPMODE  [get_keepers QSFP28B_LP_MODE]
#set RESETL  [get_keepers QSFP28B_RST_n]
#set LPMODE  [get_keepers QSFP28C_LP_MODE]
#set RESETL  [get_keepers QSFP28C_RST_n]
#set LPMODE  [get_keepers QSFP28D_LP_MODE]
#set RESETL  [get_keepers QSFP28D_RST_n]


set_false_path -to   $LPMODE
set_false_path -to   $RESETL

# From Timequest cookbook
set_clock_groups -exclusive -group [get_clocks altera_reserved_tck]

# From "AV SoC Golden Hardware Reference Design"
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

# set false path from PMA fifo flags' clock to clk_status (ex_100g_inst|ex_100g_inst|alt_s100|csr|eio_flags_csr[*])
if {0} {	
set ethA_RX_CLK0 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
set ethA_RX_CLK1 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
set ethA_RX_CLK2 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
set ethA_RX_CLK3 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
set ethA_TX_CLK0 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
set ethA_TX_CLK1 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
set ethA_TX_CLK2 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
set ethA_TX_CLK3 [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

set ethB_RX_CLK0 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
set ethB_RX_CLK1 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
set ethB_RX_CLK2 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
set ethB_RX_CLK3 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
set ethB_TX_CLK0 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
set ethB_TX_CLK1 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
set ethB_TX_CLK2 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
set ethB_TX_CLK3 [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

set ethC_RX_CLK0 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
set ethC_RX_CLK1 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
set ethC_RX_CLK2 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
set ethC_RX_CLK3 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
set ethC_TX_CLK0 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
set ethC_TX_CLK1 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
set ethC_TX_CLK2 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
set ethC_TX_CLK3 [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

set ethD_RX_CLK0 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
set ethD_RX_CLK1 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
set ethD_RX_CLK2 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
set ethD_RX_CLK3 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
set ethD_TX_CLK0 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
set ethD_TX_CLK1 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
set ethD_TX_CLK2 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
set ethD_TX_CLK3 [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

set_clock_groups -exclusive -group $ethA_RX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethA_RX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethA_RX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethA_RX_CLK3 -group $CLK100
set_clock_groups -exclusive -group $ethA_TX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethA_TX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethA_TX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethA_TX_CLK3 -group $CLK100

set_clock_groups -exclusive -group $ethB_RX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethB_RX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethB_RX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethB_RX_CLK3 -group $CLK100
set_clock_groups -exclusive -group $ethB_TX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethB_TX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethB_TX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethB_TX_CLK3 -group $CLK100

set_clock_groups -exclusive -group $ethC_RX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethC_RX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethC_RX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethC_RX_CLK3 -group $CLK100
set_clock_groups -exclusive -group $ethC_TX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethC_TX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethC_TX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethC_TX_CLK3 -group $CLK100

set_clock_groups -exclusive -group $ethD_RX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethD_RX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethD_RX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethD_RX_CLK3 -group $CLK100
set_clock_groups -exclusive -group $ethD_TX_CLK0 -group $CLK100
set_clock_groups -exclusive -group $ethD_TX_CLK1 -group $CLK100
set_clock_groups -exclusive -group $ethD_TX_CLK2 -group $CLK100
set_clock_groups -exclusive -group $ethD_TX_CLK3 -group $CLK100
}

for {set chNum 0} {$chNum < 4} {incr chNum} {
  set ethA_RX_CLK [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch$chNum] 
  set ethA_TX_CLK [get_clocks ethA|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch$chNum]
  
  set ethB_RX_CLK [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch$chNum] 
  set ethB_TX_CLK [get_clocks ethB|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch$chNum]
  
  set ethC_RX_CLK [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch$chNum] 
  set ethC_TX_CLK [get_clocks ethC|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch$chNum]
  
  set ethD_RX_CLK [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|rx_pcs_x2_clk|ch$chNum] 
  set ethD_TX_CLK [get_clocks ethD|ex_100g_inst|ex_100g_inst|xcvr|tx_pcs_x2_clk|ch$chNum]

  set_clock_groups -exclusive -group $ethA_TX_CLK -group $CLK100
  set_clock_groups -exclusive -group $ethA_RX_CLK -group $CLK100

  set_clock_groups -exclusive -group $ethB_TX_CLK -group $CLK100
  set_clock_groups -exclusive -group $ethB_RX_CLK -group $CLK100

  set_clock_groups -exclusive -group $ethC_TX_CLK -group $CLK100
  set_clock_groups -exclusive -group $ethC_RX_CLK -group $CLK100

  set_clock_groups -exclusive -group $ethD_TX_CLK -group $CLK100
  set_clock_groups -exclusive -group $ethD_RX_CLK -group $CLK100  
}


set_clock_groups -exclusive -group $ethA_RX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]
set_clock_groups -exclusive -group $ethA_TX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]

set_clock_groups -exclusive -group $ethB_RX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]
set_clock_groups -exclusive -group $ethB_TX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]

set_clock_groups -exclusive -group $ethC_RX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]
set_clock_groups -exclusive -group $ethC_TX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]

set_clock_groups -exclusive -group $ethD_RX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]
set_clock_groups -exclusive -group $ethD_TX_CORE_CLK -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]

set_clock_groups -exclusive -group $ethA_RX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]
set_clock_groups -exclusive -group $ethA_TX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]

set_clock_groups -exclusive -group $ethB_RX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]
set_clock_groups -exclusive -group $ethB_TX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]

set_clock_groups -exclusive -group $ethC_RX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]
set_clock_groups -exclusive -group $ethC_TX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]

set_clock_groups -exclusive -group $ethD_RX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]
set_clock_groups -exclusive -group $ethD_TX_CORE_CLK -group [get_clocks "u0|alt_e100s10_sys_pll_inst_refclk"]

set_clock_groups -exclusive -group $CLK100      -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}]
set_clock_groups -exclusive -group [get_clocks {u0|alt_e100s10_sys_pll_inst_refclk}] -group $CLK100
