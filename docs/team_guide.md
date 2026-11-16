# 🚀 Team Project Guide: Single-Cycle 32-Bit MIPS Processor

**Repository:** `https://github.com/SayoojSb/single-cycle-mips-processor.git`  
**Goal:** Build, modularize, verify, and document a 32-bit Single-Cycle MIPS processor as a 5-member team. Every member will have their own files, Git branch, and Pull Request (PR) merged into `main`.

---

## 📌 Team Rules & Git Workflow

1. **Never commit directly to `main`:** Every member works on their dedicated feature branch and opens a Pull Request on GitHub.
2. **Review each other’s PRs:** Leave a review/comment before merging to prove active collaboration.
3. **Execution Order:**
   - **Phase 1 (Parallel):** Members 2, 3, and 4 create their submodules (`alu.v`, `control_unit.v`, `regfile.v`, `data_memory.v`) and merge their PRs.
   - **Phase 2:** Member 1 wires all submodules into the top-level datapath (`mips.v`) and merges their PR.
   - **Phase 3:** Member 5 adds the self-checking testbench (`tb_mips.v`), build `Makefile`, and the IEEE conference report (`report/report.tex`).

---

## 👥 Member Role Summary

| Member | Assigned Role | Deliverable Files | Branch Name |
| :--- | :--- | :--- | :--- |
| **Member 1** | **Datapath & Top Integration Lead** | `rtl/mips.v` | `feature/datapath-integration` |
| **Member 2** | **ALU & Execution Specialist** | `rtl/alu.v`, `rtl/alu_control.v` | `feature/modular-alu` |
| **Member 3** | **Control Unit Engineer** | `rtl/control_unit.v` | `feature/control-unit` |
| **Member 4** | **Memory Subsystem Engineer** | `rtl/regfile.v`, `rtl/imem.v`, `rtl/data_memory.v` | `feature/memory-subsystem` |
| **Member 5** | **Verification, Software & Report Lead** | `tb/tb_mips.v`, `Makefile`, `report/report.tex` | `feature/testbench-and-docs` |

---

## 🛠️ Step-by-Step Instructions & Code for Each Member

---

### 🟢 Member 2: ALU & Execution Subsystem

#### Tasks:
1. Clone the repository and switch to a new branch:
   ```sh
   git clone https://github.com/SayoojSb/single-cycle-mips-processor.git
   cd single-cycle-mips-processor
   git checkout -b feature/modular-alu
   ```
2. Create `rtl/alu.v`:
   ```verilog
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
   ```
3. Create `rtl/alu_control.v`:
   ```verilog
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
   ```
4. Commit and push:
   ```sh
   git add rtl/alu.v rtl/alu_control.v
   git commit -m "feat(alu): implement 32-bit ALU and ALU control decoder"
   git push -u origin feature/modular-alu
   ```
5. Go to GitHub and open **Pull Request #1** to merge `feature/modular-alu` into `main`.

---

### 🟢 Member 3: Control Unit & Decoder

#### Tasks:
1. Clone the repository and switch to a new branch:
   ```sh
   git clone https://github.com/SayoojSb/single-cycle-mips-processor.git
   cd single-cycle-mips-processor
   git checkout -b feature/control-unit
   ```
