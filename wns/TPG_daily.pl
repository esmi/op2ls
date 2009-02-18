#!/usr/bin/perl
require HTML::LinkExtor;

my $daily=shift;
$p = HTML::LinkExtor->new(\&cb);
sub cb {
     my($tag, %links) = @_;
     print "$tag @{[%links]}\n";
}
$p->parse_file($daily);
