module div_tb;
	reg[7:0] A, B;
	wire[7:0] Q;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, Q);
		$display("A                      B                      Q");
		$monitor("%b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h)",
			A, A, A, B, B, B, Q, Q, Q);
	end

	reg clock;
	reg start;
	wire complete;
	div test_div(A, B, clock, start, Q, complete);

	always #10 clock = !clock;

	initial begin
		A = 8'd18;
		B = 8'd3;
		clock = 0;
		start = 1;
	end

	always @(posedge complete) begin
		#1 start = 0;
		#1 A = A - 1;
		#1 start = 1;

		if (A == 10) $finish;
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
