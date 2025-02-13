`timescale 1ps/1ps

module counter_tb;

//< DECLARE REG TYPES FOR clk, resetn and enable >
//< DECLARE WIRE TYPE FOR count >
  reg clk;
  reg resetn;
  reg enable;
  wire [31:0] count;

  
  
    always #10 clk = ~clk; // Toggle clock every 10 time units
 
 counter C1 (
    .clk(clk),
    .resetn(resetn),
    .enable(enable),
    .count(count)
 );

//< INSTANTIATE counter ASSIGN IO USING REGS/WIRES DECLARED ABOVE >

initial begin
    $dumpfile("trace.vcd");
    $dumpvars(0, counter_tb);

     clk = 0;
    resetn = 0;
    enable = 0;

    repeat (2) @(negedge clk);
   // < DRIVE resetn TO PUT THE MODULE INTO RESET >
  //  < DRIVE enable TO DISABLE THE COUNTER >
    resetn = 0;
    enable = 0;
    repeat (2) @(negedge clk);
    $monitor ("%b %b %b %h", clk, resetn, enable, count);
   // < TAKE THE MODULE OUT OF RESET >
   resetn = 1;
    repeat (5) @(negedge clk);
    enable = 1;
    repeat (5) @(negedge clk);
    enable = 0;
    repeat (2) @(negedge clk);
    enable = 1;
    repeat (5) @(negedge clk);
    if (count != 32'ha) $finish;
    //< PUT THE MODULE INTO RESET >
    resetn = 0;
    repeat (2) @(negedge clk);
   // < TAKE THE MODULE OUT OF RESET >
   resetn = 1;
    repeat (5) @(negedge clk);

    $finish;
end

endmodule
