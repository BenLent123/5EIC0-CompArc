module UUT (
    input a,
    input b,
    input clk,
    output y
);
 reg areg;
 reg breg;
 
always @(posedge clk)begin
 areg <= ((a&b) ? 0 : a);
 breg <= ((a&b) ? 0 : b); 
end

assign y = ~(areg^breg);

endmodule
