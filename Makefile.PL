use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Bit::Vector::Named',
    VERSION_FROM => 'lib/Bit/Vector/Named.pm', # finds $VERSION
    AUTHOR       => 'William Hererra (whererra@skylightview.com)',
    ABSTRACT     => 'Named bit vectors',
    PREREQ_PM    => { Bit::Vector::Minimal => 0, Test::More => 0 },
);
