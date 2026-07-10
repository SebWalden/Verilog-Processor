# 16-bit Shared-Bus Microprocessor

A hardware description and verification pipeline for a custom 16-bit microprocessor. The architecture implements a single-bus datapath layout running custom compiled instructions, supporting register manipulation, basic data memory access, status flag tracking, and hardware stack management.

## Architectural Overview

The processor is modularised into separate hardware files, each handling a specific element of the processing workflow:

* **`simple_processor.v`**: The top-level structural module. It ties the execution states, control logic signals, registers, and memory modules together onto a shared 16-bit data bus.
* **`instruction_decoder.v`**: A combinational block that splits incoming 16-bit instructions into specific fields: Opcode [15:12], Destination Register Rx [11:10], Source Register Ry [9:8], and an Immediate value [7:0].
* **`instruction_memory.v`**: Acts as the ROM block holding the pre-compiled instructions for execution tracking.
* **`data_memory.v`**: A 256-word x 16-bit FPGA-optimised RAM space utilised for LD (load), ST (store), PUSH, and POP hardware stack routines.
* **`pc_register.v`**: An 8-bit program counter register tracking the execution pointer address with asynchronous reset control.
* **`register16.v`**: Generic, parameterised 16-bit structural register instances used for general-purpose storage (r0, r1, r2) as well as temporary operational staging units (a_reg, g_reg).
* **`status_register.v`**: The conditional flag unit tracking Zero (zero_flag), Overflow (overflow_flag), and Carry (carry_flag) statuses resulting from ALU arithmetic operations.
* **`tri_buffer.v`**: Tri-state buffer modules managing datapath line access, ensuring only one hardware source drives the shared bus line at any single clock cycle to prevent line contention.
* **`seven_seg_decoder.v`**: An active-low seven-segment output display utility to translate hardware hex states into readable values on a physical board setup.
* **`simple_processor_TB.v`**: Testbench file designed for verification simulation loops, handling file dumping for wave rendering.

---

# 1. Compile the codebase
iverilog -o processor_sim simple_processor_TB.v simple_processor.v instruction_decoder.v instruction_memory.v data_memory.v pc_register.v register16.v status_register.v tri_buffer.v seven_seg_decoder.v

# 2. Run the simulation execution loop (generates processor_waveform.vcd)
vvp processor_sim

# 3. View signal state waveforms in GTKWave
gtkwave processor_waveform.vcd

## Instruction Format

Instructions are structured as standard 16-bit words divided into logical bit regions:

| 15          12 | 11       10 | 9         8 | 7              0 |
+----------------+--------------+-------------+------------------+
|     Opcode     |      Rx      |     Ry      |    Immediate     |

Opcode map

0000 LDI    (0)
0001 MOV    (1)
0010 ADD    (2)
0011 SUB    (3)
0100 MUL    (4)
0101 MAC    (5)
0110 PUSH   (6)
0111 POP    (7)
1000 CALL   (8)
1001 RET    (9)
1010 LD     (a)
1011 ST     (b)
1100 JMP    (c)
1101 JZ     (d)
1110 JO     (e)
1111 HALT   (f)
