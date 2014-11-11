#!/usr/bin/env -perl

use strict;

my (%mrna_len, %first_exon, %exon_count);
my $file = shift or die "Usage: $0 FILE\n";
open my $fh, "<:encoding(utf8)", $file or die "Could not open '$file' $!";
while (my $line = <$fh>) {
  if ($line =~ /\tmRNA\t/i) {
    my ($id) = $line =~ /ID=(at\d+g\d+\.\d+)/i;
    my @items = (split /\t/, $line);
    my $mrna = $items[4] - $items[3] + 1;
    $mrna_len{$id} = $mrna if ($id);
    }
  elsif ($line =~ /\texon\t/i) {
    my ($id) = $line =~ /parent=(at\d+g\d+\.\d+)/i;
    my @items = (split /\t/, $line);
    my $exon = $items[4] - $items[3] + 1;
    $first_exon{$id} = $exon if ($id && !$first_exon{$id});
    push (@{$exon_count{$id}}, $items[3], $items[4]) if ($id && $#{$exon_count{$id}} <= 2);
  }
}

print "Transcript\ttranscript_len\tfirst_exon\tfirst_intron\n";
foreach my $str (sort keys %mrna_len) {
  print "$str\t$mrna_len{$str}\t$first_exon{$str}\t";
  if ($#{$exon_count{$str}} <= 2) {
    print "0\n";
  }
  elsif ($#{$exon_count{$str}} > 2) {
    my @order_exon = sort {$a <=> $b} @{$exon_count{$str}};
    my $first_exon = $order_exon[2] - $order_exon[1] - 1;
    print "$first_exon\n";
  }
}
