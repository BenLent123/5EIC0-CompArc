`timescale 1ps/1ps
module Moore(
    input clk,
    input reset,
    input [1:0] coins,
    output reg coffee
);
   
    parameter cent0  = 3'b000,
              cent5  = 3'b001,
              cent10 = 3'b010,
              cent5c = 3'b011,
              cent0c = 3'b100;

    reg [2:0] state, next_state;


    always @(posedge clk) begin
        if (reset) 
            state <= cent0;
        else 
            state <= next_state;
    end

 
    always @(*) begin
    next_state = state;
        case (state)
            cent0: begin
                if (coins == 2'b01) next_state = cent10; 
                else if (coins == 2'b10) next_state = cent5;
            end
            cent5: begin
                if (coins == 2'b10) next_state = cent10; 
                else if (coins == 2'b01) next_state = cent0c;
            end
            cent10: begin
                if (coins == 2'b01) next_state = cent5c; 
                else if (coins == 2'b10) next_state = cent0c;
            end
            cent5c: begin
                if (coins == 2'b10) next_state = cent10; 
                else if (coins == 2'b01) next_state = cent0c;
                else if (coins == 2'b00) next_state = cent5;
            end
            cent0c: begin
                if (coins == 2'b00) next_state = cent0; 
                else if (coins == 2'b01) next_state = cent10; 
                else if (coins == 2'b10) next_state = cent5;
            end
            default: begin end
        endcase
    end

   assign coffee = (state == cent5c || state == cent0c) ? 1'b1 : 1'b0;
  

endmodule
