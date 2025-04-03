module timer_fsm (
input clk,
input reset,
input enable,
input complete,
output trigger
);

reg [1:0] curr_state;
reg [1:0] next_state;

parameter idle = 0;
parameter counting = 1;
parameter done = 2;
parameter paused = 3;

always@(posedge clk)begin
    if (reset) 
    curr_state <=0;
    else
    curr_state<=next_state;
end


always@(*)begin
    next_state = curr_state;
    case(curr_state)
    idle: if (enable ==1 && complete == 0) next_state = counting; 
            else if (enable == 0 && complete == 0)
                next_state = paused;
                
    counting:if (enable ==0 && complete == 1) next_state = idle; 
            else if (enable == 1 && complete == 1)
                next_state = done;
            else if (enable == 0 && complete == 0)
                next_state = paused;
                
    done: if (enable ==0 && complete == 0) next_state = paused; 
            else if (enable == 1 && complete == 0)
                next_state = counting;
            else if (complete == 1)
                next_state = idle;
    
    paused:if (enable ==1 && complete == 0) next_state = counting; 
            else if (enable == 1 && complete == 1)
                next_state = done;
            else if (enable == 0 && complete == 1)
                next_state = idle;
    
    default:;
    endcase
end

assign trigger = (curr_state == done)?1:0;

endmodule
