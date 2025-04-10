/*
 *  OffCourse::Verilog
 *		- Counter UUT
 *
 *  Copyright: Sybe
 *  License: GPLv3 or later
 */

module UUT (
input clk,
input enable,
input reset,
output reg [15:0] count
);


always @(posedge clk) begin
    if(reset) begin
        count <= 0;
    end
    else if (enable && count < 6'h2a) begin
        count <= count + 1;
    end
end


endmodule
