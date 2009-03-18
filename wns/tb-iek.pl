#!/usr/bin/perl
use Encode;
use HTML::TableExtract;
#use HTML::TableExtract qw(tree);
use File::Slurp;
use Data::Dump;
use Text::Trim;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

$te = HTML::TableExtract->new( headers => [qw(DATE TITLE SOURCE )], keep_html => 1 );
$html_string=read_file(\*STDIN);
$te->parse($html_string);


# Examine all matching tables
foreach $ts ($te->tables) {
#   print "Table (", join(',', $ts->coords), "):\n";
   foreach $row ($ts->rows) {
      print join('|', ltrim(rtrim(@$row))), "#";
   }
	
}
