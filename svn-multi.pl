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

my %EXCLUDE = map { $_ => 1 } qw(sty tex aux log out toc fff ttt svn svx);

if (!@ARGV or $ARGV[0] eq '--help' or $ARGV[0] eq '-h') {
    usage();
}

sub usage {
    print STDERR <<'EOT';
Usage: svn-multi.pl outputfile[.svx] [--fls] [--file-group|-fg] input_files ...  [--file-group|-fg] input_files ...
 Output file: should be the main LaTeX file name without the extention,
              i.e. the \\jobname.
 File group: use given file group for all following files until the next
             file group is specified.
 Option --fls: Read list of (additional) files from 'outfile.fls' produced by LaTeX
               when run with the '--recorder' option. The files will be appended
               to the end of the list, so the last file group will be used for
               them.
EOT
    exit(0);
}

my $jobname;
my $outfile = shift @ARGV;

if ($outfile =~ /^-/) {
    usage();
}
elsif ($outfile =~ s/(.*)\.tex$/.svx/) {
    $jobname = $1;
}
elsif ($outfile !~ /(.*)\.(?:.*)$/) {
    $jobname = $outfile;
    $outfile .= '.svx';
}
else {
    $jobname = $1;
}

my @files = @ARGV;

my $readfg = 0;
my $filegroup;

open (my $ofh, '>', $outfile) or die("Could not open output file!\n");
select $ofh;

foreach my $file (@files) {
    if ($readfg) {
        $readfg    = 0;
        $filegroup = $file;
        print "\\svnfilegroup{$filegroup}\n\n";
        next;
    }
    elsif ($file =~ /^--file-group|-fg/) {
        if ($file =~ /^--file-group=(.*)/) {
            $filegroup = $1;
            print "\\svnfilegroup{$filegroup}\n\n";
        }
        else {
            $readfg = 1;
        }
        next;
    }
    elsif ($file =~ /^--fls/) {
        usage() if not defined $jobname;
        read_fls("$jobname.fls");
        next;
    }
    open(my $infoh, '-|', "svn info $file") or next;
    my %info = map { chomp; split /\s*:\s*/, $_, 2 } <$infoh>;
    close($infoh);
    if (not keys %info) {
        print "% Could not receive keywords for '$file'!\n\n";
        next;
    }

    print "% Keywords for '$file'\n";
    print svnidlong(\%info);
    #print svnid(\%info);
    print "\n";
}

print "\\svnfilegroup{}\n" if $filegroup;

close ($ofh);

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
{\$LastChangedRevision: $href->{'Last Changed Rev'} \$}
{\$LastChangedBy: $href->{'Last Changed Author'} \$}
EOT
}


sub read_fls {
    my $fls = shift;
    my %stack;
    open (my $fh, '<', $fls) or return;
    while (<$fh>) {
        chomp;
        if (/^INPUT ([^\/].*)$/) {
            my $file = $1;
            my $ext = substr($file, rindex($file,'.')+1);
            $stack{$1} = 1 if not exists $EXCLUDE{$ext};
        }
    }
    close($fh);
    push @files, keys %stack;
    return 1;
}
__END__

