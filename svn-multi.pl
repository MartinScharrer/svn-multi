#!/usr/bin/perl
################################################################################
# Copyright (c) 2009 Martin Scharrer <martin@scharrer-online.de>
# This is open source software under the GPL v3 or later.
#
# This script belongs to the LaTeX package 'svn-multi'.
# Version: 2009/03/02
#
# $Id$
################################################################################
use strict;
use warnings;
use File::Basename;

my $VERSION = "0.1";

my $dollar  = '$';

my %EXCLUDE = map { $_ => 1 } qw(sty tex aux log out toc fff ttt svn svx);
sub create_svxfile ($@);

if (!@ARGV or $ARGV[0] eq '--help' or $ARGV[0] eq '-h') {
    usage();
}


warn "This is svn-multi.pl, Version $VERSION\n";

sub usage {
    print STDERR <<'EOT';
Usage:
 svn-multi.pl jobname[.tex] [--fls] [--file-group|-fg <file group>] [input_files] ...
 ... [--file-group|-fg <file group>] [input_files] ...

Description:
 This LaTeX helper script collects Subversion keywords from non-(La)TeX files
 and provides it to the 'svn-multi' package using '.svx' files.  It will first
 scan the file '<jobname>.svn' for files declared by the '\svnextern' macro but
 also allows to provide additional files including the corresponding
 file-groups. The keywords for the additional files will be written in the file
 '<jobname>.svx'.

Options:
 jobname[.tex] : The LaTeX `jobname`, i.e. the basename of your main LaTeX file.
 --file-group <FG> : Use given file group <FG> for all following files,
 or -fg <FG>         including the one read by a '--fls' option, until the next
                     file group is specified.
 --fls  : Read list of (additional) files from the file '<jobname>.fls'. This
          file is produced by LaTeX when run with the '--recorder' option and
          contains a list of all input and output files used by the LaTeX main
          file. Only input files with a relative path will be used.
          A previously selected file-group will be honoured.

Examples:
The main LaTeX file here is 'mymainlatexfile.tex'.

 svn-multi.pl mymainlatexfile
    Creates Subversion keywords for all files declared by '\svnextern' inside
    the LaTeX code.

 svn-multi.pl mymainlatexfile --file-group=FLS --fls
    Creates Subversion keywords for all files declared by '\svnextern' inside
    the LaTeX code. In addition it does the same for all relative input files
    mentioned in the .fls file which are placed in the 'FLS' file group.

 svn-multi.pl mymainlatexfile a b c --file-group=B e d f
    In addition to the '\svnextern' declared files the keywords for the files
    'a', 'b' and 'c' will be added without a specific file-group, i.e. the last
    file-group specified in the LaTeX file before the '\svnextern' macro will
    be used. The keywords for 'e', 'd', 'f' will be part of file-group 'B'.

 svn-multi.pl mymainlatexfile --file-group=A a --file-group=B b --file-group='' c
    File 'a' is in file-group 'A', 'b' is in 'B' and 'c' is not in any group.

Further Information:
See the svn-multi package manual for more information about this script.
EOT
    exit(0);
}

my ($jobname, $dir, $suffix) = fileparse(shift @ARGV);
if ($dir && $dir ne './') {
  printf STDERR "Main directory is '$dir'.\n";
  chdir($dir);
}

if ($jobname =~ /^-/) {
    usage();
}
my $outfile = "$jobname.svx";

my %external;

if (-e "$jobname.svn" and open( my $svnfh, '<', "$jobname.svn")) {
    warn "Reading '$jobname.svn'.\n";
    while (<$svnfh>) {
        chomp;
        if (/^\s*\\\@svnexternal\s*{([^}]+)}\s*{\s*(?:{(.*)}|)\s*}\s*$/) {
            my ($name,$list) = ($1,$2||"");
            $name =~ s/^\.\///;
            push @{$external{$name} ||= []}, ( split /}\s*{/, $list );
        }
    }
    foreach my $list (values %external) {
        my %temp = map { $_ => 1 } @$list;
        $list = [ keys %temp ];
    }
    close ($svnfh);
}
else {
    warn "No .svn file found for '$jobname'!\n";
}


