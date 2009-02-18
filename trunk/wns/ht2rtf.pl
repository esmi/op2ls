#!/usr/bin/perl 
use Encode;
use HTML::FormatRTF;
use File::Slurp;
use RTF::Writer;

my $text;
my $file_name=shift;
my $rtf;

if ( $file_name eq '' ) 
{	
	$text = decode('UTF-8', read_file( \*STDIN )); 
	#$rtf = RTF::Writer->new_to_handle(*STDOUT);

}
else 
{   $text = decode('UTF-8', read_file( $file_name )); }

#my $NP="# # # #  2009/2/11 9:36:00 AM  # # ";
#$rtf->number_pages(decode('UTF-8',$NP));

print STDOUT 
	HTML::FormatRTF->
		format_string( $text , 'document_language' => 1028, 'wantarray' => 1);
 
#$rtf->close;

