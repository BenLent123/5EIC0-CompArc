`timescale 1ps/1ps
module debounce #(parameter CYCLES = 20)(
    input wire clk,        
    input wire resetn,     
    input wire in,        
    output reg out         
);
parameter INIT_CYCLES = CYCLES-1;  
reg [4:0] count;
reg prev_state;

always @(posedge clk) begin
    if(!resetn) begin
        count <= INIT_CYCLES;
        prev_state <= 0;
        out <= 0;    
    end else begin
        if(in != prev_state)begin
            count <= count-1;
        end else begin
            count <= INIT_CYCLES;
        end
        out <= 0;
        if(count == 0) begin
            out <= ~prev_state;
            prev_state <= ~prev_state;
            count <= INIT_CYCLES;
        end 
    end
end
endmodule
