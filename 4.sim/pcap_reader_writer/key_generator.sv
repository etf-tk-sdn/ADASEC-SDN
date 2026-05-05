`timescale 1ps / 1ps
`define NULL 0

// Author: Amina Tankovic
// Description: Generator of key material which will be used for making the final key.
//              It always generates the same sequence of random bits, due to unchanged seed.
//              For key provider and encryptor testing purposes.

module key_generator(
    input clk,
    input rst,
    input in_valid,  //input signal which indicates whether there is valid key material
    avalon_if.out to_key_provider
);
    
always_ff  @(posedge clk) begin
    if(rst) begin
        to_key_provider.data <= '0;
        to_key_provider.valid <= 0;
    end else begin
       if(to_key_provider.ready) begin
           if (in_valid) begin
                to_key_provider.data <= {
                $urandom(), $urandom(), $urandom(), $urandom(),
                $urandom(), $urandom(), $urandom(), $urandom(),
                $urandom(), $urandom(), $urandom(), $urandom(),
                $urandom(), $urandom(), $urandom(), $urandom()
                };
                to_key_provider.valid <= 1;   
           end else begin
                to_key_provider.valid <= 0;
           end
       end else begin
               to_key_provider.valid <= 0;
       end
    end

end
endmodule
