module div_tb;
	reg[7:0] A, B;
	wire[7:0] Q;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, Q);
		$display("A                      B                      Q");
		$monitor("%b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h)",
			A, A, A, B, B, B, Q, Q, Q);
	end

	reg clock;
	reg start;
	wire complete;
	div test_div(A, B, clock, start, Q, complete);

	always #10 clock = !clock;

	initial begin
		A = 8'd18;
		B = 8'd3;
		clock = 0;
		start = 1;
	end

	always @(posedge complete) begin
		#1 start = 0;
		#1 A = A - 1;
		#1 start = 1;

		if (A == 10) $finish;
	end
endmodule
