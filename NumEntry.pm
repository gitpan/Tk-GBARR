
package Tk::NumEntry;

use Tk ();
use Tk::Frame;
use Tk::Derived;
use strict;

use vars qw(@ISA $VERSION);
@ISA = qw(Tk::Derived Tk::Frame);
$VERSION = '1.06';

Construct Tk::Widget 'NumEntry';

{ my $foo = $Tk::FireButton::INCBITMAP;
     $foo = $Tk::FireButton::DECBITMAP; # peacify -w
}

sub Populate {
    my($f,$args) = @_;

    require Tk::FireButton;
    require Tk::NumEntryPlain;

    my $orient = delete $args->{-orient} || "vertical";

    my $e = $f->Component( NumEntryPlain => 'entry',
        -borderwidth        => 0,
        -highlightthickness => 0,
	-parent             => $f,
    );

    my $binc = $f->Component( FireButton => 'inc',
	-bitmap		    => ($orient =~ /^vert/
				? $Tk::FireButton::INCBITMAP
				: $Tk::FireButton::HORIZINCBITMAP
			       ),
#	-command	    => sub { $e->incdec(1) },
	-command	    => sub { $f->incdec(1) },
	-takefocus	    => 0,
	-highlightthickness => 0,
	-anchor             => 'center',
    );

    my $bdec = $f->Component( FireButton => 'dec',
	-bitmap		    => ($orient =~ /^vert/
				? $Tk::FireButton::DECBITMAP
				: $Tk::FireButton::HORIZDECBITMAP
			       ),
#	-command	    => sub { $e->incdec(-1) },
	-command	    => sub { $f->incdec(-1) },
	-takefocus	    => 0,
	-highlightthickness => 0,
	-anchor             => 'center',
    );

    $f->gridColumnconfigure(0, -weight => 1);
    $f->gridColumnconfigure(1, -weight => 0);

    $f->gridRowconfigure(0, -weight => 1);
    $f->gridRowconfigure(1, -weight => 1);

    if ($orient eq 'vertical') {
	$binc->grid(-row => 0, -column => 1, -sticky => 'news');
	$bdec->grid(-row => 1, -column => 1, -sticky => 'news');
    } else {
	$binc->grid(-row => 0, -column => 2, -sticky => 'news');
	$bdec->grid(-row => 0, -column => 1, -sticky => 'news');
    }

    $e->grid(-row => 0, -column => 0, -rowspan => 2, -sticky => 'news');

    $f->ConfigSpecs(
	-borderwidth => ['SELF'     => "borderWidth", "BorderWidth", 2	     ],
	-relief      => ['SELF'     => "relief",      "Relief",	    "sunken"  ],
	-background  => ['CHILDREN' => "background",  "Background", Tk::NORMAL_BG ],
	-foreground  => ['CHILDREN' => "background",  "Background", Tk::BLACK ],
	-buttons     => ['METHOD'   => undef,	    undef,	   1	     ],
	-state       => ['CHILDREN' => "state", 	    "State", 	   "normal"  ],
	-repeatdelay => [[$binc,$bdec]
				  => "repeatDelay", "RepeatDelay", 300	     ],
	-repeatinterval
		     => [[$binc,$bdec]
				  => "repeatInterval",
						    "RepeatInterval",
								   100	     ],
	-highlightthickness
                     => [SELF     => "highlightThickness",
						    "HighlightThickness",
								   2	     ],
	DEFAULT      => [$e],
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

1;

__END__

=head1 NAME

Tk::NumEntry - A numeric Entry widget with inc. & dec. Buttons

=head1 SYNOPSIS

S<    >B<use Tk::NumEntry;>

S<    >I<$parent>-E<gt>B<NumEntry>(?I<-option>=E<gt>I<value>, ...?);

=head1 DESCRIPTION

B<Tk::NumEntry> defines a widget for entering integer numbers. The widget
also contains buttons for increment and decrement.

B<Tk::NumEntry> supports all the options and methods that the plain 
NumEntry widget provides (see L<Tk::NumEntryPlain>), plus the
following options

=head1 STANDARD OPTIONS

Besides the standard options of the L<Button|Tk::Button> widget
NumEntry supports:

B<-orient> B<-repeatdelay> B<-repeatinterval>

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item Name:             B<buttons>

=item Class:            B<Buttons>

=item Switch:           B<-buttons>

=item Fallback:		B<1>

Boolean that defines if the inc and dec buttons are visible.

=back


=head1 AUTHOR

Graham Barr <F<gbarr@pobox.com>>


=head1 ACKNOWLEDGEMENTS

I would to thank  Achim Bohnet <F<ach@mpe.mpg.de>>
for all the feedback and testing. And for the splitting of the original
Tk::NumEntry into Tk::FireButton, Tk::NumEntryPlain and Tk::NumEntry

=head1 COPYRIGHT

Copyright (c) 1997-1998 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

Except the typo's, they blong to Achim :-)

=cut
