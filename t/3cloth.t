use strict;
use vars '$loaded';
use Tk;
BEGIN { $^W= 1; $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk::Cloth;
$loaded = 1;
my $ok = 1;
print "ok @{[ $ok++ ]}\n";

my $top = new MainWindow;

my $cloth;
eval {
    $cloth = $top->Cloth->pack;
};
if (!$cloth)                   { print "not " } print "ok @{[ $ok++ ]}\n";
if (ref $cloth ne 'Tk::Cloth') { print "not " } print "ok @{[ $ok++ ]}\n";

eval {
    $cloth->configure(-scrollregion => [-100, -100, 100, 100]);
};
if ($@) { print "not " } print "ok @{[ $ok++ ]}\n";


my $to = $cloth->Text(-coords => [0,0], -text => "blah", -anchor => "nw");
if (ref $to ne 'Tk::Cloth::Text') { print "not " } print "ok @{[ $ok++ ]}\n";

my $go;
eval {
    $go = $cloth->Grid(-coords => [0,0,20,10], -width => 3);
};
if (ref $go ne 'Tk::Cloth::Grid' and $Tk::VERSION > 800.015) { print "not " } print "ok @{[ $ok++ ]}\n";

#Tk::MainLoop;