my @mainfilepairs;
if (exists $external{"$jobname.tex"}) {
    @mainfilepairs = (['', @{$external{"$jobname.tex"}||[]}]);
    delete $external{"$jobname.tex"};
}
push @mainfilepairs, parse_args(@ARGV);
create_svxfile("$jobname.svx", @mainfilepairs )
    if @mainfilepairs;

while ( my ($texfile, $extlist) = each %external ) {
    my $svxfile = $texfile;
    $svxfile =~ s/\.(tex|ltx)$/.svx/;
    create_svxfile($svxfile, ['', @$extlist]);
}

# Parses the arguments and builds a list of (filegroup,files) pairs
sub parse_args {
    my @args = @_;
    my $filegroup = '';
    my @files;
    my $readfg;
    my @pairs;

    foreach my $arg (@args) {
        if ($readfg) {
            $readfg    = 0;
            $filegroup = $arg;
            $filegroup =~ s/^["']|["']$//;
        }
        elsif ($arg =~ /^--file-group|^-?-fg/) {
            push @pairs, [ $filegroup, @files ];
            @files = ();
            if ($arg =~ /^--file-group=(.*)/) {
                $filegroup = $1;
                $filegroup =~ s/^["']|["']$//;
            }
            else {
                $readfg = 1;
            }
        }
        elsif ($arg =~ /^--fls/) {
            push @files, read_fls("$jobname.fls");
        }
        else {
            push @files, $arg;
        }
    }
    push @pairs, [ $filegroup, @files ] if @files;
    return @pairs;
}

sub create_svxfile ($@) {
    my ($svxfile, @fgpair) = @_;
    my $lastfilegroup = '';
    my $fgused = 0;
    open(my $svxfh, '>', $svxfile) or do {
        warn "ERROR: Could not create SVX file '$svxfile'!\n";
        return;
    };
    return if not @fgpair;
    warn "Generating .svx file '$svxfile'.\n";
    select $svxfh;
    print "% Generated by svn-multi.pl v$VERSION\n\n";

    while ( my ($filegroup, @files) = @{shift @fgpair||[]}) {
    if ($filegroup ne $lastfilegroup) {
        print "\\svnfilegroup{$filegroup}\n";
    }
    if ($filegroup) {
        $fgused = 1;
    }

    foreach my $file (@files) {
        open(my $infoh, '-|', "svn info '$file' 2>/dev/null") or next;
        my %info = map { chomp; split /\s*:\s*/, $_, 2 } <$infoh>;
        close($infoh);
        if (not keys %info) {
            print "% Could not receive keywords for '$file'!\n\n";
            next;
        }
        print "% Keywords for '$file'\n";
        print svnidlong(\%info);
        print "\n"
    }

    $lastfilegroup = $filegroup;
    }
    print "\\svnfilegroup{}\n" if $fgused and $lastfilegroup ne '';
    print "\n";
    close ($svxfh);
}


sub svnid {
    use Date::Parse;
    use Date::Format;
    my $href = shift;
    return "" if (not defined $href->{Name});
    my $date = time2str("%Y-%m-%d %XZ", str2time($href->{'Last Changed Date'}), 'Z');
    return <<"EOT";
\\svnid{${dollar}Id: $href->{Name} $href->{'Last Changed Rev'} $date $href->{'Last Changed Author'} \$}
EOT
}

sub svnidlong {
    my $href = shift;
    return <<"EOT";
\\svnidlong
{${dollar}HeadURL: $href->{URL} \$}
{${dollar}LastChangedDate: $href->{'Last Changed Date'} \$}
{${dollar}LastChangedRevision: $href->{'Last Changed Rev'} \$}
{${dollar}LastChangedBy: $href->{'Last Changed Author'} \$}
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
    return keys %stack;
}
__END__

