use ExtUtils::MakeMaker;
WriteMakefile(
	NAME	=> 'Tk::GBARR',
	VERSION	=> "1.00",
	'dist'	=> {
			COMPRESS 	=> 'gzip -9f',
			SUFFIX   	=> '.gz', 
			DIST_DEFAULT 	=> 'all tardist',
		   },
);
