#!/usr/bin/env -perl -w
# Author: LinCW
# Purpose: calculate the average length of exon and intron of arabidopsis

use strict;

my (%mrna_len, %exon_count, %exon_len, %intron_len);
my $file = shift or die "Usage: $0 FILE\n";
open my $fh, '<', $file or die "Could not open '$file' $!";
while (my $line = <$fh>) {
	my ($id, @items, $mrna, $exon);
	if ($line =~ /\tmRNA\t/i) {
		($id) = $line =~ /ID=(AT\dG\d+\.\d+)/i;
		@items = (split /\t/, $line);
		$mrna = $items[4] - $items[3] + 1;
		$mrna_len{$id} = $mrna if ($id);
    }
	elsif ($line =~ /\texon\t/i) {
		($id) = $line =~ /Parent=(AT\dG\d+\.\d+)/i;
		@items = (split /\t/, $line);
		$exon = $items[4] - $items[3] + 1;
		if ($id) {
			$exon_count{$id} ++;
			push @{$exon_len{$id}}, $exon;
			push @{$intron_len{$id}}, $items[3], $items[4];
		}
	}
}
close $fh;

print "Transcript\ttranscript_len\texon_count\texon_average_len\tintron_average_len\n";
foreach my $str (sort keys %mrna_len) {
	print "$str\t$mrna_len{$str}\t$exon_count{$str}\t";
	my $exon_sum = 0;
	my $exon_avg = 0;
	my $intron_sum = 0;
	my $intron_avg = 0;
	for (my $i = 0; $i <= $#{$exon_len{$str}}; $i ++) {
#		print "${$exon_len{$str}}[$i], ";
		$exon_sum += ${$exon_len{$str}}[$i];
		$exon_avg = ($exon_sum / $exon_count{$str});
	}
	print sprintf ("%.2f\t", $exon_avg);
	if (scalar $intron_len{$str} > 2) {
		my @tmp_intron;
		for (my $j = 0; $j <= $#{$intron_len{$str}}; $j ++) {
			push @tmp_intron, ${$intron_len{$str}}[$j];
		}
		my @sort_intron = sort {$a <=> $b} @tmp_intron;
		for (my $k = 1; $k <$#sort_intron; $k = $k + 2) {
			my $intron = $sort_intron[$k+1] - $sort_intron[$k] + 1;
			$intron_sum += $intron;
			$intron_avg = ($intron_sum / ($exon_count{$str} - 1));
		}
			# print "${$intron_len{$str}}[$j],${$intron_len{$str}}[$j+1]"
			# push my @values, ${$intron_len{$str}}[$j], ${$intron_len{$str}}[$j+1];
			# my @sort = sort {$a <=> $b} @values;
			# my $intron = $sort[1] - $sort[0];
			# $intron_sum += $intron;
			# $intron_avg = ($intron_sum / ($exon_count{$str} - 1));
		print sprintf ("%.2f\n", $intron_avg);
		# print "\n";
	}
	else {
		print "0\n";
	}
}
