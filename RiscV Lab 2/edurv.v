// Copyright (c) 2023 Technische Universiteit Eindhoven

`timescale 1ps/1ps

module edurv #(
    parameter START_PC = 32'h0000_0000
)(
    input clk,
    input resetn,

    output [31:0] mmio_address_i,
    output mmio_read_word_i,
    output [3:0] mmio_write_byte_i,
    output [31:0] mmio_write_data_i,

    input mmio_ready_i,
    input mmio_busy_wait_i,
    input [31:0] mmio_read_data_i,

    output [31:0] mmio_address_d,
    output mmio_read_word_d,
    output [3:0] mmio_write_byte_d,
    output [31:0] mmio_write_data_d,

    input mmio_ready_d,
    input mmio_busy_wait_d,
    input [31:0] mmio_read_data_d

`ifdef RISCV_FORMAL
    ,`RVFI_OUTPUTS
`endif
);

reg [31:0] pc_r, pc_nxt;
wire [31:0] instruction;
wire [31:0] instruction_address;
wire [31:0] instruction_address_next;
wire instruction_ready; 
wire busy_wait;
wire [4:0] rs1, rs2, rd;
wire [31:0] Data1, Data2;
wire [4:0] ALUctl;
wire [31:0] ALUOut;
wire [31:0] immediate;
wire RegWrite;
wire ALUSrc1;
wire ALUSrc2;
wire Jump;
wire [31:0] pc_increment;
wire [31:0] pc_new_value;
`ifdef RISCV_FORMAL
wire [31:0] rd_wdata;
`endif
wire zero;
wire branch;
wire [1:0] ALUOp;
wire MemRead;
wire MemWrite;
wire MemToReg;
wire [2:0] MemSize;
wire mem_unaligned;
wire [31:0] read_data;
wire mem_ready;
wire mem_busy_wait;
wire valid;

reg [5:0] ID_EX_EX_nxt, ID_EX_EX_r; //adjust size
reg [6:0] ID_EX_M_nxt, ID_EX_M_r; 
reg [1:0] ID_EX_WB_nxt, ID_EX_WB_r;

reg ID_EX_valid_nxt, ID_EX_valid_r;
reg [31:0] ID_EX_insn_nxt, ID_EX_insn_r;
reg [31:0] ID_EX_pc_rdata_nxt, ID_EX_pc_rdata_r;
reg [31:0] ID_EX_pc_wdata_nxt, ID_EX_pc_wdata_r;
reg [31:0] ID_EX_rs1_rdata_nxt, ID_EX_rs1_rdata_r;
reg [31:0] ID_EX_rs2_rdata_nxt, ID_EX_rs2_rdata_r;
reg [4:0] ID_EX_rs1_addr_nxt, ID_EX_rs1_addr_r;
reg [4:0] ID_EX_rs2_addr_nxt, ID_EX_rs2_addr_r;
reg [4:0] ID_EX_rd_addr_nxt, ID_EX_rd_addr_r;
reg [31:0] ID_EX_imm_nxt, ID_EX_imm_r;
reg ID_EX_trap_nxt, ID_EX_trap_r;

reg [6:0] EX_MEM_M_nxt, EX_MEM_M_r;
reg [1:0] EX_MEM_WB_nxt, EX_MEM_WB_r;

