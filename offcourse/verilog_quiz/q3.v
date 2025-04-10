module UUT (
    input [1:0] a,
    input b,
    output [2:0] y
);

assign y = {a,b};

  
endmodule
