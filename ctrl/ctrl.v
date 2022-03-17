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

		// communication with the address ALU
		output[7:0] inst_address,
		output[7:0] inst_offset,
		input[7:0] new_inst_address,
		output[2:0] inst_op_select
	);

	// external variables
	wire clock;

	reg[7:0] A, B;
	wire[2:0] S;
	wire[7:0] D;
	wire C;

	reg[7:0] address;
	wire[7:0] from_mem;
	reg[7:0] to_mem;
	reg mem_clock;
	reg mem_write;

	wire[7:0] inst_address;
	wire[7:0] inst_offset;
	wire[7:0] new_inst_address;
	reg[2:0] inst_op_select;

	// internal variables
	reg[7:0] accumulator;
	reg[7:0] register_file[7:0];
	reg[7:0] next_instr;
	reg branch;
	wire acc_to_reg;

	assign inst_address = register_file[7];
	
	assign inst_offset = 
		branch ? {{4{next_instr[3]}}, next_instr[3:0]} : // sign-extended offset
		         8'b1; // just move one ahead if not branching

	assign acc_to_reg = next_instr[3]; // the D bit for moves
	assign S = next_instr[5:3]; // the ALU select bits encoded in ALU insts

	initial begin
		mem_clock = 0;
		mem_write = 0;
		register_file[7] = 8'b0;
		inst_op_select = 3'b0; // always add
		//$monitor("0x%h: %b (%d)", register_file[7], next_instr, next_instr);
	end

	always @(posedge clock) begin
		// reset from last cycle
		branch <= 0;

		// load the next instruction from memory
		address <= register_file[7];
		mem_write <= 0;
		mem_clock <= 1;
		#1;
		next_instr <= from_mem;
		#1;
		$display("0x%h: %d (%b)", address, next_instr, next_instr);
		mem_clock = 0;

		case(next_instr[7:4])
			4'b0000: begin // ADD/SUB
				$display("  ADD/SUB %b", next_instr[3:0]);
				A <= accumulator;
				B <= register_file[next_instr[3:0]];
				#1; // do the thing
				accumulator <= D;
				#1;
			end
			4'b0001: begin // AND/OR
				$display("  AND/OR %b", next_instr[3:0]);
				A <= accumulator;
				B <= register_file[next_instr[3:0]];
				#1; // do the thing
				accumulator <= D;
				#1;
			end
			4'b0010: begin // LSL/LSR
				$display("  LSL/LSR %b", next_instr[3:0]);
				A <= accumulator;
				B <= {5'b0, next_instr[2:0]};
				#3; // do the thing
				accumulator <= D;
			end

			4'b0100: begin // B
				$display("  B %b", next_instr[3:0]);
				// bring branch line high to set up instruction ALU
				branch <= 1;
			end

			4'b0101: begin // BZ
				$display("  BZ %b", next_instr[3:0]);
				// bring branch line high if accumulator is zero
				if (accumulator == 0) branch <= 1; // XXX; use ANDs
			end

			4'b0110: begin // BNN
				$display("  BNN %b", next_instr[3:0]);
				// bring branch line high if accumulator is nonnegative
				branch <= ~accumulator[7]; // TODO: use a proper MUX for this
			end

			4'b1100: begin // SET
				$display("  SET %b", next_instr[3:0]);
				accumulator[3:0] <= next_instr[3:0];
			end

			4'b1101: begin // MOV
				$display("  MOV %b", next_instr[3:0]);
				if (acc_to_reg)
					register_file[next_instr[2:0]] <= accumulator;
				else
					accumulator <= register_file[next_instr[2:0]];
			end
		endcase

		#1;
		$display("  accumulator is %b", accumulator);

		#1;
		register_file[7] = new_inst_address; // TODO: use the ALU for this
	end
endmodule
