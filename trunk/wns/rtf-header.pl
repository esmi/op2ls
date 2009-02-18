use Encode;
use RTF::Writer;

my $NP=shift;
my $rtf = RTF::Writer->new_to_handle(*STDOUT);
$rtf->number_pages(decode('UTF-8',$NP));

$rtf->close;
