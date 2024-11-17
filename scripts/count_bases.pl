#!/usr/bin/perl
use strict;
use warnings;

# This script reads a FASTA file and calculates per-base totals and percentages
# It also calculates the total number of repetitive and non-repetitive bases

# Check if the input file is provided
if (@ARGV != 1) {
    die "Usage: $0 <input_file>\n";
}

my $input_file = $ARGV[0];
my %bases;
my $total_bases = 0;
my $repetitive = 0;
my $non_repetitive = 0;
# Open the input file
open(my $fh, '<', $input_file) or die("Could not open file '$input_file': $!");

# Process the file
while (my $line = <$fh>) {
    chomp $line;
    next if $line =~ /^>/;  # Skip header lines
    $bases{$_}++ for split //, $line;
    $total_bases += length $line;
}

# Close the file
close($fh);

# Print the results in a tabular format
print "Base\tPercentage\tCount\n";
print "----\t----------\t-----\n";

foreach my $base (sort keys %bases) {
    my $count = $bases{$base};
    my $percentage = ($bases{$base} / $total_bases);
    if ($base =~ /[A-Z]/) {
        $non_repetitive += $count;
    } else {
        $repetitive += $count;
    }
    printf "%-4s\t%.3f\t\t%d\n", $base, $percentage, $count;
}

print "\nCategory\tPercentage\tCount\n";
print "--------\t----------\t-----\n";
my $repetitive_percentage = $repetitive / $total_bases;
my $non_repetitive_percentage = $non_repetitive / $total_bases;
printf "Repetitive\t%.3f\t\t%d\n", $repetitive_percentage, $repetitive;
printf "Non-repetitive\t%.3f\t\t%d\n", $non_repetitive_percentage, $non_repetitive;
