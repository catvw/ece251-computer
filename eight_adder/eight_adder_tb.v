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
