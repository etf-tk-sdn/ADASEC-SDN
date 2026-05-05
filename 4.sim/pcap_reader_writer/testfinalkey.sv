`timescale 1ps / 1ps
`define NULL 0

module testfinalkey;

logic clk = 0;
logic rst = 1;
integer count_ones;
avalon_if #(.DATA_WIDTH(512)) avalon_int(.clk(clk),.rst(rst));

logic [511:0] final_key;
logic [383:0] position_vec;  

key_material_generator keygen(
    .clk(clk),
    .rst(rst),
    .to_key_provider(avalon_int)
);

key_provider keyprov(
    .clk(clk),
    .rst(rst),
    .from_generator(avalon_int),
    .count_ones(count_ones),
    .position_vector(position_vec),
    .final_key(final_key)
);

    integer clock_period = 2560;
    always #(clock_period/2) clk = ~clk;
	

    integer i = 0;

    initial begin
        #(1*clock_period);
        rst<=0;
        count_ones<=0;
        #(3*clock_period);
        #(1*clock_period);
        //bit_vector<=64'b0101_1010_1100_1100_0101_1010_1100_1100_0101_1010_1100_1100_0101_1010_1100_1100;
        count_ones <= 4;
        #(clock_period/2);
        position_vec[383:378] <= 6'b000001;
        position_vec[377:372] <= 6'b000010;
        position_vec[371:366] <= 6'b000100;
        position_vec[365:360] <= 6'b001000;       
        #(1*clock_period);
        count_ones <= 6; 
        position_vec[383:378] <= 6'b000000;
        position_vec[377:372] <= 6'b000010;
        position_vec[371:366] <= 6'b000100;
        position_vec[365:360] <= 6'b010000;  
        position_vec[359:354] <= 6'b110000; 
        position_vec[353:348] <= 6'b111111; 
        #(1*clock_period);
        
    end
endmodule

