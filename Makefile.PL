use ExtUtils::MakeMaker;

#--- MY package

sub MY::libscan
{
 my($self,$path) = @_;

 return '' 
	if($path =~ m:/(RCS|CVS|SCCS)/: ||
	   $path =~ m:[~%]$: ||
	   $path =~ m:\.(orig|rej|nfs[0-9A-Za-z]+|b[ac]k)$:
	  );
 
 $path;
}

#--- Write the Makefile

WriteMakefile(
	NAME	=> 'Tk::GBARR',
	VERSION	=> "1.01",
	'dist'	=> {
			COMPRESS 	=> 'gzip -9f',
			SUFFIX   	=> '.gz', 
			DIST_DEFAULT 	=> 'all tardist',
		   },
	PMLIBDIRS => ['Tk'],
);
