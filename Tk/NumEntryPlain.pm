
package Tk::NumEntryPlain;

use Tk (); 
use Tk::Derived;
use Tk::Entry;
use strict;

use vars qw(@ISA $VERSION);
@ISA = qw(Tk::Derived Tk::Entry);
$VERSION = "0.02";

Construct Tk::Widget 'NumEntryPlain';

sub ClassInit {
    my ($class,$mw) = @_;

    $class->SUPER::ClassInit($mw);

    $mw->bind($class,'<Leave>', 'Leave');
    $mw->bind($class,'<FocusOut>', 'Leave');
    $mw->bind($class,'<Return>', 'Return');
    $mw->bind($class,'<Up>', 'Up');
    $mw->bind($class,'<Down>', 'Down');
}


## Bindings callbacks

sub Leave {
    my $e = shift;
    $e->incdec(0);  # range check
}

sub Return {
    my $e = shift;
    my $cmd = $e->{Configure}{'-command'};

    my $v = $e->value; # range check

    $cmd->Call($v)
	if $cmd;
}

sub Up {
    my $e = shift;
    $e->incdec(1,'initial');
}

sub Down {
    my $e = shift;
    $e->incdec(-1,'initial');
}

sub Insert {
    my($e,$c) = @_;

    if($c =~ /^[-0-9]$/) {
	$e->SUPER::Insert($c);
    }
    elsif(defined($c) && length($c)) {
	$e->_ringBell;
    }
}


## Widget constructor

sub Populate {
    my ($e, $args) = @_;

#    $e->SUPER::Populate($args);


    $e->ConfigSpecs(
        -value       => [METHOD   => undef,         undef,         "0"       ],
        -defaultvalue
		     => [PASSIVE  => undef,         undef,         undef     ],
        -maxvalue    => [PASSIVE  => undef,         undef,         undef     ],
        -minvalue    => [PASSIVE  => undef,         undef,         undef     ],
        -bell        => [PASSIVE  => "bell",        "Bell",        1         ],
        -command     => [CALLBACK => undef,         undef,         undef     ],
        -textvariable
                     => [PASSIVE  => undef,         undef,         undef     ],
    );

}

## Options implementation

sub value {
    my $e = shift;
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
        $e->incdec(0); # range check
        $old = $e->get;
    }

    # Do a range check after all configuration has finished,
    # as we may not yet know the range

    $e->DoWhenIdle([ \&incdec, $e, 0]);

    length($old) ? $old + 0 : $e->{Configure}{'-defaultvalue'};
}

sub _ringBell {
    my $e = shift;
    my $v;
    return
        unless defined($v = $e->{Configure}{'-bell'});
    $e->bell
        if(($v =~ /^\d+$/ && $v) || $v =~ /^true$/i);
}


sub incdec {
    my($e,$inc,$i) = @_;
    my $val = $e->get;

    if($inc == 0 && $val =~ /^-?$/) {
        $val = "";
    }
    else {
        my $min = $e->{Configure}{'-minvalue'};
        my $max = $e->{Configure}{'-maxvalue'};

        $val += $inc;
        my $limit = undef;

        $limit = $val = $min
            if(defined($min) && $val < $min);

        $limit = $val = $max
            if(defined($max) && $val > $max);

        if(defined $limit) {
            $e->_ringBell
                if $inc;
        }
    }

    my $pos = $e->index('insert');
    $e->delete(0,'end');
    $e->insert(0,$val);
    $e->icursor($pos);
}


1;

__END__

=head1 NAME

Tk::NumEntryPlain - A numeric entry widget

=head1 SYNOPSIS

    use Tk::NumEntryPlain;

=head1 DESCRIPTION

C<Tk::NumEntryPlain> defines a widget for entering integer numbers.

C<Tk::NumEntryPlain> supports all the options and methods that a normal
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

=head1 HISTORY

The code was extracted Tk::NumEntry and slightly modified
by Achim Bohnet <ach@mpe.mpg.de>.  Tk::NumEntry's author
is Graham Barr <gbarr@pobox.com>.

=head1 COPYRIGHT

Copyright (c) 1997 Graham Barr. All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

Except the typo's, they blong to Achim :-)

=cut
