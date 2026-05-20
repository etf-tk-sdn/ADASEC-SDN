`timescale 1ps / 1ps
`define NULL 0

// Author: Amina Tankovic
// Description: Network packet classifier: consists of header parser (first stage), lookup table (secnond stage)
//              and match-action table (writing result into channel signal - third stage).
//              Csr used for writing and reading processes
// 
              
module classifier#(
) (
    input logic clk,
    input logic rst, 

    //csr interface - avalon mm 
    input logic          csr_clk,
    input logic          csr_reset,
    input logic  [31:0]  csr_address,  //5 za bazni dio, 4 za offset kojim upravljam jel se radi o tabeli s podacima ili maskama, i kojem polju tabele se radi
    input logic          csr_read,
    output logic [31:0]  csr_readdata,
    input logic	         csr_write,        
    input logic  [31:0]	 csr_writedata,
    input logic  [3:0]   csr_byteenable,
    output logic         csr_waitrequest,                                      

    //avalon st input and output
    avalon_if.in    from_pcap_reader_to_classifier,
    avalon_if.out   from_classifier
);


//logic [7:0]  protocol;
//logic [15:0] src_port;
//logic [15:0] dst_port;
//logic [31:0] src_ip_add;
//logic [31:0] dst_ip_add; 

logic [2:0]  routing_tag_extracted;  //5 mogucih smjerova rutiranja
logic [4:0]  flow_id_extracted;


logic [223:0] mat_table [0:31];   //2^5 redova max jer flow_id ima 5 bita; svaki od unosa ima 224 bita (poravnanje na 28B)
                                  //224 = 8(enable) + 8(routing tag) + 2x8(protocol data+mask)  + 
                                  //    + 2x16(src port data+mask)   + 2x16(dst port data+mask) +
                                  //    + 2x32(src ip add data+mask) + 2x32(dst ip add data+mask)


logic [103:0]  data_test [0:31];
logic [103:0]  mask_test [0:31];
logic [103:0]  entry;
logic [4:0]    csr_address_base;
logic [4:0]    csr_address_offset;
logic [4:0]    seq_numb = 0;

avalon_if #(.DATA_WIDTH(512)) first_reg(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512)) second_reg(.clk(clk),.rst(rst));
avalon_if #(.DATA_WIDTH(512)) third_reg(.clk(clk),.rst(rst));

always_comb begin
        csr_address_base = csr_address[9:5];
        csr_address_offset = csr_address[4:0];
end


