#!/usr/bin/perl 
use Encode;
use HTML::FormatRTF;
use File::Slurp;

my $text;
my $file_name=shift;

if ( $file_name eq '' ) 
{	$text = decode('UTF-8', read_file( \*STDIN )); }
else 
{   $text = decode('UTF-8', read_file( $file_name )); }

print STDOUT 
	HTML::FormatRTF->
		format_string( $text , 'document_language' => 1028, 'wantarray' => 1);

