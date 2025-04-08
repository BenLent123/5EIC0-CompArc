// THIS FILE IS CALLED UUT.V in offcours !!!!!!!!

/*
 *  OffCourse::Verilog
 *		- ice-cream-moore UUT
 *
 *  Copyright: Aleksandrs
 *  License: GPLv3 or later
 */

module UUT (
    output wire [7:0] state, // Connect this wire to your current state, so it can be checked
    input reset,
    input clk,
    input reg [1:0] coins,
    output reg [1:0] ice_cream_balls
);
parameter C0B0 = 0,
  C1B0 = 1,
  C2B0 = 2,
  C3B0 = 3,
  C0B1 = 4,
  C1B1 = 5,
  C0B2 = 6,
  C1B2 = 7,
  C2B2 = 8; 
reg [7:0] state_r, next_state;

assign state = state_r;

always @(posedge clk)begin
    if(reset) begin
    state_r <= C0B0;
    end
    else begin
    state_r <= next_state;
    end
end

always @(*)begin
next_state = state_r;
    case(state)
    C0B0:begin
    if(coins == 1) next_state = C1B0;
    else if(coins == 2) next_state = C2B0;
    else next_state = C0B0;
    end
    C2B0:begin
    if(coins == 1) next_state = C3B0;
    else if(coins == 2) next_state = C1B1;
    else if(!coins) next_state = C0B1;
    else next_state = C2B0;
    end
    C0B1:begin
    if(coins == 1) next_state = C1B0;
    else if(coins == 2) next_state = C2B0;
    else next_state = C0B1;
    end
    C1B0:begin
    if(coins == 1) next_state = C2B0;
    else if(coins == 2) next_state = C3B0;
    else next_state = C1B0;
    end
    C3B0:begin
    if(coins == 1) next_state = C1B2;
    else if(coins == 2) next_state = C2B2;
    else if(!coins) next_state = C0B2;
    else next_state = C3B0;
    end
    C0B2:begin
    if(coins == 1) next_state = C1B0;
    else if(coins == 2) next_state = C2B0;
    else next_state = C0B2;
    end
    C2B2:begin
    if(coins == 1) next_state = C3B0;
    else if(coins == 2) next_state = C1B1;
    else next_state = C2B2;
    end
    C1B2:begin
    if(coins == 1) next_state = C2B0;
    else if(coins == 2) next_state = C3B0;
    else next_state = C1B2;
    end
    C1B1:begin
    if(coins == 1) next_state = C2B0;
    else if(coins == 2) next_state = C3B0;
    else next_state = C1B1;
    end
    default:begin end
    endcase
    
end

always @(*)begin
  if (state_r == C0B1 || state_r == C1B1)
        ice_cream_balls = 1;
    else if (state_r == C0B2 || state_r == C2B2 || state_r == C1B2)
        ice_cream_balls = 2;
    else
        ice_cream_balls = 0;
end

endmodule