reg EX_MEM_zero_nxt, EX_MEM_zero_r;
reg [31:0] EX_MEM_result_nxt, EX_MEM_result_r;
reg EX_MEM_valid_nxt, EX_MEM_valid_r;
reg [31:0] EX_MEM_insn_nxt, EX_MEM_insn_r;
reg [31:0] EX_MEM_pc_rdata_nxt, EX_MEM_pc_rdata_r;
reg [31:0] EX_MEM_pc_wdata_nxt, EX_MEM_pc_wdata_r;
reg [31:0] EX_MEM_rs1_rdata_nxt, EX_MEM_rs1_rdata_r;
reg [31:0] EX_MEM_rs2_rdata_nxt, EX_MEM_rs2_rdata_r;
reg [4:0] EX_MEM_rs1_addr_nxt, EX_MEM_rs1_addr_r;
reg [4:0] EX_MEM_rs2_addr_nxt, EX_MEM_rs2_addr_r;
reg [4:0] EX_MEM_rd_addr_nxt, EX_MEM_rd_addr_r;
reg [31:0] EX_MEM_pc_branch_nxt, EX_MEM_pc_branch_r;
reg EX_MEM_trap_nxt, EX_MEM_trap_r;

reg MEM_WB_valid_nxt, MEM_WB_valid_r;
reg [31:0] MEM_WB_insn_nxt, MEM_WB_insn_r;
reg [31:0] MEM_WB_pc_rdata_nxt, MEM_WB_pc_rdata_r;
reg [31:0] MEM_WB_pc_wdata_nxt, MEM_WB_pc_wdata_r;
reg [31:0] MEM_WB_rs1_rdata_nxt, MEM_WB_rs1_rdata_r;
reg [31:0] MEM_WB_rs2_rdata_nxt, MEM_WB_rs2_rdata_r;
reg [4:0] MEM_WB_rs1_addr_nxt, MEM_WB_rs1_addr_r;
reg [4:0] MEM_WB_rs2_addr_nxt, MEM_WB_rs2_addr_r;
reg [4:0] MEM_WB_rd_addr_nxt, MEM_WB_rd_addr_r;
reg [31:0] MEM_WB_rd_wdata_nxt, MEM_WB_rd_wdata_r;
reg MEM_WB_trap_nxt, MEM_WB_trap_r;

reg [1:0] MEM_WB_WB_nxt, MEM_WB_WB_r;

reg [31:0] MEM_WB_mem_addr_nxt, MEM_WB_mem_addr_r;
reg [3:0]  MEM_WB_mem_rmask_nxt, MEM_WB_mem_rmask_r;
reg [3:0]  MEM_WB_mem_wmask_nxt, MEM_WB_mem_wmask_r;
reg [31:0] MEM_WB_mem_rdata_nxt, MEM_WB_mem_rdata_r;
reg [31:0] MEM_WB_mem_wdata_nxt, MEM_WB_mem_wdata_r;

wire set_PC = ID_EX_EX_r[5] | (ID_EX_EX_r[4] & zero); // change
wire retire_valid = resetn & MEM_WB_valid_r & ~(MEM_WB_WB_r[0] & mem_busy_wait);

wire hazard;

