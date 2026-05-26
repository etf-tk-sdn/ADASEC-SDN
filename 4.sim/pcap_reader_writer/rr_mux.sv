//Adjusted version of multiplexer from wireguard-fpga project 

module rr_mux (
   input  logic  pause,
   output logic  is_idle,

   avalon_if.in from_cpu,
   avalon_if.in from_eth_1,
   avalon_if.in from_eth_2,
   avalon_if.in from_eth_3,
   avalon_if.in from_eth_4,
   avalon_if.out to_sw
);

   typedef enum logic [3:0] {
      IDLE,
      R0, S0,
      R1, S1,
      R2, S2,
      R3, S3,
      R4, S4
   } state_t;

   state_t state, next_state;

   avalon_if to_sw_sbuff(.clk(from_cpu.clk), .rst(from_cpu.rst));

// FSM registers
   always_ff @(posedge from_cpu.clk) begin
      if (from_cpu.rst) begin
         state <= IDLE;
      end else begin
         state <= next_state;
      end
   end

// FSM transition logic
   always_comb begin
      next_state = state;

      unique case (state)
         IDLE: begin
            if (!pause) next_state = R0;
         end

         R0: begin
            if (from_cpu.valid && from_cpu.sop && to_sw_sbuff.ready)        next_state = S0;
            else if (pause)                                                 next_state = IDLE;
            else if (!from_cpu.valid && to_sw_sbuff.ready)                  next_state = R1;
         end

         S0: begin
            if (from_cpu.eop && from_cpu.valid && to_sw_sbuff.ready) begin
               next_state = pause ? IDLE : R1;
            end
         end

         R1: begin
            if (from_eth_1.valid && from_eth_1.sop && to_sw_sbuff.ready)     next_state = S1;
            else if (pause)                                                  next_state = IDLE;
            else if (!from_eth_1.valid && to_sw_sbuff.ready)                 next_state = R2;
         end

         S1: begin
            if (from_eth_1.eop && from_eth_1.valid && to_sw_sbuff.ready) begin
               next_state = pause ? IDLE : R2;
            end
         end

         R2: begin
            if (from_eth_2.valid && from_eth_2.sop && to_sw_sbuff.ready)     next_state = S2;
            else if (pause)                                                  next_state = IDLE;
            else if (!from_eth_2.valid && to_sw_sbuff.ready)                 next_state = R3;
         end

         S2: begin
            if (from_eth_2.eop && from_eth_2.valid && to_sw_sbuff.ready) begin
               next_state = pause ? IDLE : R3;
            end
         end

         R3: begin
            if (from_eth_3.valid && from_eth_3.sop && to_sw_sbuff.ready)      next_state = S3;
            else if (pause)                                                   next_state = IDLE;
            else if (!from_eth_3.valid && to_sw_sbuff.ready)                  next_state = R4;
         end

         S3: begin
            if (from_eth_3.eop && from_eth_3.valid && to_sw_sbuff.ready) begin
               next_state = pause ? IDLE : R4;
            end
         end

         R4: begin
            if (from_eth_4.valid && to_sw_sbuff.ready)                        next_state = S4;
            else if (pause)                                                   next_state = IDLE;
            else if (!from_eth_4.valid && to_sw_sbuff.ready)                  next_state = R0;
         end

         S4: begin
            if (from_eth_4.eop && from_eth_4.valid && to_sw_sbuff.ready) begin
               next_state = pause ? IDLE : R0;
            end
         end

         default:
            next_state = state;
      endcase
   end

// Outputs logic
   always_comb begin
      // Default assignments
      is_idle = 1'b0;
      to_sw_sbuff.valid = 1'b0;
      to_sw_sbuff.data = '0;
      to_sw_sbuff.eop = 1'b0;
      to_sw_sbuff.sop = 1'b0;
      to_sw_sbuff.empty = '0;
      to_sw_sbuff.channel = '0;
      from_cpu.ready = 1'b0;
      from_eth_1.ready = 1'b0;
      from_eth_2.ready = 1'b0;
      from_eth_3.ready = 1'b0;
      from_eth_4.ready = 1'b0;

      unique case (state)
         IDLE: begin
            is_idle = !to_sw.valid;
         end

         R0, S0: begin
            is_idle = 1'b0;
            to_sw_sbuff.valid = from_cpu.valid;
            to_sw_sbuff.data = from_cpu.data;
            to_sw_sbuff.eop = from_cpu.eop;
            to_sw_sbuff.sop = from_cpu.sop;
	    to_sw_sbuff.empty = from_cpu.empty;
            to_sw_sbuff.channel = from_cpu.channel;
            from_cpu.ready = to_sw_sbuff.ready;
         end

         R1, S1: begin
            is_idle = 1'b0;
            to_sw_sbuff.valid = from_eth_1.valid;
            to_sw_sbuff.data = from_eth_1.data;
            to_sw_sbuff.eop = from_eth_1.eop;
            to_sw_sbuff.sop = from_eth_1.sop;
	    to_sw_sbuff.empty = from_eth_1.empty;
            to_sw_sbuff.channel = from_eth_1.channel;
            from_eth_1.ready = to_sw_sbuff.ready;
         end

         R2, S2: begin
            is_idle = 1'b0;
            to_sw_sbuff.valid = from_eth_2.valid;
            to_sw_sbuff.data = from_eth_2.data;
            to_sw_sbuff.eop = from_eth_2.eop;
            to_sw_sbuff.sop = from_eth_2.sop;
	    to_sw_sbuff.empty = from_eth_2.empty;
            to_sw_sbuff.channel = from_eth_2.channel;
            from_eth_2.ready = to_sw_sbuff.ready;
         end

         R3, S3: begin
            is_idle = 1'b0;
            to_sw_sbuff.valid = from_eth_3.valid;
            to_sw_sbuff.data = from_eth_3.data;
            to_sw_sbuff.eop = from_eth_3.eop;
            to_sw_sbuff.sop = from_eth_3.sop;
	    to_sw_sbuff.empty = from_eth_3.empty;
            to_sw_sbuff.channel = from_eth_3.channel;
            from_eth_3.ready = to_sw_sbuff.ready;
         end

         R4, S4: begin
            is_idle = 1'b0;
            to_sw_sbuff.valid = from_eth_4.valid;
            to_sw_sbuff.data = from_eth_4.data;
            to_sw_sbuff.eop = from_eth_4.eop;
            to_sw_sbuff.sop = from_eth_4.sop;
	    to_sw_sbuff.empty = from_eth_4.empty;
            to_sw_sbuff.channel = from_eth_4.channel;
            from_eth_4.ready = to_sw_sbuff.ready;
         end

         default:
            is_idle = !to_sw.valid;
      endcase
   end

// Skid buffers
   avalon_if_skid_buffer skid_buffer_to_sw (
      .inp(to_sw_sbuff),
      .outp(to_sw)
   );
endmodule