`include "../eight_adder/eight_adder.v"

module alu(
		input[7:0] A, B, // inputs to operate on
		input[2:0] S, // operation-select input
		output[7:0] D, // output
		output C // carry-out
	);

	wire Cin;
	wire Cout;
	wire[7:0] adder_out;
	reg[8:0] intermediate;

	wire add_or_sub = ~(S[2] + S[1]); // add or subtract

	// set up the output multiplexer
	assign C = add_or_sub ? Cout : intermediate[8];
	assign D = add_or_sub ? adder_out : intermediate[7:0];
	assign Cin = 0; // TODO: use this

	eight_adder adder(A, B, Cin, adder_out, Cout);

	always @(A, B, S) begin
		case(S)
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
