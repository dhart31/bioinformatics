#!/usr/bin/perl
use strict;
use warnings;

# This is a simple script to tidy up the headers in a FASTA file
# You can change regex1 and regex2 to match the headers in your file

# Check if the input file is provided
if (@ARGV != 1) {
    die "Usage: $0 <input_file>\n";
}

my $input_file = $ARGV[0];

open(my $fh, '<', $input_file) or die("Could not open file '$input_file': $!");

my $regex1 = qr/^>\S+::(ERCC-\d+):.*/;
my $regex2 = qr/^>(\S+)::.*/;

# Process the file
while(my $line = <$fh>) {
    chomp $line;
    if ($line =~ $regex1) {
        print ">$1\n";
    } elsif ($line =~ $regex2) {
        print ">$1\n";
    } else {
        print $line, "\n";
    }
}