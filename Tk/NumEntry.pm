
package Tk::NumEntry;

use Tk 402.002 'Ev';
use strict;
use vars qw(@ISA $VERSION);

require Tk::Entry;

@ISA = qw(Tk::Frame);
$VERSION = "1.00";

Construct Tk::Widget 'NumEntry';

my($DECBITMAP,$INCBITMAP);

sub ClassInit {
    my($class,$mw) = @_;

    unless(defined($INCBITMAP)) {
	$INCBITMAP = __PACKAGE__ . "::inc";
	$DECBITMAP = __PACKAGE__ . "::dec";

	my $bits = pack("b8"x5,	"........",
				"...11...",
				"..1111..",
				".111111.",
				"........");

	$mw->DefineBitmap($INCBITMAP => 8,5, $bits);

	# And of course, decrement is the reverse of increment :-)
	$mw->DefineBitmap($DECBITMAP => 8,5, scalar reverse $bits);
    }
}

sub Populate {
    my($f,$args) = @_;

    my $binc = $f->Component( Button => 'inc',
	-bitmap		    => $INCBITMAP,
	-anchor		    => 'center',
	-highlightthickness => 0,
	-takefocus 	    => 0,
	-padx 		    => 0,
	-pady 		    => 0,
    );

    my $bdec = $f->Component( Button => 'dec',
	-bitmap		    => $DECBITMAP,
	-anchor 	    => 'center',
	-highlightthickness => 0,
	-takefocus 	    => 0,
	-padx 		    => 0,
	-pady 		    => 0,
    );

    $binc->privateData('Tk::NumEntry')->{'value'} = +1;
    $bdec->privateData('Tk::NumEntry')->{'value'} = -1;

    my $e = $f->Component(Entry => 'entry',
        -borderwidth        => 0,
        -highlightthickness => 0,
    );

    $f->gridColumnconfigure(0, -weight => 1);
    $f->gridColumnconfigure(1, -weight => 0);

    $f->gridRowconfigure(0, -weight => 1);
    $f->gridRowconfigure(1, -weight => 1);

    $binc->grid(-row => 0, -column => 1, -sticky => 'news');
    $bdec->grid(-row => 1, -column => 1, -sticky => 'news');

    $e->grid(-row => 0, -column => 0, -rowspan => 2, -sticky => 'news');

    $f->ConfigSpecs(
	-borderwidth => [SELF	  => "borderWidth", "BorderWidth", 2	     ],
	-relief      => [SELF	  => "relief",	    "Relief",	   "sunken"  ],
	-background  => [SELF	  => "background",  "Background",  "#d9d9d9" ],
	-width       => [$e	  => "width",	    "Width",	   4	     ],
	-repeatdelay => [PASSIVE  => "repeatDelay", "RepeatDelay", 300	     ],
	-value       => [METHOD   => undef,	    undef,	   "0"	     ],
	-buttons     => [METHOD   => undef,	    undef,	   1	     ],
	-maxvalue    => [PASSIVE  => undef,	    undef,	   undef     ],
	-minvalue    => [PASSIVE  => undef,	    undef,	   undef     ],
	-bell	     => [PASSIVE  => "bell",	    "Bell",	   1         ],
	-command     => [CALLBACK => undef,	    undef,	   undef     ],
	-state       => [[$e,$binc,$bdec]
				  => "state", 	    "State", 	   "normal"  ],
	-repeatinterval
		     => [PASSIVE  => "repeatInterval",
						    "RepeatInterval",
								   100	     ],
	-textvariable
		     => [$e       => undef,	    undef,	   undef     ],
	-highlightthickness
                     => [SELF     => "highlightThickness",
						    "HighlightThickness",
								   2	     ],
    );

    $f->Delegates(DEFAULT => $e);

    $f;
}

sub buttons {
    my $f = shift;
    my $var = \$f->{Configure}{'-buttons'};
    my $old = $$var;

    if(@_) {
	my $val = shift;
	$$var = $val ? 1 : 0;
	my $e = $f->Subwidget('entry');
	my %info = $e->gridInfo; $info{'-sticky'} = 'news';
	delete $info{' -sticky'};
	$e->grid(%info, -columnspan => $val ? 1 : 2);
	$e->raise;
    }

    $old;
}

sub value {
    my $f = shift;
    my $e = $f->Subwidget('entry');
    my $old;

    if(@_) {
	my $new = 0 + shift;
	my $pos = $e->index('insert');

        $old = $e->get;

	$e->delete(0,'end');
	$e->insert(0,$new);
	$e->icursor($pos);
    }
    else {
        $f->incdec($f,0); # range check
        $old = $e->get;
    }

    # Do a range check after all configuration has finished,
    # as we may not yet know the range

    $f->DoWhenIdle([ \&incdec, $f, $f, 0]);

    $old ? $old + 0 : 0;
}

