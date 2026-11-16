`timescale 1ns/1ps

module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [3:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);
    always @* begin
        case (alu_ctrl)
            4'b0010: result = a + b;                                // ADD / ADDI / LW / SW
            4'b0110: result = a - b;                                // SUB / BEQ
            4'b0000: result = a & b;                                // AND
            4'b0001: result = a | b;                                // OR
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT (signed)
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);
endmodule