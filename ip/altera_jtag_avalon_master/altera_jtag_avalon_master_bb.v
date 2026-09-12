module altera_jtag_avalon_master (
		input  wire        clk_clk,              //          clk.clk,           Clock Input
		input  wire        clk_reset_reset,      //    clk_reset.reset,         Reset Input
		output wire        master_reset_reset,   // master_reset.reset,         Reset Output
		output wire [31:0] master_address,       //       master.address,       Address output of Avalon Memory Mapped Host
		input  wire [31:0] master_readdata,      //             .readdata,      Read Data input to Avalon Memory Mapped Host
		output wire        master_read,          //             .read,          Read command from Avalon Memory Mapped Host
		output wire        master_write,         //             .write,         Write command from Avalon Memory Mapped Host
		output wire [31:0] master_writedata,     //             .writedata,     Write Data from Avalon Memory Mapped Host
		input  wire        master_waitrequest,   //             .waitrequest,   Wait request from Avalon Memory Mapped Agent, indicates agent is not ready
		input  wire        master_readdatavalid, //             .readdatavalid, Valid read data indication from Avalon Memory Mapped Agent
		output wire [3:0]  master_byteenable     //             .byteenable,    Indicates valid write data/read data location
	);
endmodule

