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

	'mul' => 0b1000_0_000,
	'div' => 0b1000_1_000,

	'b'   => 0b01_00_0000,
	'bz'  => 0b01_01_0000,
	'bnn' => 0b01_10_0000,
	'ba'  => 0b01_11_0_000,
	'br'  => 0b01_11_1_000,

	'ld'  => 0b1110_0_000,
	'st'  => 0b1110_1_000,

	'sel' => 0b1100_0000,
	'seh' => 0b1101_0000,

	'adi' => 0b1001_0000,
	'mov' => 0b1010_0000,
	'wr'  => 0b1111_0000,
	'hlt' => 0b1111_1010,
	'no'  => 0b1111_1111,
);

my @takes_register = (
	'add', 'sub', 'and', 'or' , 'not', 'xor', 'mul', 'div', 'ld', 'st', 'mov',
	'ba', 'br'
);

my @takes_direction = (
	'mov',
);

my @takes_immediate = (
	'lsl', 'lsr', 'sel', 'seh', 'adi'
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
		m/^\s*(?:(\w+):)?(?:\s*(#?\w+)\s+([<>]?)(\[?\S*)\]?)?/;

	$labels{$label} = $address if $label;

	if ($name) {
		# extract potential numeric constant (like #66)
		my ($constant) = ($name =~ m/#(\d+)/);

		if (exists $instructions{$name}) {
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
				imm => $imm,
			};

			push @program, $next_instr;
			++$address;
		} elsif ($name eq "addr") {
			# push on a special-looking instruction
			my $addr_instr = {
				line_number => $.,
				address => $address,
				name => $name,
				arg => $arg,
			};

			push @program, $addr_instr;
			$address += 2;
		} elsif (defined $constant) {
			# push on a constant-setting instruction
			my $const_instr = {
				line_number => $.,
				address => $address,
				name => "#$constant",
				dir => '',
				arg => '',
				reg => '',
				imm => '',
				constant => $constant,
			};

			push @program, $const_instr;
			++$address;
		}
	}
}
close $input;
undef $address;

# assemble and write to output
my $output;
open $output, '>:raw', $output_file or die "could not open $output_file"
	if $output_file;
foreach (@program) {
	if ($_->{name} eq 'addr') {
		# get the referenced address
		my $ref_addr = $labels{$_->{arg}};

		# write a sel/seh pair to load that address
		my $sel_imm = $ref_addr & 0xf;
		my $sel_instr = {
			line_number => $_->{line_number},
			address => $_->{address},
			name => 'sel',
			dir => '',
			arg => "#$sel_imm",
			reg => '',
			imm => $sel_imm,
		};

		my $seh_imm = $ref_addr >> 4;
		my $seh_instr = {
			line_number => $_->{line_number},
			address => $_->{address} + 1,
			name => 'seh',
			dir => '',
			arg => "#$seh_imm",
			reg => '',
			imm => $seh_imm,
		};

		write_instr ($sel_instr);
		write_instr ($seh_instr);
	} else {
		write_instr ($_);
	}
}

sub write_instr {
	my $instr = shift;

	my $line_number = $instr->{line_number};
	my $address = $instr->{address};
	my $name = $instr->{name};
	my $dir = $instr->{dir};
	my $arg = $instr->{arg};
	my $reg = $instr->{reg};
	my $imm = $instr->{imm};

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

	# constant, just set binary to this
	$binary = $instr->{constant} if ($name =~ /^#/);

	if ($output) {
		print $output pack 'C', $binary;
	} else {
		printf "#%02x: %02x | \x1b[1m%s\x1b[0m\n",
			$address, $binary, "$name $dir$arg";
	}
}

close $output if $output;

# Copyright (C) 2022, C. R. Van West
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
