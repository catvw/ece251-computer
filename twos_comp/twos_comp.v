`ifndef TWOS_COMP
`define TWOS_COMP

`include "../eight_adder/eight_adder.v"

module twos_comp(
		input[7:0] Ain,
		output[7:0] Aout
	);

	wire Cout; // just a placeholder
	wire[7:0] Ain_bitneg = ~Ain; // just 8 NOT gates
	eight_adder comp_calc(Ain_bitneg, 8'b1, 1'b0, Aout, Cout);
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
