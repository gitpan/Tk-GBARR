package Tk::Pane;

use Tk;
use strict;
use vars qw(@ISA);

@ISA = qw(Tk::Frame);

Construct Tk::Widget 'Pane';

sub ClassInit {
    my ($class,$mw) = @_;
    $mw->bind($class,'<Configure>',['QueueLayout',4]);
    $mw->bind($class,'<FocusIn>',  'NoOp');
    return $class;
}

sub Populate {
    my $pan = shift;

    my $frame    = $pan->Component(Frame => "frame");

    $pan->DoWhenIdle(['Manage',$pan,$frame]);
    $pan->DoWhenIdle(['QueueLayout',$pan,1]);

    $pan->Delegates(DEFAULT => $frame);

    $pan->ConfigSpecs(
	DEFAULT		=> [$frame],
	-sticky		=> [PASSIVE	=> undef, undef, undef],
	-gridded	=> [PASSIVE	=> undef, undef, undef],
	-xscrollcommand => [CALLBACK	=> undef, undef, undef],
	-yscrollcommand => [CALLBACK	=> undef, undef, undef],
    );


    $pan;
}


sub grid {
    my $w = shift;
    $w = $w->Subwidget('frame')
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
    $w->Subwidget('frame');
}

sub pack {
    my $w = shift;
    $w = $w->Subwidget('frame')
	if (@_ && $_[0] =~ /^(?:propagate|slaves)$/x);
    $w->SUPER::pack(@_);
}

sub QueueLayout {
    shift if ref $_[1];
    my($m,$why) = @_;
    $m->DoWhenIdle(['Layout',$m]) unless ($m->{LayoutPending});
    $m->{LayoutPending} |= $why;
}

sub AdjustXY {
    my($w,$Wref,$X,$st,$scrl,$getx) = @_;
    my $W = $$Wref;

    if($w >= $W) {
	my $v = 0;
	if($getx) {
	$v |= 1 if $st =~ /w/i;
	$v |= 2 if $st =~ /e/i;
	}
	else {
	$v |= 1 if $st =~ /n/i;
	$v |= 2 if $st =~ /s/i;
	}

	if($v == 0) {
	    $X = int(($w - $W) / 2);
	}
	elsif($v == 1) {
	    $X = 0;
	}
	elsif($v == 2) {
	    $X = int($w - $W);
	}
	else {
	    $X = 0;
	    $$Wref = $w;
	}
	$scrl->Call(0,1)
	    if $scrl;
    }
    elsif($scrl) {
	$X = 0
	    if $X > 0;
	$X = $w - $W
	    if(($X + $W) < $w);
	$scrl->Call(-$X / $W,(-$X + $w) / $W);
    }
    else {
	$X = 0;
	$$Wref = $w;
    }

    return $X;
}

sub Layout {
    my $pan = shift;
    my $why = $pan->{LayoutPending};

    my $slv = $pan->Subwidget('frame');

    return unless $slv;

    my $H = $slv->ReqHeight;
    my $W = $slv->ReqWidth;
    my $X = $slv->x;
    my $Y = $slv->y;
    my $w = $pan->width;
    my $h = $pan->height;
    my $yscrl = $pan->{Configure}{'-yscrollcommand'};
    my $xscrl = $pan->{Configure}{'-xscrollcommand'};

    $yscrl = undef
	if(UNIVERSAL::isa($yscrl, 'SCALAR') && !defined($$yscrl));
    $xscrl = undef
	if(UNIVERSAL::isa($xscrl, 'SCALAR') && !defined($$xscrl));

    if($why & 1) {
	$h = $pan->{Configure}{'-height'} || 0
	    unless($h > 1);
	$w = $pan->{Configure}{'-width'} || 0
	    unless($w > 1);

	$h = $H
	    unless($h > 1 || defined($yscrl));
	$w = $W
	    unless($w > 1 || defined($xscrl));

	$w = 100 if $w <= 1;
	$h = 100 if $h <= 1;

	$pan->GeometryRequest($w,$h);
    }

    my $st = $pan->{Configure}{'-sticky'} || '';

    $pan->{LayoutPending} = 0;

    $slv->MoveResizeWindow(
	AdjustXY($w,\$W,$X,$st,$xscrl,1),
	AdjustXY($h,\$H,$Y,$st,$yscrl,0),
	$W,$H
    );
}

