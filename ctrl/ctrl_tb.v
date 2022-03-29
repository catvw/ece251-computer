`timescale 1ms / 1ms
`include "../mem/mem.v"
`include "../alu/alu.v"
`include "../mult/mult.v"
`include "../div/div.v"

module ctrl_tb;
	reg clock;

	reg mem_clock;
	reg mem_write;

	reg[7:0] address, to_mem;
	wire[7:0] from_mem;
	wire[7:0] ctrl_addr_out, ctrl_to_mem;
	reg[7:0] ctrl_from_mem;
	wire ctrl_mem_clock;
	wire ctrl_mem_write;

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

		ctrl_addr_out,
		ctrl_from_mem,
		ctrl_to_mem,
		ctrl_mem_clock,
		ctrl_mem_write
	);

	mem test_mem(mem_clock, mem_write, address, to_mem, from_mem);
	always #20 clock = !clock;

	integer program_file;
	reg[7:0] next_instr;
	reg[7:0] next_addr;
	initial begin
		// read the program into memory
		next_addr = 8'b0;
		program_file = $fopen("program.bin", "r");
		mem_write = 1;
		assign to_mem = next_instr;
		assign address = next_addr;
		while ($fread(next_instr, program_file)) begin
			// cycle the memory clock and move to the next address
			mem_clock = 1;
			#1 mem_clock = 0;
			#1 ++next_addr;
		end
		deassign to_mem;
		deassign address;
		$fclose(program_file);

		// hook up memory and control
		assign mem_clock = ctrl_mem_clock;
		assign mem_write = ctrl_mem_write;
		assign address = ctrl_addr_out;
		assign to_mem = ctrl_to_mem;
		assign ctrl_from_mem = from_mem;

		clock <= 1; // and we're away!
	end
endmodule
