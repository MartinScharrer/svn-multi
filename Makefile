# $Id: Makefile 1052 2009-05-03 12:24:53Z martin $

PACKAGE     = svn-multi
PACKAGE_STY = ${PACKAGE}.sty
PACKAGE_DTX = ${PACKAGE}.dtx ${PACKAGE}-pl.dtx
PACKAGE_SCR = ${PACKAGE}.pl
PACKAGE_DOC = $(PACKAGE_DTX:.dtx=.pdf)
PACKAGE_SRC = ${PACKAGE_DTX} ${PACKAGE}.ins Makefile example_chap1.tex example_main.tex group_example.tex
PACKFILES   = ${PACKAGE_SRC} ${PACKAGE_DOC} README

TEXAUX = *.aux *.log *.glo *.ind *.idx *.out *.svn *.svx *.svt *.toc *.ilg *.gls *.hd *.exa *.exb *.fdb_latexmk
INSGENERATED = ${PACKAGE_STY} svnkw.sty svn-multi.pl
GENERATED = ${INSGENERATED} ${PACKAGE}.pdf svn-multi-pl.pdf example.pdf group_example.pdf group_example_*.tex ${PACKAGE}.zip ${PACKAGE}.tar.gz ${TESTDIR}/test*.pdf
ZIPFILE = ${PACKAGE}-${ZIPVERSION}.zip
TDSZIPFILE = ${PACKAGE}-${ZIPVERSION}.tds.zip

TESTDIR = tests
TESTS = $(patsubst %.tex,%,$(subst ${TESTDIR}/,,$(wildcard ${TESTDIR}/test?.tex ${TESTDIR}/test??.tex))) # look for all test*.tex file names and remove the '.tex' 
TESTARGS = -output-directory ${TESTDIR}

LATEX_OPTIONS = -interaction=batchmode
LATEX = pdflatex ${LATEX_OPTIONS}

TEXMFDIR = ${HOME}/texmf

RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: all doc package clean fullclean example testclean ${TESTS} tds ${CHECK_LOG}

###############################################################################

all: package doc example
new: fullclean all

doc: ${PACKAGE_DOC}

package: ${PACKAGE_STY} ${PACKAGE_SCR}

%.pdf: %.dtx
	${LATEX} $*.dtx
	-makeindex -s gind.ist -o $*.ind $*.idx
	-makeindex -s gglo.ist -o $*.gls $*.glo
	${LATEX} $*.dtx
	${LATEX} $*.dtx

${PACKAGE}.pdf: ${PACKAGE}.sty

${INSGENERATED}: ${PACKAGE_DTX} ${PACKAGE}.ins 
	yes | latex ${PACKAGE}.ins
	@-chmod +x *.pl

clean:
	rm -f ${TEXAUX} $(addprefix ${TESTDIR}/, ${TEXAUX})

fullclean: clean
	rm -f ${GENERATED} *~ *.backup
	rm -f ${PACKAGE}*.zip
	rm -rf tds/

###############################################################################

example: example.pdf gexample

example.pdf: example_main.tex example_chap1.tex ${PACKAGE}.sty
	${LATEX} $<
	perl ./svn-multi.pl $<
	${LATEX} $<
	mv example_main.pdf $@

gexample: group_example.pdf
	
group_example.pdf: group_example.tex svn-multi.sty
	${RM} $(addprefix group_example, ${TEXAUX}) group_example_*.tex
	${LATEX} $<
	perl svn-multi.pl group_example
	${LATEX} $<
	${LATEX} $<
	${LATEX} $<

###############################################################################

zip: ${PACKFILES}
	@${MAKE} --no-print-directory ${ZIPFILE}

zip: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

tdszip: ZIPVERSION=$(shell grep "Package: ${PACKAGE} " ${PACKAGE}.log | \
	sed -e "s/.*Package: ${PACKAGE} ....\/..\/..\s\+\(v\S\+\).*/\1/")

