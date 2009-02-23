#!/usr/bin/perl 
use HTML::TagFilter;
use HTML::ExtractContent;

my $my_text=shift;
my $tf = HTML::TagFilter->new(deny => {img => {'all'}},{'href'},{'script'});

$tf->parse_file($my_text);
$tf->allow_tags({});
$tf->deny_tags({});
my $oput = $tf->output;

my $extractor = HTML::ExtractContent->new;
$extractor->extract($oput);
print $extractor->as_html;

