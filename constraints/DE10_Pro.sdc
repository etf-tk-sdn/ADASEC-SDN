# Timing exceptions
set added_uncertainty_312mhz 0.48ns
set added_uncertainty_390mhz 0.424ns

set trs_divided_osc_clk [get_clocks ALTERA_INSERTED_INTOSC_FOR_TRS|divided_osc_clk]
set clk_100 [get_clocks u_system_pll|altera_system_pll_inst_outclk0]
set clk_300 [get_clocks u_system_pll|altera_system_pll_inst_outclk1]

set eth_1_rx_core_clk [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_clkout2|ch1]
set eth_1_tx_core_clk [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_clkout2|ch1]

set eth_2_rx_core_clk [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_clkout2|ch1]
set eth_2_tx_core_clk [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_clkout2|ch1]

set eth_3_rx_core_clk [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_clkout2|ch1]
set eth_3_tx_core_clk [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_clkout2|ch1]

set eth_4_rx_core_clk [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_clkout2|ch1]
set eth_4_tx_core_clk [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_clkout2|ch1]

# The central 300 MHz domain crosses the 100G MAC core domains through
# asynchronous FIFOs. Cut timing between the unrelated clock domains without
# cutting timing between the related 100 MHz and 300 MHz system PLL outputs.
set_clock_groups -asynchronous -group $clk_300 -group $eth_1_rx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_1_tx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_2_rx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_2_tx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_3_rx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_3_tx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_4_rx_core_clk
set_clock_groups -asynchronous -group $clk_300 -group $eth_4_tx_core_clk

set_clock_groups -exclusive -group $eth_1_tx_core_clk -group $eth_1_rx_core_clk -group $trs_divided_osc_clk -group $clk_100 -group eth_1_clk_ref_r
set_clock_groups -exclusive -group $eth_2_tx_core_clk -group $eth_2_rx_core_clk -group $trs_divided_osc_clk -group $clk_100 -group eth_2_clk_ref_r
set_clock_groups -exclusive -group $eth_3_tx_core_clk -group $eth_3_rx_core_clk -group $trs_divided_osc_clk -group $clk_100 -group eth_3_clk_ref_r
set_clock_groups -exclusive -group $eth_4_tx_core_clk -group $eth_4_rx_core_clk -group $trs_divided_osc_clk -group $clk_100 -group eth_4_clk_ref_r

set_clock_groups -exclusive -group [get_clocks altera_reserved_tck]

set_false_path -from [get_keepers {CPU_RESET_n}]
set_false_path -from [get_ports {SW[*]}]
set_false_path -from [get_ports {BUTTON[*]}]
set_false_path -to [get_ports {LED[*]}]

# set false path from PMA fifo flags' clock to clk_status (altera_ethernet_100g_inst|altera_ethernet_100g_inst|alt_s100|csr|eio_flags_csr[*])
if {0} {
    set eth_1_rx_clk_0 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
    set eth_1_rx_clk_1 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
    set eth_1_rx_clk_2 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
    set eth_1_rx_clk_3 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
    set eth_1_tx_clk_0 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
    set eth_1_tx_clk_1 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
    set eth_1_tx_clk_2 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
    set eth_1_tx_clk_3 [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

    set eth_2_rx_clk_0 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
    set eth_2_rx_clk_1 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
    set eth_2_rx_clk_2 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
    set eth_2_rx_clk_3 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
    set eth_2_tx_clk_0 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
    set eth_2_tx_clk_1 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
    set eth_2_tx_clk_2 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
    set eth_2_tx_clk_3 [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

    set eth_3_rx_clk_0 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
    set eth_3_rx_clk_1 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
    set eth_3_rx_clk_2 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
    set eth_3_rx_clk_3 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
    set eth_3_tx_clk_0 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
    set eth_3_tx_clk_1 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
    set eth_3_tx_clk_2 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
    set eth_3_tx_clk_3 [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

    set eth_4_rx_clk_0 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch0]
    set eth_4_rx_clk_1 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch1]
    set eth_4_rx_clk_2 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch2]
    set eth_4_rx_clk_3 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch3]
    set eth_4_tx_clk_0 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch0]
    set eth_4_tx_clk_1 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch1]
    set eth_4_tx_clk_2 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch2]
    set eth_4_tx_clk_3 [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch3]

    set_clock_groups -exclusive -group $eth_1_rx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_rx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_rx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_rx_clk_3 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_tx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_tx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_tx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_1_tx_clk_3 -group $clk_100

    set_clock_groups -exclusive -group $eth_2_rx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_rx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_rx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_rx_clk_3 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_tx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_tx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_tx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_2_tx_clk_3 -group $clk_100

    set_clock_groups -exclusive -group $eth_3_rx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_rx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_rx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_rx_clk_3 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_tx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_tx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_tx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_3_tx_clk_3 -group $clk_100

    set_clock_groups -exclusive -group $eth_4_rx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_rx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_rx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_rx_clk_3 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_tx_clk_0 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_tx_clk_1 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_tx_clk_2 -group $clk_100
    set_clock_groups -exclusive -group $eth_4_tx_clk_3 -group $clk_100
}

