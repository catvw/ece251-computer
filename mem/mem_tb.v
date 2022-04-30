`timescale 1ms / 1ms  

`define MEMFILE "empty.mem"

module mem_tb;
	reg clock;
	reg write;
	reg[7:0] address, to_mem;
	wire[7:0] from_mem;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, clock, write, address, to_mem, from_mem);
		$display("clock   write   address to_mem  from_mem");
		$monitor("#%d:     %b;      0x%h;   0x%h;   0x%h",
			clock, write, address, to_mem, from_mem);
	end

	mem test_mem(clock, write, address, to_mem, from_mem);
	initial begin
		clock = 0;
		write = 1;
		to_mem = 8'b0;
		address = 8'h80;

		for (integer i = 0; i < 16; ++i) begin
			#1 clock = 1;
			#1 clock = 0;
			to_mem = to_mem + 1;
			address = address + 1;
		end

		write = 0;
		address = 8'h80;
		for (integer i = 0; i < 16; ++i) begin
			#1 clock = 1;
			#1 clock = 0;
			to_mem = to_mem + 1;
			address = address + 1;
		end
	end
endmodule

/*
 * Copyright (C) 2022, C. R. Van West
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
