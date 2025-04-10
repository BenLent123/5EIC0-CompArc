/*
 *  offcourse::verilog
 *		- ice-cream-mealy UUT
 *
 *  copyright: Aleksandrs
 *  license: GPLv3 or later
 */
 module UUT (
  output wire [1:0] state,
  input reset,
  input clk,
  input reg [1:0] coins,
  output reg [1:0] ice_cream_balls
);

reg [1:0] state_r, next_state_r;
reg [1:0] ice_prev;
assign state = state_r;

parameter   CS0 = 0,
  CS1 = 1,
  CS2 = 2,
  CS3 = 3;

parameter c0 = 0,
    c1 = 1,
    c2 = 2;
    
    always @(posedge clk) begin
        if (reset) begin
            state_r <= CS0;
            ice_prev <=0;
            end
        else begin
            state_r <= next_state_r;
            ice_prev <= ice_cream_balls;
            end
    end

  
    always @(*) begin
    next_state_r = state_r;
    ice_cream_balls = ice_prev;
        case (state_r)
        
            CS0:  begin
                 ice_cream_balls = 0;
                case (coins)
                    c1: begin next_state_r = CS1; end
                    c2: begin next_state_r = CS2;  end
                 endcase
                 end
                 
            CS1: case (coins)
                    c1: begin next_state_r = CS2;  end
                    c2: begin next_state_r = CS3; ice_cream_balls = 2; end
                 endcase
                 
            CS2: case (coins)
                    c0: begin next_state_r = CS0; ice_cream_balls = 1; end
                    c1: begin next_state_r = CS3; ice_cream_balls = 2; end
                    c2: begin next_state_r = CS1; ice_cream_balls =2; end
                 endcase
                 
             CS3: case (coins)
                    c0: begin next_state_r = CS0; ice_cream_balls = 0; end
                    c1: begin next_state_r = CS1; ice_cream_balls = 0; end
                    c2: begin next_state_r = CS2; ice_cream_balls = 0; end
                    
                 endcase
        endcase
        
      
    end



endmodule
