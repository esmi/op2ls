#!/usr/bin/perl 
use Encode;
use HTML::TagFilter;
use HTML::ExtractContent;

binmode(STDOUT, ":utf8");
#binmode(STDIN, ":utf8");

my $my_text=shift;
my $tf = HTML::TagFilter->new(deny => {img => {'all'}},{'href'},{span => {'all'}});

$tf->allow_tags({});
#$tf->deny_tags({ span => { class=> [] } });
$tf->deny_tags({ span => { 'all' }  });
$tf->parse_file($my_text);
my $oput = decode('UTF-8', $tf->output);

my $extractor = HTML::ExtractContent->new;
$extractor->extract($oput);
print $extractor->as_html;

