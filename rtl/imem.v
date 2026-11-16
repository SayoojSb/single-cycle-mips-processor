`timescale 1ns/1ps

module imem(
    input  wire [31:0] addr,
    output wire [31:0] instr
);
    reg [31:0] mem[0:255];
    assign instr = mem[addr[9:2]];
endmodule
