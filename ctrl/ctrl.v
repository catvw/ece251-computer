`include "../alu/alu.v"
`include "../mult/mult.v"
`include "../div/div.v"

module ctrl(
		input clock,

		// communication with the memory module
		output[7:0] address,
		input[7:0] from_mem,
		output[7:0] to_mem,
		output mem_clock,
		output mem_write,

		// communication with the general-purpose ALU
		output[7:0] A, B,
		output[2:0] S,
		input[7:0] D,
		input C,

		// communication with the multiplier
		output[7:0] mA, mB,
		input[7:0] P,

		// communication with the divider
		output[7:0] dA, dB,
		output div_clock,
		output div_start,
		input[7:0] Q,
		input div_complete,

		// communication with the address ALU
		output[7:0] inst_address,
		output[7:0] inst_offset,
		input[7:0] new_inst_address,
		output[2:0] inst_op_select
	);

	// external variables
	/*
	wire clock;

	wire[7:0] A, B;
	wire[2:0] S;
	wire[7:0] D;
	wire C;

	wire[7:0] mA, mB, P;

	wire[7:0] dA, dB, Q;
	wire div_clock;
	reg div_start;
	wire div_complete;
	*/

	reg[7:0] address;
	wire[7:0] from_mem;
	reg[7:0] to_mem;
	reg mem_clock;
	reg mem_write;

	/*
	wire[7:0] inst_address;
	wire[7:0] inst_offset;
	wire[7:0] new_inst_address;
	reg[2:0] inst_op_select;

	// internal variables
	reg[7:0] accumulator;
	reg[7:0] register_file[7:0];
	reg[7:0] next_instr;
	wire[3:0] inst_arg;
	reg branch;
	reg immediate; // used for ALU ops
	wire acc_to_reg;
	reg div_active;
	wire multi_cycle; // used for multi-cycle instructions (like DIV)

	assign inst_address = register_file[7];
	
	assign inst_offset = 
		branch ? {{4{next_instr[3]}}, next_instr[3:0]} : // sign-extended offset
		multi_cycle ? 8'b0 : // don't move at all if still working
		         8'b1; // just move one ahead if not branching

	assign acc_to_mem = next_instr[3]; // the D bit for moves & LD/ST

	assign A = accumulator;
	assign B = immediate ? {5'b0, next_instr[2:0]} :
	                       register_file[next_instr[2:0]];
	assign S = next_instr[5:3]; // the ALU select bits encoded in ALU insts

	assign mA = accumulator;
	assign mB = register_file[next_instr[2:0]];

	assign dA = accumulator;
	assign dB = register_file[next_instr[2:0]];
	assign div_clock = ~clock & div_active;

	assign multi_cycle = div_active;

	initial begin
		mem_clock = 0;
		mem_write = 0;
		register_file[7] = 8'b0;
		inst_op_select = 3'b0; // always add
		div_active = 0;
		//$monitor("0x%h: %b (%d)", register_file[7], next_instr, next_instr);
	end
	*/

	reg[7:0] accumulator;
	reg[7:0] register_file[7:0];

	reg[7:0] fetch_address;
	reg[7:0] fetch_instr;

	reg[7:0] exec_instr;
	reg[7:0] exec_register;

	reg stall_for_load_store;

	initial begin
		fetch_address <= 8'b0;
		fetch_instr <= 8'hFF;
		exec_instr <= 8'hFF;
		stall_for_load_store <= 0;

		accumulator <= 8'b0;
		register_file[0] <= 0;
		register_file[1] <= 1;
		register_file[2] <= 2;
		register_file[3] <= 3;
		register_file[4] <= 4;
		register_file[5] <= 5;
		register_file[6] <= 6;
		register_file[7] <= 0;

		mem_clock <= 0;
		mem_write <= 0;
	end

	wire[2:0] ALU_op = exec_instr[5:3];
	wire[7:0] ALU_result;
	wire ALU_Cout;
	alu general_alu(accumulator, exec_register, ALU_op, ALU_result, ALU_Cout);

	wire[7:0] product;
	mult general_mult(accumulator, exec_register, product);

	always @(negedge clock) begin
		// handle clock cleanup
		mem_clock <= 0;

		// finish instruction or data fetch
		if (stall_for_load_store) begin
			if (~exec_instr[3]) accumulator <= from_mem;
			exec_instr <= 8'hFF; // no-op, so we don't do anything rash
			stall_for_load_store <= 0;
		end else begin
			exec_instr <= from_mem;
			exec_register <= register_file[from_mem[2:0]];
			register_file[7] = register_file[7] + 1; // TODO: use the ALU for this
		end

		$display("  accumulator is %b (%d)", accumulator, accumulator);
	end

	always @(posedge clock) begin
		// reset from last cycle
		//branch <= 0;

		// start instruction fetch
		mem_write <= 0;
		mem_clock <= 1;
		address <= register_file[7];

		// start instruction execute
		$display("0x%h: %d (%b)", address, exec_instr, exec_instr);

		case(exec_instr[7:4])
			4'b0000: begin
				$display("  ADD/SUB %b", exec_instr[3:0]);
				accumulator <= ALU_result;
			end
			4'b0001: begin
				$display("  AND/OR %b", exec_instr[3:0]);
				accumulator <= ALU_result;
			end
			4'b0010: begin
				$display("  LSL/LSR %b", exec_instr[3:0]);
				accumulator <= ALU_result;
			end
			4'b0011: begin
				$display("  NOT/XOR %b", exec_instr[3:0]);
				accumulator <= ALU_result;
			end

			4'b1100: begin
				$display("  SET %b", exec_instr[3:0]);
				accumulator[3:0] <= exec_instr[3:0];
			end

			4'b1101: begin
				$display("  MOV %b", exec_instr[3:0]);
				if (exec_instr[3]) // outbound to registers
					register_file[exec_instr[2:0]] <= accumulator;
				else
					accumulator <= exec_register;
			end

			4'b1110: begin
				$display("  LD/ST %b", exec_instr[3:0]);
				address <= exec_register;
				if (exec_instr[3]) begin
					mem_write <= 1;
					to_mem <= accumulator;
				end

				// set up special handling on the falling edge
				stall_for_load_store <= 1;
			end

			4'b0100: begin
				$display("  B %b", exec_instr[3:0]);
				// hijack instruction load and program counter addition
				address <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
				register_file[7] <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
			end

			4'b0101: begin
				$display("  BZ %b", exec_instr[3:0]);
				if (accumulator == 0) begin
					address <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
					register_file[7] <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
				end
			end

			4'b0110: begin
				$display("  BNN %b", exec_instr[3:0]);
				if (~accumulator[7]) begin
					address <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
					register_file[7] <= address + {{4{exec_instr[3]}}, exec_instr[3:0]};
				end
			end

			4'b1000: begin
				$display("  MUL %b", exec_instr[3:0]);
				accumulator <= product;
			end

			4'b1111: begin
				$display("  NO");
			end

			4'b1010: begin
				$display("  HLT");
				$finish;
			end

			default: begin // just in case
				$display("illegal instruction");
				$finish;
			end

			/*
			4'b1001: begin // DIV
				$display("  DIV %b", next_instr[3:0]);
				div_start <= ~div_active; // start if we haven't yet
				// stay active until we finish the divide
				div_active <= ~div_active ? 1'b1 :
				                            ~div_complete;

				#4; // finish resolving this cycle
				if (div_complete) begin
					accumulator <= Q;
					$display("  complete");
				end
			end*/
		endcase
	end
endmodule
