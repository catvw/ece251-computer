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
);

print "arguments: <input> <output>\n" and exit unless $#ARGV == 1;
my ($input_file, $output_file) = @ARGV;

open my $input, '<', $input_file or die "could not open $input_file"; 
open my $output, '>:raw', $output_file or die "could not open $output_file";

while (<$input>) {
	# split the instruction into pieces
	my ($instr, $direction, $argument) = m/^\s*(\w+)\s+([<>]?)(\w+)/;

	# convert all to lower case
	$instr = lc($instr);
	$direction = lc($direction);
	$argument = lc($argument);

	print "$instr $direction $argument\n";
	print "$instructions{$instr}\n";

	print $output pack 'c', $instructions{$instr};
}

close $input;
close $output;
