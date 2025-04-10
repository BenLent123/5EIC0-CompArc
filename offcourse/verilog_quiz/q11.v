module UUT (
    input in,
    input clk,
    input [4:0] pattern,
    output detected
);
reg num1,num2,num3,num4,num5;
always @(posedge clk)begin
    num1 <= in;
    num2 <= num1;
    num3 <= num2;
    num4 <= num3;
    num5 <= num4;
end

assign detected = (pattern == {num5,num4,num3,num2,num1}) ? 1:0;

endmodule
