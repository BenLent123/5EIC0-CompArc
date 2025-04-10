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
    wwait =  3'b000,
    wwait_resend1 = 3'b001,
    wwait_resend2 = 3'b010,
    eerror = 3'b100,
    rrelease = 3'b011;

reg [2:0] curr_state;
reg [2:0] next_state;

always@(posedge clk)begin
    if (reset ) begin
        curr_state<=0;
        curr_valid<=0;
        curr_error<=0;
        curr_request_resend <=0;
        end else begin
        curr_request_resend<=next_request_resend;
        curr_valid<=next_valid;
        curr_error<=next_error;
        curr_state<=next_state; end
end


always@(*)begin

    next_error = curr_error;
    next_request_resend = curr_request_resend;
    next_valid = curr_valid;
    next_state = curr_state;

    case(curr_state)
    
    wwait:  if (!parity_error&& frame_valid)begin
                
                next_state = rrelease;
                next_valid = 1;
            
            end else if (parity_error) begin 
            
                next_state = wwait_resend1; next_request_resend = 1;
            
            end
            
    wwait_resend1: if (!timeout && !frame_valid) begin
                    
                    next_state = wwait_resend1;
                    next_request_resend =0;
                    
                    end else if (timeout && !frame_valid)begin
                    
                    next_state = wwait_resend2; 
                    next_error = 1; //////////////debugger mistake
                    
                    end else if (frame_valid)begin
                    
                    next_state = rrelease;
                    next_request_resend = 0;
                    next_valid = 1;
                    
                    end
                    
    wwait_resend2: if (ack) begin
                    next_state = 0;
                    next_error = 0;
                    end    
                    
                    else if (!timeout && frame_valid) begin
                    
                    next_state = wwait_resend2; /////////////////// debugger mistake
                    next_request_resend = 0; /////////////// debugger mistake
                    
                    end else if (timeout && !frame_valid)begin
                    
                    next_state = wwait;next_error = 0; next_request_resend = 0;  //////////////changed state and error next
                    
                    end else if (frame_valid)begin
                    
                    next_state = rrelease;next_request_resend = 0;next_valid = 1;
                    
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
