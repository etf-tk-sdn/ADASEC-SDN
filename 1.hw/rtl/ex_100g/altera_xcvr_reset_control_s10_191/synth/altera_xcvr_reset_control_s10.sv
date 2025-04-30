// (C) 2001-2019 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// File Name: altera_xcvr_reset_control_s10.sv
//
// Description:
//
//    A configurable reset controller for Stratix 10  intended to drive resets for HSSI transceiver PLLs and CHANNELS, 
//  and the AIB adapter blocks. The reset controller makes use of individual reset counters to control reset timing for 
//  the various reset outputs. This module serves to replace the existing reset controller design and will 
//  be used in Stratix 10 devices.
//	
//  ***NOTE*** Manual mode is NO longer available in S10 reset controller
//             Automatic mode is the only mode available meaning:
//                    - For TX, tx_digitalreset can automatically be restarted on loss of pll_locked
//                    - For RX, rx_digitalreset can automatically be restarted on loss of rx_is_lockedtodata
//
//     Features:
//      - Optional TX,RX,PLL reset control.
//      - Reset for AIB adapter blocks in S10 design (through the digital resets, i.e. PCS and AIB share reset signal)
//      - Synchronization of the reset input
//      - Optional hysteresis for the pll_locked status inputs
//      - Reset control per channel or shared. (E.g. separate rx_digitalreset control for each channel
//        or one control for all channels)
//      - Configurable reset timings
//        (For TX, tx_digitalreset can automatically be restarted on loss of pll_locked)
//        (For RX, rx_digitalreset can automatically be restarted on loss of rx_is_lockedtodata)
//	- Digital reset request override (tx_digitalreset_or and rx_digitalreset_or)
//	- Faster reset time for simulation

`timescale 1ns / 1ns

// Parameter for clogb2 function
`define MAX_PRECISION 32	// VCS requires this declaration outside the function

module  altera_xcvr_reset_control_s10
#(
    // General Options
    parameter CHANNELS           = 1,    // Number of CHANNELS
    parameter PLLS               = 1,    // Number of TX PLLs. For pll_powerdown and pll_locked
    parameter SYS_CLK_IN_MHZ     = 250,  // Clock frequency in MHz. Required for reset timers
    parameter REDUCED_SIM_TIME   = 1,    // (0,1) 1=Reduced reset timings for simulation
    parameter ENABLE_DIGITAL_SEQ = 0,    // (0,1) 0=TX and RX digital resets are independent of each other
                                         //       1=Enable sequencing of TX and RX digital resets (TX gates RX)

    // PLL options
    parameter TX_PLL_ENABLE     = 0,    // (0,1) Enable TX PLL reset
    parameter T_PLL_POWERDOWN   = 1000, // pll_powerdown period in ns
                                        // !NOTE! Will prevent PLL merging across reset controllers
    // TX options
    parameter TX_ENABLE         = 0,    // (0,1) Enable TX resets
    parameter TX_PER_CHANNEL    = 0,    // (0,1) 1=separate TX reset per channel
    parameter T_TX_ANALOGRESET  = 0,    // tx_analogreset period (after reset removal)
    parameter T_TX_DIGITALRESET = 20,   // tx_digitalreset period
    parameter T_PLL_LOCK_HYST   = 0,    // Amount of hysteresis to add to pll_locked status signal
    parameter TX_MANUAL_RESET   = 0,    // (0,1) Enable manual mode for TX reset
                                        // 0 = Automatically restart tx_digitalreset when pll_locked deasserts.
                                        // 1 = Do nothing when pll_locked deasserts

    // RX options
    parameter RX_ENABLE         = 0,    // (0,1) Enable RX resets
    parameter RX_PER_CHANNEL    = 0,    // (0,1) 1=separate RX reset per channel
    parameter T_RX_ANALOGRESET  = 40,   // rx_analogreset period
    parameter T_RX_DIGITALRESET = 5000, // rx_digitalreset period 
    parameter RX_MANUAL_RESET   = 0,    // (0,1) Enable manual mode for RX reset
                                        // 0 = Automatically restart rx_digitalreset when rx_is_lockedtodata deasserts
                                        // 1 = Do nothing when rx_is_lockedtodata deasserts

    // CAL BUSY option
    parameter EN_PLL_CAL_BUSY = 0       // Enable PLL cal busy and expose port
) (
  // User inputs and outputs
  input   wire    clock,  // System clock
  input   wire    reset,  // Asynchronous reset

  // Reset signals
  output  wire  [PLLS-1:0]      pll_powerdown,      // reset TX PLL (to PHY/PLL)
  output  wire  [CHANNELS-1:0]  tx_analogreset,     // reset TX PMA (to PHY)
  output  wire  [CHANNELS-1:0]  tx_digitalreset,    // reset TX PCS (to PHY)
  output  wire  [CHANNELS-1:0]  rx_analogreset,     // reset RX PMA (to PHY)
  output  wire  [CHANNELS-1:0]  rx_digitalreset,    // reset RX PCS (to PHY)

  // Status input
  input   wire  [CHANNELS-1:0]  tx_analogreset_stat,  // TX PMA reset status (from PHY)
  input   wire  [CHANNELS-1:0]  tx_digitalreset_stat, // TX AIB and PCS reset status (from PHY)
  input   wire  [CHANNELS-1:0]  rx_analogreset_stat,  // RX PMA reset status (from PHY)
  input   wire  [CHANNELS-1:0]  rx_digitalreset_stat, // RX AIB and PCS reset status (from PHY)

  // Status output
  output  wire  [CHANNELS-1:0]  tx_ready,           // TX is not in reset
  output  wire  [CHANNELS-1:0]  rx_ready,           // RX is not in reset

  // Digital reset override inputs (must by synchronous with clock)
  input   wire  [CHANNELS-1:0]  tx_digitalreset_or, // reset request for tx_digitalreset
  input   wire  [CHANNELS-1:0]  rx_digitalreset_or, // reset request for rx_digitalreset

  // TX control inputs
  input   wire  [PLLS-1:0]      pll_locked,         // TX PLL lock status (from PHY/PLL)
  input   wire  [(pll_select_width(PLLS,TX_PER_CHANNEL,CHANNELS))-1:0] pll_select, // Select TX PLL locked signal 
  input   wire  [CHANNELS-1:0]  tx_cal_busy,        // TX channel calibration status (from PHY/Reconfig)
  input   wire  [PLLS-1:0]      pll_cal_busy,       // TX PLL calibration status (from PLL)

  // RX control inputs
  input   wire  [CHANNELS-1:0]  rx_is_lockedtodata, // RX CDR PLL locked-to-data status (from PHY)
  input   wire  [CHANNELS-1:0]  rx_cal_busy         // RX channel calibration status (from PHY/Reconfig)

);

