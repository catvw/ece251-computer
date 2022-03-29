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
		output mem_write
	);

	// external variables
	reg[7:0] address;
	wire[7:0] from_mem;
	reg[7:0] to_mem;
	reg mem_clock;
	reg mem_write;

	// internal variables
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
