`timescale 1ms / 1ms  

module alu_tb;
	reg[7:0] A, B;
	reg[2:0] S;
	wire[7:0] D;
	wire C;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, S, D, C);
		$display("S              A                      B                      D                      C");
		$monitor("%b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h)",
			S, S, S, A, A, A, B, B, B, D, D, D, C, C, C);
	end

	alu test_alu(A, B, S, D, C);
	initial begin
		A = 8'h83;
		B = 8'h06;
		S = 3'h0;

		for (integer i = 0; i <= 6; ++i) begin
			#10 S = S + 8'h01;
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
