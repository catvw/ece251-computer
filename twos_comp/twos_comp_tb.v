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
