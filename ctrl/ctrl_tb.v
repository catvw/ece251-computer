`timescale 1ms / 1ms

`define MEMFILE "program.bin"
//`define PRINT_STUFF

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
		#1 clock <= 1; // and we're away!
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
