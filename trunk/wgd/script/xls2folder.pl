#!/usr/bin/perl -w

use strict;
use Encode;
use Spreadsheet::ParseExcel;

binmode(STDOUT, ":utf8");

my $xlsfile = shift;
my $sheet_name = shift;
print $xlsfile ,"wks:", $sheet_name;
my $parser   = Spreadsheet::ParseExcel->new();

my $workbook = $parser->Parse($xlsfile);

my $worksheet = $workbook->worksheet($sheet_name);
print "Name: $worksheet->{Name}\n";
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();

    for my $row ( $row_min .. $row_max ) {
        for my $col ( $col_min .. $col_max ) {

            my $cell = $worksheet->get_cell( $row, $col );
            #next unless $cell;

            #print "$row, $col";
			if ($cell) {
		        print decode_utf8($cell->value());
			    #print "Unformatted = ", $cell->unformatted(), ";";
			}
			else {
				print "";
	            #print "Unformatted = ", "", ";";
			}
			print '|';
        }
            print "\n";
    }
#}
