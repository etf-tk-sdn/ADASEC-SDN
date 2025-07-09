`timescale 1ps / 1ps
`define NULL 0

module pcap_reader_writer_test;

    // Inputs
    logic CLOCK = 0;
    logic reset = 1;
    logic available;
    logic [7:0] pktcount;
    logic pcapfinished;
    parameter DATA_WIDTH = 512;
    parameter SIGNAL_TYPE = "avalon";
  
    avalon_if #(.DATA_WIDTH(DATA_WIDTH)) avalon_int(.clk(CLOCK),.rst(reset));
    axis_if #(.DATA_WIDTH(DATA_WIDTH)) axis_int(.clk(CLOCK),.rst(reset));

    pcapreader #(
        .PCAP_FILENAME( "proba1.pcap" ),
        .SIGNAL_TYPE(SIGNAL_TYPE),
        .DATA_WIDTH(DATA_WIDTH)
    ) pcap (
	.clk_out(CLOCK),
        .reset(reset),
        .available(available),
        .pktcount(pktcount),
	.pcapfinished(pcapfinished),

	.from_reader_avalon(avalon_int),
        .from_reader_axis(axis_int)
    );

    pcapwriter #(
	.PCAP_FILENAME( "novipcap.pcap" ),
        .SIGNAL_TYPE(SIGNAL_TYPE),
        .DATA_WIDTH(DATA_WIDTH)
    ) pcapwr (
	.clk_in(CLOCK),
	.reset(reset),

	.to_writer_avalon(avalon_int),
        .to_writer_axis(axis_int)
    );

    integer clock_period = 2560;

    always #(clock_period/2) CLOCK = ~CLOCK;
	

    integer i = 0;

    initial begin

        $dumpfile("novi1.txt");
        $dumpvars(0);
        avalon_int.ready <= 1;

        #clock_period;
        reset <= 0;
        #(2*clock_period);
        avalon_int.ready <= 0;
        #(3*clock_period);
        avalon_int.ready <= 1;
		
        while (~pcapfinished ) begin
	    #20
	    i = i+1;
	end

	#(2*clock_period);

	$finish;

    end

endmodule