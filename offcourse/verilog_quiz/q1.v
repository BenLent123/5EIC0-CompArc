module	UUT (
    input [7:0] a,
    input reset,
    input clk,
    output reg [7:0] y
    );

      reg [7:0] a_reg;

    always @(posedge clk) begin
        if (reset) begin
            a_reg <= 0;
            y <= 0;
        end else begin
            a_reg <= a;
            y <= a_reg;
        end
    end

endmodule
