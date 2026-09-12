module altera_reset_release (
		output wire  ninit_done  // ninit_done.ninit_done, You can use the nINIT_DONE signal in one of the following ways: To gate an external or internal reset; To gate the reset input to the transceiver and I/O PLLs; To gate the write enable of design blocks such as embedded memory blocks, state machine, and shift registers; To synchronously drive register reset input ports in your design.
	);
endmodule

