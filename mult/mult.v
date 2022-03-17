module mult(
		input[7:0] A, B,
		output[7:0] P
	);

	wire[7:0] A, B;
	reg[7:0] P;

	always @(A, B) begin
		P = A * B;
	end
endmodule
