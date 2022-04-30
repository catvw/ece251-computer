`ifndef FULL_ADDER
`define FULL_ADDER

module full_adder(
		input A, B, Cin, // input numerical and carry bits
		output S, Cout // output sum and carry bits
	);

	wire inter;

	assign inter = A ^ B;
	assign S = inter ^ Cin;
	assign Cout = (inter & Cin) + (A & B);
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
