use strict;
use vars '$loaded';
BEGIN { $^W= 1; $| = 1; print "1..10\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::FireButton;
$loaded = 1;
my $ok = 1;
print "ok " . $ok++ . "\n";

# two MainWindows test...
my $top1 = new MainWindow;
my $top2 = new MainWindow;

my $fb;
eval {
    $fb = $top1->FireButton;
          $top2->FireButton;
};
if ($@) { print "not " } print "ok " . $ok++ . "\n";

{
    local $^W = 0; # suppress "used only once" warnings
    eval q{
	$top1->FireButton(-bitmap => $Tk::Bitmap::INCBITMAP);
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$top2->FireButton(-bitmap => $Tk::Bitmap::DECBITMAP);
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$top1->FireButton(-bitmap => $Tk::Bitmap::HORIZINCBITMAP);
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$top2->FireButton(-bitmap => $Tk::Bitmap::HORIZDECBITMAP);
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    my $r;
    eval q{
	$r = $fb->INCBITMAP eq $Tk::Bitmap::INCBITMAP;
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$r = $fb->DECBITMAP eq $Tk::Bitmap::DECBITMAP;
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$r = $fb->HORIZINCBITMAP eq $Tk::Bitmap::HORIZINCBITMAP;
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";

    eval q{
	$r = $fb->HORIZDECBITMAP eq $Tk::Bitmap::HORIZDECBITMAP;
    };
    if ($@) { print "not " } print "ok " . $ok++ . "\n";
}

