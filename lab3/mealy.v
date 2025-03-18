`timescale 1ps/1ps
module Mealy (
    input clk,
    input reset,
    input [1:0] coins,
    output reg coffee
);

  
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;
    
    reg [1:0] state, next_state;
    reg coffee_prev;
    


    always @(posedge clk) begin
        if (reset) begin
            state <= S0;
            coffee_prev <=0;
            end
        else begin
            state <= next_state;
            coffee_prev <= coffee;
            end
    end

  
    always @(*) begin
    next_state = state;
    coffee = coffee_prev;
        case (state)
            S0: case (coins)
                    2'b01: begin next_state = S2; coffee = 0; end
                    2'b10: begin next_state = S1; coffee = 0; end
                    2'b00: begin next_state = S0; coffee = 0; end
                    default: next_state = S0;
                 endcase
            S1: case (coins)
                    2'b01: begin next_state = S0; coffee = 1; end
                    2'b10: begin next_state = S2; coffee = 0; end
                    2'b00: begin next_state = S1; coffee = 0; end
                    default: next_state = S1;
                 endcase
            S2: case (coins)
                    2'b01: begin next_state = S1; coffee = 1; end
                    2'b10: begin next_state = S0; coffee = 1; end
                    2'b00: begin next_state = S2; coffee = 0; end
                    default: next_state = S2;
                 endcase
            default: next_state = S0;
        endcase
        
      
    end



endmodule