always_ff @(posedge csr_clk) begin 
   if(csr_reset) begin
       for (int i = 0; i < 32; i++) begin
            //Data values
            mat_table[i][223:200] <= '0;
            mat_table[i][191:176] <= '0;
            mat_table[i][159:144] <= '0;
            mat_table[i][127:96] <= '0;
            mat_table[i][63:32] <= '0;
            //Mask values
            mat_table[i][199:192] <= '1;
            mat_table[i][175:160] <= '1;
            mat_table[i][143:128] <= '1;
            mat_table[i][95:64] <= '1;
            mat_table[i][31:0] <= '1;
       end
   end else begin
       if(csr_write) begin
            if(csr_address_offset == 5'b00000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][223:216] <= csr_writedata[31:24];   // Enable signal
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][215:208] <= csr_writedata[23:16];   // Routing Tag 
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][207:200] <= csr_writedata[15:8];    // Protocol (Data)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      mat_table[int'(csr_address_base)][199:192] <= csr_writedata[7:0];    // Protocol (Mask)
                 end
            end else if (csr_address_offset == 5'b00100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][191:184] <= csr_writedata[31:24];   // Src port (Data)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][183:176] <= csr_writedata[23:16];   // Src port (Data)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][175:168] <= csr_writedata[15:8];    // Src port (Mask)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][167:160] <= csr_writedata[7:0];     // Src port (Mask)
                 end 
            end else if (csr_address_offset == 5'b01000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][159:152] <= csr_writedata[31:24];   // Dst port (Data)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][151:144] <= csr_writedata[23:16];   // Dst port (Data)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][143:136] <= csr_writedata[15:8];    // Dst port (Mask)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][135:128] <= csr_writedata[7:0];     // Dst port (Mask)
                 end 
            end else if (csr_address_offset == 5'b01100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][127:120] <= csr_writedata[31:24];   // Src IP add (Data - first byte)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][119:112] <= csr_writedata[23:16];   // Src IP add (Data - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][111:104] <= csr_writedata[15:8];    // Src IP add (Data - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][103:96] <= csr_writedata[7:0];      // Src IP add (Data - fourth byte)
                 end 
            end else if (csr_address_offset == 5'b10000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][95:88] <= csr_writedata[31:24];     // Src IP add (Mask - first byte)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][87:80] <= csr_writedata[23:16];     // Src IP add (Mask - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][79:72] <= csr_writedata[15:8];      // Src IP add (Mask - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][71:64] <= csr_writedata[7:0];       // Src IP add (Mask - fourth byte)
                 end 
            end else if (csr_address_offset == 5'b10100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][63:56] <= csr_writedata[31:24];     // Dst IP add (Data - first byte)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][55:48] <= csr_writedata[23:16];     // Dst IP add (Data - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][47:40] <= csr_writedata[15:8];      // Dst IP add (Data - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][39:32] <= csr_writedata[7:0];       // Dst IP add (Data - fourth byte)
                 end
            end else if (csr_address_offset == 5'b11000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     mat_table[int'(csr_address_base)][31:24] <= csr_writedata[31:24];     // Dst IP add (Mask - first byte)
                 end 
                 if (csr_byteenable[2] == 1'b1) begin
                     mat_table[int'(csr_address_base)][23:16] <= csr_writedata[23:16];     // Dst IP add (Mask - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     mat_table[int'(csr_address_base)][15:8] <= csr_writedata[15:8];       // Dst IP add (Mask - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                     mat_table[int'(csr_address_base)][7:0] <= csr_writedata[7:0];         // Dst IP add (Mask - fourth byte)
                 end
            end else begin
                 
            end
       end else if(csr_read) begin
            if(csr_address_offset == 5'b00000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][223:216];          // Enable signal
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][215:208];          // Routing Tag 
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][207:200];          // Protocol (Data)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][199:192];         // Protocol (Mask)
                 end 
            end else if(csr_address_offset == 5'b00100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][191:184];          // Src port (Data)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][183:176];          // Src port (Data)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][175:168];          // Src port (Mask)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][167:160];         // Src port (Mask)
                 end  
            end else if(csr_address_offset == 5'b01000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][159:152];          // Dst port (Data)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][151:144];          // Dst port (Data)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][143:136];          // Dst port (Mask)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][135:128];         // Dst port (Mask)
                 end  
            end else if(csr_address_offset == 5'b01100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][127:120];          // Src IP add (Data - first byte)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][119:112];          // Src IP add (Data - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][111:104];          // Src IP add (Data - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][103:96];          // Src IP add (Data - fourth byte)
                 end  
            end else if(csr_address_offset == 5'b10000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][95:88];            // Src IP add (Mask - first byte)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][87:80];            // Src IP add (Mask - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][79:72];            // Src IP add (Mask - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][71:64];           // Src IP add (Mask - fourth byte)
                 end   
            end else if(csr_address_offset == 5'b10100) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][63:56];            // Dst IP add (Data - first byte)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][55:48];            // Dst IP add (Data - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][47:40];            // Dst IP add (Data - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][39:32];           // Dst IP add (Data - fourth byte)
                 end  
            end else if(csr_address_offset == 5'b11000) begin
                 if (csr_byteenable[3] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][31:24];            // Dst IP add (Mask - first byte)
                 end
                 if (csr_byteenable[2] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][23:16];            // Dst IP add (Mask - second byte)
                 end 
                 if (csr_byteenable[1] == 1'b1) begin
                     csr_readdata <=  mat_table[int'(csr_address_base)][15:8];             // Dst IP add (Mask - third byte)
                 end 
                 if (csr_byteenable[0] == 1'b1) begin
                      csr_readdata <=  mat_table[int'(csr_address_base)][7:0];             // Dst IP add (Mask - fourth byte)
                 end 
            end else begin
                 csr_readdata <= '0; 
            end
       end
   end

end

//Classifier

always_ff @(posedge clk) begin
    if (rst) begin
      first_reg.sop <= 1'b0;
      first_reg.eop <= 1'b0;
      first_reg.valid <= 1'b0;
      first_reg.data <= '0;
      first_reg.channel <= '0;
      first_reg.empty <= '0;

      second_reg.sop <= 1'b0;
      second_reg.eop <= 1'b0;
      second_reg.valid <= 1'b0;
      second_reg.data <= '0;
      second_reg.channel <= '0;
      second_reg.empty <= '0;

      third_reg.sop <= 1'b0;
      third_reg.eop <= 1'b0;
      third_reg.valid <= 1'b0;
      third_reg.data <= '0;
      third_reg.channel <= '0;
      third_reg.empty <= '0;
      
    end else begin


      if(from_classifier.ready==1) begin
        if(from_pcap_reader_to_classifier.valid) begin
            if(from_pcap_reader_to_classifier.sop) begin
                seq_numb <= 1;
            end else if (from_pcap_reader_to_classifier.eop) begin
                seq_numb <= 0;
            end else begin
                seq_numb <= seq_numb + 1;
            end
        end else begin 
                seq_numb <= 0;
        end
      end

      //first stage
      if (from_pcap_reader_to_classifier.valid && from_pcap_reader_to_classifier.sop) begin
            //entry <= {protocol, src_port, dst_port, src_ip_add, dst_ip_add};
            entry <= {from_pcap_reader_to_classifier.data[327:320], from_pcap_reader_to_classifier.data[239:224], from_pcap_reader_to_classifier.data[223:208], from_pcap_reader_to_classifier.data[303:272], from_pcap_reader_to_classifier.data[271:240]};
      end

      first_reg.sop <= from_pcap_reader_to_classifier.sop;
      first_reg.eop <= from_pcap_reader_to_classifier.eop;
      first_reg.valid <= from_pcap_reader_to_classifier.valid;
      first_reg.data <= from_pcap_reader_to_classifier.data;
      first_reg.channel[4:0] <= seq_numb;
      first_reg.empty <= from_pcap_reader_to_classifier.empty;
      from_pcap_reader_to_classifier.ready <= first_reg.ready;

      //second stage

      if(first_reg.valid && first_reg.sop) begin
           foreach (mat_table[i]) begin
                        //if (entry & mask) == (data & mask)
                        if ((entry & {mat_table[i][199:192], mat_table[i][175:160], mat_table[i][143:128], mat_table[i][95:64], mat_table[i][31:0]}) == ({mat_table[i][207:200], mat_table[i][191:176], mat_table[i][159:144], mat_table[i][127:96], mat_table[i][63:32]} & {mat_table[i][199:192], mat_table[i][175:160], mat_table[i][143:128], mat_table[i][95:64], mat_table[i][31:0]})) begin
                               routing_tag_extracted <= mat_table[i][210:208];  // kada pronadje podudaranje, uzme zadnja 2 bita iz drugog bajta (Routing Tag-a) cijelog zapisa
                               flow_id_extracted <= 5'(i);                      // pretvori pronadjeni indeks iz tabele u binarni zapis (5 bita) 
                               break;        
                        end else begin
                               routing_tag_extracted <= 3'(4);  // ako nema zapisa u tabeli, proslijedi ga na izlaz 4 (4 - CPU)
                               flow_id_extracted <= '1;         //privremeno 
                        end
           end
       end

      second_reg.sop <= first_reg.sop;
      second_reg.eop <= first_reg.eop;
      second_reg.valid <= first_reg.valid;
      second_reg.data <= first_reg.data;
      second_reg.channel <= first_reg.channel;
      second_reg.empty <= first_reg.empty;
      first_reg.ready <= second_reg.ready;

      //third stage

      if(second_reg.valid && second_reg.sop) begin
         from_classifier.channel[12:10] <= routing_tag_extracted;
         from_classifier.channel[9:5] <= flow_id_extracted;
      end
      from_classifier.channel[4:0] <= second_reg.channel[4:0];   //zadrzi isti sekvencni broj

      //output

      from_classifier.sop <= second_reg.sop;
      from_classifier.eop <= second_reg.eop;
      from_classifier.valid <= second_reg.valid;
      from_classifier.data <= second_reg.data;
      from_classifier.empty <= second_reg.empty;
      second_reg.ready <= from_classifier.ready;
      
    end
end
   
endmodule



