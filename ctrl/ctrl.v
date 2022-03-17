module ctrl(
		input clock,

		// communication with the memory module
		output[7:0] address,
		input[7:0] from_mem,
		output[7:0] to_mem,
		output mem_clock,
		output mem_write,

		// communication with the address ALU
		output[7:0] inst_address,
		output[7:0] inst_offset,
		input[7:0] new_inst_address,
		output[2:0] inst_op_select
	);

	// external variables
	wire clock;

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
	reg[7:0] register_file[7:0];
	reg[7:0] next_instr;
	reg branch;

	assign inst_address = register_file[7];
	
	assign inst_offset = 
		branch ? {{4{next_instr[3]}}, next_instr[3:0]} : // sign-extended offset
		         8'b1; // just move one ahead if not branching

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
			4'b0100: begin // B
				$display("branch");
				// bring branch line high to set up instruction ALU
				branch <= 1;
			end
		endcase

		#1;
		register_file[7] = new_inst_address; // TODO: use the ALU for this
	end
endmodule
