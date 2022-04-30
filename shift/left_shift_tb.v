`timescale 1ms / 1ms  

module left_shift_tb;
	reg[7:0] Ain;
	reg[2:0] bits;
	reg dir;
	wire[7:0] Aout;

	left_shift test(Ain, bits, dir, Aout);

	initial begin
		Ain = 3;
		bits = 0;
		dir = 0;
		for (integer i = 0; i < 8; ++i) begin
			#1 $display("%b << %d -> %b", Ain, bits, Aout);
			bits = bits + 1;
		end

		Ain = 160;
		bits = 0;
		dir = 1;
		for (integer i = 0; i < 8; ++i) begin
			#1 $display("%b >> %d -> %b", Ain, bits, Aout);
			bits = bits + 1;
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