// Faster reset time for simulation if indicated
localparam  SYNTH_CLK_IN_HZ = SYS_CLK_IN_MHZ * 1000000;
localparam  SIM_CLK_IN_HZ = (REDUCED_SIM_TIME == 1) 
                            ? 2 * 1000000 : SYNTH_CLK_IN_HZ;
`ifdef ALTERA_RESERVED_QIS
  localparam  SYS_CLK_IN_HZ = SYNTH_CLK_IN_HZ;
`else
  localparam  SYS_CLK_IN_HZ = SIM_CLK_IN_HZ;
`endif

// Calculate delays
wire  reset_sync;         // Synchronized reset input
wire  stat_pll_powerdown; // PLL powerdown status

genvar ig;

//**************************************************************************
//************************ Synchronize Reset Input *************************

  alt_xcvr_resync_std #(
      .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
      .WIDTH            (1),  // Number of bits to resync
      .INIT_VALUE       (1'b1)
  ) alt_xcvr_resync_reset (
    .clk    (clock      ),
    .reset  (reset      ),
    .d      (1'b0       ),
    .q      (reset_sync )
  );

//************************ Synchronize Reset Input *************************
//**************************************************************************


//***************************************************************************
//*************************** TX PLL Reset Logic ****************************
generate if(TX_PLL_ENABLE) begin: g_pll // NOTE: PLL resets are disconnected in
  wire  lcl_pll_powerdown;              //       S10 (i.e. TX_PLL_ENABLE==0)
  wire  reset_pll;

  assign  pll_powerdown = {PLLS{lcl_pll_powerdown}};
  assign  reset_pll = reset_sync;
  
  // pll_powerdown 
  alt_xcvr_reset_counter_s10 #(
      .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
      .RESET_PER_NS (T_PLL_POWERDOWN  ), // Reset period in ns
      .ACTIVE_LEVEL (0                )
  ) counter_pll_powerdown (
    .clk        (clock              ),
    .async_req  (reset_pll          ),  // asynchronous reset request
    .sync_req   (1'b0               ),  // synchronous reset request
    .reset_or   (1'b0               ),
    .reset      (lcl_pll_powerdown  ),  // synchronous reset out
    .reset_n    (/*unused*/         ),
    .reset_stat (stat_pll_powerdown )
  );

end else begin : g_no_pll
  assign  pll_powerdown = {PLLS{1'b0}};
  assign  stat_pll_powerdown  = 1'b0;
end
endgenerate
//************************* End TX PLL Reset Logic **************************
//***************************************************************************


//***************************************************************************
//***************************** TX Reset Logic ******************************

// Local wire needed for the case where TX digital reset must be deasserted complete before RX digital reset is deasserted
wire [CHANNELS-1:0] tx_digitalreset_stat_assert_sync;   // tx_digitalreset_stat after synchronization (used for assertion)
wire [CHANNELS-1:0] tx_digitalreset_stat_deassert_sync; // tx_digitalreset_stat after synchronization (used for deassertion)
wire [CHANNELS-1:0] stat_tx_digitalreset;

generate if(TX_ENABLE) begin: g_tx
  localparam  PLL_SEL_WIDTH = clogb2((PLLS-1));

  for (ig=0;ig<CHANNELS;ig=ig+1) begin : g_tx
    if(ig == 0 || TX_PER_CHANNEL == 1) begin : g_tx

      wire  lcl_tx_cal_busy;                   // tx_cal_busy for this channel
      wire  lcl_tx_digitalreset_or;            // tx_digitalreset_or for this channel
      wire  lcl_pll_locked;                    // pll_locked[lcl_pll_select]
      wire  lcl_pll_cal_busy;                  // pll_cal_busy[lcl_pll_select]
      wire  lcl_tx_analogreset_stat_assert;    // tx_analogreset_stat for this channel (used for assertion)
      wire  lcl_tx_digitalreset_stat_assert;   // tx_digitalreset_stat for this channel (used for assertion)
      wire  lcl_tx_analogreset_stat_deassert;  // tx_analogreset_stat for this channel (used for deassertion)
      wire  lcl_tx_digitalreset_stat_deassert; // tx_digitalreset_stat for this channel (used for deassertion)
      wire [PLL_SEL_WIDTH-1:0]  lcl_pll_select;

      // Synchronized signals
      wire  tx_cal_busy_sync;                  // tx_cal_busy after synchronization
      wire  pll_cal_busy_sync;                 // pll_cal_busy after synchronization
      wire  pll_locked_sync;                   // pll_locked after synchronization
      wire  pll_locked_hyst;                   // pll_locked after hysteresis
      reg   pll_locked_latch;                  // One shot latched pll_locked
      wire  tx_analogreset_stat_assert_sync;   // tx_analogreset_stat after synchronization (used for assertion)
      wire  tx_analogreset_stat_deassert_sync; // tx_analogreset_stat after synchronization (used for deassertion)
      wire  tx_or_pll_cal_busy_sync;           // output of OR between synchronized tx_cal_busy and pll_cal_busy
      wire  tx_manual;                         // Set manual or auto reset mode for this TX channel

      // Reset status signals
      wire  stat_tx_analogreset;

      // Control signal for this channel. With separate reset control per channel, each channel
      // listens to its own control signal. Otherwise the control signals for all channels are
      // combined for the shared reset control.
      assign  lcl_tx_cal_busy                   = TX_PER_CHANNEL ? tx_cal_busy[ig]          : |tx_cal_busy;
      assign  lcl_tx_digitalreset_or            = TX_PER_CHANNEL ? tx_digitalreset_or [ig]  : |tx_digitalreset_or;
      assign  lcl_pll_locked                    = pll_locked[lcl_pll_select];	
      assign  lcl_tx_analogreset_stat_assert    = TX_PER_CHANNEL ? tx_analogreset_stat[ig]  : &tx_analogreset_stat;
      assign  lcl_tx_digitalreset_stat_assert   = TX_PER_CHANNEL ? tx_digitalreset_stat[ig] : &tx_digitalreset_stat;
      assign  lcl_tx_analogreset_stat_deassert  = TX_PER_CHANNEL ? tx_analogreset_stat[ig]  : |tx_analogreset_stat;
      assign  lcl_tx_digitalreset_stat_deassert = TX_PER_CHANNEL ? tx_digitalreset_stat[ig] : |tx_digitalreset_stat;

      assign  tx_or_pll_cal_busy_sync  = tx_cal_busy_sync | pll_cal_busy_sync;
      assign  tx_manual                = TX_MANUAL_RESET ? 1'b0 : ~pll_locked_hyst;

      if(EN_PLL_CAL_BUSY==1) begin : cal_busy
          assign  lcl_pll_cal_busy  = pll_cal_busy[lcl_pll_select];
      end else begin : no_cal_busy
          assign  lcl_pll_cal_busy  = 1'b0;
      end

      assign  lcl_pll_select            = TX_PER_CHANNEL ? pll_select[ig*PLL_SEL_WIDTH+:PLL_SEL_WIDTH]
                                                     : (PLLS > 1)   ? pll_select
                                                     : 1'b0;

      // Synchonize TX inputs
      alt_xcvr_resync_std #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH      (7),
          .INIT_VALUE (0)
      ) resync_tx_cal_busy (
        .clk    (clock            ),
        .reset  (reset_sync       ),
        .d      ({lcl_tx_cal_busy , lcl_pll_cal_busy , lcl_pll_locked , lcl_tx_analogreset_stat_assert , lcl_tx_digitalreset_stat_assert     , lcl_tx_analogreset_stat_deassert , lcl_tx_digitalreset_stat_deassert     }),
        .q      ({tx_cal_busy_sync, pll_cal_busy_sync, pll_locked_sync, tx_analogreset_stat_assert_sync, tx_digitalreset_stat_assert_sync[ig], tx_analogreset_stat_deassert_sync, tx_digitalreset_stat_deassert_sync[ig]})
      );

      // Add hysteresis to pll_locked if needed
      // Reset counter works fine for hysteresis
      if(T_PLL_LOCK_HYST != 0) begin : g_pll_locked_hyst
        alt_xcvr_reset_counter_s10 #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ  ), // Clock frequency in Hz
            .RESET_PER_NS (T_PLL_LOCK_HYST)  // Reset period in ns
        ) counter_pll_locked_hyst (
          .clk        (clock                ),
          .async_req  (reset_sync           ),  // asynchronous reset request
          .sync_req   (~pll_locked_sync ),  // synchronous reset request
          .reset_or   (1'b0                 ),
          .reset      (/*unused*/           ),  // synchronous reset out
          .reset_n    (pll_locked_hyst  ),
          .reset_stat (/*unused*/           )
        );
      end else begin : g_no_pll_locked_hyst
        // No hysteresis added; use synchronized pll_locked directly.
        assign  pll_locked_hyst = pll_locked_sync;
      end

      // Add one-shot latch to pll_locked for initial reset sequence (need because of manual mode)
      always @(posedge clock or posedge reset_sync)
      if(reset_sync)  pll_locked_latch  <= 1'b0;
      else if(pll_locked_hyst & ~tx_cal_busy_sync)
                      pll_locked_latch  <= 1'b1;

      // tx_analogreset
      // Assert tx_analogreset while any of the following:
      // 1 - TX or PLL calibration is in progress
      // 2 - tx_analogreset_stat is deasserted and stat_tx_analogreset is asserted
      // and for "T_TX_ANALOGRESET" ns thereafter
        alt_xcvr_reset_counter_s10 #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
            .RESET_PER_NS (T_TX_ANALOGRESET )  // Reset period in ns
        ) counter_tx_analogreset (
          .clk        (clock                  ),
          .async_req  (reset_sync             ),  // asynchronous reset request
          .sync_req   (tx_or_pll_cal_busy_sync|(~tx_analogreset_stat_assert_sync&stat_tx_analogreset)),  // synchronous reset request
          .reset_or   (1'b0                   ),  // auxilliary reset override
          .reset      (tx_analogreset[ig]     ),  // synchronous reset out
          .reset_n    (/*unused*/             ),
          .reset_stat (stat_tx_analogreset)
        );

      // tx_digitalreset
      // Assert tx_digitalreset while any of the following
      // 1 - Reset input (asynchronous) is asserted.
      // 2 - pll_powerdown is asserted.
      // 3 - tx_analogreset_stat is asserted.
      // 4 - tx_digitalreset_stat is deasserted and stat_tx_digitalreset is asserted.
      // 5 - TX calibration is in progress.
      // 6 - PLL has not reached initial lock (pll_locked_latch)
      // 7 - PLL is not locked AND TX reset is NOT under manual control (tx_manual)
      // 8 - Reset override (tx_digitalreset_or).
      alt_xcvr_reset_counter_s10 #(
          .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
          .RESET_PER_NS (T_TX_DIGITALRESET )  // Reset period in ns
      ) counter_tx_digitalreset (
        .clk        (clock                      ),
        .async_req  (reset_sync                 ),  // asynchronous reset request
        .sync_req   (stat_tx_analogreset|~pll_locked_latch|tx_manual|tx_analogreset_stat_deassert_sync|(~tx_digitalreset_stat_assert_sync[ig]&stat_tx_digitalreset[ig])),  // synchronous reset request
        .reset_or   (lcl_tx_digitalreset_or     ),  // auxilliary reset override
        .reset      (tx_digitalreset[ig]        ),  // synchronous reset out
        .reset_n    (/*unused*/                 ),
        .reset_stat (stat_tx_digitalreset[ig]   )
      );
  
      // tx_ready
      // Assert when tx_digitalreset and tx_digitalreset_stat deassert
      alt_xcvr_reset_counter_s10 #(
          .RESET_COUNT(3)
      ) counter_tx_ready (
        .clk        (clock                ),
        .async_req  (reset_sync           ),  // asynchronous reset request
        .sync_req   (stat_tx_digitalreset[ig] | tx_digitalreset_stat_deassert_sync[ig]),  // synchronous reset request
        .reset_or   (1'b0                 ),  // auxilliary reset override
        .reset      (/*unused*/           ),  // synchronous reset out
        .reset_n    (tx_ready[ig]         ),
        .reset_stat (/*unused*/           )   // reset status
      );
    end else begin : g_fanout_tx
      assign  tx_analogreset  [ig]                   = tx_analogreset  [0];
      assign  tx_digitalreset [ig]                   = tx_digitalreset [0];
      assign  tx_ready        [ig]                   = tx_ready        [0];
      assign  stat_tx_digitalreset[ig]               = stat_tx_digitalreset[0];
      assign  tx_digitalreset_stat_assert_sync[ig]   = tx_digitalreset_stat_assert_sync[0];
      assign  tx_digitalreset_stat_deassert_sync[ig] = tx_digitalreset_stat_deassert_sync[0];
    end
  end
end else begin : g_no_tx
  assign  tx_analogreset  = {CHANNELS{1'b0}};
  assign  tx_digitalreset = {CHANNELS{1'b0}};
  assign  tx_ready        = {CHANNELS{1'b0}};
end
endgenerate
//*************************** End TX Reset Logic ****************************
//***************************************************************************


//***************************************************************************
//***************************** RX Reset Logic ******************************
generate if (RX_ENABLE) begin : g_rx
  for (ig=0;ig<CHANNELS;ig=ig+1) begin : g_rx
    if(ig == 0 || RX_PER_CHANNEL == 1) begin : g_rx
      wire  lcl_rx_cal_busy;                   // rx_cal_busy for this channel
      wire  lcl_rx_is_lockedtodata;            // rx_is_lockedtodata for this channel
      wire  lcl_rx_digitalreset_or;            // rx_digitalreset_or for this channel
      wire  lcl_rx_analogreset_stat_assert;    // rx_analogreset_stat for this channel (used for assertion)
      wire  lcl_rx_digitalreset_stat_assert;   // rx_digitalreset_stat for this channel (used for assertion)
      wire  lcl_rx_analogreset_stat_deassert;  // rx_analogreset_stat for this channel (used for deassertion)
      wire  lcl_rx_digitalreset_stat_deassert; // rx_digitalreset_stat for this channel (used for deassertion)

      // Synchronized signals
      wire  rx_cal_busy_sync;                   // rx_cal_busy after synchronization
      wire  rx_is_lockedtodata_sync;            // rx_is_lockedtodata after synchronization
      wire  rx_analogreset_stat_assert_sync;    // rx_analogreset_stat after synchronization (used for assertion)
      wire  rx_digitalreset_stat_assert_sync;   // rx_digitalreset_stat after synchronization (used for assertion)
      wire  rx_analogreset_stat_deassert_sync;  // rx_analogreset_stat after synchronization (used for deassertion)
      wire  rx_digitalreset_stat_deassert_sync; // rx_digitalreset_stat after synchronization (used for deassertion)
      wire  rx_manual;                          // Set manual or auto reset mode for this RX channel

      // Reset status signals
      wire  stat_rx_analogreset;
      wire  stat_rx_digitalreset;

      // Control signal for this channel. With separate reset control per channel, each channel
      // listens to its own control signal. Otherwise the control signals for all channels are
      // combined for the shared reset control.
      assign  lcl_rx_cal_busy                   = RX_PER_CHANNEL  ? rx_cal_busy        [ig]  : |rx_cal_busy;
      assign  lcl_rx_is_lockedtodata            = RX_PER_CHANNEL  ? rx_is_lockedtodata [ig]  : &rx_is_lockedtodata;
      assign  lcl_rx_digitalreset_or            = RX_PER_CHANNEL  ? rx_digitalreset_or [ig]  : |rx_digitalreset_or;
      assign  lcl_rx_analogreset_stat_assert    = RX_PER_CHANNEL  ? rx_analogreset_stat[ig]  : &rx_analogreset_stat;
      assign  lcl_rx_digitalreset_stat_assert   = RX_PER_CHANNEL  ? rx_digitalreset_stat[ig] : &rx_digitalreset_stat;
      assign  lcl_rx_analogreset_stat_deassert  = RX_PER_CHANNEL  ? rx_analogreset_stat[ig]  : |rx_analogreset_stat;
      assign  lcl_rx_digitalreset_stat_deassert = RX_PER_CHANNEL  ? rx_digitalreset_stat[ig] : | rx_digitalreset_stat;
      assign  rx_manual                         = RX_MANUAL_RESET ? 1'b0 : ~rx_is_lockedtodata_sync;
      
      // Synchonize RX inputs
      alt_xcvr_resync_std #(
          .SYNC_CHAIN_LENGTH(2),  // Number of flip-flops for retiming
          .WIDTH            (6),
          .INIT_VALUE       (6'b100000)
      ) resync_rx_cal_busy (
        .clk    (clock            ),
        .reset  (reset_sync       ),
        .d      ({lcl_rx_cal_busy , lcl_rx_is_lockedtodata , lcl_rx_analogreset_stat_assert , lcl_rx_digitalreset_stat_assert , lcl_rx_analogreset_stat_deassert , lcl_rx_digitalreset_stat_deassert }),
        .q      ({rx_cal_busy_sync, rx_is_lockedtodata_sync, rx_analogreset_stat_assert_sync, rx_digitalreset_stat_assert_sync, rx_analogreset_stat_deassert_sync, rx_digitalreset_stat_deassert_sync})
      );

      // rx_analogreset
      // Assert rx_analogreset while any of the following:
      // 1 - RX calibration is in progress
      // 2 - rx_analogreset_stat is deasserted and stat_rx_analogreset is asserted
      // and for "T_RX_ANALOGRESET" ns thereafter
      alt_xcvr_reset_counter_s10 #(
          .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
          .RESET_PER_NS (T_RX_ANALOGRESET )  // Reset period in ns
      ) counter_rx_analogreset (
        .clk        (clock              ),
        .async_req  (reset_sync         ),  // asynchronous reset request
        .sync_req   (rx_cal_busy_sync|(~rx_analogreset_stat_assert_sync&stat_rx_analogreset)),  // synchronous reset request
        .reset_or   (1'b0               ),  // auxilliary reset override
        .reset      (rx_analogreset[ig] ),  // synchronous reset out
        .reset_n    (/*unused*/         ),
        .reset_stat (stat_rx_analogreset)
      );
    
      // rx_digitalreset
      // Assert rx_digitalreset while any of the following:
      // 1 - Reset input is asserted.
      // 2 - rx_analogreset is asserted.
      // 3 - rx_analogreset_stat is asserted.
      // 4 - rx_digitalreset_stat is deasserted and stat_rx_digitalreset is asserted.
      // 5 - RX calibration is in progress.
      // 6 - RX is not locked to data AND RX reset is NOT under manual control
      //        (meaning user wants us to respond to loss of RX data lock)
      // 7 - Digital reset override (rx_digitalreset_or)
      // 8 - If TX_ENABLE && ENABLE_DIGITAL_SEQ == 1 and stat_tx_digitalreset or tx_digitalreset_stat are asserted
      if (TX_ENABLE && ENABLE_DIGITAL_SEQ)
        alt_xcvr_reset_counter_s10 #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
            .RESET_PER_NS (T_RX_DIGITALRESET )  // Reset period in ns
        ) counter_rx_digitalreset (
          .clk        (clock                  ),
          .async_req  (reset_sync             ),  // asynchronous reset request
          .sync_req   (stat_rx_analogreset|rx_manual|rx_analogreset_stat_deassert_sync|(~rx_digitalreset_stat_assert_sync&stat_rx_digitalreset)|tx_digitalreset_stat_deassert_sync[ig]|stat_tx_digitalreset[ig]),  // synchronous reset request
          .reset_or   (lcl_rx_digitalreset_or ),  // auxilliary reset override
          .reset      (rx_digitalreset[ig]    ),  // synchronous reset out
          .reset_n    (/*unused*/             ),
          .reset_stat (stat_rx_digitalreset   )
        );
      else
        alt_xcvr_reset_counter_s10 #(
            .CLKS_PER_SEC (SYS_CLK_IN_HZ    ), // Clock frequency in Hz
            .RESET_PER_NS (T_RX_DIGITALRESET )  // Reset period in ns
        ) counter_rx_digitalreset (
          .clk        (clock                  ),
          .async_req  (reset_sync             ),  // asynchronous reset request
          .sync_req   (stat_rx_analogreset|rx_manual|rx_analogreset_stat_deassert_sync|(~rx_digitalreset_stat_assert_sync&stat_rx_digitalreset)),  // synchronous reset request
          .reset_or   (lcl_rx_digitalreset_or ),  // auxilliary reset override
          .reset      (rx_digitalreset[ig]    ),  // synchronous reset out
          .reset_n    (/*unused*/             ),
          .reset_stat (stat_rx_digitalreset   )
        );

      // rx_ready
      alt_xcvr_reset_counter_s10 #(
          .RESET_COUNT(3)
      ) counter_rx_ready (
        .clk        (clock                ),
        .async_req  (reset_sync           ),  // asynchronous reset request
        .sync_req   (stat_rx_digitalreset | rx_digitalreset_stat_deassert_sync),  // synchronous reset request
        .reset_or   (1'b0                 ),  // auxilliary reset override
        .reset      (/*unused*/           ),  // synchronous reset out
        .reset_n    (rx_ready[ig]         ),
        .reset_stat (/*unused*/           )
      );
    
    end else begin : g_fanout_rx
      assign  rx_analogreset  [ig]  = rx_analogreset  [0];
      assign  rx_digitalreset [ig]  = rx_digitalreset [0];
      assign  rx_ready        [ig]  = rx_ready        [0];
    end
  end
end else begin : g_no_rx
  assign  rx_analogreset  = {CHANNELS{1'b0}};
  assign  rx_digitalreset = {CHANNELS{1'b0}};
  assign  rx_ready        = {CHANNELS{1'b0}};
end
endgenerate
//*************************** End RX Reset Logic ****************************
//***************************************************************************

////////////////////////////////////////////////////////////////////
// Return the number of bits required to represent an integer
// E.g. 0->1; 1->1; 2->2; 3->2 ... 31->5; 32->6
//
function integer clogb2;
  input integer MAX_CNT;

  begin
    integer input_num_temp;
    input_num_temp = MAX_CNT; 
    for (clogb2=0; input_num_temp > 0 && clogb2<`MAX_PRECISION; clogb2=clogb2+1)
     input_num_temp = input_num_temp >> 1;
    if(clogb2 == 0)
      clogb2 = 32'b1;
  end
endfunction


// pll_select_width
// Internal function to calculate the width of pll_select port.
// @param PLLS - Number of TX PLLs
// @param TX_PER_CHANNEL - Separate TX reset controller per channel
// @param CHANNELS - The number of TX CHANNELS
//
// @return - The width of the pll_select port
function integer pll_select_width;
  input integer PLLS;
  input integer TX_PER_CHANNEL;
  input integer CHANNELS;

  integer tmp_pll_select_width;
  begin
    tmp_pll_select_width = clogb2((PLLS - 1));
    pll_select_width = (TX_PER_CHANNEL) ? (CHANNELS * tmp_pll_select_width) : tmp_pll_select_width;
  end
endfunction

endmodule

