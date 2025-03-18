`timescale 1ps/1ps
module adder (
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [31:0] c
);
   wire carry [32:0];
   assign carry[0] = 0; 
    // Least Significant Bit (LSB) using Half Adder
    half_adder HA3 (
        .a(a[0]), 
        .b(b[0]), 
        .s(c[0]), 
        .c(carry[1])
    );

    
    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin : full_adder_loop
            full_adder FA1 (
                .a(a[i]),
                .b(b[i]),
                .cin(carry[i]),  
                .s(c[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate
endmodule
