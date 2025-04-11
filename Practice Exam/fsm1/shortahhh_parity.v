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
valid = (state == stop_even) ? 1'b1 : 1'b0;
error = (state == stop_odd) ? 1'b1 : 1'b0;
case(state)
    break: next_state = signal ? idle : break;
    idle: next_state = signal ? idle : start;
    start: next_state = signal ? bit1_odd : bit1_even;
    bit1_even:  next_state = signal ? bit2_odd :  bit2_even;
    bit1_odd:  next_state = signal ? bit2_even :  bit2_odd;
    bit2_even:  next_state = signal ?  bit3_odd : bit3_even ;
    bit2_odd: next_state = signal ? bit3_even :  bit3_odd;
    bit3_even:  next_state = signal ? bit4_odd :  bit4_even;
    bit3_odd:  next_state = signal ? bit4_even :  bit4_odd;
    bit4_even: next_state = signal ? parity_odd :  parity_even;
    bit4_odd:  next_state = signal ? parity_even :  parity_odd;
    parity_even: next_state = signal ? stop_even :  break;
    parity_odd: next_state = signal ? stop_odd :  break;
    stop_even: next_state = signal ? idle : start;
    stop_odd: next_state = signal ? idle : start;
        default:begin end
    endcase
end

endmodule
