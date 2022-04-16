`timescale 1ms / 1ms

`define MEMFILE "program.bin"

`include "../mem/mem.v"
`include "../alu/alu.v"
`include "../mult/mult.v"
`include "../div/div.v"

module ctrl_tb;
	reg clock;

	wire mem_clock;
	wire mem_write;
	wire[7:0] address;
	wire[7:0] to_mem;
	wire[7:0] from_mem;

	ctrl test_ctrl(
		clock,

		address,
		from_mem,
		to_mem,
		mem_clock,
		mem_write
	);

	mem test_mem(
		mem_clock,
		mem_write,
		address,
		to_mem,
		from_mem
	);

	always #20 clock = !clock;

	initial begin
		clock <= 1; // and we're away!
	end
endmodule
