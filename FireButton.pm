# POD after __END__

package Tk::FireButton;

use Tk 402.002 (); # for DefineBitmap
use Tk::Derived;
use Tk::Button;
use strict;

use vars qw(@ISA $VERSION);
@ISA = qw(Tk::Derived Tk::Button);
$VERSION = '0.04';

Construct Tk::Widget 'FireButton';

#my($DECBITMAP,$INCBITMAP);
use vars qw($DECBITMAP $INCBITMAP);

$INCBITMAP = __PACKAGE__ . "::inc";
$DECBITMAP = __PACKAGE__ . "::dec";

my $def_bitmaps = 0;

sub ClassInit {
    my($class,$mw) = @_;

    unless($def_bitmaps) {
	my $bits = pack("b8"x5,	"........",
				"...11...",
				"..1111..",
				".111111.",
				"........");

	$mw->DefineBitmap($INCBITMAP => 8,5, $bits);

	# And of course, decrement is the reverse of increment :-)
	$mw->DefineBitmap($DECBITMAP => 8,5, scalar reverse $bits);
    }

    $class->SUPER::ClassInit($mw);
}


sub butDown {
    my $b = shift;
    my $fire = shift || 'initial';

    if ($fire eq 'initial') {
	# XXX why isn't relief saving done the Tk::Button as
        #soon as callback is invoked?
	$b->{tk_firebutton_save_relief} = $b->cget('-relief');

   	$b->RepeatId($b->after( $b->cget('-repeatdelay'),
		[\&butDown, $b, 'again'])
		); 
    } else {
    	$b->invoke;
        $b->RepeatId($b->after( $b->cget('-repeatinterval'),
                [\&butDown, $b, 'again'])
                );
    }

    $b->SUPER::butDown;
}

sub butUp {
    my $b = shift;
    $b->CancelRepeat;
    $b->SUPER::butUp;
    $b->configure(-relief=>$b->{tk_firebutton_save_relief})
	if $b->{tk_firebutton_save_relief};
}

sub Populate {
    my($b,$args) = @_;

    $b->SUPER::Populate($args);

    $b->ConfigSpecs(
	# Override button fallbacks
	-padx 		    => [qw(SELF padX               Pad                0)],
	-pady 		    => [qw(SELF padY               Pad                0)],

	# new options
        -repeatdelay     => [qw(PASSIVE repeatDelay    RepeatDelay    300)],
	-repeatinterval  => [qw(PASSIVE repeatInterval RepeatInterval 100)],
	);

    $b;
}

1;

__END__

=head1 NAME

Tk::FireButton - Button that keeps invoking callback when pressed


=head1 SYNOPSIS

    use Tk::FireButton;

    $fire = $parent->FireButton( ... );

    # May/should change:
    $w->Whatever(... -bitmap => $Tk::FireButton::INCBITMAP, ...);
    $w->Whatever(... -bitmap => $Tk::FireButton::DECBITMAP, ...);


=head1 DESCRIPTION

B<FireButton> is-a B<Button> widget (see L<Tk::Button>) that
keeps invoking the callback bound to it as long as the <FireButton>
is pressed.


=head1 SUPER-CLASS

The B<FireButton> widget-class is derived from the B<Button>
widget-class and inherits all the methods and options its
super-class (see L<Tk::Button>).


=head1 STANDARD OPTIONS

B<FireButton> supports all the standard options of a B<Button> widget.
See L<Tk::options> for details on the standard options.


=head1 WIDGET-SPECIFIC OPTIONS


=over 4

=item Name:             B<repeatDelay>

=item Class:            B<RepeatDelay>

=item Switch:           B<-repeatdelay>

=item Fallback:		B<300> (milliseconds)

Specifies the amount of time before the callback is first invoked after
the Button-1 is pressed over the widget.


=item Name:             B<repeatInterval>

=item Class:            B<RepeatInterval>

=item Switch:           B<-repeatinterval>

=item Fallback:		B<100> (milliseconds)

Specifies the amount of time between invokations of the
callback bound to the widget with the C<command> option.

=back

=head1 CHANDED OPTION FALLBACK VALUES

The fallback values of the following options as different
from the B<Button> widget:

        -padx               => 0,
        -pady               => 0,


=head1 METHODS

Same as for L<Button|Tk::Button> widget.


=head1 ADVERTISED WIDGETS

None.


=head1 HISTORY

The code was extracted from Tk::NumEntry and slightly modified
by Achim Bohnet E<gt>ach@mpe.mpg.deE<gt>.  Tk::NumEntry's author
is Graham Barr E<gt>gbarr@pobox.comE<gt>.

=cut