always @(posedge clk) begin
    if (resetn) begin
        pc_r <= {pc_nxt[31:2], 2'b0};

        ID_EX_valid_r <= ID_EX_valid_nxt;
        ID_EX_insn_r <= ID_EX_insn_nxt;
        ID_EX_EX_r <= ID_EX_EX_nxt;
        ID_EX_M_r <= ID_EX_M_nxt;
        ID_EX_WB_r <= ID_EX_WB_nxt;
        ID_EX_rs1_addr_r <= ID_EX_rs1_addr_nxt;
        ID_EX_rs2_addr_r <= ID_EX_rs2_addr_nxt;
        ID_EX_rd_addr_r <= ID_EX_rd_addr_nxt;
        ID_EX_rs1_rdata_r <= ID_EX_rs1_rdata_nxt;
        ID_EX_rs2_rdata_r <= ID_EX_rs2_rdata_nxt;

        ID_EX_pc_rdata_r <= ID_EX_pc_rdata_nxt;
        ID_EX_pc_wdata_r <= ID_EX_pc_wdata_nxt;
        ID_EX_imm_r <= ID_EX_imm_nxt;
        ID_EX_trap_r <= ID_EX_trap_nxt;

        EX_MEM_M_r <= EX_MEM_M_nxt;
        EX_MEM_WB_r <= EX_MEM_WB_nxt;
        EX_MEM_zero_r <= EX_MEM_zero_nxt;
        EX_MEM_result_r <= EX_MEM_result_nxt;
        EX_MEM_valid_r <= EX_MEM_valid_nxt;
        EX_MEM_insn_r <= EX_MEM_insn_nxt;
        EX_MEM_pc_rdata_r <= EX_MEM_pc_rdata_nxt;
        EX_MEM_pc_wdata_r <= EX_MEM_pc_wdata_nxt;
        EX_MEM_rs1_rdata_r <= EX_MEM_rs1_rdata_nxt;
        EX_MEM_rs2_rdata_r <= EX_MEM_rs2_rdata_nxt;
        EX_MEM_rs1_addr_r <= EX_MEM_rs1_addr_nxt;
        EX_MEM_rs2_addr_r <= EX_MEM_rs2_addr_nxt;
        EX_MEM_rd_addr_r <= EX_MEM_rd_addr_nxt;
        EX_MEM_pc_branch_r <= EX_MEM_pc_branch_nxt;
        EX_MEM_trap_r <= EX_MEM_trap_nxt;

        MEM_WB_WB_r <= MEM_WB_WB_nxt;

        MEM_WB_valid_r <= MEM_WB_valid_nxt;
        MEM_WB_insn_r <= MEM_WB_insn_nxt;
        MEM_WB_pc_rdata_r <= MEM_WB_pc_rdata_nxt;
        MEM_WB_pc_wdata_r <= MEM_WB_pc_wdata_nxt;
        MEM_WB_rs1_rdata_r <= MEM_WB_rs1_rdata_nxt;
        MEM_WB_rs2_rdata_r <= MEM_WB_rs2_rdata_nxt;
        MEM_WB_rs1_addr_r <= MEM_WB_rs1_addr_nxt;
        MEM_WB_rs2_addr_r <= MEM_WB_rs2_addr_nxt;
        MEM_WB_rd_addr_r <= MEM_WB_rd_addr_nxt;
        MEM_WB_rd_wdata_r <= MEM_WB_rd_wdata_nxt;
        MEM_WB_trap_r <= MEM_WB_trap_nxt;

        MEM_WB_mem_addr_r <= MEM_WB_mem_addr_nxt;
        MEM_WB_mem_rmask_r <= MEM_WB_mem_rmask_nxt;
        MEM_WB_mem_wmask_r <= MEM_WB_mem_wmask_nxt;
        MEM_WB_mem_rdata_r <= MEM_WB_mem_rdata_nxt;
        MEM_WB_mem_wdata_r <= MEM_WB_mem_wdata_nxt;
    end else begin
        pc_r <= START_PC;

        ID_EX_EX_r <= 6'b0;
        ID_EX_M_r <= 7'b0;
        ID_EX_WB_r <= 2'b0;

        ID_EX_valid_r <= 1'b0;
        ID_EX_insn_r <= 32'b0;
        ID_EX_pc_rdata_r <= 32'b0;
        ID_EX_pc_wdata_r <= 32'b0;
        ID_EX_rs1_addr_r <= 5'b0;
        ID_EX_rs2_addr_r <= 5'b0;
        ID_EX_rd_addr_r <= 5'b0;
        ID_EX_rs1_rdata_r <= 32'b0;
        ID_EX_rs2_rdata_r <= 32'b0;
        ID_EX_imm_r <= 32'b0;
        ID_EX_trap_r <= 1'b0;

        EX_MEM_M_r  <= 7'b0;
        EX_MEM_WB_r <= 2'b0;
        EX_MEM_zero_r <= 1'b0;
        EX_MEM_result_r <= 32'b0;
        EX_MEM_valid_r <= 1'b0;
        EX_MEM_insn_r <= 32'b0;
        EX_MEM_pc_rdata_r <= 32'b0;
        EX_MEM_pc_wdata_r <= 32'b0;
        EX_MEM_rs1_addr_r <= 5'b0;
        EX_MEM_rs2_addr_r <= 5'b0;
        EX_MEM_rd_addr_r <= 5'b0;
        EX_MEM_rs1_rdata_r <= 32'b0;
        EX_MEM_rs2_rdata_r <= 32'b0;
        EX_MEM_pc_branch_r <= 32'b0;
        EX_MEM_trap_r <= 1'b0;

        MEM_WB_WB_r <= 2'b0;
        MEM_WB_valid_r <= 1'b0;
        MEM_WB_insn_r <= 32'b0;
        MEM_WB_pc_rdata_r <= 32'b0;
        MEM_WB_pc_wdata_r <= 32'b0;
        MEM_WB_rs1_addr_r <= 5'b0;
        MEM_WB_rs2_addr_r <= 5'b0;
        MEM_WB_rd_addr_r <= 5'b0;
        MEM_WB_rs1_rdata_r <= 32'b0;
        MEM_WB_rs2_rdata_r <= 32'b0;
        MEM_WB_rd_wdata_r <= 32'b0;
        MEM_WB_trap_r <= 1'b0;

        MEM_WB_mem_addr_r <= 32'b0;
        MEM_WB_mem_rmask_r <= 4'b0;
        MEM_WB_mem_wmask_r <= 4'b0;
        MEM_WB_mem_rdata_r <= 32'b0;
        MEM_WB_mem_wdata_r <= 32'b0;
    end
end

always @(*) begin
    pc_nxt = pc_r;

    if (set_PC) begin
        pc_nxt = {pc_new_value[31:2],2'b0};
    end else
    if (~busy_wait) begin
        pc_nxt = {pc_increment[31:2], 2'b0};
    end
end

add Add_IF (
    .A(pc_r),
    .B(32'd4),
    .Out(pc_increment)
);

instruction_memory InstructionMemory (
    .clk(clk),
    .resetn(resetn),

    .address(pc_r),
    .read(~set_PC),
    .clear_previous(set_PC),
    .busy_wait(busy_wait),

    .instruction_read(~(mem_busy_wait | hazard)),
    .instruction(instruction),
    .instruction_address(instruction_address),
    .instruction_ready(instruction_ready),

    .mmio_address(mmio_address_i),
    .mmio_read_word(mmio_read_word_i),
    .mmio_write_byte(mmio_write_byte_i),
    .mmio_write_data(mmio_write_data_i),
    .mmio_ready(mmio_ready_i),
    .mmio_busy_wait(mmio_busy_wait_i),
    .mmio_read_data(mmio_read_data_i)
);

add Add_ID (
    .A(instruction_address),
    .B(32'd4),
    .Out(instruction_address_next)
);

ctrl Control (
    .instruction(instruction),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    
    .ALUOp(ALUOp),
    .Jump(Jump),

    .ALUCtl(),
    .ALUSrc1(ALUSrc1),
    .ALUSrc2(ALUSrc2),

    .Branch(branch),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemSize(MemSize),

    .RegWrite(RegWrite),
    .MemToReg(MemToReg),

    .valid(valid)
);

hazard Hazard_Detection_Unit (
    .rs1(rs1),
    .rs2(rs2),

    .ex_RegWrite(ID_EX_WB_r[1]),
    .ex_rd(ID_EX_rd_addr_r),
    .mem_RegWrite(EX_MEM_WB_r[1]),
    .mem_rd(EX_MEM_rd_addr_r),
    .wb_RegWrite(MEM_WB_WB_r[1]),
    .wb_rd(MEM_WB_rd_addr_r),

    .stall(hazard)
);

immgen ImmGen (
    .instruction(instruction),
    .immediate(immediate)
);

regfile Registers (
    .clk(clk),
    .Read1(rs1),
    .Read2(rs2),
    .WriteReg(MEM_WB_rd_addr_r),
    .WriteData(MEM_WB_WB_r[0] ? read_data : MEM_WB_rd_wdata_r),
    .RegWrite(MEM_WB_WB_r[1] & retire_valid & ~MEM_WB_trap_r),
    .Data1(Data1),
    .Data2(Data2)
`ifdef RISCV_FORMAL
    ,
    .rd_wdata(rd_wdata)
`endif
);

always @(*) begin
    ID_EX_EX_nxt = ID_EX_EX_r;
    ID_EX_M_nxt = ID_EX_M_r;
    ID_EX_WB_nxt = ID_EX_WB_r;
    ID_EX_valid_nxt = ID_EX_valid_r;
    ID_EX_insn_nxt = ID_EX_insn_r;
    ID_EX_rs1_addr_nxt = ID_EX_rs1_addr_r;
    ID_EX_rs2_addr_nxt = ID_EX_rs2_addr_r;
    ID_EX_rd_addr_nxt = ID_EX_rd_addr_r;
    ID_EX_rs1_rdata_nxt = ID_EX_rs1_rdata_r;
    ID_EX_rs2_rdata_nxt = ID_EX_rs2_rdata_r;
    ID_EX_pc_rdata_nxt = ID_EX_pc_rdata_r;
    ID_EX_pc_wdata_nxt = ID_EX_pc_wdata_r;
    ID_EX_imm_nxt = ID_EX_imm_r;
    ID_EX_trap_nxt = ID_EX_trap_r;

    if (~mem_busy_wait) begin
        if (~instruction_ready | hazard | set_PC) begin
            ID_EX_EX_nxt = 0;
            ID_EX_M_nxt = 0;
            ID_EX_WB_nxt = 0;
            ID_EX_valid_nxt = 1'b0;
        end else begin
            ID_EX_EX_nxt = {Jump, branch, ALUOp, ALUSrc2, ALUSrc1};
            ID_EX_M_nxt = {Jump, branch, MemWrite, MemRead, MemSize};
            ID_EX_WB_nxt = {RegWrite, MemToReg};
            ID_EX_valid_nxt = 1'b1;
            ID_EX_insn_nxt = instruction;
            ID_EX_rs1_addr_nxt = rs1;
            ID_EX_rs2_addr_nxt = rs2;
            ID_EX_rd_addr_nxt = rd;
            ID_EX_rs1_rdata_nxt = Data1;
            ID_EX_rs2_rdata_nxt = Data2;
            ID_EX_pc_rdata_nxt = instruction_address;
            ID_EX_pc_wdata_nxt = instruction_address_next;
            ID_EX_imm_nxt = immediate;
            ID_EX_trap_nxt = ~valid;
        end 
    end
end

alu ALU (
    .ALUctl(ALUctl),
    .A(ID_EX_EX_r[0] ? ID_EX_pc_rdata_r : ID_EX_rs1_rdata_r),
    .B(ID_EX_EX_r[1] ? ID_EX_imm_r : ID_EX_rs2_rdata_r),
    .Zero(zero),
    .ALUOut(ALUOut)
);

alu_ctrl ALUcontrol (
    .ALUinst({ID_EX_insn_r[30], ID_EX_insn_r[14:12]}),
    .ALUOp(ID_EX_EX_r[3:2]),
    .ALUctl(ALUctl)
);

add Add_EX (
    .A(ID_EX_EX_r[0] | ID_EX_EX_r[4] ? ID_EX_pc_rdata_r : ID_EX_rs1_rdata_r),
    .B(ID_EX_imm_r),
    .Out(pc_new_value)
);

always @(*) begin

    EX_MEM_M_nxt = EX_MEM_M_r;
    EX_MEM_WB_nxt = EX_MEM_WB_r;
    EX_MEM_zero_nxt = EX_MEM_zero_r;
    EX_MEM_result_nxt = EX_MEM_result_r;
    EX_MEM_valid_nxt = EX_MEM_valid_r;
    EX_MEM_insn_nxt = EX_MEM_insn_r;
    EX_MEM_pc_rdata_nxt = EX_MEM_pc_rdata_r;
    EX_MEM_pc_wdata_nxt = EX_MEM_pc_wdata_r;
    EX_MEM_rs1_rdata_nxt = EX_MEM_rs1_rdata_r;
    EX_MEM_rs2_rdata_nxt = EX_MEM_rs2_rdata_r;
    EX_MEM_rs1_addr_nxt = EX_MEM_rs1_addr_r;
    EX_MEM_rs2_addr_nxt = EX_MEM_rs2_addr_r;
    EX_MEM_rd_addr_nxt = EX_MEM_rd_addr_r;
    EX_MEM_pc_branch_nxt = EX_MEM_pc_branch_r;
    EX_MEM_trap_nxt = EX_MEM_trap_r;

    if (~mem_busy_wait) begin
            EX_MEM_M_nxt = ID_EX_M_r;
            EX_MEM_WB_nxt = ID_EX_WB_r;
            EX_MEM_zero_nxt = zero;
            EX_MEM_result_nxt = set_PC ? ID_EX_pc_wdata_r : ALUOut; // changed 
            EX_MEM_valid_nxt = ID_EX_valid_r;
            EX_MEM_insn_nxt = ID_EX_insn_r;
            EX_MEM_pc_rdata_nxt = ID_EX_pc_rdata_r;
            EX_MEM_pc_wdata_nxt = ID_EX_pc_wdata_r;
            EX_MEM_rs1_rdata_nxt = ID_EX_rs1_rdata_r;
            EX_MEM_rs2_rdata_nxt = ID_EX_rs2_rdata_r;
            EX_MEM_rs1_addr_nxt = ID_EX_rs1_addr_r;
            EX_MEM_rs2_addr_nxt = ID_EX_rs2_addr_r;
            EX_MEM_rd_addr_nxt = ID_EX_rd_addr_r;
            EX_MEM_pc_branch_nxt = pc_new_value;
            EX_MEM_trap_nxt = ID_EX_trap_r;
    end
end

memory_access Memory (
    .clk(clk),
    .resetn(resetn),
    .address(EX_MEM_result_r),
    .write(EX_MEM_M_r[4]),
    .read(EX_MEM_M_r[3]),
    .size(EX_MEM_M_r[2:0]),
    .write_data(EX_MEM_rs2_rdata_r),
    .read_data(read_data),
    .read_address(),
    .read_size(),
    .busy_wait(mem_busy_wait),
    .ready(mem_ready),
    .unaligned(mem_unaligned),

    .mmio_address(mmio_address_d),
    .mmio_read_word(mmio_read_word_d),
    .mmio_write_byte(mmio_write_byte_d),
    .mmio_write_data(mmio_write_data_d),
    .mmio_ready(mmio_ready_d),
    .mmio_busy_wait(mmio_busy_wait_d),
    .mmio_read_data(mmio_read_data_d)
    );

always @(*) begin
    MEM_WB_WB_nxt = MEM_WB_WB_r;
    MEM_WB_valid_nxt = MEM_WB_valid_r;
    MEM_WB_insn_nxt = MEM_WB_insn_r;
    MEM_WB_pc_rdata_nxt = MEM_WB_pc_rdata_r;
    MEM_WB_pc_wdata_nxt = MEM_WB_pc_wdata_r;
    MEM_WB_rs1_rdata_nxt = MEM_WB_rs1_rdata_r;
    MEM_WB_rs2_rdata_nxt = MEM_WB_rs2_rdata_r;
    MEM_WB_rs1_addr_nxt = MEM_WB_rs1_addr_r;
    MEM_WB_rs2_addr_nxt = MEM_WB_rs2_addr_r;
    MEM_WB_rd_addr_nxt = MEM_WB_rd_addr_r;
    MEM_WB_rd_wdata_nxt = MEM_WB_rd_wdata_r;
    MEM_WB_trap_nxt = MEM_WB_trap_r;

    MEM_WB_mem_addr_nxt = MEM_WB_mem_addr_r;
    MEM_WB_mem_rmask_nxt = MEM_WB_mem_rmask_r;
    MEM_WB_mem_wmask_nxt = MEM_WB_mem_wmask_r;
    MEM_WB_mem_rdata_nxt = MEM_WB_mem_rdata_r;
    MEM_WB_mem_wdata_nxt = MEM_WB_mem_wdata_r;

    if (~mem_busy_wait) begin
        MEM_WB_WB_nxt = EX_MEM_WB_r;
        MEM_WB_valid_nxt = EX_MEM_valid_r;
        MEM_WB_insn_nxt = EX_MEM_insn_r;
        MEM_WB_pc_rdata_nxt = EX_MEM_pc_rdata_r;
        MEM_WB_pc_wdata_nxt = set_PC ? pc_nxt : EX_MEM_pc_wdata_r;
        MEM_WB_rs1_rdata_nxt = EX_MEM_rs1_rdata_r;
        MEM_WB_rs2_rdata_nxt = EX_MEM_rs2_rdata_r;
        MEM_WB_rs1_addr_nxt = EX_MEM_rs1_addr_r;
        MEM_WB_rs2_addr_nxt = EX_MEM_rs2_addr_r;
        MEM_WB_rd_addr_nxt = EX_MEM_rd_addr_r;
        
        MEM_WB_rd_wdata_nxt = EX_MEM_result_r; // changed
        MEM_WB_trap_nxt = mem_unaligned | EX_MEM_trap_r; //changed

        MEM_WB_mem_addr_nxt = mmio_address_d;
        MEM_WB_mem_rmask_nxt = {4{mmio_read_word_d}};
        MEM_WB_mem_wmask_nxt = mmio_write_byte_d;
        MEM_WB_mem_rdata_nxt = mmio_read_data_d;
        MEM_WB_mem_wdata_nxt = mmio_write_data_d;
    end else
    if (retire_valid) begin
        MEM_WB_WB_nxt = 0;
        MEM_WB_valid_nxt = 1'b0;
        MEM_WB_trap_nxt = 1'b0;
    end
end

`ifdef RISCV_FORMAL
always @(posedge clk) begin
    if (resetn) begin
        rvfi_order <= rvfi_order + retire_valid;
    end else begin
        rvfi_order <= 64'b0;
    end
end

always @(*) begin
    rvfi_valid=retire_valid;
    rvfi_insn = MEM_WB_insn_r;
    rvfi_trap = MEM_WB_trap_r;
    rvfi_halt = 1'b0;
    rvfi_intr = 1'b0;
    rvfi_mode = 2'd3;
    rvfi_ixl = 2'd1;
    rvfi_rs1_addr = MEM_WB_rs1_addr_r;
    rvfi_rs2_addr = MEM_WB_rs2_addr_r;
    rvfi_rs1_rdata = MEM_WB_rs1_rdata_r;
    rvfi_rs2_rdata = MEM_WB_rs2_rdata_r;
    rvfi_rd_addr = MEM_WB_rd_addr_r;
    rvfi_rd_wdata = rd_wdata;
    rvfi_pc_rdata = MEM_WB_pc_rdata_r;
    rvfi_pc_wdata = MEM_WB_pc_wdata_r;
    rvfi_mem_addr = MEM_WB_mem_addr_r;
    rvfi_mem_rmask = MEM_WB_mem_rmask_r;
    rvfi_mem_wmask = MEM_WB_mem_wmask_r;
    rvfi_mem_rdata = mmio_read_data_d;
    rvfi_mem_wdata = MEM_WB_mem_wdata_r;
end
`endif

endmodule
