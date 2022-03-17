module mult_tb;
	reg[7:0] A, B;
	wire[7:0] P;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, P);
		$display("A                     B                     P");
		$monitor("%b (%d) (0x%0h); %b (%d) (0x%0h); %b (%d) (0x%0h)",
			A, A, A, B, B, B, P, P, P);
	end

	mult test_mult(A, B, P);
	initial begin
		A = 8'h1;
		B = 8'h3;

		for (integer i = 0; i <= 10; ++i) begin
			#10 A = A + 1;
		end
	end
endmodule
