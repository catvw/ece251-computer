`timescale 1ms / 1ms  

module alu_tb;
	reg[7:0] A, B;
	reg[2:0] S;
	wire[7:0] D;
	wire C;

	initial begin
		$dumpfile("test.vcd");
		$dumpvars(0, A, B, S, D, C);
		$display("S              A                      B                      D                      C");
		$monitor("%b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h); %b (%d) (0x%h)",
			S, S, S, A, A, A, B, B, B, D, D, D, C, C, C);
	end

	alu test_alu(A, B, S, D, C);
	initial begin
		A = 8'h83;
		B = 8'h06;
		S = 3'h0;

		for (integer i = 0; i <= 6; ++i) begin
			#10 S = S + 8'h01;
		end
	end
endmodule
