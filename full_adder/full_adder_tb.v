`timescale 1ms / 1ms  

module full_adder_tb;
	reg[2:0] num;
	wire A, B, Cin;
	wire S, Cout;

	assign A = num[2];
	assign B = num[1];
	assign Cin = num[0];

	full_adder test(A, B, Cin, S, Cout);

	initial begin
		$display("A   B   Cin  | S   Cout");
		$monitor("%b   %b   %b    | %b   %b", A, B, Cin, S, Cout);
	end

	initial begin
		num = 3'b000;

		for (integer i = 0; i <= 6; ++i) begin
			#10 num = num + 1;
		end
	end
endmodule
