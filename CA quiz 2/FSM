module seq0110(
input in,
input clk,
input reset,
output out
);

   parameter s1  = 3'b000,
              s0  = 3'b001,
              s01 = 3'b010,
              s011 = 3'b011,
              s0110 = 3'b100;

    reg [2:0] state, next_state;


    always @(posedge clk) begin
        if (reset) 
            state <= s1;
        else 
            state <= next_state;
    end
    
    
    
     always @(*) begin
    next_state = state;
        case (state)
            s1: begin
                if (in == 1'b0) next_state = s0; 
                else next_state = s1; 
            end
            s0: begin
                if (in == 1'b1) next_state = s01; 
                else next_state = s0;
            end
            s01: begin
                if (in == 1'b1) next_state = s011; 
                else if (in == 1'b0) next_state = s0;
            end
            s011: begin
                if (in == 1'b0) next_state = s0110; 
                else if (in == 1'b1) next_state = s1;
            end
            s0110: begin
                if (in == 1'b1) next_state = s01; 
                else if (in == 1'b0) next_state = s0; 
            end
            default: begin end
        endcase
    end
  
assign out = (state == s0110) ? 1'b1 : 1'b0;

endmodule
