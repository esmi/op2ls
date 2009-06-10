#!/usr/bin/perl 
use Encode;
use File::Slurp;

#binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
require Encode::Detect;
my $data=read_file(\*STDIN);
my $utf8 = decode("Detect", $data);
print $utf8;


