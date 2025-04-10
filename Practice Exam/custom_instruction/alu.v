// Copyright (c) 2023 Technische Universiteit Eindhoven

`timescale 1ps/1ps

module alu (
        input [4:0] ALUctl,
        input [31:0] A,
        input [31:0] B,
        output Zero,
        output reg [31:0] ALUOut
    );

    always @(*) begin
        case (ALUctl[3:0])
            4'd0: ALUOut = A + B;
            4'd1,4'd9: ALUOut = A << B[4:0];
            4'd2: ALUOut = {31'd0, $signed(A) < $signed(B)};
            4'd3: ALUOut = {31'd0, A < B};
            4'd4: ALUOut = A ^ B;
            4'd5: ALUOut = A >> B[4:0];
            4'd6: ALUOut = A | B;
            4'd7: ALUOut = A & B;
            4'd8: ALUOut = A - B;
            4'd13: ALUOut = $signed(A) >>> B[4:0];
            4'd15: ALUOut = ($signed(A)  < 0) ? 0 : (($signed(A)  > 127) ? 127 : A);
            default: ALUOut = 32'd0;
        endcase
    end

    wire eq_zero = (ALUOut == 32'd0);

    assign Zero = (ALUctl[4] ? ~eq_zero : eq_zero);

endmodule
