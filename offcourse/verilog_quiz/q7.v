module UUT(
    input reset,
    input clk,
    output [2:0] y
);

reg [2:0] val;

always @(posedge clk)begin
    if(reset)
        val <=0;
    else
        val <= val+1;
end

assign y[0] = val[1]  ^ val[0];
assign y[1] = val[1] ^ val[2];
assign y[2] = val[2];

endmodule
