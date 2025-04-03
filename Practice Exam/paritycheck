
module uart_parity_even(
input reset,
input clk,
input signal,
output reg valid,
output reg error
);

reg [3:0] state,next_state;
parameter break = 1,idle=2,start=3,bit1_even=4,bit1_odd=5,bit2_even=6,bit2_odd=7,bit3_even=8,bit3_odd=9,bit4_even=10,bit4_odd=11,parity_odd=12,parity_even=13,stop_odd=14,stop_even=15;

always @(posedge clk)begin
    if(reset) begin
    state <= break;
    end else
    state <= next_state;
    end
    
always @(*)begin
next_state = state;
case(state)
    break:begin
        if(signal==1) next_state = idle;
        else if(signal==0) next_state = break;
        end
    idle:begin
        if(signal==0) next_state = start;
        else if(signal==1) next_state = idle;
        end
    start:begin
        if(signal==0) next_state = bit1_even;
        else if(signal==1) next_state = bit1_odd;
        end
    bit1_even:begin
        if(signal==0) next_state = bit2_even;
        else if(signal==1) next_state = bit2_odd;
        end
    bit1_odd:begin
        if(signal==0) next_state = bit2_odd;
        else if(signal==1) next_state = bit2_even;
        end
    bit2_even:begin
        if(signal==0) next_state = bit3_even ;
        else if(signal==1) next_state = bit3_odd;
        end
    bit2_odd:begin
        if(signal==0) next_state = bit3_odd;
        else if(signal==1) next_state = bit3_even;
        end
    bit3_even:begin
        if(signal==0) next_state = bit4_even;
        else if(signal==1) next_state = bit4_odd;
        end
    bit3_odd:begin
        if(signal==0) next_state = bit4_odd;
        else if(signal==1) next_state = bit4_even;
        end
    bit4_even:begin
        if(signal==0) next_state = parity_even;
        else if(signal==1) next_state = parity_odd;
        end
    bit4_odd:begin
        if(signal==0) next_state = parity_odd;
        else if(signal==1) next_state = parity_even;
        end
    parity_even:begin
        if(signal==0) next_state = break;
        else if(signal==1) next_state = stop_even;
        end
    parity_odd:begin
        if(signal==0) next_state = break;
        else if(signal==1) next_state = stop_odd;
        end
    stop_even:begin
        if(signal==0) next_state = start;
        else if(signal==1) next_state = idle;
        end
    stop_odd:begin
        if(signal==0) next_state = start;
        else if(signal==1) next_state = idle;
        end
        default:begin end
    endcase
end

always @(*)begin
    valid = (state == stop_even) ? 1'b1 : 1'b0;
    error = (state == stop_odd) ? 1'b1 : 1'b0;
end

endmodule
