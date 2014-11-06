#!/usr/bin/env -perl -w

use strict;

open my $gff, "<:encoding(utf8)", @ARGV or die "$!";

while (<>) {
	if (/mRNA/) {
		chomp;
		my @items = split ("\t", $_);
		$_ =~ /ID=(.+);Name/;
		my $length = $items[4] - $items[3] + 1;
		print "$1\t$length\n" if ($1);
	}
}

close $gff;