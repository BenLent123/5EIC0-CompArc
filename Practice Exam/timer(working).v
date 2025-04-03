module timer (
    input clk,
    input reset,
    input enable,
    input [4:0] value,
    input valid,
    output trigger,
    output [4:0] count
);

    reg [4:0] count_reg;
    reg [4:0] next_count;

    wire complete;
    assign complete = (count_reg != 5'd0) ? 1:0;

    // Combinational logic for next count
    always @(*) begin
        if (valid)
            next_count = value;
        else if (enable && valid)
            next_count = count_reg - 5'd1;
        else
            next_count = count_reg;
    end

    // Count register
    always @(posedge clk) begin
        if (reset)
            count_reg <= 5'd0;
        else
            count_reg <= next_count;
    end

    assign count = count_reg;

    // FSM instantiation
    timer_fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .complete(complete),
        .trigger(trigger)
    );

endmodule
