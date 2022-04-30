`include "../alu/alu.v"
`include "../mult/mult.v"
`include "../div/div.v"
`include "../eight_adder/eight_adder.v"

// program counter
`define PC register_file[7]

module ctrl(
		input clock,

		// communication with the memory module
		output[7:0] address,
		input[7:0] from_mem,
		output[7:0] to_mem,
		output mem_clock,
		output mem_write
	);

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, clock, exec_instr, exec_register, accumulator, ALU_result,
			next_exec, stall, address, to_mem, from_mem, is_branch,
			should_near_branch, `PC, next_pc);
	end

	// external variables
	reg[7:0] address;
	wire[7:0] from_mem;
	reg[7:0] to_mem;
	wire mem_clock;
	reg mem_write;

	assign #1 mem_clock = clock; // delay to allow set-up time

	// internal variables
	reg[7:0] accumulator;
	reg[7:0] register_file[7:0];

	reg[7:0] fetch_address;
	reg[7:0] fetch_instr;

	reg[7:0] exec_instr;
	reg[7:0] exec_register;

	reg stall_for_div;
	wire is_load_store; // only stalls for one cycle, so all we need to check
	wire stall = stall_for_div | is_load_store;

	// external module hookups
	wire[2:0] ALU_op = exec_instr[5:3];
	wire[7:0] ALU_result;
	wire ALU_Cout;
	alu general_alu(accumulator, exec_register, ALU_op, ALU_result, ALU_Cout);

	wire[7:0] product;
	mult general_mult(accumulator, exec_register, product);

	wire[7:0] quotient;
	wire div_complete;
	div general_div(accumulator, exec_register, clock, stall_for_div, quotient,
	                div_complete);

	// instruction logic lines
	wire is_branch = ~exec_instr[7] & exec_instr[6];
	wire is_register_branch = is_branch &
	                          exec_instr[5] &
	                          exec_instr[4];
	wire is_near_branch = is_branch & ~is_register_branch;

	wire is_alu = ~(exec_instr[7] | exec_instr[6]);
	wire is_move = exec_instr[7] &
	               ~exec_instr[6] &
	               exec_instr[5] &
	               ~exec_instr[4];
	assign is_load_store = exec_instr[7] &
	                       exec_instr[6] &
	                       exec_instr[5] &
	                       ~exec_instr[4];

	wire is_mul_div = exec_instr[7] &
	                  ~(exec_instr[6] |
	                    exec_instr[5] |
	                    exec_instr[4]);
	wire is_mul = is_mul_div & ~exec_instr[3];
	wire is_div = is_mul_div & exec_instr[3];

	wire is_set = exec_instr[7] &
	              exec_instr[6] &
	              ~exec_instr[5];
	wire is_sel = is_set & ~exec_instr[4];
	wire is_seh = is_set & exec_instr[4];

	wire is_adi = exec_instr[7] &
	              ~exec_instr[6] &
	              ~exec_instr[5] &
	              exec_instr[4];

	// branching logic
	wire should_near_branch = is_near_branch & (
		(
			// branch if zero
			exec_instr[4] & ~(
				accumulator[7] |
				accumulator[6] |
				accumulator[5] |
				accumulator[4] |
				accumulator[3] |
				accumulator[2] |
				accumulator[1] |
				accumulator[0]
			)
		) |
		// branch if nonnegative
		(exec_instr[5] & ~accumulator[7]) |
		// branch unconditionally
		~(exec_instr[5] | exec_instr[4])
	);

	// multiplexer for next instruction to execute
	wire[7:0] next_exec = stall ? 8'hFF : from_mem;

	// program counter advance calculation
	wire[7:0] near_jump_next_pc;
	wire[7:0] next_pc =
		// if we're doing a register branch, set to the appropriate register;
		// else, just take the near-jump option (constant + PC + advance)
		is_register_branch ? (
			exec_instr[3] ? exec_register : accumulator
		) :
		near_jump_next_pc;
	wire pc_adder_Cout;

	// lower 4 instruction bits, sign-extended
	wire[7:0] sign_ext_immediate = {{4{exec_instr[3]}}, exec_instr[3:0]};

	// immediate ANDed with whether we're executing a near-branch
	wire[7:0] cond_branch_diff = {8{should_near_branch}} & sign_ext_immediate;

	// whether we should just advance the program counter by one
	wire advance_by_one = ~(stall | should_near_branch);

	// dedicated adders for a few things
	eight_adder pc_adder(`PC, cond_branch_diff, advance_by_one,
	                     near_jump_next_pc, pc_adder_Cout);

	wire[7:0] acc_plus_immed;
	wire immed_adder_Cout;
	eight_adder immed_adder(accumulator, sign_ext_immediate, 1'b0,
	                        acc_plus_immed, immed_adder_Cout);

	initial begin
		fetch_address <= 8'b0;
		fetch_instr <= 8'hFF;
		exec_instr <= 8'hFF;
		stall_for_div <= 0;

		accumulator <= 8'b0;
		register_file[0] <= 1;
		register_file[1] <= 2;
		register_file[2] <= 3;
		register_file[3] <= 5;
		register_file[4] <= 7;
		register_file[5] <= 11;
		register_file[6] <= 13;
		register_file[7] <= 8'hFF; // so that the *next* address is 0

		mem_write <= 0;
	end

	always @(negedge clock) begin
		// finish divide or instruction/data fetch
		exec_instr <= next_exec;

		// load from memory if we need to do so
		accumulator <=
			is_load_store & ~exec_instr[3] ? from_mem : accumulator;

		// read the register for the upcoming operation
		exec_register <= register_file[from_mem[2:0]];
`ifdef PRINT_STUFF
		$display("  accumulator is %b (%d)", accumulator, accumulator);
`endif
	end

	always @(posedge clock) begin
		`PC <= next_pc;

		// set the next value of the accumulator; could be done more
		// efficiently in actual hardware, but whatever
		accumulator <=
			is_alu ? ALU_result :
			(is_move & ~exec_instr[3]) ? exec_register :
			is_mul ? product :
			is_sel ? {accumulator[7:4], exec_instr[3:0]} :
			is_seh ? {exec_instr[3:0], accumulator[3:0]} :
			is_adi ? acc_plus_immed :
			stall_for_div & div_complete ? quotient :
			accumulator;

		// write to registers if necessary
		if (is_move & exec_instr[3])
			register_file[exec_instr[2:0]] <= accumulator;

		if (is_register_branch)
			register_file[exec_instr[2:0]] <= near_jump_next_pc;

		// set up memory read/write
		mem_write <= is_load_store & exec_instr[3];
		address <= is_load_store ? exec_register : next_pc;
		to_mem <= accumulator; // will do nothing if mem_write is zero

		// update division stall flag
		stall_for_div <= is_div | (stall_for_div & ~div_complete);

`ifdef PRINT_STUFF
		// print out fun stuff
		$display("0x%h: %h (%b)", address, exec_instr, exec_instr);
		case(exec_instr[7:4])
			4'b0000: $display("  ADD/SUB %b", exec_instr[3:0]);
			4'b0001: $display("  AND/OR %b", exec_instr[3:0]);
			4'b0010: $display("  LSL/LSR %b", exec_instr[3:0]);
			4'b0011: $display("  NOT/XOR %b", exec_instr[3:0]);

			4'b1100: $display("  SEL %b", exec_instr[3:0]);
			4'b1101: $display("  SEH %b", exec_instr[3:0]);

			4'b1110: $display("  LD/ST %b", exec_instr[3:0]);

			4'b0100: $display("  B %b", exec_instr[3:0]);
			4'b0101: $display("  BZ %b", exec_instr[3:0]);
			4'b0110: $display("  BNN %b", exec_instr[3:0]);
			4'b0111: $display("  BA/BR %b", exec_instr[3:0]);

			4'b1000: $display("  MUL/DIV %b", exec_instr[3:0]);

			4'b1001: $display("  ADI %b", exec_instr[3:0]);
			4'b1010: $display("  MOV %b", exec_instr[3:0]);

			4'b1111: begin
				case(exec_instr[3:0])
					4'b0000: $display("  WR");
					4'b1111: $display("  NO");

					4'b1010: begin
						$display("  HLT");
					end
				endcase
			end

			default: begin // just in case
				$display("illegal instruction");
			end
		endcase

		if (stall_for_div & div_complete) begin
			$display("  divide finished");
		end
`endif
		
		if (exec_instr[7:4] == 4'b1111) begin
			case(exec_instr[3:0])
				4'b0000: $display("acc: 0x%h / %d / 0b%b",
					accumulator, accumulator, accumulator);
				4'b1010: $finish;
			endcase
		end
	end
endmodule

/*
 * Copyright (C) 2022, C. R. Van West
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
