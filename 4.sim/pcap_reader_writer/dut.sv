`timescale 1ns / 1ps
`define NULL 0

// Author: Amina Tankovic
// 
// Description: 

module dut#
(
) ( input logic clk,
    input logic rst,
    avalon_if.in from_pcap_reader,
   // avalon_if.out to_pcap_writer
    output logic [511:0] final_key
);


dual_port_ram dualportram(
    .clkA(clk),
    .rdaddrA(from_pcap_reader.channel),
    .wraddrA(),
    .wrdataA(),
    .rddataA(),
    .wrA(),

    .clkB(clk),
    .rdaddrB(),
    .wraddrB(),
    .wrdataB(),
    .rddataB(),
    .wrB()
);

key_provider keyprov(                                     
) (
    .clk(clk),
    .rst(rst),
    .from_generator(),   
    .count_ones(),           
    .position_vector(), 
    .final_key(final_key)         

);

/*encryption_block encryptor(
)(
    .key(),
    .data(),
    .encrypted_data()
);*/
endmodule


