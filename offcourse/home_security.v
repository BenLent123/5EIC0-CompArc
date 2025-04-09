// called UUT.V in offcourse!

/*
 *  OffCourse::Verilog
 *		- Home Security UUT
 *
 *  Copyright: Sybe
 *  License: GPLv3 or later
 */

module UUT (
    input reset,
    input clk,
    input [1:0] command,
    input [3:0] digit,
    input input_digit,
    input trigger,
    output reg alarm,
    output reg armed
	);

parameter DISARMED = 0,
ARM0 = 1,
ARM1 = 2,
ARM2 = 3,
ARMED = 4,
DISARM0 = 5,
DISARM1= 6,
DISARM2 = 7,
ALARM = 8,
ARM1B = 9,
ARM2B = 10,
DISARM1B = 11,
DISARM2B  = 12;

reg [3:0] state, next_state;

always @(posedge clk)begin
    if(reset) begin
    state <= DISARMED;
    end
    else begin
    state <= next_state;
    end
end

always @(*)begin
next_state = state;
alarm = alarm;
armed = armed;
    case(state)
    DISARMED: begin
    if(command == 2'b01) next_state = ARM0; else next_state = DISARMED;
    end
    ARM0: begin
    if(input_digit == 1 && digit == 1) next_state = ARM1;
    else if(input_digit == 1 && digit != 1) next_state = ARM1B;
    else next_state = ARM0;
    end
    ARM1: begin
    if(input_digit == 1 && digit == 2) next_state = ARM2;
    else if(input_digit == 1 && digit != 2) next_state = ARM2B;
    else next_state = ARM1;
    end
    ARM1B: begin
    if(input_digit == 1) next_state = ARM2B;
    else next_state = ARM1B;
    end
    ARM2B: begin
    if(input_digit == 1) next_state = DISARMED;
    else next_state = ARM2B;
    end
    ARM2: begin
    if(input_digit == 1 && digit == 4) next_state = ARMED;
    else if(input_digit == 1 && digit != 4) next_state = DISARMED;
    else next_state = ARM2;
    end
    ARMED: begin
    if(trigger == 1) next_state = ALARM;
    else if(trigger == 0 && command == 2) next_state = DISARM0;
    else next_state = ARMED;
    end
    ALARM: begin
    if(command == 2) next_state = DISARM0;
    else next_state = ALARM;
    end
    DISARM0: begin
    if(input_digit == 1 && digit == 1) next_state = DISARM1;
    else if(input_digit == 1 && digit != 1) next_state = DISARM1B;
    else next_state = DISARM0;
    end
    DISARM1: begin
    if(input_digit == 1 && digit == 2) next_state = DISARM2;
    else if(input_digit == 1 && digit != 2) next_state = DISARM2B;
    else next_state = DISARM1;
    end
    DISARM1B: begin
    if(input_digit == 1) next_state = DISARM2B;
    else next_state = DISARM1B;
    end
    DISARM2B: begin
    if(input_digit == 1) next_state =ARMED;
    else next_state = DISARM2B;
    end
    DISARM2: begin
    if(input_digit == 1 && digit != 4) next_state = ARMED;
    else if(input_digit == 1 && digit == 4) next_state = DISARMED;
    end
    default: begin end
    endcase
end

always @(*)begin
 if(state != DISARMED) begin
    if(state == ARMED) begin
        armed = 1;
    end
 end else begin
    armed = 0;
 end
 
end

always @(*)begin
 if(state == ALARM) begin
    alarm = 1;
 end else begin
    alarm = 0;
 end
end


endmodule
