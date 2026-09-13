`timescale 1ps / 1ps
`define NULL 0

// Author: Amina Tankovic
// Description: Key provider uses material obtained from key generator, number of bytes that need to be encrypted and position vector (positions/addreses of bytes that need to be encrypted)
//              to generate the final key material, which will be then distributed and used for XOR encryption. It consists of dual_port_ram and key_vector modules.                       

module key_provider#(                                     
) (
    input logic clk,
    input logic rst,
    input logic [9:0] rdaddrA,
    input logic [9:0] addrB,
    input logic [390:0] wrdataB,
    input logic wrB,
    output logic [390:0] rddataB,
    avalon_if.in from_pcap_reader,   
    avalon_if.in from_key_generator,
    avalon_if.out to_key_scheduler
);


logic [390:0] readdataA;
dual_port_ram dualportram(
    .clk(clk),
    .addrA(rdaddrA),
    .rddataA(readdataA),

    .addrB(addrB),
    .wrdataB(wrdataB),
    .rddataB(rddataB),
    .wrB(wrB)
);


key_vector keyvec(
    .clk(clk),
    .rst(rst),
    .from_generator(from_key_generator),
    .readdata(readdataA),
    .from_pcap_reader(from_pcap_reader),
    .key_vector_next(to_key_scheduler)
);

endmodule
