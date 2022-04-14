#!/usr/bin/perl

print "arguments: <input> <output>\n" and exit unless $#ARGV == 1;
my ($input_file, $output_file) = @ARGV;

open my $input, '<', $input_file or die "could not open $input_file"; 
open my $output, '>', $output_file or die "could not open $output_file";

while (<$input>) {
	print $_;
}

close $input;
close $output;
