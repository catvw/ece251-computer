module full_adder(
		input A, B, Cin // input numerical and carry bits
		output S, Cout // output sum and carry bits
	);

	wire inter;

	assign inter = A ^ B;
	assign S = inter ^ Cin;
	assign Cout = (inter & Cin) + (A & B);
endmodule;
