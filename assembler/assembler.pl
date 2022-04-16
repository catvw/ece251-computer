#!/usr/bin/perl
use strict;
use warnings;

my %instructions = (
	'add' => 0b00_000_000,
	'sub' => 0b00_001_000,
	'and' => 0b00_010_000,
	'or'  => 0b00_011_000,
	'lsl' => 0b00_100_000,
	'lsr' => 0b00_101_000,
	'not' => 0b00_110_000,
	'xor' => 0b00_111_000,

	'mul' => 0b100_0_0_000,
	'div' => 0b100_1_0_000,

	'b'   => 0b01_00_0000,
	'bz'  => 0b01_01_0000,
	'bnn' => 0b01_10_0000,

	'ld'  => 0b1110_0_000,
	'st'  => 0b1110_1_000,

	'set' => 0b1100_0000,
	'mov' => 0b1101_0_000,
	'hlt' => 0b1010_0000,
	'no'  => 0b1111_0000,
);

my @takes_register = (
	'add', 'sub', 'and', 'or' , 'not', 'xor', 'mul', 'div', 'ld', 'st', 'mov',
);

my @takes_direction = (
	'mov',
);

my @takes_immediate = (
	'lsl', 'lsr', 'set', 'b', 'bz', 'bnn', # TODO: remove branches
);

my %directions = (
	'>' => 0b0000_1_000,
	'<' => 0b0000_0_000,
);

print "arguments: <input> [output]\n" and exit
	unless ($#ARGV == 0 || $#ARGV == 1);
my ($input_file, $output_file) = @ARGV;

open my $input, '<', $input_file or die "could not open $input_file"; 
my $output;
open $output, '>:raw', $output_file or die "could not open $output_file"
	if $output_file;

my $address = 0;
while (<$input>) {
	# split the instruction into pieces
	my ($instr, $dir, $arg) = m/^\s*(\w+)\s+([<>]?)(\S*)/;

	if ($instr) {
		my $bin_instr = $instructions{lc $instr};

		my $reg;
		my $imm;
		if ($arg) {
			# extract immediate or register spec
			($reg) = ($arg =~ m/r(\d)/);
			($imm) = ($arg =~ m/#(-?\d)/);

			# do a four-bit two's-comp conversion if needed
			$imm += 16 if ($imm && $imm < 0);
		}

		$bin_instr |= $reg if grep { $_ eq $instr } @takes_register;
		$bin_instr |= $imm if grep { $_ eq $instr } @takes_immediate;
		$bin_instr |= $directions{$dir}
			if grep { $_ eq $instr } @takes_direction;

		if ($output) {
			print $output pack 'C', $bin_instr;
		} else {
			printf "%02x: \x1b[1m%-7s\x1b[0m -> %02x\n",
				$address, "$instr $dir$arg", $bin_instr;
		}

		++$address;
	}
}

close $input;
close $output if $output;
