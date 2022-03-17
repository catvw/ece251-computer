module alu(
		input[7:0] A, B, // inputs to operate on
		input[2:0] S, // operation-select input
		output[7:0] D, // output
		output C // carry-out
	);

	reg[8:0] intermediate;
	assign C = intermediate[8]; // not always strictly "carry-out"
	assign D = intermediate[7:0];

	always @(A, B, S) begin
		case(S)
			3'b000:
				intermediate = A + B;
			3'b001:
				intermediate = A - B;
			3'b010:
				intermediate = A & B;
			3'b011:
				intermediate = A | B;
			3'b100:
				intermediate = A << B;
			3'b101:
				intermediate = A >> B;
			3'b110:
				intermediate = A ^ B;
			3'b111:
				intermediate = ~A;
		endcase
	end
endmodule
