`timescale 1ps/1ps
module counter (
input clk,
input resetn,
input enable,
output reg [31:0] count
);

    wire [31:0] next_count;
    wire [31:0] incremented_value;
    wire [31:0] mux_out;

    assign incremented_value = 32'd1;

    adder A1 (
        .a(count), 
        .b(incremented_value), 
        .c(next_count) // next_count = count + 1
    );

   
    assign mux_out = (enable) ? next_count : count; 

    always @(posedge clk) begin
        if (!resetn)
            count <= 32'd0; 
        else
            count <= mux_out; 
    end

endmodule