for {set ch_num 0} {$ch_num < 4} {incr ch_num} {
    set eth_1_rx_clk [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch$ch_num]
    set eth_1_tx_clk [get_clocks u_eth_1|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch$ch_num]

    set eth_2_rx_clk [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch$ch_num]
    set eth_2_tx_clk [get_clocks u_eth_2|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch$ch_num]

    set eth_3_rx_clk [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch$ch_num]
    set eth_3_tx_clk [get_clocks u_eth_3|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch$ch_num]

    set eth_4_rx_clk [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|rx_pcs_x2_clk|ch$ch_num]
    set eth_4_tx_clk [get_clocks u_eth_4|u_altera_ethernet_100g|altera_ethernet_100g_inst|xcvr|tx_pcs_x2_clk|ch$ch_num]

    set_clock_groups -exclusive -group $eth_1_tx_clk -group $clk_100
    set_clock_groups -exclusive -group $eth_1_rx_clk -group $clk_100

    set_clock_groups -exclusive -group $eth_2_tx_clk -group $clk_100
    set_clock_groups -exclusive -group $eth_2_rx_clk -group $clk_100

    set_clock_groups -exclusive -group $eth_3_tx_clk -group $clk_100
    set_clock_groups -exclusive -group $eth_3_rx_clk -group $clk_100

    set_clock_groups -exclusive -group $eth_4_tx_clk -group $clk_100
    set_clock_groups -exclusive -group $eth_4_rx_clk -group $clk_100
}

set_clock_groups -exclusive -group $eth_1_rx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]
set_clock_groups -exclusive -group $eth_1_tx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]

set_clock_groups -exclusive -group $eth_2_rx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]
set_clock_groups -exclusive -group $eth_2_tx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]

set_clock_groups -exclusive -group $eth_3_rx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]
set_clock_groups -exclusive -group $eth_3_tx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]

set_clock_groups -exclusive -group $eth_4_rx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]
set_clock_groups -exclusive -group $eth_4_tx_core_clk -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]

set_clock_groups -exclusive -group $eth_1_rx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]
set_clock_groups -exclusive -group $eth_1_tx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]

set_clock_groups -exclusive -group $eth_2_rx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]
set_clock_groups -exclusive -group $eth_2_tx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]

set_clock_groups -exclusive -group $eth_3_rx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]
set_clock_groups -exclusive -group $eth_3_tx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]

set_clock_groups -exclusive -group $eth_4_rx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]
set_clock_groups -exclusive -group $eth_4_tx_core_clk -group [get_clocks "u_system_pll|altera_system_pll_inst_refclk"]

set_clock_groups -exclusive -group $clk_100 -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}]
set_clock_groups -exclusive -group [get_clocks {u_system_pll|altera_system_pll_inst_refclk}] -group $clk_100
