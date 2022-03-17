module div(
		input[7:0] A, B,
		input clock,
		input start, // rising-edge signal to start a new division
		output[7:0] Q, // Q = A / B
		output complete // whether we're done
	);

	// external variables
	wire[7:0] A, B;
	wire clock;
	wire start;
	reg[7:0] Q;
	reg complete;

	// internal variables
	reg[15:0] divisor;
	reg[15:0] remainder;
	reg[7:0] quotient;
	reg[3:0] counter; // 4 bits is all we need
	wire remainder_pos;

	assign remainder_pos = ~remainder[15];

	initial begin
		complete = 0;
		counter = 0;
	end

	always @(posedge start) begin
		complete <= 0;
		remainder <= {8'b0, A};
		divisor <= {B, 8'b0};
		quotient <= 8'b0;
		counter <= 0;
	end

	// all done according to the division algorithm in Comp Org & Design
	always @(posedge clock) begin
		#1 remainder <= remainder - divisor;
		//#1 $display(" 1 r %b | d %b | q %b", remainder, divisor, quotient);
		#1 quotient <= quotient << 1;
		#1 quotient[0] <= remainder_pos;
		#1 remainder <= remainder_pos ? remainder :
		                                remainder + divisor;
		#1 divisor <= divisor >> 1;
		#1 ++counter;

		#1;
		if (counter[3] & counter[0] & ~complete) begin
			// we're done, copy out everything
			complete <= 1;
			Q <= quotient;
		end
		//#1 $display(" 2 r %b | d %b | q %b", remainder, divisor, quotient);
	end

endmodule
