`timescale 1ns/1ps

module tb_mips;
    reg clk;
    reg reset;
    wire [31:0] pc, instr, addr, wdata, rdata;
    wire we;
    integer errors = 0;
    integer i;

    mips cpu(
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .mem_addr(addr),
        .mem_wdata(wdata),
        .mem_we(we),
        .mem_rdata(rdata)
    );

    data_memory ram(
        .clk(clk),
        .reset(reset),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .rdata(rdata)
    );

    always #5 clk = ~clk;

    task check;
        input [255:0] name;
        input [31:0]  actual;
        input [31:0]  expected;
        begin
            if (actual === expected) begin
                $display("PASS %0s = %08h", name, actual);
            end else begin
                $display("FAIL %0s: expected %08h, got %08h", name, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mips);

        for (i = 0; i < 256; i = i + 1) ram.mem[i] = 32'd0;
        $readmemh("test.hex", cpu.imem_inst.mem, 0, 23);

        clk = 0;
        reset = 1;
        #20;
        reset = 0;
        #300;

        check("zero register",       cpu.rf_inst.regs[0],  32'h00000000);
        check("addi positive",       cpu.rf_inst.regs[1],  32'h00000005);
        check("addi negative",       cpu.rf_inst.regs[2],  32'hfffffffd);
        check("add",                 cpu.rf_inst.regs[3],  32'h00000002);
        check("sub",                 cpu.rf_inst.regs[4],  32'h00000008);
        check("and",                 cpu.rf_inst.regs[5],  32'h00000005);
        check("or",                  cpu.rf_inst.regs[6],  32'hfffffffd);
        check("signed slt",          cpu.rf_inst.regs[7],  32'h00000001);
        check("store",               ram.mem[0],           32'h00000002);
        check("load",                cpu.rf_inst.regs[8],  32'h00000002);
        check("branch and jump",     cpu.rf_inst.regs[9],  32'h0000002a);
        check("skipped instructions",cpu.rf_inst.regs[10], 32'h00000000);
        check("not-taken branch",    cpu.rf_inst.regs[11], 32'h00000007);
        check("second store",        ram.mem[1],           32'h00000007);

        if (errors == 0) begin
            $display("PASS: all checks completed");
        end else begin
            $display("FAIL: %0d check(s) failed", errors);
            $fatal(1);
        end

        $finish;
    end
endmodule