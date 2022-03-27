module eight_adder(
		input[7:0] A, B, // input numbers
		input Cin, // carry-in
		output[7:0] S, // output sum
		output Cout // carry-out
	);

	wire[6:0] carry; // for inter-stage carries

	full_adder a0(A[0], B[0], Cin, S[0], carry[0]);
	full_adder a1(A[1], B[1], carry[0], S[1], carry[1]);
	full_adder a2(A[2], B[2], carry[1], S[2], carry[2]);
	full_adder a3(A[3], B[3], carry[2], S[3], carry[3]);
	full_adder a4(A[4], B[4], carry[3], S[4], carry[4]);
	full_adder a5(A[5], B[5], carry[4], S[5], carry[5]);
	full_adder a6(A[6], B[6], carry[5], S[6], carry[6]);
	full_adder a7(A[7], B[7], carry[6], S[7], Cout);

endmodule
