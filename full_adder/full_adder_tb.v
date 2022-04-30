`timescale 1ms / 1ms  

module full_adder_tb;
	reg[2:0] num;
	wire A, B, Cin;
	wire S, Cout;

	assign A = num[2];
	assign B = num[1];
	assign Cin = num[0];

	full_adder test(A, B, Cin, S, Cout);

	initial begin
		$display("A   B   Cin  | S   Cout");
		$monitor("%b   %b   %b    | %b   %b", A, B, Cin, S, Cout);
	end

	initial begin
		num = 3'b000;

		for (integer i = 0; i <= 6; ++i) begin
			#10 num = num + 1;
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
