`timescale 1ns/1ps

module alu_control(
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output reg  [3:0] alu_ctrl
);
    always @* begin
        case (alu_op)
            2'b00: alu_ctrl = 4'b0010; // Memory access & ADDI -> ADD
            2'b01: alu_ctrl = 4'b0110; // Branch equal (BEQ) -> SUB
            2'b10: begin               // R-Type
                case (funct)
                    6'h20: alu_ctrl = 4'b0010; // add
                    6'h22: alu_ctrl = 4'b0110; // sub
                    6'h24: alu_ctrl = 4'b0000; // and
                    6'h25: alu_ctrl = 4'b0001; // or
                    6'h2a: alu_ctrl = 4'b0111; // slt
                    default: alu_ctrl = 4'b0000;
                endcase
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end
endmodule