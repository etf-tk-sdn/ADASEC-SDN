// Author: Amina Tankovic
// Description: Dual port RAM - used to store number of bytes that need to be encrypted (count_ones) and their positions/addresses (position vector)
//              for each segment of each flow/packet. Write and read operations can be done in different clock domains.

module dual_port_ram (

  //port A
  input logic clkA,
  input logic[9:0] rdaddrA,  //routing_tag(3)+ pckt_number/flow_id(5 bits - arbitrarily chosen) + seq_number(5 bits, because there can be max 24 segments in MTU (1500B))
  input logic[9:0] wraddrA,
  input logic[390:0] wrdataA, //count_ones(7 bits, because there can be max 64 bytes that need to be encrypted) + position_vec(384 bits, 64x6 bits for each address)
  output logic[390:0] rddataA,
  input logic wrA,

  //port B

  input logic clkB,
  input logic[9:0] rdaddrB,  
  input logic[9:0] wraddrB,
  input logic[390:0] wrdataB, 
  output logic[390:0] rddataB,
  input logic wrB
  
);

 // logic [390:0] ram_array [0:1023];   //2^10 entries in table currently supported
   logic [390:0] ram_array [0:65535] = '{65536{'0}};   //2^10 entries in table currently supported

  // Port A logic
    always_ff @(posedge clkA) begin
        if (wrA) begin
            ram_array[wraddrA] <= wrdataA;
        end else begin
            rddataA <= ram_array[rdaddrA]; // Read is always active
        end
    end

  // Port B logic
    always_ff @(posedge clkB) begin
        if (wrB) begin
            ram_array[wraddrB] <= wrdataB;
        end else begin
            rddataB <= ram_array[rdaddrB]; // Read is always active
        end
    end

endmodule