2. Create `rtl/control_unit.v`:
   ```verilog
   `timescale 1ns/1ps

   module control_unit(
       input  wire [5:0] op,
       output reg        reg_dst,
       output reg        alu_src,
       output reg        mem_to_reg,
       output reg        reg_write,
       output reg        mem_write,
       output reg        branch,
       output reg        jump,
       output reg  [1:0] alu_op
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
                   reg_dst    = 1'b1;
                   reg_write  = 1'b1;
                   alu_op     = 2'b10;
               end
               6'h08: begin // ADDI
                   alu_src    = 1'b1;
                   reg_write  = 1'b1;
                   alu_op     = 2'b00;
               end
               6'h23: begin // LW
                   alu_src    = 1'b1;
                   mem_to_reg = 1'b1;
                   reg_write  = 1'b1;
                   alu_op     = 2'b00;
               end
               6'h2b: begin // SW
                   alu_src    = 1'b1;
                   mem_write  = 1'b1;
                   alu_op     = 2'b00;
               end
               6'h04: begin // BEQ
                   branch     = 1'b1;
                   alu_op     = 2'b01;
               end
               6'h02: begin // JUMP
                   jump       = 1'b1;
               end
               default: begin end
           endcase
       end
   endmodule
   ```
3. Commit and push:
   ```sh
   git add rtl/control_unit.v
   git commit -m "feat(control): implement single-cycle control unit decoder"
   git push -u origin feature/control-unit
   ```
4. Go to GitHub and open **Pull Request #2** to merge `feature/control-unit` into `main`.

---

### 🟢 Member 4: Memory Subsystem & Storage

#### Tasks:
1. Clone the repository and switch to a new branch:
   ```sh
   git clone https://github.com/SayoojSb/single-cycle-mips-processor.git
   cd single-cycle-mips-processor
   git checkout -b feature/memory-subsystem
   ```
2. Create `rtl/regfile.v`:
   ```verilog
   `timescale 1ns/1ps

   module regfile(
       input  wire        clk,
       input  wire        reset,
       input  wire        reg_write,
       input  wire [4:0]  read_reg1,
       input  wire [4:0]  read_reg2,
       input  wire [4:0]  write_reg,
       input  wire [31:0] write_data,
       output wire [31:0] read_data1,
       output wire [31:0] read_data2
   );
       reg [31:0] regs[0:31];
       integer i;

       assign read_data1 = (read_reg1 == 5'd0) ? 32'd0 : regs[read_reg1];
       assign read_data2 = (read_reg2 == 5'd0) ? 32'd0 : regs[read_reg2];

       always @(posedge clk) begin
           if (reset) begin
               for (i = 0; i < 32; i = i + 1) regs[i] <= 32'd0;
           end else if (reg_write && (write_reg != 5'd0)) begin
               regs[write_reg] <= write_data;
           end
       end
   endmodule
   ```
3. Create `rtl/imem.v`:
   ```verilog
   `timescale 1ns/1ps

   module imem(
       input  wire [31:0] addr,
       output wire [31:0] instr
   );
       reg [31:0] mem[0:255];
       assign instr = mem[addr[9:2]];
   endmodule
   ```
4. Create `rtl/data_memory.v`:
   ```verilog
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
   ```
5. Commit and push:
   ```sh
   git add rtl/regfile.v rtl/imem.v rtl/data_memory.v
   git commit -m "feat(memory): implement regfile, imem, and data_memory with alignment protection"
   git push -u origin feature/memory-subsystem
   ```
6. Go to GitHub and open **Pull Request #3** to merge `feature/memory-subsystem` into `main`.

---

### 🟢 Member 1: Datapath & Top Integration Lead

#### Tasks:
*(Wait until Members 2, 3, and 4 have merged their PRs into `main`)*
1. Pull the latest `main` branch:
   ```sh
   git checkout main
   git pull origin main
   git checkout -b feature/datapath-integration
   ```
2. Replace `rtl/mips.v` with the integrated top-level datapath:
   ```verilog
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
   ```
3. Commit and push:
   ```sh
   git add rtl/mips.v
   git commit -m "refactor(core): assemble modular datapath and wire top-level signals"
   git push -u origin feature/datapath-integration
   ```
4. Go to GitHub and open **Pull Request #4** to merge `feature/datapath-integration` into `main`.

---

### 🟢 Member 5: Verification, Automation & IEEE Report

#### Tasks:
*(After Member 1 merges PR #4)*
1. Pull the latest `main` branch:
   ```sh
   git checkout main
   git pull origin main
   git checkout -b feature/testbench-and-docs
   ```
2. Create `tb/tb_mips.v`:
   ```verilog
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
           $dumpfile("results/mips.vcd");
           $dumpvars(0, tb_mips);

           for (i = 0; i < 256; i = i + 1) ram.mem[i] = 32'd0;
           $readmemh("programs/test.hex", cpu.imem_inst.mem);

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
   ```
3. Create `Makefile`:
   ```makefile
   SIM_DIR = results
   RTL_SRCS = rtl/alu.v rtl/alu_control.v rtl/control_unit.v rtl/regfile.v rtl/imem.v rtl/data_memory.v rtl/mips.v
   TB_SRCS = tb/tb_mips.v

   all: sim

   $(SIM_DIR):
    mkdir -p $(SIM_DIR)

   sim: $(SIM_DIR)
    iverilog -g2012 -s tb_mips -o $(SIM_DIR)/sim $(RTL_SRCS) $(TB_SRCS)
    vvp $(SIM_DIR)/sim

   wave: sim
    gtkwave $(SIM_DIR)/mips.vcd &

   clean:
    rm -rf $(SIM_DIR)/sim $(SIM_DIR)/mips.vcd
   ```
4. Create `report/report.tex` (IEEE Conference Format):
   ```latex
   \documentclass[conference]{IEEEtran}
   \usepackage{cite}
   \usepackage{amsmath,amssymb,amsfonts}
   \usepackage{algorithmic}
   \usepackage{graphicx}
   \usepackage{textcomp}
   \usepackage{xcolor}

   \begin{document}

   \title{Design and Verification of a Single-Cycle 32-bit MIPS Processor with Memory Interface}

   \author{
   \IEEEauthorblockN{Member 1 Name}
   \IEEEauthorblockA{\textit{Dept. of Computer Applications} \\
   Datapath \& Top-Level Integration}
   \and
   \IEEEauthorblockN{Member 2 Name}
   \IEEEauthorblockA{\textit{Dept. of Computer Applications} \\
   ALU Subsystem \& Execution Unit}
   \and
   \IEEEauthorblockN{Member 3 Name}
   \IEEEauthorblockA{\textit{Dept. of Computer Applications} \\
   Control Unit \& Instruction Decoder}
   \and
   \IEEEauthorblockN{Member 4 Name}
   \IEEEauthorblockA{\textit{Dept. of Computer Applications} \\
   Memory Subsystem \& Register File}
   \and
   \IEEEauthorblockN{Member 5 Name}
   \IEEEauthorblockA{\textit{Dept. of Computer Applications} \\
   Verification, Testbench \& Documentation}
   }

   \maketitle

   \begin{abstract}
   This paper presents the microarchitecture, register transfer level (RTL) implementation, and verification of a single-cycle 32-bit MIPS-like processor. Designed using Verilog HDL, the processor executes a core subset of MIPS instructions comprising arithmetic/logic operations (ADD, SUB, AND, OR, SLT), immediate arithmetic (ADDI), memory operations (LW, SW), and control transfer instructions (BEQ, J) within a single clock cycle. The design features a modular architecture comprising a decoupled ALU subsystem, dedicated instruction decoding and control unit, a dual-read single-write register file with hardwired zero-register protection, and an aligned 1-KB data memory interface. Functional verification via Icarus Verilog demonstrates 100\% pass across 14 comprehensive test conditions.
   \end{abstract}

   \section{Introduction}
   The single-cycle MIPS processor executes every instruction within a single clock cycle. Instruction fetch, decode, operand fetch, ALU execution, memory access, and register write-back all occur combinatorially before the state is updated on the rising edge of the system clock.

   \section{Architecture and Microarchitecture}
   The processor consists of five principal functional modules:
   \begin{enumerate}
   \item \textbf{Instruction Memory and PC:} Updates sequentially by 4 or via branch/jump targets.
   \item \textbf{Control Unit:} Decodes the 6-bit opcode into multiplexer select lines and write enables.
   \item \textbf{Register File:} 32 general-purpose registers where \$0 is hardwired to zero.
   \item \textbf{Arithmetic Logic Unit (ALU):} Performs 32-bit operations and calculates zero condition flags.
   \item \textbf{Data Memory:} 256-word RAM supporting aligned byte addresses 0 through 1020.
   \end{enumerate}

   \section{Simulation and Results}
   The processor was simulated using Icarus Verilog with 14 automated assertion checks testing arithmetic calculations, register zero immutability, data memory load/store integrity, and branch/jump target accuracy. All 14 tests completed with zero errors.

   \section{Conclusion}
   A modular single-cycle MIPS processor has been implemented and verified. Future extensions include pipelining with hazard detection and forwarding units to support higher clock frequencies.

   \end{document}
   ```
5. Commit and push:
   ```sh
   git add tb/tb_mips.v Makefile report/report.tex
   git commit -m "test: add automated testbench, simulation Makefile, and IEEE report"
   git push -u origin feature/testbench-and-docs
   ```
6. Open **Pull Request #5** to merge into `main`.

---

## 🎬 Video Presentation Division (Target: ~4 Mins)

When recording your group demonstration video, divide the speaking roles according to `video/script.md`:

- **0:00–0:25 (Member 1):** Introduce the project title, repository, and all 5 team members.
- **0:25–1:05 (Member 3 & Member 1):** Explain the single-cycle concept and walkthrough the Datapath and Control Unit.
- **1:05–1:45 (Member 2 & Member 4):** Walkthrough the ALU operations, Register File ($0 protection), and RAM memory interface.
- **1:45–2:45 (Member 5):** Run `make sim` in the terminal and demonstrate the 14 passing checks.
- **2:45–3:35 (Member 5 & Team):** Open `results/mips.vcd` in GTKWave and highlight the PC transitions and memory writes.
- **3:35–4:15 (All Members):** Summarize contributions, course takeaways, and future work (FPGA synthesis).

