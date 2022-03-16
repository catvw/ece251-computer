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

	wire[7:0] from_mem;
	reg[7:0] to_mem;
	reg mem_clock;
	reg mem_write;

	// internal variables
	reg[7:0] register_file[7:0];

	initial begin
		register_file[7] = 8'b0;
		$monitor("PC = 0x%h", register_file[7]);
	end

	always @(posedge clock) begin
		register_file[7] = register_file[7] + 1; // TODO: use the ALU for this
	end
endmodule
