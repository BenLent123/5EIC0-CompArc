module timer_fsm(
input reset,
input enable,
input clk,
input complete,
output reg trigger
);

parameter idle=1,counting=2,done=3,paused=4;
reg [2:0] state,next_state;

always @(posedge clk)begin
if(reset)begin
state <= idle;
end 
else begin
state<= next_state;
end
end

always @(*)begin
next_state = state;
case(state)
    idle: begin
        if(enable == 1 && complete == 0) next_state = counting;
        else if(enable == 0 && complete == 0) next_state = paused;
    end
    counting: begin
        if(enable == 1 && complete == 0) next_state = paused;
        else if(enable == 0 && complete == 1) next_state = idle;
        else if(enable == 1 && complete == 1) next_state = done;
    end
    done: begin
        if(enable == 1 && complete == 0) next_state = counting;
        else if(enable == 0 && complete == 0) next_state = paused;
        else if(complete == 1) next_state = idle;
    end
    paused: begin
        if(enable == 1 && complete == 0) next_state = counting;
        else if(enable == 0 && complete == 1) next_state = idle;
        else if(enable == 1 && complete == 1) next_state = done;
    end
    default:begin end
    endcase
end

always @(*)begin
    trigger = (state == done) ? 1'b1 : 1'b0;
end

endmodule
