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

	wire should_branch = is_branch & (
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
	wire[7:0] next_pc;
	wire pc_adder_Cout;

	// lower 4 instruction bits, sign-extended
	wire[7:0] sign_ext_branch_diff = {{4{exec_instr[3]}}, exec_instr[3:0]};

	// branch diff ANDed with whether we're executing a branch
	wire[7:0] cond_branch_diff = {8{should_branch}} & sign_ext_branch_diff;

	// whether we should just advance the program counter by one
	wire advance_by_one = ~(stall | should_branch);

	eight_adder pc_adder(`PC, cond_branch_diff, advance_by_one, next_pc,
	                     pc_adder_Cout);

	always @(negedge clock) begin
		// finish divide or instruction/data fetch
		exec_instr <= next_exec;

		// load from memory if we need to do so
		accumulator <=
			is_load_store & ~exec_instr[3] ? from_mem : accumulator;

		// read the register for the upcoming operation
		exec_register <= register_file[from_mem[2:0]];
		$display("  accumulator is %b (%d)", accumulator, accumulator);
	end

	always @(posedge clock) begin
		`PC <= next_pc;

		// set the next value of the accumulator
		accumulator <=
			is_alu ? ALU_result :
			(is_move & ~exec_instr[3]) ? exec_register :
			is_mul ? product :
			is_sel ? {accumulator[7:4], exec_instr[3:0]} :
			is_seh ? {exec_instr[3:0], accumulator[3:0]} :
			stall_for_div & div_complete ? quotient :
			accumulator;

		// write to registers if necessary
		if (is_move & exec_instr[3])
			register_file[exec_instr[2:0]] <= accumulator;

		// set up memory read/write
		mem_write <= is_load_store & exec_instr[3];
		address <= is_load_store ? exec_register : next_pc;
		to_mem <= accumulator; // will do nothing if mem_write is zero

		// update division stall flag
		stall_for_div <= is_div | (stall_for_div & ~div_complete);

		// print out fun stuff (and also run halt/illegal)
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

			4'b1000: $display("  MUL/DIV %b", exec_instr[3:0]);

			4'b1001: $display("  ADI %b", exec_instr[3:0]);
			4'b1010: $display("  MOV %b", exec_instr[3:0]);

			4'b1111: begin
				case(exec_instr[3:0])
					4'b1111: $display("  NO");

					4'b1010: begin
						$display("  HLT");
						$finish;
					end
				endcase
			end

			default: begin // just in case
				$display("illegal instruction");
				$finish;
			end
		endcase

		if (stall_for_div & div_complete) begin
			$display("  divide finished");
		end
	end
endmodule
