`timescale 1ns/1ps

module control_unit(
    input  wire [5:0] op,
    output reg       reg_dst,
    output reg       alu_src,
    output reg       mem_to_reg,
    output reg       reg_write,
    output reg       mem_write,
    output reg       branch,
    output reg       jump,
    output reg [1:0] alu_op
);
    always @* begin
        reg_dst    = 1'b0;
        alu_src    = 1'b0;
        mem_to_reg = 1'b0;
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        alu_op     = 2'b00;

        case (op)
            6'h00: begin // R-Type
                reg_dst   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end
            6'h08: begin // ADDI
                alu_src   = 1'b1;
                reg_write = 1'b1;
            end
            6'h23: begin // LW
                alu_src    = 1'b1;
                mem_to_reg = 1'b1;
                reg_write  = 1'b1;
            end
            6'h2b: begin // SW
                alu_src   = 1'b1;
                mem_write = 1'b1;
            end
            6'h04: begin // BEQ
                branch = 1'b1;
                alu_op = 2'b01;
            end
            6'h02: jump = 1'b1; // JUMP
            default: begin end
        endcase
    end
endmodule
