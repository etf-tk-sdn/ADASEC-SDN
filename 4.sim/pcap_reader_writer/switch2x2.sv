
// Author: Amina Tankovic
// Description: Switch 2x2 for omega network (i.e. stage in omega network);  
               

module switch_2x2#(
    parameter stage_order = 5  //stage order can take values from 0 to 5 (64x64 omega network consists of 6 stages)                                      
) (
    input logic [14:0] u,     //first bit is priority/enable bit, indicates whether this address is used; next 6 bits is address [13:8]; remaining 8 bits [7:0] represent payload/byte of key material
    input logic [14:0] v,    

    output logic [14:0] x, 
    output logic [14:0] y
);

  always_comb begin
      if(u[14] == 1'b1 && v[14] == 1'b0) begin
         if(u[13-stage_order]==1'b0) begin
            x = u;
            y = v;
         end else begin
            x = v;
            y = u;
         end
      end else if(v[14] == 1'b1 && u[14] == 1'b0) begin
         if(v[13-stage_order]==1'b0) begin
            x = v;
            y = u;
         end else begin
            y = v;
            x = u;
         end
      end else begin
         if(u[13-stage_order]==1'b0 && v[13-stage_order]==1'b1) begin
            x = u;
            y = v;
         end else begin
            x = v;
            y = u;
         end
      end
  end

endmodule 