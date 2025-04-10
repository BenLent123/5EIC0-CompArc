module UUT (
    input a,
    input b,
    input s,
    output y
);
   assign y = s ? (b ? a : ~a) : (a ? b : ~b);
endmodule
