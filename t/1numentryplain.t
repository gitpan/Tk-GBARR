BEGIN
  {
    $^W = 1;
    $| = 1;

    eval { require Test; };
    if ($@)
      {
        $^W=0;
        print "1..0\n";
        print STDERR "\n\tTest.pm module not installed.\n\tGrab it from CPAN.\n\t";
        exit;
      }
    Test->import;
  }
use strict;
use Tk;

BEGIN { plan tests => 8 };

my $mw = Tk::MainWindow->new;

my $nep;
{
   eval { require Tk::NumEntryPlain; };
   ok($@, "", 'Problem loading Tk::NumEntryPlain');
   eval { $nep = $mw->NumEntryPlain(); };
   ok($@, "", 'Problem creating NumEntryPlain widget');
   ok( Tk::Exists($nep) );
   eval { $nep->grid; };
   ok($@, "", '$text->grid problem');
   eval { $nep->update; };
   ok($@, "", '$nep->update problem');
}
##
## Check that -textvariable works for reading
##	(set work but not supported)
##
{
    my $num = 0;
    my $e = $mw->NumEntryPlain(-textvariable=>\$num);
    eval { $e->value(6); };
    ok($@, "", 'Problem setting value');
    ok($num, "6", "Textvariable is not updated");

    eval { $e->update; };
    ok($@, "", 'Problem in update after setting value');
}

1;
__END__
