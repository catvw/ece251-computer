`ifndef MEM
`define MEM

// inspired by the dual-port memory in Verilog by Example (Readler), though this
// is really single-port memory
module mem(
		input clock,
		input write,
		input[7:0] address,
		input[7:0] in_bus,
		output[7:0] out_bus
	);

	wire[7:0] in_bus;
	reg[7:0] out_bus;

	reg[7:0] memory[255:0]; // as much addressable memory as we have

	integer memfile, read;
	initial begin
		memfile = $fopen(`MEMFILE, "r");
		read = $fread(memory, memfile);
		$fclose(memfile);
	end

	always @(posedge clock) begin
		if (write)
			memory[address] <= in_bus;
		out_bus <= memory[address];
	end
endmodule

`endif
