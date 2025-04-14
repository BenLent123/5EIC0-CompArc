module uart_retrans_fsm(
input reset,
input clk,
input frame_valid,
input ack,
input timeout,
input parity_error,
output reg valid,
output reg request_resend,
output reg error
);

reg p_valid,p_error,p_request_resend;

parameter 
    wwait =  0,
    wwait_resend = 1,
    eerror = 2,
    rrelease = 3;

reg [1:0] state, next_state;


always@(posedge clk)begin
    if (reset ) begin
        state<=0;
        p_valid<=0;
        p_error<=0;
        p_request_resend <=0;
    end 
    else begin
        p_request_resend<=request_resend;
        p_valid<=valid;
        p_error<=error;
        state<=next_state;
    end
end


always@(*)begin

    error = p_error;
    request_resend = p_request_resend;
    valid = p_valid;
    next_state = state;

    case(state)
        wwait:  
            if (parity_error == 1 )begin 
                next_state = wwait_resend;
                request_resend = 1;
            end
            else if (parity_error == 0 && frame_valid == 1) begin 
                next_state = rrelease; valid = 1;
            end
            
    wwait_resend: 
            if(timeout == 0 && frame_valid == 0) begin
                    next_state = wwait_resend;
                    request_resend =0;
            end 
            else if (timeout == 1 && frame_valid == 0)begin
                    next_state = eerror; 
                    error = 1;
            end 
            else if (frame_valid == 1 )begin
                    next_state = rrelease;
                    request_resend = 0;
                    valid = 1;
            end
    eerror:if (ack)begin
            next_state = wwait;  
            error = 0;
            end
    rrelease:
            if (ack)begin
            valid = 0;
            next_state = wwait; end
    default:;
    
    endcase
end



endmodule
