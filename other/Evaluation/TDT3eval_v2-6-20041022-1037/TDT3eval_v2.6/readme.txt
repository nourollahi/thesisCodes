

	      Nist TDT3 Evaluation Software Version 2.6

This directory contains the NIST TDT Evaluation Software.  The
software was written to match the TDT 2004 evaluation plan entitled on
the NIST TDT web site http://www.nist.gov/speech/tests/tdt".

The software has been written in PERL version 5, and will not work
using PERL version 4 or lower.  There is a command line program for
each of the three TDT3 tasks.  The programs are TDT3seg.pl,
TDT3trk.pl, TDT3det.pl TDT3fsd.pl for the Segmentation, Tracking,
Topic Detection and First Story Detection Tasks respectively.  The
makefile will install these scripts and the library they share in
appropriate system locations.

An implementation goal of this software project was to re-use as much
pre-existing software as possible and to start utilizing SGML-tagged
document parsing libraries within the evaluation software.  The
evaluation software makes use of two freely available packages, 1)
'SGMLSpm-103ii', a PERL5 SGML document parsing class library, and 2)
'nsgmls' an SGML normalization program.  

User documentation can be found opening the file 'doc/TDT3eval.htm' in
your favorite WWW browser.  The remainder of this file contains
installation instructions.



Installation Instructions:
--------------------------

As noted above, several packages must be installed before the TDT3 scoring
programs can be run.  There are 4 installation steps required to complete
the installation.  They are:

	1: Installation of 'nsgmls'
	2: Installation of 'PERL5'
	3: Installation of 'SGMLPpm'
	4: Installation of the TDT3 Evaluation Scoring Modules

Each step includes a test to make sure the that installation step has
succeeded.  The fourth step includes final installation tests to
verify proper coordinated execution of all packages.


1: Installation of 'nsgmls'

Nsgmls parses and validates the SGML documents using an SGML Document
Type Definition (DTD).  The program is part of 'SP', a free,
object-oriented toolkit for SGML parsing and entity management,
written by James Clark 'jjc@jclark.com'.  The main WWW page of SP is
'http://www.jclark.com/sp/index.htm'.

SP is a well-documented and regarded packages.  At NIST,
we have not compiled the SP package, but have instead have relied on
pre-compiled executables.  From the SP web page, there is a link
entitled "How to get SP", 'http://www.jclark.com/sp/howtoget.htm', 
that lists pre-compiled binaries and the source code distributions.

Installation of nsgmls should conclude by having the program accessible
via your PATH variable.  

The installation can be verified by executing the command:

	% make nsgmls-check

**** The SGML parsers runs very slowly, so each script has an option,
**** '-s', which disables the use of the SGML parser.  Therefore,
**** installation of nsgmls is not required.


2: Installation of PERL5

Perl is an interpreted language optimized for scanning arbitrary text
files, extracting information from those text files, and printing
reports based on that information.  Most of you already have PERL5
installed on your systems already, so I won't go into detail.  The
make WWW page for PERL is 'http://language.perl.com'.

Installation of perl should result with the perl executable in
accessible in your path.

The installation can be verified by executing the command:

	% make perl5-check

3: Installation of 'SGMLPpm'

'SGMLS.pm' is an extensible perl5 class library for processing the
output from the sgmls and nsgmls parsers.  Documentation and source
code are available from the URL:
'http://www.cs.indiana.edu/hyplan/asengupt/asengupt/sgml/SGMLSpm/DOC/HTML/SGMLSpm/sgmlspm.html'
and within this source code directory, 'SGMLSpm-1.03ii.tar.gz'.  The
supplied copy of SPMLSpm was installed at NIST to write the TDT3
evaluation programs, and is supplied under the terms the accompanying
GNU-licensing agreement.

Follow the installation instructions documented within the SGMLSpm package.
After installation, the perl class module 'SGMLS' should accessible
from a PERL execution.  

The installation can be verified by executing the command:

	% make SGMLSpm-check

**** The PERL SGML class library parsers runs very slowly, so each
**** script has an option, '-s', which disables the use of the SGML
**** class library..  Therefore, installation of SGMLSpm is not
**** required.

4: Installation of the TDT3 Evaluation Scoring Modules

To install the TDT3 evaluation scoring modules, first verify and/or
change two macro definitions in the 'makefile'.  The macro names
are PERL5_MODULES and BINDIR.  

The PERL5_MODULES macro is the directory containing PERL5 modules.
The directory is defined by the system administrator, however a common
location for the directory is '/usr/local/lib/perl5'.

*** If you do not have root access to add the perl module, you can add
*** the option "-I SGMLSpm_DIR" to all command line executions.  The
*** 'SGMLSpm_DIR' directory is were you've compile the SGMLSpm package.

The BINDIR macro is the directory in which the TDT3 evaluation
programs will be installed.  A possible location might be
'/usr/local/bin' or '$HOME/bin'.  The chosen directory should be
included in our PATH variable.

After checking or modifying the 'makefile', executed the commands:
	
	% make install-TDT3.pm   ### To install the TDT3 PERL5 library
	% make install-TDT3      ### To install the eval programs

*** If you do not have root access to add the TDT evaluation scripts
*** to local binary directories, you can add the option "-I TDT3eval"
*** to all command line executions.  The 'TDTeval' directory is were
*** you've extracted the TDT3eval package.

To check the full installation, execute the command:

	% make check-all

