# $Id: Makefile 628 2007-07-10 20:32:06Z martin $

PACKAGE=svn-multi
PACKFILES = ${PACKAGE}.dtx ${PACKAGE}.ins ${PACKAGE}.pdf svn-multi-pl.dtx svn-multi.pl example_main.tex \
			example_chap1.tex example.pdf Makefile README
TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.toc *.ilg *.gls *.hd
TESTDIR = tests
TESTS = $(patsubst %.tex,%,$(subst ${TESTDIR}/,,$(wildcard ${TESTDIR}/test?.tex ${TESTDIR}/test??.tex))) # look for all test*.tex file names and remove the '.tex' 
TESTARGS = -output-directory ${TESTDIR}
INSGENERATED = ${PACKAGE}.sty svnkw.sty svn-multi.pl
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf svn-multi-pl.pdf example.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf



RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

.PHONY: all doc package clean fullclean example testclean ${TESTS}

all: package doc example
new: fullclean all

doc: ${PACKAGE}.pdf svn-multi-pl.pdf

package: ${PACKAGE}.sty

%.pdf: %.dtx
	pdflatex $*.dtx
	pdflatex $*.dtx
	-makeindex -s gind.ist -o $*.ind $*.idx
	-makeindex -s gglo.ist -o $*.gls $*.glo
	pdflatex $*.dtx
	pdflatex $*.dtx

${INSGENERATED}: *.dtx ${PACKAGE}.ins 
	yes | latex ${PACKAGE}.ins
	@-chmod +x *.pl

clean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX}) ${GENERATED} *~ *.backup

example: example.pdf gexample

example.pdf: example_main.tex example_chap1.tex ${PACKAGE}.sty
	pdflatex $<
	perl ./svn-multi.pl $<
	pdflatex $<
	mv example_main.pdf $@

gexample: group_example.tex $(wildcard group*.tex) svn-multi.sty
	${RM} group_example_*.tex
	pdflatex $<
	pdflatex $<

zip: package doc example ${PACKAGE}.zip

${PACKAGE}.zip: ${PACKFILES}
	grep -q '\* Checksum passed \*' svn-multi.log
	grep -q '\* Checksum passed \*' svn-multi-pl.log
	zip $@ ${PACKFILES}
	#cd .. && zip ${PACKAGE}/$@ $(addprefix ${PACKAGE}/, ${PACKFILES})

tar.gz: ${PACKAGE}.tar.gz

${PACKAGE}.tar.gz:
	tar -czf $@ ${PACKFILES}

# Make sure TeX finds the input files in TESTDIR
tests ${TESTS}: export TEXINPUTS:=${TEXINPUTS}:${TESTDIR}

testclean:
	@${RM} $(foreach ext, aux log out pdf svn svx, tests/test*.${ext})

tests: package testclean
	@echo "Running tests: ${TESTS}:"
	@${MAKE} -e -i --no-print-directory ${TESTS} \
		TESTARGS="-interaction=batchmode -output-directory=${TESTDIR}"\
		TESTPLOPT="-q"\
		> /dev/null

${TESTS}: % : ${TESTDIR}/%.tex package testclean
	@-pdflatex -interaction=nonstopmode ${TESTARGS} $< 1>/dev/null 2>/dev/null
	@if test -e ${TESTDIR}/$*.svn; then perl ./svn-multi.pl ${TESTDIR}/$* 1>/dev/null ; fi
	@if (pdflatex ${TESTARGS} $< && (test ! -e ${TESTDIR}/$*.pl || ${TESTDIR}/$*.pl ${TESTPLOPT})); \
		then /bin/echo -e "${GREEN}$@ succeeded${WHITE}" >&2; \
		else /bin/echo -e "${RED}$@ failed!!!!!!${WHITE}" >&2; fi


