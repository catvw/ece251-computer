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

	wire[7:0] A, B, D;
	wire[2:0] S;
	wire C;

	wire[7:0] mA, mB, P;

	wire[7:0] dA, dB, Q;
	wire div_clock, div_start, div_complete;

	wire[7:0] inst_address;
	wire[7:0] inst_offset;
	wire[7:0] new_inst_address;
	wire[2:0] inst_op_select;
	wire inst_carry_out;

	initial begin
//		$dumpfile("test.vcd");
//		$dumpvars(0, clock, write, address, to_mem, from_mem);
//		$display("clock   write   address to_mem  from_mem");
//		$monitor("#%d:     %b;      0x%h;   0x%h;   0x%h",
//			clock, write, address, to_mem, from_mem);
//		$monitor("#%4d: %b", $time, clock);
	end

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

	integer program_file;
	reg[7:0] next_instr;
	reg[7:0] next_addr;
	initial begin
		clock <= 1; // and we're away!
	end
endmodule
