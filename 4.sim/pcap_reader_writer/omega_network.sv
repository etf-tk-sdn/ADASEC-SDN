// Author: Amina Tankovic
// Description: 64x64 omega network used to distribute key material to desired positions/addresses to make the final key.

module omega_network#(                                    
) (
    input logic [14:0] inp [0:63], 
    output logic [14:0] outp [0:63],
    output logic [511:0] outp_key 
);

logic [14:0] outp1 [0:63];
logic [14:0] outp2 [0:63];
logic [14:0] outp3 [0:63];
logic [14:0] outp4 [0:63];
logic [14:0] outp5 [0:63];

stage #(
         .stage_order(0)
        ) stage0(
            .inp(inp),
            .outp(outp1)
        );

stage #(
         .stage_order(1)
        ) stage1(
            .inp(outp1),
            .outp(outp2)
        );

stage #(
         .stage_order(2)
        ) stage2(
            .inp(outp2),
            .outp(outp3)
        );

stage #(
         .stage_order(3)
        ) stage3(
            .inp(outp3),
            .outp(outp4)
        );

stage #(
         .stage_order(4)
        ) stage4(
            .inp(outp4),
            .outp(outp5)
        );

stage #(
         .stage_order(5)
        ) stage5(
            .inp(outp5),
            .outp(outp)
        );


always_comb begin
   for (int i = 0; i < 64; i++) begin 
       outp_key[511-i*8-:8] = outp[i][7:0];  
   end
end


endmodule 
