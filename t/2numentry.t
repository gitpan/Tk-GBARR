use strict;
use vars '$loaded';
BEGIN { $^W= 1; $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::NumEntry;
$loaded = 1;
my $ok = 1;
print "ok " . $ok++ . "\n";

my $top = new MainWindow;
my $ne;
eval {
    $ne = $top->NumEntry->pack;
};
if ($@) { print "not " } print "ok " . $ok++ . "\n";

eval {
    $top->NumEntry(-orient => "horizontal")->pack;
};
if ($@) { print "not " } print "ok " . $ok++ . "\n";

$ne->configure(-value => 1);
if ($ne->cget(-value) != 1) { print "not " } print "ok " . $ok++ . "\n";

$ne->incdec(1);
if ($ne->cget(-value) != 2) { print "not " } print "ok " . $ok++ . "\n";

$ne->incdec(-1);
if ($ne->cget(-value) != 1) { print "not " } print "ok " . $ok++ . "\n";

#Tk::MainLoop;
