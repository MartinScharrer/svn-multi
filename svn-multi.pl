#!/usr/bin/perl
################################################################################
# Copyright (c) 2009 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
#
# This script belongs to the LaTeX package 'svn-multi'.
# Version: 2009/03/02
################################################################################
use strict;
use warnings;

my @files = @ARGV;

my $readfg = 0;
my $filegroup;

foreach my $file (@files) {
    if ($readfg) {
        $readfg    = 0;
        $filegroup = $file;
        print "\\svnfilegroup{$filegroup}\n\n";
        next;
    }
    if ($file =~ /^--file-group|-fg/) {
        if ($file =~ /^--file-group=(.*)/) {
            $filegroup = $1;
            print "\\svnfilegroup{$filegroup}\n\n";
        }
        else {
            $readfg = 1;
        }
        next;
    }
    open(my $infoh, '-|', "svn info $file") or next;
    my %info = map { chomp; split /\s*:\s*/, $_, 2 } <$infoh>;
    close($infoh);
    print "% Keywords for '$file'\n";
    print svnidlong(\%info);
    #print svnid(\%info);
    print "\n";
}

print "\\svnfilegroup{}\n" if $filegroup;

sub svnid {
    use Date::Parse;
    use Date::Format;
    my $href = shift;
    return "" if (not defined $href->{Name});
    my $date = time2str("%Y-%m-%d %XZ", str2time($href->{'Last Changed Date'}), 'Z');
    return <<"EOT";
\\svnid{\$Id: $href->{Name} $href->{'Last Changed Rev'} $date $href->{'Last Changed Author'} \$}
EOT
}

sub svnidlong {
    my $href = shift;
    return <<"EOT";
\\svnidlong
{\$HeadURL: $href->{URL} \$}
{\$LastChangedDate: $href->{'Last Changed Date'} \$}
{\$LastChangedRev: $href->{'Last Changed Rev'} \$}
{\$LastChangedBy: $href->{'Last Changed Author'} \$}
EOT
}
__END__

