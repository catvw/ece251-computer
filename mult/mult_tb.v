module mult_tb;
	reg[7:0] A, B;
	wire[7:0] P;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, P);
		$display("A                     B                     P");
		$monitor("%b (%d) (0x%0h); %b (%d) (0x%0h); %b (%d) (0x%0h)",
			A, A, A, B, B, B, P, P, P);
	end

	mult test_mult(A, B, P);
	initial begin
		A = 8'h1;
		B = 8'h3;

		for (integer i = 0; i <= 10; ++i) begin
			#10 A = A + 1;
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
