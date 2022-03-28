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
