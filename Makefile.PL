use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Test::Output',
    AUTHOR              => 'Shawn Sorichetti <ssoriche@coloredblocks.net>',
    VERSION_FROM        => 'lib/Test/Output.pm',
    ABSTRACT_FROM       => 'lib/Test/Output.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Test-Output-*' },
);
