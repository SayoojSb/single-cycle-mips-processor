`timescale 1ns/1ps

module data_memory(
    input  wire        clk,
    input  wire        reset,
    input  wire        we,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);
    reg [31:0] mem[0:255];
    wire valid = (addr[31:10] == 22'd0 && addr[1:0] == 2'b00);
    assign rdata = valid ? mem[addr[9:2]] : 32'd0;

    always @(posedge clk) begin
        if (!reset && we && valid) begin
            mem[addr[9:2]] <= wdata;
        end
    end
endmodule
