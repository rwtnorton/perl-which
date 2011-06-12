#!/usr/bin/env perl
use strict;
use warnings;

use Test::More; END { done_testing(); }

use FindBin qw( $Bin );
use Path::Class qw( dir file );

my $perl_which = file( $Bin, '..', 'perl-which' );

ok -e $perl_which, 'script exists';
ok -x $perl_which, '... and is executable';
BAIL_OUT 'Unable to run perl-which' unless -x $perl_which;

# happy path for empty arg list
{
    my @paths = `$perl_which`;
    is scalar @paths, 0, 'without args, no paths found';
}

# happy path for single arg
{
    my @paths = `$perl_which Test::More`;
    chomp @paths;
    cmp_ok scalar @paths, '>', 0, 'found path for Test::More';
    my @inc = map { dir($_) } @INC;
    for my $path (@paths) {
        $path =~ s/Test.More\.pm$//;
        $path = dir($path);
        cmp_ok scalar(grep { $_ eq $path } @inc), '>', 0,
            "... where path is in \@INC: $path"
            or diag explain {
                needle => "$path", haystack => [map { "$_" } @inc] };
        my $filename = file( $path, 'Test', 'More.pm' );
        ok -e $filename, "... and file really exists: $filename";
    }
}

# happy path for multiple args
{
    my @paths = `$perl_which Test::More Path::Class`;
    chomp @paths;
    cmp_ok scalar(grep { /Test.More\.pm$/  } @paths),
           '>', 0, 'found path for Test::More';
    cmp_ok scalar(grep { /Path.Class\.pm$/ } @paths),
           '>', 0, 'found path for Path::Class';
    my @inc = map { dir($_) } @INC;

    # Not very DRY ...
    for my $path (@paths) {
        if ($path =~ /Test.More\.pm$/) {
            $path =~ s/Test.More\.pm$//;
            $path = dir($path);
            cmp_ok scalar(grep { $_ eq $path } @inc), '>', 0,
                "... where path is in \@INC: $path"
                or diag explain {
                    needle => "$path", haystack => [map { "$_" } @inc] };
            my $filename = file( $path, 'Test', 'More.pm' );
            ok -e $filename, "... and file really exists: $filename";
        }
        elsif ($path =~ /Path.Class\.pm$/) {
            $path =~ s/Path.Class\.pm$//;
            $path = dir($path);
            cmp_ok scalar(grep { $_ eq $path } @inc), '>', 0,
                "... where path is in \@INC: $path"
                or diag explain {
                    needle => "$path", haystack => [map { "$_" } @inc] };
            my $filename = file( $path, 'Path', 'Class.pm' );
            ok -e $filename, "... and file really exists: $filename";
        }
    }
}

# nonsensical module not found (I hope!!!)
{
    my $fail_module = join '::', qw(
        WhyWould
        You
        Ever
        HaveSome
        Module
        With
        ThisSuper
        Long
        Name
        ForCryin
        OutLoud
        Cuz
        YouReally
        Oughta
        KnowBetter
        IfYouKnowWhatI
        Mean
    );
    my @paths = `$perl_which $fail_module`;
    is scalar @paths, 0, 'non-existent module produces no matches'
        or diag "Wise guy, eh?  Nix these, Chuckles: ["
            . map { "'$_'" } join(', ', @paths) . "]";
}
