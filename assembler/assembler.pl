#!/usr/bin/perl

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
	'add', 'sub', 'and', 'or' , 'lsl', 'lsr', 'not', 'xor', 'mul', 'div', 'ld',
	'st', 'mov',
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

print "arguments: <input> <output>\n" and exit unless $#ARGV == 1;
my ($input_file, $output_file) = @ARGV;

open my $input, '<', $input_file or die "could not open $input_file"; 
open my $output, '>:raw', $output_file or die "could not open $output_file";

while (<$input>) {
	# split the instruction into pieces
	my ($instr, $dir, $arg) = m/^\s*(\w+)\s+([<>])?((#-?)?\w+)?/;

	# convert all to lower case
	$instr = lc($instr);
	$direction = lc($direction);
	$argument = lc($argument);

	# extract immediate or register spec
	my ($reg) = ($arg =~ m/r(\d)/);
	my ($imm) = ($arg =~ m/#(-?\d)/);

	# do a four-bit two's-comp conversion if needed
	$imm += 16 if ($imm < 0);

	my $bin_instr = $instructions{$instr};

	$bin_instr |= $direction{$dir} if ($instr ~~ @takes_direction);
	$bin_instr |= $reg if ($instr ~~ @takes_register);
	$bin_instr |= $imm if ($instr ~~ @takes_immediate);

	printf $output pack 'c', $bin_instr;
}

close $input;
close $output;
