`timescale 1ps / 1ps
`define NULL 0

// Author: Amina Tankovic
// Description: Encryption block takes the data from pcap reader (delayed through FIFO) and the final key (from key provider+scheduler). 
//              It generates final data using XOR encryption and prepares the rest of Avalon-ST signals. 

module encryption_block#(                                     
) (
    input clk,
    input rst, 
    avalon_if.in    from_key_scheduler,
    avalon_if.in    from_reader_register,
    avalon_if.out   encrypted
);

logic output_ready;

// The output register may accept a new item whenever it is empty, even if the
// downstream sink is currently applying backpressure.  Once full, its value
// is held until the sink accepts it.
assign output_ready = !encrypted.valid || encrypted.ready;

always_ff @(posedge clk) begin
    if(rst) begin
        encrypted.data <= '0;
        encrypted.valid <= 0;
        encrypted.sop <= 0;
        encrypted.eop <= 0;
        encrypted.empty <= '0; 
        encrypted.channel <= '0;
    end else if (output_ready) begin
        encrypted.valid <= from_reader_register.valid && from_key_scheduler.valid;
        if (from_reader_register.valid && from_key_scheduler.valid) begin
           encrypted.data <= from_key_scheduler.data ^ from_reader_register.data; //XOR encryption
           encrypted.sop <= from_reader_register.sop;
           encrypted.eop <= from_reader_register.eop;
           encrypted.empty <= from_reader_register.empty;
           encrypted.channel <= from_reader_register.channel;
        end else begin
            encrypted.data <= '0;
            encrypted.sop <= 1'b0;
            encrypted.eop <= 1'b0;
            encrypted.empty <= '0;
            encrypted.channel <= '0;
        end
    end
end 

// Join the delayed payload and its scheduled key.  Each input advances only
// when the other input is valid and the output can accept the result.
assign from_reader_register.ready = output_ready && from_key_scheduler.valid;
assign from_key_scheduler.ready = output_ready && from_reader_register.valid;

endmodule
