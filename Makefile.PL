# Shamelessly ripped off of
# https://github.com/miyagawa/cpanminus/blob/master/Makefile.PL

# perl Makefile.PL (from git repo) copies 'perl-which' -> 'bin/perl-which'
if (-e 'perl-which') {
    print STDERR "Generating bin/perl-which from perl-which\n";
    open my $in, "<perl-which" or die $!;
    open my $out, ">bin/perl-which" or die $!;
    while (<$in>) {
        s|^#!/usr/bin/env perl|#!perl|; # so MakeMaker can fix it
        print $out $_
    }
}

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'perl-which',
    VERSION_FROM => "perl-which",
    ABSTRACT => q{locate a Perl module in the user's @INC},
    PREREQ_PM => {
        'Module::Build' => 0.36,
        'ExtUtils::MakeMaker' => 6.31,
        'ExtUtils::Install' => 1.46,
        'Path::Class' => 0.23,
        'Test::More' => 0.94,
    },
    LICENSE => 'perl',
    EXE_FILES => [ 'bin/perl-which' ],
);
