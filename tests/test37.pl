#!/usr/bin/perl
################################################################################
# Copyright (c) 2009-2022 Martin Scharrer <martin.scharrer@web.de>
# This is open source software under the GPL v3 or later.
#
# $Id$
################################################################################
use strict;
use warnings;
use Test::More tests => 1;

my $name = $0;
$name =~ s/\.pl$//;
print "Perl test script for $name.\n";

# Read tex and svn file and compare both:
open (my $tex, '<', "$name.tex");
my @TEX = grep { chomp; s/^\s*\\svnexternal\s*// } <$tex>;
close ($tex);

open (my $svn, '<', "$name.aux");
my @SVN = grep { chomp; s/^\s*\\\@svnexternal\s*// } <$svn>;
close ($svn);

for (@SVN) { s/^\s*(?:\[(.*?)\])?{.*?}//; $_ = "[$1]".$_ if $1; s/##/#/g }
for (@TEX,@SVN) { s/^path\s*/path / }

is_deeply( \@TEX, \@SVN );

exit 0;
__END__
