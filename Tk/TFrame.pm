package Tk::TFrame;

use Tk;
use strict;
use vars qw($VERSION @ISA);

@ISA = qw(Tk::Frame);
$VERSION = "1.00";

Construct Tk::Widget "TFrame";

sub Populate {
    my($frame,$args) = @_;

    $frame->Tk::configure(-borderwidth => 0, -highlightthickness => 0);

    my $border    = $frame->Component(Frame => "border");

    my @label = (
	-padx => 4,
	-pady => 2,
	-borderwidth => 2,
	-relief => 'flat'
    );

    if (exists $args->{'-label'}) {
       if (not ref $args->{'-label'}) {
           $args->{'-label'} = [ -text => $args->{'-label'} ];
       }
       push @label, @{$args->{'-label'}};
    }

    my $label     = $frame->Component(Label => "label",@label);

    my $container = $frame->Component(Frame => "container");

    my $rh = $label->ReqHeight;

    my $px = $args->{'-ipadx'} || 0;
    my $py = $args->{'-ipady'} || 0;

    $border->place(
	-relwidth => 1.0,
	-relheight => 1.0,
	-height => -int($rh / 2),
       '-y' => int($rh / 2)
    );

    $container->place(
	-in => $border,
       '-x' => $px,
	-width => -2 * $px,
	-relwidth => 1.0,

       '-y' => int($rh / 2) + $py,
	-height => -int($rh / 2) - $py*2,
	-relheight => 1.0,
    );

    $label->place(
       '-x' => 10, '-y' => 0
    );

    $frame->bind('<Configure>', [\&layoutRequest, $frame]);

    layoutRequest($frame,$frame);

    $frame->Default("container" => $container);

    $frame->ConfigSpecs(
	-label => [ 'METHOD', undef, undef, undef],
	-relief => [$border,'relief','Relief','groove'],
	-borderwidth => [$border,'borderwidth','Borderwidth',2],
	-ipadx => [PASSIVE => undef, undef, 0],
	-ipady => [PASSIVE => undef, undef, 0],
    );

    $frame;    
}

sub label {
    my $frame = shift;
    my $v = shift || [];
    my $l = $frame->Subwidget('label');

    $l->configure(@$v);
}

sub layoutRequest {
    my($w,$f) = @_;
    $f->DoWhenIdle(['adjustLayout',$f]) unless $f->{'layout_pending'};
    $f->{'layout_pending'} = 1;
}

sub adjustLayout {
    my $f = shift;
    my $l = $f->Subwidget('label');
    my $c = $f->Subwidget('container');
    my $b = $f->Subwidget('border');

    $c->update;
    $f->{'layout_pending'} = 0;

    my $px = $f->{Configure}{'-ipadx'} || 0;
    my $py = $f->{Configure}{'-ipady'} || 0;

    my $bw = $b->cget('-borderwidth')*2;
    my $w  = $c->ReqWidth + $bw + $px*2;
    my $h  = $bw + $l->ReqHeight + $c->ReqHeight + $f->cget('-borderwidth')*2
		+ $py*2;

    $f->GeometryRequest($w,$h);
}

sub grid {
    my $w = shift;
    $w = $w->Subwidget('container')
	if (@_ && $_[0] =~ /^(?: bbox
				|columnconfigure
				|location
				|propagate
				|rowconfigure
				|size
				|slaves)$/x);
    $w->SUPER::grid(@_);
}

sub slave {
    my $w = shift;
    $w->Subwidget('container');
}

sub pack {
    my $w = shift;
    $w = $w->Subwidget('container')
	if (@_ && $_[0] =~ /^(?:propagate|slaves)$/x);
    $w->SUPER::pack(@_);
}

1;

__END__

=head1 NAME

Tk::TFrame - A Titled Frame widget

=head1 SYNOPSIS

    use Tk::TFrame;
    
    $frame1 = $parent->TFrame(
	-label => [ -text => 'Title' ]
	-borderwidth => 2,
	-relief => 'groove'
    );

    # or simply
    $frame2 = $parent->TFrame(
       -label => 'Title'
    );

    $frame1->pack;
    $frame2->pack;

=head1 DESCRIPTION

C<Tk::TFrame> provides a frame but with a title which overlaps the border
by half of it's height.

=head1 AUTHOR

Graham Barr E<lt>F<gbarr@ti.com>E<gt>

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
