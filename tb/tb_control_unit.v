`timescale 1ns/1ps

// Run: iverilog -g2012 -Wall -s tb_control_unit -o /tmp/tb_control_unit rtl/control_unit.v tb/tb_control_unit.v
//      vvp /tmp/tb_control_unit
module tb_control_unit;
    reg [5:0] op;
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_write, branch, jump;
    wire [1:0] alu_op;
    wire [8:0] controls = {reg_dst, alu_src, mem_to_reg, reg_write,
                           mem_write, branch, jump, alu_op};
    reg [8:0] expected;
    integer opcode;
    integer previous;

    control_unit dut(
        .op(op), .reg_dst(reg_dst), .alu_src(alu_src),
        .mem_to_reg(mem_to_reg), .reg_write(reg_write),
        .mem_write(mem_write), .branch(branch), .jump(jump),
        .alu_op(alu_op)
    );

    initial begin
        // Exercise every transition to catch stale outputs as well as decoding errors.
        for (previous = 0; previous < 64; previous = previous + 1) begin
            for (opcode = 0; opcode < 64; opcode = opcode + 1) begin
                op = previous;
                #1;
                op = opcode;
                case (opcode)
                    0:  expected = 9'b100100010; // R-Type
                    8:  expected = 9'b010100000; // ADDI
                    35: expected = 9'b011100000; // LW
                    43: expected = 9'b010010000; // SW
                    4:  expected = 9'b000001001; // BEQ
                    2:  expected = 9'b000000100; // JUMP
                    default: expected = 9'b000000000;
                endcase
                #1;
                if (controls !== expected)
                    $fatal(1, "opcode %02h after %02h: expected %09b, got %09b",
                           op, previous, expected, controls);
            end
        end
        $display("PASS: all 64 opcodes across all 4096 opcode transitions");
        $finish;
    end
endmodule
