
package Tk::NumEntry;

use Tk ();
use Tk::Frame;
use strict;

use vars qw(@ISA $VERSION);
@ISA = 'Tk::Frame';
$VERSION = '1.01';

Construct Tk::Widget 'NumEntry';

{ my $foo = $Tk::FireButton::INCBITMAP;
     $foo = $Tk::FireButton::DECBITMAP; # peacify -w
}

sub Populate {
    my($f,$args) = @_;

    require Tk::FireButton;
    require Tk::NumEntryPlain;

    my $e = $f->Component(NumEntryPlain => 'entry',
        -borderwidth        => 0,
        -highlightthickness => 0,
    );

    my $binc = $f->Component( FireButton => 'inc',
	-bitmap		    => $Tk::FireButton::INCBITMAP,
	-command	    => sub { $e->incdec(1) },
    );

    my $bdec = $f->Component( FireButton => 'dec',
	-bitmap		    => $Tk::FireButton::DECBITMAP,
	-command	    => sub { $e->incdec(-1) },
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
	-background  => [CHILDREN => "background",  "Background",  "#d9d9d9" ],
	-buttons     => [METHOD   => undef,	    undef,	   1	     ],
	-state       => [CHILDREN => "state", 	    "State", 	   "normal"  ],
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

    use Tk::NumEntry;

=head1 DESCRIPTION

C<Tk::NumEntry> defines a widget for entering integer numbers. The widget
also contains buttons for increment and decrement.

C<Tk::NumEntry> supports all the options and methods that the plain 
NumEntry widget provides (see L<Tk::NumEntryPlain>), plus the
following options

=head1 STANDARD OPTIONS

I<-repeatdelay -repeatinterval>

=head1 WIDGET-SPECIFIC OPTIONS

=over 4

=item Name:             B<buttons>

=item Class:            B<Buttons>

=item Switch:           B<-buttons>

=item -buttons

boolian that defines if the inc. and dec buttons are visible
(default = true).

=back


=head1 AUTHOR

Graham Barr <F<gbarr@ti.com>>


=head1 ACKNOWLEDGEMENTS

I would to thank  Achim Bohnet <F<ach@mpe.mpg.de>>
for all the feedback and testing. And for the splitting of the original
Tk::NumEntry into Tk::FireButton, Tk::NumEntryPlain and Tk::NumEntry

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

Except the typo's, they blong to Achim :-)

=cut
