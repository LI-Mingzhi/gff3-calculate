#!/usr/bin/env -perl -w

use strict;

my (%mrna_len, %exon_count, %exon_len);
my $file = shift or die "Usage: $0 FILE\n";
open my $fh, '<', $file or die "Could not open '$file' $!";
while (my $line = <$fh>) {
	if ($line =~ /\tmRNA\t/i) {
		my ($id) = $line =~ /ID=(AT\dG\d+\.\d+)/i;
		my @items = (split /\t/, $line);
		my $mrna = $items[4] - $items[3] + 1;
		$mrna_len{$id} = $mrna if ($id);
    }
	elsif ($line =~ /\texon\t/i) {
		my ($id) = $line =~ /Parent=(AT\dG\d+\.\d+)/i;
		my @items = (split /\t/, $line);
		my $exon = $items[4] - $items[3] + 1;
		$exon_count{$id} ++ if ($id);
		push (@{$exon_len{$id}}, $exon) if ($id);
	}
}

print "Transcript\ttranscript_len\texon_count\texon_average_len\n";
foreach my $str (sort keys %mrna_len) {
	print "$str\t$mrna_len{$str}\t$exon_count{$str}\t";
	my $exon_sum = 0;
	my $exon_avg = 0;
	for (my $i = 0; $i <= $#{$exon_len{$str}}; $i ++) {
#		print "${$exon_len{$str}}[$i], ";
		$exon_sum += ${$exon_len{$str}}[$i];
		$exon_avg = ($exon_sum / $exon_count{$str});
	}
	print sprintf ("%.2f\n", $exon_avg);

}
