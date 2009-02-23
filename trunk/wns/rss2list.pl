#!/usr/bin/perl -w
#use strict;
#use Encode;

use HTTP::Date;
use XML::RSS::Parser;
use FileHandle;
use Text::Trim;

binmode(STDOUT, ":utf8");
binmode (STDIN, ":utf8");

my $rss_f=shift;
my $p = XML::RSS::Parser->new;
my $fh = FileHandle->new($rss_f);
#binmode($fh,":utf8");
my $feed = $p->parse_file($fh);
if ( $feed ) { 
	print "feed is created"; 

	foreach my $i ( $feed->query('//item') ) { 

		my $title = $i->query('title')->text_content;
		my $link = $i->query('link')->text_content;
		my $pubDate=$i->query('pubDate')->text_content;

	    #my $description=$i->query('description')->text_cont;
		#$pubDate=~ s/\r\n//g;
		#$link=~ s/\r\n//g;
		#$title=~ s/\r\n//g;
		#print $pubDate."|".
		#	$title."|".$link."|".$rss_f;
		#print $pubDate."|".
		#	decode('UTF-8',$title)."|".$link;
		#
	print trim($pubDate)."|".
		trim($title)."|".trim($link)."|".$rss_f;
    print "\n"; 
	}
}
else { 
	print STDERR "XML::RSS::Parser feeder is not created, Please check RSS file: $rss_f format." ; }

