use strict;
use warnings;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Module::LoadVersion',
    VERSION_FROM      => 'lib/Module/LoadVersion.pm',
    PREREQ_PM         => {
        'Module::Info' => 0,
        'Digest::MD5'  => 0,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Module/LoadVersion.pm',
       AUTHOR         => 'tjmc') : ()),
);
