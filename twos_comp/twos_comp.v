`ifndef TWOS_COMP
`define TWOS_COMP

`include "../eight_adder/eight_adder.v"

module twos_comp(
		input[7:0] Ain,
		output[7:0] Aout
	);

	wire Cout; // just a placeholder
	wire[7:0] Ain_bitneg = ~Ain; // just 8 NOT gates
	eight_adder comp_calc(Ain_bitneg, 8'b1, 1'b0, Aout, Cout);
endmodule

`endif