${PACKAGE}%.zip: ${PACKFILES}
	@test -n "${IGNORE_CHECKSUM}" || grep -L '\* Checksum passed \*' ${PACKAGE_DTX:.dtx=.log} | wc -l | grep -q '^0$$'
	-pdfopt ${PACKAGE}.pdf opt_${PACKAGE}.pdf && mv opt_${PACKAGE}.pdf ${PACKAGE}.pdf
	${RM} $@
	zip $@ ${PACKFILES}
	@echo
	@echo "ZIP file $@ created!"

release: fullclean package doc example tests ${ZIPFILE}

###############################################################################

# Make sure TeX finds the input files in TESTDIR
tests ${TESTS}: export TEXINPUTS:=${TEXINPUTS}:${TESTDIR}
tests ${TESTS}: LATEX_OPTIONS=

testclean:
	@${RM} $(foreach ext, aux log out pdf svn svx, tests/test*.${ext})

tests: package testclean
	@echo "Running tests: ${TESTS}:"
	@${MAKE} -e -i --no-print-directory ${TESTS} \
		TESTARGS="-interaction=batchmode -output-directory=${TESTDIR}"\
		TESTPLOPT="-q"\
		> /dev/null

${TESTS}: % : ${TESTDIR}/%.tex package testclean
	@-${LATEX} -interaction=nonstopmode ${TESTARGS} $< 1>/dev/null 2>/dev/null
	@if test -e ${TESTDIR}/$*.svn; then perl ./svn-multi.pl ${TESTDIR}/$* 1>/dev/null ; fi
	@if (${LATEX} ${TESTARGS} $< && (test ! -e ${TESTDIR}/$*.pl || ${TESTDIR}/$*.pl ${TESTPLOPT})); \
		then /bin/echo -e "${GREEN}$@ succeeded${WHITE}" >&2; \
		else /bin/echo -e "${RED}$@ failed!!!!!!${WHITE}" >&2; fi

###############################################################################

tds: .tds

.tds: ${PACKAGE_STY} ${PACKAGE_DOC} ${PACKAGE_SRC}
	@grep -q '\* Checksum passed \*' ${PACKAGE}.log
	${RMDIR} tds
	${MKDIR} tds/
	${MKDIR} tds/tex/ tds/tex/latex/ tds/tex/latex/${PACKAGE}/
	${MKDIR} tds/doc/ tds/doc/latex/ tds/doc/latex/${PACKAGE}/
	${MKDIR} tds/source/ tds/source/latex/ tds/source/latex/${PACKAGE}/
	test -n "${PACKAGE_SCR}" && ${MKDIR} tds/scripts/ tds/scripts/${PACKAGE}/
	${CP} ${PACKAGE_STY} tds/tex/latex/${PACKAGE}/
	${CP} ${PACKAGE_DOC} tds/doc/latex/${PACKAGE}/
	${CP} ${PACKAGE_SRC} tds/source/latex/${PACKAGE}/
	test -n "${PACKAGE_SCR}" && ${CP} ${PACKAGE_SCR} tds/scripts/${PACKAGE}/
	@touch $@

tdszip: ${TDSZIPFILE}

${TDSZIPFILE}: .tds
	${RM} ${TDSZIPFILE}
	cd tds && zip -r ../${TDSZIPFILE} .

###############################################################################

install: .tds
	test -d "${TEXMFDIR}" && ${CP} -a tds/* "${TEXMFDIR}/" && texhash ${TEXMFDIR}

uninstall:
	test -d "${TEXMFDIR}" && ${RM} -rv "${TEXMFDIR}/tex/latex/${PACKAGE}" \
	"${TEXMFDIR}/doc/latex/${PACKAGE}" "${TEXMFDIR}/source/latex/${PACKAGE}" \
	"${TEXMFDIR}/scripts/${PACKAGE}" && texhash ${TEXMFDIR}

