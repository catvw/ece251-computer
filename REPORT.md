# Report on the Design and Implementation of an 8-Bit Computer in Verilog
Designed by Charles Van West throughout Spring '22.

# Instruction Set Architecture
The first task for this computer was the design of the ISA. Since I did not
want overly complex control logic, I created something as close to a MISC
architecture as possible.

## General Choices
Instructions are 8 bits long, so as to be loadable in a single cycle. Unlike
the 4004, which heavily inspired this computer, there are no two-byte
instructions for simplicity. Opcodes usually take up 4 or 5 bits, depending on
the instruction; the rest is reserved for a register specification or an
immediate. Since space within an instruction is highly constrained, this
computer uses an accumulator as both an argument and target register for most
instructions.

The computer is also 8-bit addressed and byte-addressable. This allows only 256
bytes of addressable memory, but, given that it is a computer made fro the
purpose of learning about computer architecture, this was deemed to be fine.

Instruction and data memory are stored in the same bank (von Neumann
architecture).

TODO: maybe split instructions in half: have one-byte and two-byte versions
depending on whether an immediate is necessary. That probably isn't too
complicated.

## Registers
There are 8 registers, so as to fit register specifications into 3 bits each.
Register 7 (`R7`) is also used as the program counter.

## Instructions in Detail
There are about 4 instruction formats, along with a few miscellaneous
special-case instructions. This is not as simple as I would have liked, but
there are not that many bits per instruction, so this seemed the most efficient
use of program space. The instructions (in their respective categories) are
described in the following sections.

### ALU Instructions
Note that this is not called "arithmetic instructions," as multiplication and
division are not ALU operations.

| Name | Format | Example | Description |
| --- | --- | --- | --- |
| (general) | `00 SSS RRR/III` | (see below) | Perform ALU operation SSS on register `RRR`/immediate `III` and the accumulator. |
| `ADD` | `00 000 RRR` | `ADD R1` | Add register `RRR` to the accumulator. |
| `SUB` | `00 001 RRR` | `SUB R3` | Subtract register `RRR` from the accumulator. |
| `AND` | `00 010 RRR` | `AND R6` | Bitwise-AND the accumulator with register `RRR`. |
| `OR` | `00 011 RRR` | `OR R5` | Bitwise-OR the accumulator with register `RRR`. |
| `LSL` | `00 100 CCC` | `LSL #3` | Shift the accumulator left by `CCC` bits. |
| `LSR` | `00 101 CCC` | `LSR #5` | Shift the accumulator right by `CCC` bits. |
| `XOR` | `00 110 RRR` | `XOR R3` | Bitwise-XOR the accumulator with register `RRR`. |
| `NOT` | `00 111 XXX` | `NOT` | Bitwise-negate the accumulator. |

### Special Arithmetic Instructions
Multiply and divide both require specialized hardware, and thus are not ALU
instructions. Note that division requires multiple cycles to complete and
*will* cause a processor stall until finished.

| Name | Format | Example | Description |
| --- | --- | --- | --- |
| (general) | `100 S X RRR` | (see below) | Perform special arithmetic operation `S` on register `RRR` and the accumulator. |
| `MUL` | `100 0 X RRR` | `MUL R0` | Multiply the accumulator by register `RRR` (unsigned). |
| `DIV` | `100 1 X RRR` | `DIV R2` | Divide the accumulator by register `RRR` (unsigned). |

TODO: actually use the extra bit. No reason not to.

### Branch Instructions
All branches (for now) are PC-relative, and the branch constant `CCCC` is
sign-extended to allow branching backwards.

| Name | Format | Example | Description |
| --- | --- | --- | --- |
| (general) | `01 SS CCCC` | (see below) | Perform branch type `SS` to `R7 + CCCC`. |
| `B` | `01 00 CCCC` | (see below) | Unconditionally branch to `R7 + CCCC`. |
| `BZ` | `01 01 CCCC` | (see below) | Branch to `R7 + CCCC` if the accumulator is zero. |
| `BNN` | `01 10 CCCC` | (see below) | Branch to `R7 + CCCC` if the accumulator is nonnegative. |

# Sources
- *Computer Organization and Design: The Hardware/Software Interface, ARM®
  Edition*, David A. Patterson & John L. Hennesey
- *Verilog by Example: A Concise Introduction for FPGA Design*, Blaine Readler
- Intel 4004 datasheet:
  http://datasheets.chipdb.org/Intel/MCS-4/datashts/intel-4004.pdf
