# Single-Cycle MIPS-Like Processor with Memory Interface

A 32-bit educational processor implemented in Verilog. It fetches and executes a small set of arithmetic, logic, memory, branch, and jump instructions using a single-cycle datapath and a separate data-memory interface.

## Project status

The modular design has been run in EDA Playground using Icarus Verilog. The shared simulation log reports **14 passing directed checks**. These checks provide evidence for the included test program, not exhaustive verification. Synthesis, timing, and FPGA implementation have not been verified here.

## Supported instructions

- **R-type:** `add`, `sub`, `and`, `or`, `slt` (signed).
- **Immediate and memory:** `addi`, `lw`, `sw`.
- **Control flow:** `beq`, `j`.

This is a MIPS-like teaching subset, not a complete MIPS32 implementation. In particular, it omits branch/jump delay slots, overflow and address exceptions, interrupts, and memory wait states. Arithmetic wraps on overflow. The memory model uses combinational reads; using synchronous FPGA block RAM would require a timing or architectural change.

## Datapath overview

The program counter selects an instruction from instruction memory. The control unit decodes it, the register file supplies operands, and the ALU performs an operation or computes a memory address. A load selects memory data for register write-back; a store writes register data to memory. The next PC selects sequential execution, a taken branch, or a jump. The PC and register file update on rising clock edges.

The register file has 32 registers with register zero hardwired to zero. The included data memory supports aligned byte addresses from 0 to 1020; invalid reads return zero and invalid writes are ignored. The instruction memory uses PC bits 9:2 and aliases outside its 1 KiB range. Reset clears the PC and registers but does not clear data memory.

## Repository contents

- `rtl/mips.v` — top-level processor and datapath connections.
- `rtl/alu.v`, `rtl/alu_control.v` — ALU and operation decoder.
- `rtl/control_unit.v` — instruction control signals.
- `rtl/regfile.v`, `rtl/imem.v`, `rtl/data_memory.v` — registers and memory models.
- `tb/tb_mips.v` — self-checking testbench.
- [`report/report.pdf`](report/report.pdf) — project report.
- [`result/project-screenshot.png`](result/project-screenshot.png) — simulation waveform screenshot.
- [`docs/team_guide.md`](docs/team_guide.md) — team workflow and module guide.

## Run the simulation locally

Install Icarus Verilog (`iverilog` and `vvp`) and run these commands from the repository root. **The testbench expects a file named `test.hex` in the repository root.** If it is not in your checkout, create it with the contents below before running the simulation:

```text
20010005
2002fffd
00221820
00222022
00222824
00223025
0041382a
ac030000
8c080000
11030001
200a0063
2009002a
10220001
200b0007
ac0b0004
08000011
200a0058
20000001
08000012
00000000
00000000
00000000
00000000
00000000
```

Compile and run:

```bash
iverilog -g2012 -s tb_mips -o sim rtl/*.v tb/tb_mips.v
vvp sim
```

The expected final message is `PASS: all checks completed`. A missing `test.hex` prevents the instruction program from loading. The simulator creates `dump.vcd` in the current directory. If GTKWave is installed, view it with:

```bash
gtkwave dump.vcd
```

## Run on EDA Playground

1. Select SystemVerilog/Verilog and Icarus Verilog.
2. Paste the contents of all seven files in `rtl/` into the Design pane, one after another.
3. Paste `tb/tb_mips.v` into the Testbench pane.
4. Add a file named `test.hex` and paste the program above.
5. Select **Open EPWave after run**, then click **Run**. In EPWave, add `clk`, `reset`, `pc`, `instr`, `addr`, `wdata`, `rdata`, and `we`.

## Verification

The testbench checks register-zero protection, positive and negative immediates, five R-type operations, store/load results, taken and untaken branches, and jump behavior. The waveform screenshot shows a store of `2` to address `0` followed by a load from the same address. More boundary, unsupported-instruction, and timing tests are needed for broader confidence.

## Team

- Ravichandra Shinde
- Sayooj S B
- Satya Prakash
- Shobhit Bararia
- Siddharth Dangi

See the report and Git history for the group's agreed and actual contributions.

## Demonstration video

Add the link to the recorded prototype video here once it is available to the evaluator.
