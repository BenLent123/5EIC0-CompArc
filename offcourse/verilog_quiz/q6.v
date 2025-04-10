module UUT (
    input [3:0] a,
    output [1:0] y,
    output [1:0] z
);
  
  assign y[0] = a[1];
  assign y[1] = a[0];
  assign z[0] = a[3];
  assign z[1] = a[2];
endmodule
