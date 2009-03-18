#!/usr/bin/perl
use Encode;
use HTML::TableExtract;
#use HTML::TableExtract qw(tree);
use File::Slurp;
use Data::Dump;
use Text::Trim;
binmode(STDOUT, ":utf8");
binmode(STDIN, ":utf8");

$te = HTML::TableExtract->new( headers => [qw( pubdate title download)], keep_html => 1 );
#$te = HTML::TableExtract->new( headers => [ qw(title authunit author pubdate download ) ], keep_html => 1 );

#title authuniti author pubdate download
        
$html_string=read_file(\*STDIN);
$te->parse($html_string);


# Examine all matching tables
foreach $ts ($te->tables) {
#   print "Table (", join(',', $ts->coords), "):\n";
   foreach $row ($ts->rows) {
      print join('|', ltrim(rtrim(@$row))), "#";
   }
	
}
