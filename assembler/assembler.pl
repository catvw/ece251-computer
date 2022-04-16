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
	'lsl', 'lsr', 'set',
);

my @takes_label = (
	'b', 'bz', 'bnn',
);

my %directions = (
	'>' => 0b0000_1_000,
	'<' => 0b0000_0_000,
);

print "arguments: <input> [output]\n" and exit
	unless ($#ARGV == 0 || $#ARGV == 1);
my ($input_file, $output_file) = @ARGV;

open my $input, '<', $input_file or die "could not open $input_file";

# take two's-complement of a nybble
sub nybble_2s {
	my $n = shift;
	return $n + 16 if ($n && $n < 0);
	return $n;
}

# read and tokenize input
my @program = ();
my %labels = ();
my $address = 0;
while (<$input>) {
	# remove comments
	s#//[^\n]*$##;

	# split the instruction into pieces
	my ($label, $name, $dir, $arg) =
		m/^\s*(?:(\w+):)?(?:\s*(\w+)\s+\[?([<>]?)(\S*))?\]?/;

	$labels{$label} = $address if $label;

	if ($name) {
		my $reg;
		my $imm;
		if ($arg) {
			# extract immediate or register spec
			($reg) = ($arg =~ m/r(\d+)/);
			($imm) = ($arg =~ m/#(-?\d+)/);
		}

		my $next_instr = {
			line_number => $.,
			address => $address,
			name => $name,
			dir => $dir,
			arg => $arg,
			reg => $reg,
			imm => $imm
		};
		push @program, $next_instr;

		++$address;
	}
}
close $input;
undef $address;

# assemble and write to output
my $output;
open $output, '>:raw', $output_file or die "could not open $output_file"
	if $output_file;
foreach (@program) {
	my $line_number = $_->{line_number};
	my $address = $_->{address};
	my $name = $_->{name};
	my $dir = $_->{dir};
	my $arg = $_->{arg};
	my $reg = $_->{reg};
	my $imm = $_->{imm};

	# get base binary instruction
	my $binary = $instructions{lc $name};

	# do a four-bit two's-comp conversion if needed
	$imm = nybble_2s($imm);

	$binary |= $reg if grep { $_ eq $name } @takes_register;
	$binary |= $imm if grep { $_ eq $name } @takes_immediate;
	$binary |= $directions{$dir} if grep { $_ eq $name } @takes_direction;

	if (grep { $_ eq $name } @takes_label) {
		my $jump_diff = $labels{$arg} - $address;

		if ($jump_diff >= -8 && $jump_diff <= 7) {
			$binary |= nybble_2s($jump_diff);
		} else {
			die "line $line_number: distance to \"$arg\" is $jump_diff!";
		}
	}

	if ($output) {
		print $output pack 'C', $binary;
	} else {
		printf "#%02x: %02x | \x1b[1m%s\x1b[0m\n",
			$address, $binary, "$name $dir$arg";
	}
}
close $output if $output;
