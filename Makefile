# $Id: Makefile 628 2007-07-10 20:32:06Z martin $

PACKAGE=svn-multi
PACKFILES = ${PACKAGE}.dtx ${PACKAGE}.ins ${PACKAGE}.pdf example_main.tex \
			example_chap1.tex example.pdf Makefile README
TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.toc *.ilg *.gls *.hd
TESTDIR = tests
TESTS = $(patsubst %.tex,%,$(subst ${TESTDIR}/,,$(wildcard ${TESTDIR}/test?.tex ${TESTDIR}/test??.tex))) # look for all test*.tex file names and remove the '.tex' 
TESTARGS = -output-directory ${TESTDIR}
GENERATED = ${PACKAGE}.pdf ${PACKAGE}.sty svnkw.sty example.pdf ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf

RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

.PHONY: all doc package clean fullclean example ${TESTS}

all: package doc example
new: fullclean all

doc: ${PACKAGE}.pdf

package: ${PACKAGE}.sty

${PACKAGE}.pdf: ${PACKAGE}.dtx ${PACKAGE}.sty
	pdflatex ${PACKAGE}.dtx
	pdflatex ${PACKAGE}.dtx
	pdflatex ${PACKAGE}.dtx
	makeindex -s gind.ist -o ${PACKAGE}.ind ${PACKAGE}.idx
	makeindex -s gglo.ist -o ${PACKAGE}.gls ${PACKAGE}.glo
	pdflatex ${PACKAGE}.dtx
	pdflatex ${PACKAGE}.dtx

${PACKAGE}.sty: ${PACKAGE}.dtx ${PACKAGE}.ins
	yes | latex ${PACKAGE}.ins

clean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX}) ${GENERATED} *~ *.backup

example: example.pdf

example.pdf: example_main.tex example_chap1.tex ${PACKAGE}.sty
	pdflatex $<
	./svn-multi.pl $<
	pdflatex $<
	mv example_main.pdf $@

fgexample: filegroup_example.tex $(wildcard filegroup*.tex) svn-multi.sty
	${RM} filegroup_example_*.tex
	pdflatex $<
	pdflatex $<

zip: package doc example ${PACKAGE}.zip

${PACKAGE}.zip: ${PACKFILES}
	grep -q '\* Checksum passed \*' svn-multi.log
	cd .. && zip ${PACKAGE}/$@ $(addprefix ${PACKAGE}/, ${PACKFILES})

tar.gz: ${PACKAGE}.tar.gz

${PACKAGE}.tar.gz:
	tar -czf $@ ${PACKFILES}

# Make sure TeX finds the input files in TESTDIR
tests ${TESTS}: export TEXINPUTS:=${TEXINPUTS}:${TESTDIR}

tests: package
	@echo "Running tests: ${TESTS}:"
	@${MAKE} -e -i --no-print-directory ${TESTS} \
		TESTARGS="-interaction=batchmode -output-directory=${TESTDIR}"\
		TESTPLOPT="-q"\
		> /dev/null

${TESTS}: % : ${TESTDIR}/%.tex package
	@-pdflatex -interaction=nonstopmode ${TESTARGS} $< 1>/dev/null 2>/dev/null
	@if (pdflatex ${TESTARGS} $< && (test ! -e ${TESTDIR}/$*.pl || ${TESTDIR}/$*.pl ${TESTPLOPT})); \
		then /bin/echo -e "${GREEN}$@ succeeded${WHITE}" >&2; \
		else /bin/echo -e "${RED}$@ failed!!!!!!${WHITE}" >&2; fi


