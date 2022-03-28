`ifndef SHIFT
`define SHIFT

module shift(
		input[7:0] Ain,
		input[2:0] bits,
		input dir,
		output[7:0] Aout
	);

	wire[2:0] nbits = ~bits;

	wire[7:0] sh0 = {8{nbits[2] & nbits[1] & nbits[0]}};
	wire[7:0] sh1 = {8{nbits[2] & nbits[1] & bits[0]}};
	wire[7:0] sh2 = {8{nbits[2] & bits[1] & nbits[0]}};
	wire[7:0] sh3 = {8{nbits[2] & bits[1] & bits[0]}};
	wire[7:0] sh4 = {8{bits[2] & nbits[1] & nbits[0]}};
	wire[7:0] sh5 = {8{bits[2] & nbits[1] & bits[0]}};
	wire[7:0] sh6 = {8{bits[2] & bits[1] & nbits[0]}};
	wire[7:0] sh7 = {8{bits[2] & bits[1] & bits[0]}};

	// flip input (and later output) depending on shift direction
	wire[7:0] dir_ext = {8{dir}};
	wire[7:0] inter_in = (~dir_ext & Ain) | (dir_ext & {Ain[0],
	                                                    Ain[1],
	                                                    Ain[2],
	            /* there is, unfortunately, */          Ain[3],
	            /* no short way to do this; */          Ain[4],
	            /* easy in hardware, though */          Ain[5],
	                                                    Ain[6],
	                                                    Ain[7]});

	wire[7:0] inter_out = (sh0 & inter_in) |
		(sh1 & {inter_in[6:0], 1'b0}) |
		(sh2 & {inter_in[5:0], 2'b0}) |
		(sh3 & {inter_in[4:0], 3'b0}) |
		(sh4 & {inter_in[3:0], 4'b0}) |
		(sh5 & {inter_in[2:0], 5'b0}) |
		(sh6 & {inter_in[1:0], 6'b0}) |
		(sh7 & {inter_in[0], 7'b0});

	assign Aout = (~dir_ext & inter_out) | (dir_ext & {inter_out[0],
	                                                   inter_out[1],
	                                                   inter_out[2],
	                                                   inter_out[3],
	                                                   inter_out[4],
	                                                   inter_out[5],
	                                                   inter_out[6],
	                                                   inter_out[7]});
endmodule

`endif
