// Copyright (c) 2023 Technische Universiteit Eindhoven

`timescale 1ps/1ps

module alu_ctrl (
        input  [3:0] ALUinst,
        input  [1:0] ALUOp,
        output reg [4:0] ALUctl
    );

    always @(*) begin
        ALUctl = 5'd0;

        case (ALUOp)
            2'b00: ALUctl = 5'd0;
            2'b01:
                case (ALUinst[2:0])
                    3'd0: ALUctl = {1'b0, 4'd8};
                    3'd1: ALUctl = {1'b1, 4'd8};
                    3'd4: ALUctl = {1'b1, 4'd2};
                    3'd5: ALUctl = {1'b0, 4'd2};
                    3'd6: ALUctl = {1'b1, 4'd3};
                    3'd7: ALUctl = {1'b0, 4'd3};
                    default: ;
                endcase
            2'b10: ALUctl = {1'b0, ALUinst};
            2'b11:
                if (ALUinst[1:0] != 2'b1) begin
                    ALUctl = {2'b0, ALUinst[2:0]};
                end else begin
                    ALUctl = {1'b0, ALUinst};
                end
        endcase
    end

endmodule
