`timescale 1ms / 1ms  

module twos_comp_tb;
	reg[7:0] Ain;
	wire[7:0] Aout;
	wire signed[7:0] Ain_signed = Ain;
	wire signed[7:0] Aout_signed = Aout;

	twos_comp test(Ain, Aout);

	initial begin
		$monitor("%b (%d) -> %b (%d)", Ain, Ain_signed, Aout, Aout_signed);
	end

	initial begin
		Ain = 9;
		#1 Ain = 255;
		#1 Ain = 127;
		#1 Ain = 128;
		#1 Ain = 0;
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
