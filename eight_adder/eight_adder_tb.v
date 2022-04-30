`timescale 1ms / 1ms  

module eight_adder_tb;
	reg[7:0] A, B;
	reg Cin;
	wire[7:0] S;
	wire Cout;

	eight_adder test(A, B, Cin, S, Cout);

	initial begin
		$display("  A      B  Cin      S Cout");
		$monitor("%d;   %d;   %b;   %d;   %b", A, B, Cin, S, Cout);
	end

	initial begin
		A = 9;
		B = 10;
		Cin = 0;
		#1;

		Cin = 1;
		#1;

		A = 254;
		B = 1;
		Cin = 0;
		#1;

		Cin = 1;
		#1;
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
