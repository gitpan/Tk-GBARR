use ExtUtils::MakeMaker;

#--- MY package

sub MY::libscan
{
 my($self,$path) = @_;

 return '' 
	if($path =~ m:/(RCS|CVS|SCCS|alpha)/: ||
	   $path =~ m:[~%]$: ||
	   $path =~ m:\.(orig|rej|nfs[0-9A-Za-z]+|b[ac]k)$:
	  );

 $path;
}

#--- Write the Makefile

my %pm = map { ($_ => '$(INST_LIB)/Tk/' . $_) }
    qw(Cloth.pm FireButton.pm NumEntry.pm NumEntryPlain.pm TFrame.pm);
for (qw(cloth firebutton numentry numentryplain tframe)) {
    $pm{"examples/$_"} = ($] >= 5.005
			  ? '$(INST_ARCHLIB)'
			  : '$(INST_LIB)') . '/Tk/demos/widtrib/' . $_ . '.pl';
}

WriteMakefile(
	PREREQ_PM => { 'Tk' => '402.002' }, # Tk/NumEntry need it
	NAME	=> 'Tk::GBARR',
	DISTNAME => 'Tk-GBARR',
	VERSION	=> "2.06",
	PM => \%pm,
	'dist'	=> {
			COMPRESS 	=> 'gzip -9f',
			SUFFIX   	=> '.gz', 
			#DIST_DEFAULT 	=> 'all tardist',
		   },
);

sub MY::postamble {
	my $rules = "";
        if (defined $ENV{USER} && $ENV{USER} eq 'eserte') {
                $rules .= <<'EOF';
release :: dist
	cpan-upload $(DISTVNAME).tar$(SUFFIX)

EOF
        }

	if (0) { # not yet XXX
	$rules .= '
demo :: pure_all
	$(FULLPERL) -w -I$(SITELIBEXP)/Tk/demos/widget_lib -I$(SITEARCHEXP)/Tk/demos/widget_lib -Mblib demos/date.pl

';
	}
	$rules;
}
