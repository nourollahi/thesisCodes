### makefile for TDT3eval

PERL5_MODULES = /usr/lib/perl5/5.8.0
BINDIR = /usr/local/bin

default:
	@-echo "No default target defined."

check-all: nsgmls-check perl5-check SGMLSpm-check TDT3seg-check

nsgmls-check:
	@-sh test/chk_nsg.sh `pwd`

perl5-check:
	@-chmod +x test/chk_prl.pl
	@-echo Testing PERL5
	@-test/chk_prl.pl

libcheck:
	TDT3trk.pl __CHECKLIB__
	TDT3det.pl __CHECKLIB__
	TDT3seg.pl __CHECKLIB__
	TDT3fsd.pl __CHECKLIB__
	DetectionScore.pl __CHECKLIB__

SGMLSpm-check: 
	@-echo Testing SGMLSpm in conjunction with nsgmls
	@-cd test ; chk_spm.pl

TDT3seg-check:
	@-echo Testing TDT3seg.pl
	@-sh test/chk_tdt.sh

install-TDT3.pm:
	cp TDT3.pm $(PERL5_MODULES)

install-link-to-TDT3.pm:
	rm -f $(PERL5_MODULES)/TDT3.pm
	ln -s `pwd`/TDT3.pm $(PERL5_MODULES)/TDT3.pm

install-TDT3:
	cp TDT3seg.pl TDT3trk.pl TDT3det.pl $(BINDIR)



dist:
	@echo "TDT3eval_v"`grep Version\  readme.txt | head -1 | perl -pe 's/.*Version\s+//'` > .fname	
	@echo "Building a release version" `cat .fname`
	@echo "Verifying and up-to-date CVS copy"
	cvs up
	cvs co -d `cat .fname` TDT3eval
	echo "Building the TAR file"
#	(cd `cat .fname`; rm -r fromAO test_suite/medium* test_suite/example_figs*txt test_suite/judge* src/loadDump.pl src/VertexInfo.pm src/htd-1.0.dtd)
	tar czf `cat .fname`"-"`date +%Y%m%d-%H%M`.tgz --exclude CVS `cat .fname` 
	rm -r `cat .fname`



