module uart_retrans_fsm(
input reset,
input clk,
input frame_valid,
input ack,
input timeout,
input parity_error,
output valid,
output request_resend,
output error
);

reg next_valid,curr_valid;
reg next_request_resend,curr_request_resend;
reg next_error,curr_error;

parameter 
    wwait =  0,
    wwait_resend = 1,
    eerror = 2,
    rrelease = 3;

reg [1:0] state;
reg [1:0] next_state;

always@(posedge clk)begin
    if (reset ) begin
        state<=0;
        curr_valid<=0;
        curr_error<=0;
        curr_request_resend <=0;
        end else begin
        curr_request_resend<=next_request_resend;
        curr_valid<=next_valid;
        curr_error<=next_error;
        state<=next_state; end
end


always@(*)begin

    next_error = curr_error;
    next_request_resend = curr_request_resend;
    next_valid = curr_valid;
    next_state = state;

    case(state)
    
    wwait:  if (parity_error == 1 )begin
                
                next_state = wwait_resend;
                next_request_resend = 1;
            end
             else if (parity_error == 0 && frame_valid == 1) begin 
            
                next_state = rrelease; next_valid = 1;
            
            end
            
    wwait_resend: if(timeout == 0 && frame_valid == 0) begin
                    
                    next_state = wwait_resend;
                    next_request_resend =0;
                    
                    end else if (timeout == 1 && frame_valid == 0)begin
                    
                    next_state = eerror; 
                    next_error = 1; //////////////debugger mistake
                    
                    end else if (frame_valid == 1 )begin
                    
                    next_state = rrelease;
                    next_request_resend = 0;
                    next_valid = 1;
                    
                    end
                    
    eerror:if (ack)begin
            
            next_state = wwait;  
            next_error = 0;
            
            end
    rrelease:
            if (ack)begin
            
            next_valid = 0;
            next_state = wwait; end
    default:;
    
    endcase
end

assign valid = next_valid;
assign request_resend = next_request_resend;
assign error = next_error;

endmodule
