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

WriteMakefile(
	PREREQ_PM => { 'Tk' => '402.002' }, # Tk/NumEntry need it
	NAME	=> 'Tk::GBARR',
	DISTNAME => 'Tk-GBARR',
	VERSION	=> "2.03",
	'dist'	=> {
			COMPRESS 	=> 'gzip -9f',
			SUFFIX   	=> '.gz', 
			#DIST_DEFAULT 	=> 'all tardist',
		   },
);

sub MY::postamble {
	'
demo :: pure_all
	$(FULLPERL) -w -I$(SITELIBEXP)/Tk/demos/widget_lib -I$(SITEARCHEXP)/Tk/demos/widget_lib -Mblib demos/date.pl

';
}
