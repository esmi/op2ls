#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  html_tagfilter_1.pl
#
#        USAGE:  ./html_tagfilter_1.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  12/31/08 14:53:35    
#     REVISION:  ---
#===============================================================================

#use strict;
#use warnings;
use HTML::TagFilter;
use HTML::ExtractContent;

#my $my_text="1.html";
my $my_text=shift;
my $tf = HTML::TagFilter->new(deny => {img => {'all'}},{'href'},{'script'});
$tf->parse_file($my_text);
my $oput = $tf->output;
#print $oput;

$tf->allow_tags({});
$tf->deny_tags({});
#print $tf->filter($oput);
#print $tf->filter($my_text);

my $extractor = HTML::ExtractContent->new;
$extractor->extract($oput);
print $extractor->as_text;


