#!/usr/bin/perl
################################################################################
# Copyright (c) 2008-2022 Martin Scharrer <martin.scharrer@web.de>
# This is open source software under the GPL v3 or later.
#
# $Id$
################################################################################
use strict;
use warnings;
my $nerrors = 0;

# Get name of test over filename, e.g. 'test32':
my ($dir,$name) = ($0 =~ m{^(.*/)?(.*?)(?:\.pl)?$});
chdir $dir if ($dir);

if (@ARGV && $ARGV[0] eq '-q') {
    open(STDERR, "/dev/null");
}

die "Test file not found" if not -e "$name.pdf";

open(my $in, "-|", "pdftotext -layout $name.pdf -") or die "pdftotext failure!\n";

while (<$in>) {
    chomp;
    if (/^(.*?): (.*?)=\?= (.*)$/) {
        my ($label,$is,$should) = ($1,$2,$3);
        if ($is ne $should) {
            $nerrors++;
            print STDERR "FAILED: $label: '$is' != '$should'\n";
        }
        else {
            print STDERR "PASSED: $label: '$is' != '$should'\n";
        }
    }
}
close($in);

print STDERR ($nerrors) ? "FAILED: $nerrors errors detected!\n"
                        : "PASSED: no errors detected!\n";

if ($nerrors > 254) {
    exit(255);
}
else {
    exit($nerrors);
}


__END__

