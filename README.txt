--------------------------------------------------------------
 svn-multi (was svnkw)
--------------------------------------------------------------

This package lets you typeset keywords of the version
control system Subversion inside your LaTeX files anywhere
you like. Unlike the very similar package 'svn' the usage of
multiple files for one LaTeX document is well supported.

Copyright (c) 2006-2022 Martin Scharrer
E-mail: martin.scharrer@web.de
svn-multi/

This work may be distributed and/or modified under the
conditions of the LaTeX Project Public License, either version 1.3c
of this license or (at your option) any later version.
The latest version of this license is in
  http://www.latex-project.org/lppl.txt
and version 1.3c or later is part of all distributions of LaTeX
version 2008/05/04 or later.

This work has the LPPL maintenance status `maintained'.

The Current Maintainer of this work is Martin Scharrer.

This work consists of the files svn-multi.dtx, svn-multi-pl.dtx, svn-multi.ins
and the derived files svn-multi.sty, svnkw.sty and svn-multi.pl.


Tiny example:
~~~~~~~~~~~~~
Put the following Subversion keyword at the start of all your LaTeX files of
your document:

\svnidlong
{$HeadURL$}
{$LastChangedDate$}
{$LastChangedRevision$}
{$LastChangedBy$}

or

\svnid{$Id$}

or both.
Attach the subversion property svn:keyword with a value of 
'URL Date Revision Author', 'Id' or both, respectively, to all LaTeX files.
Subversion will expand this keywords the next time the files are committed and
then the SVN information can be typeset using
    \svnauthor, \svnrev, \svndate, \svnhour, ...
which will hold the information of the latest comitted file
anywhere in your multi-file LaTeX document.

Also per-file macros exist:
    \svnfileauthor, \svnfilerev, ...
which hold the keyword values of the current file.


INSTALL:
~~~~~~~~
From the .dtx file (if you don't get the .sty files directly):
==================
Unpack the zip file and run 'make'.
You also can do it manually:
  [pdf]latex svn-multi.ins      # for the style file and perl script
  [pdf]latex svn-multi.dtx      # for the documentation
2x[pdf]latex example-main       # for the example

For the large keyword group example document:
  [pdf]latex group-example
  perl svn-multi.pl group-example
2x[pdf]latex group-example

Place the two .sty files
  svn-multi.sty         # Package
  svnkw.sty             # Wrapper for backward compatibility
into your TEXMF tree, e.g. in
  $TEXMF/tex/latex/svn-multi

Make the perl script svn-multi.pl executable:
  chmod +x svn-multi.pl
and place it in an directory in your $PATH, e.g. under Unix/Linux in
  /usr/bin/svn-multi.pl          or
  /usr/local/bin/svn-multi.pl    or
  $HOME/bin/svn-multi.pl
Consider to rename or link it to 'svn-multi'.

