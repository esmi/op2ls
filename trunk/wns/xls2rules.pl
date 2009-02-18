#!/usr/bin/perl -w

use strict;
use Spreadsheet::ParseExcel;


my $xlsfile = shift;
my $parser   = Spreadsheet::ParseExcel->new();

my $workbook = $parser->Parse($xlsfile);

#for my $worksheet ( $workbook->worksheets('tagging') ) {

my $worksheet = $workbook->worksheet('tagging');
print "Name: $worksheet->{Name}\n";
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();

    for my $row ( $row_min .. $row_max ) {
        for my $col ( $col_min .. $col_max ) {

            my $cell = $worksheet->get_cell( $row, $col );
            #next unless $cell;

            #print "$row, $col";
			if ($cell) {
		        print $cell->value();
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
