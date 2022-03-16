`timescale 1ms / 1ms  
`include "../mem/mem.v"

module ctrl_tb;
	reg clock;

	wire mem_clock;
	wire mem_write;

	wire[7:0] address, from_mem, to_mem;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, clock, write, address, to_mem, from_mem);
//		$display("clock   write   address to_mem  from_mem");
//		$monitor("#%d:     %b;      0x%h;   0x%h;   0x%h",
//			clock, write, address, to_mem, from_mem);
//		$monitor("#%4d: %b", $time, clock);
	end

	ctrl test_ctrl(clock, address, from_mem, to_mem, mem_clock, mem_write);
	mem test_mem(mem_clock, write, address, to_mem, from_mem);
	always #1 clock = !clock;

	integer program_file;
	reg[7:0] next_instr;
	reg[7:0] next_addr;
	initial begin
		assign clock = 0; // hold clock at zero until we're ready

		// read the program into memory
		$monitor("%b (%d)", next_instr, next_instr);
		next_addr = 8'b0;
		program_file = $fopen("program.bin", "r");
		while ($fread(next_instr, program_file)) begin
			#1 ++next_addr;
		end
		$fclose(program_file);

		deassign clock; // and we're away!
		#20 $finish;
	end
endmodule