sub SlaveGeometryRequest {
    my ($m,$s) = @_;
    $m->QueueLayout(1);
}

sub LostSlave {
    my($m,$s) = @_;
    $m->{Slave} = undef;
}

sub Manage {
    my $m = shift;
    my $s = shift;

    $m->{Slave} = $s;
    $m->ManageGeometry($s);
    $s->MapWindow;
    $m->QueueLayout(2);
}

sub xview { xyview(1,@_); }
sub yview { xyview(0,@_); }

sub xyview {
    my($horz,$pan,$cmd,$val,$mul) = @_;
    my $slv = $pan->Subwidget('frame');
    return unless $slv;

    my($XY,$WH,$wh,$scrl,@a);

    if($horz) {
	$XY   = $slv->x;
	$WH   = $slv->ReqWidth;
	$wh   = $pan->width;
	$scrl = $pan->{Configure}{'-xscrollcommand'};
    }
    else {
	$XY   = $slv->y;
	$WH   = $slv->ReqHeight;
	$wh   = $pan->height;
	$scrl = $pan->{Configure}{'-yscrollcommand'};
    }

    $scrl = undef
	if(UNIVERSAL::isa($scrl, 'SCALAR') && !defined($$scrl));

    if($WH < $wh) {
	$scrl->Call(0,1);
	return;
    }

    if($cmd eq 'scroll') {
	my $dxy = 0;

	my $gridded = $pan->{Configure}{'-gridded'} || '';
	my $do_gridded = ($gridded eq 'both'
				|| (!$horz == ($gridded ne 'x'))) ? 1 : 0;

	if($do_gridded && $slv->isa('Tk::Frame') && $mul eq 'pages') {
	    my $ch = ($slv->children)[0];
	    if(defined($ch) && $ch->manager eq 'grid') {
		@a = $horz
			? (1-$XY,int($slv->width / 2))
			: (int($slv->height / 2),1-$XY);
		my $rc = ($slv->gridLocation(@a))[$horz ? 0 : 1];
		my $mrc = ($slv->gridSize)[$horz ? 0 : 1];
		$rc += $val;
		$rc = 0 if $rc < 0;
		$rc = $mrc if $rc > $mrc;
		my $gsl;
		while($rc >= 0 && $rc < $mrc) {
		    $gsl = ($slv->gridSlaves(-row => $rc))[0];
		    last
			if defined $gsl;
		    $rc += $val;
		}
		if(defined $gsl) {
		    @a = $horz ? ($rc,0) : (0,$rc);
		    $XY = 0 - ($slv->gridBbox(@a))[$horz ? 0 : 1];
		}
		else {
		    $XY = $val > 0 ? $wh - $WH : 0;
		}
		$dxy = $val; $val = 0;
	    }
	}
	$dxy = $mul eq 'pages' ? ($horz ? $pan->width : $pan->height) : 10
	    unless $dxy;
	$XY -= $dxy * $val;
    }
    elsif($cmd eq 'moveto') {
	$XY = -int($WH * $val);
    }

    $XY = $wh - $WH
	if($XY < ($wh - $WH));
    $XY = 0
	if $XY > 0;

    @a = $horz
	? ( $XY, $slv->y)
	: ($slv->x, $XY);

    $slv->MoveWindow(@a);

    $scrl->Call(-$XY / $WH,(-$XY + $wh) / $WH);
}

1;

__END__

=head1 NAME

Tk::Pane - A window panner

=head1 SYNOPSIS

    use Tk::Pane;
    
    $pane = $mw->Scrolled(Pane, Name => 'fred',
	-scrollbars => 'soe',
	-sticky => 'we',
	-gridded => 'y'
    );

    $pane->Frame;

    $pane->pack;

=head1 DESCRIPTION

C<Tk::Pane> provides creates a widget which allows you to view
only part of a sub-widget.

=head1 AUTHOR

Graham Barr E<lt>F<gbarr@ti.com>E<gt>

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
