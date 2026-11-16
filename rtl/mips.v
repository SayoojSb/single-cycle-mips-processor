`timescale 1ns/1ps

module mips(
    input  wire        clk,
    input  wire        reset,
    output reg  [31:0] pc,
    output wire [31:0] instr,
    output wire [31:0] mem_addr,
    output wire [31:0] mem_wdata,
    output wire        mem_we,
    input  wire [31:0] mem_rdata
);
    wire [5:0] op    = instr[31:26];
    wire [4:0] rs    = instr[25:21];
    wire [4:0] rt    = instr[20:16];
    wire [4:0] rd    = instr[15:11];
    wire [5:0] funct = instr[5:0];

    wire reg_dst, alu_src, mem_to_reg, reg_write, branch, jump;
    wire [1:0] alu_op;
    wire [3:0] alu_ctrl;

    wire [31:0] reg_data1, reg_data2;
    wire [31:0] sign_ext_imm = {{16{instr[15]}}, instr[15:0]};
    wire [4:0]  write_reg    = reg_dst ? rd : rt;
    wire [31:0] alu_b        = alu_src ? sign_ext_imm : reg_data2;
    wire [31:0] alu_result;
    wire        zero;
    wire [31:0] write_data   = mem_to_reg ? mem_rdata : alu_result;

    wire [31:0] pc_plus_4     = pc + 32'd4;
    wire [31:0] branch_target = pc_plus_4 + (sign_ext_imm << 2);
    wire [31:0] jump_target   = {(pc_plus_4 & 32'hf0000000)} | {4'b0, instr[25:0], 2'b00};
    wire        take_branch   = branch & zero;
    wire [31:0] next_pc       = jump ? jump_target : (take_branch ? branch_target : pc_plus_4);

    always @(posedge clk) begin
        if (reset) pc <= 32'd0;
        else       pc <= next_pc;
    end

    imem imem_inst (
        .addr(pc),
        .instr(instr)
    );

    control_unit cu_inst (
        .op(op),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_write(mem_we),
        .branch(branch),
        .jump(jump),
        .alu_op(alu_op)
    );

    regfile rf_inst (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(rs),
        .read_reg2(rt),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    alu_control ac_inst (
        .alu_op(alu_op),
        .funct(funct),
        .alu_ctrl(alu_ctrl)
    );

    alu alu_inst (
        .a(reg_data1),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    assign mem_addr  = alu_result;
    assign mem_wdata = reg_data2;

endmodule