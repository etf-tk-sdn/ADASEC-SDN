// Encryption-instruction RAM.
//
// Port A is the datapath lookup port.  Port B is the Avalon-MM
// read/modify/write port.  Both ports use the dataplane clock; sharing one
// address for read and write on port B matches the native bidirectional
// dual-port M20K template.
module dual_port_ram (
    input logic clk,
    input logic [9:0] addrA,
    output logic [390:0] rddataA,

    input logic [9:0] addrB,
    input logic [390:0] wrdataB,
    output logic [390:0] rddataB,
    input logic wrB
);

    (* ramstyle = "M20K, no_rw_check" *)
    logic [390:0] ram_array [0:1023] = '{1024{'0}};

    always_ff @(posedge clk) begin
        rddataA <= ram_array[addrA];
        if (wrB) begin
            ram_array[addrB] <= wrdataB;
        end
        rddataB <= ram_array[addrB];
    end

endmodule
