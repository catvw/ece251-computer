`ifndef MEM
`define MEM

// inspired by the dual-port memory in Verilog by Example (Readler), though this
// is really single-port memory
module mem(
		input clock,
		input write,
		input[7:0] address,
		input[7:0] in_bus,
		output[7:0] out_bus
	);

	wire[7:0] in_bus;
	reg[7:0] out_bus;

	reg[7:0] memory[255:0]; // as much addressable memory as we have

	integer memfile, read;
	initial begin
		memfile = $fopen(`MEMFILE, "r");
		read = $fread(memory, memfile);
		$fclose(memfile);
	end

	always @(posedge clock) begin
		if (write)
			memory[address] <= in_bus;
		out_bus <= memory[address];
	end
endmodule

`endif

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
