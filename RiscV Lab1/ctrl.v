// Copyright (c) 2023 Technische Universiteit Eindhoven

`timescale 1ps/1ps

module ctrl (
    input [31:0] instruction,

    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,

    output reg [1:0] ALUOp,

    output reg Jump,

    output reg [3:0] ALUCtl,
    output reg ALUSrc1,
    output reg ALUSrc2,

    output reg Branch,
    output reg MemRead,
    output reg MemWrite,
    output reg [2:0] MemSize,

    output reg RegWrite,
    output reg MemToReg,

    output reg valid
);

wire [6:0] opcode_value = instruction[6:0];
wire [4:0] rs1_value = instruction[19:15];
wire [4:0] rs2_value = instruction[24:20];
wire [4:0] rd_value = instruction[11:7];
wire [2:0] funct3_value = instruction[14:12];
wire [6:0] funct7_value = instruction[31:25];
wire [3:0] ALUCtl_value = {funct7_value[5], funct3_value};

always @(*) begin
    rs1 = 5'd0;
    rs2 = 5'd0;
    rd = 5'd0;
    Jump = 1'b0;
    ALUCtl = 4'd0;
    ALUSrc1 = 1'b0;
    ALUSrc2 = 1'b0;
    Branch = 1'b0;
    MemRead = 1'b0;
    MemWrite = 1'b0;
    RegWrite =1'b0;
    MemToReg = 1'b0;
    ALUOp = 2'b0;
    MemSize = 3'b0;
    valid = 1'b0;

    case (opcode_value)
    7'd55: begin // 0110111 LUI
        valid = 1'b1;
        rd = rd_value;
        RegWrite = 1'b1;
        ALUSrc2 = 1'b1;
    end
     7'd11: begin //  Custom CLIP Instruction
        valid = 1'b1;         // Mark the instruction as valid
        rs1 = rs1_value;      // Source register
        rs2 = rs2_value;      // source register 2
        rd = rd_value;        // Destination register
        RegWrite = 1'b1;      // This instruction writes back to a register
        ALUOp = 2'b10;        // ALUOp should be set to match the ALU control logic
        ALUCtl  = 4'd15;     // Custom ALU control signal for CLIP
        ALUSrc1 = 1'b0;       // Use register rs1 as source
        ALUSrc2 = 1'b0;       // No immediate value needed
    end

    7'd23: begin // 0010111 AUIPC
        valid = 1'b1;
        rd = rd_value;
        RegWrite = 1'b1;
        ALUSrc1 = 1'b1;
        ALUSrc2 = 1'b1;
    end
    7'd111: begin // 1101111 JAL
        valid = 1'b1;
        rd = rd_value;
        Jump = 1'b1;
        RegWrite = 1'b1;
        ALUSrc1 = 1'b1;
    end
    7'd103: begin // 1100111 JALR
        valid = ~|funct3_value;
        rs1 = rs1_value;
        rd = rd_value;
        Jump = 1'b1;
        RegWrite = 1'b1;
    end
    7'd99: begin // 1100011 BEQ, BNE, BLT, BGE, BLTU, BGEU
        rs1 = rs1_value;
        rs2 = rs2_value;
        Branch = 1'b1;
        ALUCtl = 4'd8;
        ALUOp = 2'b01;
        RegWrite = 1'b1;
        case (funct3_value)
            3'd0, // BEQ
            3'd1, // BNE
            3'd4, // BLT
            3'd5, // BGE
            3'd6, // BLTU
            3'd7: // BGEU
                valid = 1'b1;
            default: ;
        endcase
    end
    7'd3: begin // 0000011 LB, LH, LW, LBU, LHU
        rs1 = rs1_value;
        rd = rd_value;
        ALUSrc2 = 1'b1;
        MemRead = 1'b1;
        RegWrite = 1'b1;
        MemToReg = 1'b1;
        MemSize = funct3_value;
        case (funct3_value)
            3'd0, // LB
            3'd1, // LH
            3'd2, // LW
            3'd4, // LBU
            3'd5: // LHU
                valid = 1'b1;
            default: ;
        endcase
    end
    7'd35: begin // 0100011 SB, SH, SW
        rs1 = rs1_value;
        rs2 = rs2_value;
        ALUSrc2 = 1'b1;
        MemWrite = 1'b1;
        MemSize = funct3_value;
        case (funct3_value)
            3'd0, // SB
            3'd1, // SH
            3'd2: // SW
                valid = 1'b1;
            default: ;
        endcase
    end
    7'd19: begin // 0010011 ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        rs1 = rs1_value;
        rd = rd_value;
        if (funct3_value[1:0] == 2'b1) begin
            ALUCtl = ALUCtl_value;
        end else begin
            ALUCtl = {1'b0, funct3_value};
        end
        RegWrite = 1'b1;
        ALUSrc2 = 1'b1;
        ALUOp = 2'b11;
        case (funct3_value)
            3'd0, // ADDI
            3'd2, // SLTI
            3'd3, // SLTIU
            3'd4, // XORI
            3'd6, // ORI
            3'd7: // ANDI
                valid = 1'b1;
            3'd1: // SLLI
                valid = ~|funct7_value;
            3'd5:
                case (funct7_value)
                    7'd0,  // SRLI
                    7'd32: // SRAI
                        valid = 1'b1; 
                    default: ;
                endcase
            default: ;
        endcase
    end
    7'd51: begin // 0110011 ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
        rs1 = rs1_value;
        rs2 = rs2_value;
        rd = rd_value;
        ALUCtl = ALUCtl_value;
        RegWrite = 1'b1;
        ALUOp = 2'b10;
        case (funct7_value)
            7'd0: valid = 1'b1;
            7'd32:
                case (funct3_value)
                    3'd0, // SUB
                    3'd5: // SRA
                        valid = 1'b1;
                    default: ;
                endcase
            default: ;
        endcase
    end
    7'd15: begin // 0001111 FENCE
        valid = ~|funct3_value;
        //rs1 = rs1_value;
        //rd = rd_value;
    end
    default: ;
    endcase
end

endmodule
