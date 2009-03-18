#!/usr/bin/perl 
use HTML::ContentExtractor;
use LWP::UserAgent;
use File::Slurp;
use Encode;

    my $extractor = HTML::ContentExtractor->new();
#    my $agent=LWP::UserAgent->new;
my $url="";
    #my $url='http://sports.sina.com.cn/g/2007-03-23/16572821174.shtml';
#    my $url='http://www.eettaiwan.com/ART_8800564416_617723_NT_2f00a141.HTM';
#    my $res=$agent->get($url);
#    my $HTML = $res->decoded_content();
	#$text = decode('UTF-8', read_file( \*STDIN )); 
 my $HTML=decode('UTF-8', read_file( \*STDIN )); 
    $extractor->extract($url,$HTML);
    print $extractor->as_html();
    #print $extractor->as_text();
