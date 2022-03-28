`ifndef ALU
`define ALU

`include "../eight_adder/eight_adder.v"
`include "../twos_comp/twos_comp.v"

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

	wire add_or_sub = ~(S[2] | S[1]); // + or -
	wire and_or_xor_not = S[1]; // one of &|^~
	wire[7:0] B_neg; // B negated in two's complement
	wire[7:0] B_multi = S[0] ? B_neg : B; // multiplexed adder input

	// logical operation output; see REPORT.md for discussion
	wire[7:0] S2e = {8{S[2]}};
	wire[7:0] S0e = {8{S[0]}};
	wire[7:0] logical_out =
		(S0e & (A ^ B)) | (~S2e & A & B) | (S2e & ~S0e & ~A);

	// set up the output multiplexer
	assign C = add_or_sub ? Cout :
		and_or_xor_not ? 1'b0 :
		intermediate[8]; // not always carry-out
	assign D = add_or_sub ? adder_out :
		and_or_xor_not ? logical_out :
		intermediate[7:0];
	assign Cin = 0; // TODO: use this

	eight_adder adder(A, B_multi, Cin, adder_out, Cout);
	twos_comp comp_calc(B, B_neg);

	always @(A, B, S) begin
		case(S)
			3'b100:
				intermediate = A << B;
			3'b101:
				intermediate = A >> B;
		endcase
	end
endmodule

`endif
