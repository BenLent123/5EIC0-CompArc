module timer (
    input clk,
    input reset,
    input enable,
    input [4:0] value,
    input valid,
    output trigger,
    output reg [4:0] count
);
    wire complete;

    always @(posedge clk) begin
        if (reset)
            count <= 5'd0;
        else if (valid)
            count <= value;
        else if (enable && !complete)
            count <= count - 1;
        else
            count <= count;
            
    end
    
    assign complete = (count == 0) ? 1:0;
   
    // FSM instantiation
    timer_fsm timer_ins (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .complete(complete),
        .trigger(trigger)
    );

endmodule