sub _ringBell {
    my $f = shift;
    my $v;
    return
	unless defined($v = $f->{Configure}{'-bell'});
    $f->bell
	if(($v =~ /^\d+$/ && $v) || $v =~ /^true$/i);
}

sub incdec {
    my($f,$b,$inc,$i) = @_;
    my $e = $f->Subwidget('entry');
    my $val = $e->get;

    if($inc == 0 && $val =~ /^-?$/) {
	$val = "";
    }
    else {
	my $min = $f->{Configure}{'-minvalue'};
	my $max = $f->{Configure}{'-maxvalue'};

	$val += $inc;
	my $limit = undef;

	$limit = $val = $min
            if(defined($min) && $val < $min);

	$limit = $val = $max
            if(defined($max) && $val > $max);

	if(defined $limit) {
	    $f->_ringBell
		if $inc;
	}
	elsif(defined($i) && $b->isa('Tk::Button')) {
            my $t = $i eq 'initial'
                    ? $f->cget("-repeatdelay")
                    : $f->cget("-repeatinterval");

            $b->RepeatId($b->after($t,[\&incdec,$f,$b,$inc,"again"]));
	}
    }

    my $pos = $e->index('insert');
    $e->delete(0,'end');
    $e->insert(0,$val);
    $e->icursor($pos);
}

package Tk::NumEntry::Button;

use vars qw(@ISA);

require Tk::Button;

@ISA = qw(Tk::Button);

Construct Tk::NumEntry 'Button';

sub butDown {
    my $b = shift;
    $b->SUPER::butDown;
    my $f = $b->parent;

    $f->incdec($b,$b->privateData('Tk::NumEntry')->{'value'},'initial');
}

sub butUp {
    my $b = shift;
    $b->CancelRepeat;
    $b->SUPER::butUp;
}

package Tk::NumEntry::Entry;

use vars qw(@ISA);

@ISA = qw(Tk::Entry);

Construct Tk::NumEntry 'Entry';

sub ClassInit {
    my ($class,$mw) = @_;

    $class->SUPER::ClassInit($mw);

    $mw->bind($class,'<Leave>', 'Leave');
    $mw->bind($class,'<FocusOut>', 'Leave');
    $mw->bind($class,'<Return>', 'Return');
    $mw->bind($class,'<Up>', 'Up');
    $mw->bind($class,'<Down>', 'Down');
}

sub Leave {
    my $e = shift;
    my $f = $e->parent;
    $f->incdec($f,0);  # range check
}

sub Return {
    my $e = shift;
    my $f = $e->parent;
    my $cmd = $f->{Configure}{'-command'};

    $f->incdec($f,0); # range check

    $cmd->Call($e->get + 0)
	if $cmd;
}

sub Up {
    my $e = shift;
    my $f = $e->parent;
    $f->incdec($f,1,'initial');
}

sub Down {
    my $e = shift;
    my $f = $e->parent;
    $f->incdec($f,-1,'initial');
}

sub Insert {
    my($e,$c) = @_;

    if($c =~ /^[-0-9]$/) {
	$e->SUPER::Insert($c);
    }
    elsif(defined($c) && length($c)) {
	$e->parent->_ringBell;
    }
}

1;

__END__

=head1 NAME

Tk::NumEntry - A numeric entry widget

=head1 SYNOPSIS

    use Tk::NumEntry;

=head1 DESCRIPTION

C<Tk::NumEntry> defines a widget for entering integer numbers. The widget
also contains butons for increment and decrement.

C<Tk::NumEntry> supports all the options and methods that a normal
Entry widget provides, plus the following options

=head1 STANDARD OPTIONS

I<-repeatdelay -repeatinterval>

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item -minvalue

Defines the minimum legal value that the widget can hold. If this
value is C<undef> then there is no minimum value (default = undef)

=item -maxvalue

Defines the maximum legal value that the widget can hold. If this
value is C<undef> then there is no maximum value (default = undef)

=item -bell

Specifies a boolean value. If true then a bell will ring if the user
attempts to enter an illegal character into the entry widget, and
when the user reaches the upper or lower limits when using the
up/down buttons for keys.

=item -value

Specifies the value to be inserted into the entry widget. Similar to the
standard C<-text> option, but will perform a range check on the value.

=back

=head1 AUTHOR

Graham Barr E<lt>F<gbarr@ti.com>E<gt>

=head1 ACKNOWLEDGEMENTS

I would to thank  Achim Bohnet E<lt>F<ach@mpe.mpg.de>E<gt>
for all the feedback and testing.

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
