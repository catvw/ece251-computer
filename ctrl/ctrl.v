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
	wire clock;

	reg[7:0] address;
	wire[7:0] from_mem;
	reg[7:0] to_mem;
	reg mem_clock;
	reg mem_write;

	// internal variables
	reg[7:0] register_file[7:0];
	reg[7:0] next_instr;

	initial begin
		mem_clock = 0;
		mem_write = 0;
		register_file[7] = 8'b0;
		//$monitor("0x%h: %b (%d)", register_file[7], next_instr, next_instr);
	end

	always @(posedge clock) begin
		address = register_file[7];
		mem_write = 0;
		mem_clock = 1;
		#1;
		next_instr = from_mem;
		$display("0x%h: %d", address, next_instr);
		mem_clock = 0;

		register_file[7] = register_file[7] + 1; // TODO: use the ALU for this
	end
endmodule
