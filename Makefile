CONTRIBUTION  = svn-multi
NAME          = Martin Scharrer
EMAIL         = martin@scharrer-online.de
DIRECTORY     = /macros/latex/contrib/${CONTRIBUTION}
LICENSE       = free
FREEVERSION   = lppl
CTAN_FILE     = ${CONTRIBUTION}.zip
export CONTRIBUTION VERSION NAME EMAIL SUMMARY DIRECTORY DONOTANNOUNCE ANNOUNCE NOTES LICENSE FREEVERSION CTAN_FILE


MAINDTXS      = ${CONTRIBUTION}.dtx svn-multi-pl.dtx
DTXFILES      = ${MAINDTXS} 
INSFILES      = ${CONTRIBUTION}.ins
LTXFILES      = ${CONTRIBUTION}.sty svnkw.sty
MAINPDFS      = ${CONTRIBUTION}.pdf svn-multi-pl.pdf
LTXDOCFILES   = svn-multi.pdf README example_chap1.tex example_main.tex group_example.tex
LTXSRCFILES   = ${DTXFILES} ${INSFILES} 
FIXEDSRCFILES = ${INSFILES} README example_chap1.tex example_main.tex group_example.tex
PLAINFILES    = #${CONTRIBUTION}.tex
PLAINDOCFILES = #${CONTRIBUTION}.?
PLAINSRCFILES = #${CONTRIBUTION}.?
GENERICFILES  = #${CONTRIBUTION}.tex
GENDOCFILES   = #${CONTRIBUTION}.?
GENSRCFILES   = #${CONTRIBUTION}.?
SCRIPTFILES   = svn-multi.pl
SCRDOCFILES   = svn-multi-pl.pdf
ALLFILES      = ${DTXFILES} ${INSFILES} ${LTXFILES} ${LTXDOCFILES} ${LTXSRCFILES} \
				${PLAINFILES} ${PLAINDOCFILES} ${PLAINSRCFILES} \
				${GENERICFILES} ${GENDOCFILES} ${GENSRCFILES} \
				${SCRIPTFILES} ${SCRDOCFILES}
MAINFILES     = ${DTXFILES} ${INSFILES} ${LTXFILES}
CTANFILES     = ${DTXFILES} ${INSFILES} ${LTXDOCFILES} ${PLAINDOCFILES} ${GENDOCFILES} ${SCRDOCFILES}

TDSZIP      = ${CONTRIBUTION}.tds.zip

TEXMF       = ${HOME}/texmf
LTXDIR      = ${TEXMF}/tex/latex/${CONTRIBUTION}/
LTXDOCDIR   = ${TEXMF}/doc/latex/${CONTRIBUTION}/
LTXSRCDIR   = ${TEXMF}/source/latex/${CONTRIBUTION}/
GENERICDIR  = ${TEXMF}/tex/generic/${CONTRIBUTION}/
GENDOCDIR   = ${TEXMF}/doc/generic/${CONTRIBUTION}/
GENSRCDIR   = ${TEXMF}/source/generic/${CONTRIBUTION}/
PLAINDIR    = ${TEXMF}/tex/plain/${CONTRIBUTION}/
PLAINDOCDIR = ${TEXMF}/doc/plain/${CONTRIBUTION}/
PLAINSRCDIR = ${TEXMF}/source/plain/${CONTRIBUTION}/
SCRIPTDIR   = ${TEXMF}/scripts/${CONTRIBUTION}/
SCRDOCDIR   = ${TEXMF}/doc/support/${CONTRIBUTION}/

TDSDIR   = tds
TDSFILES = ${LTXFILES} ${LTXDOCFILES} ${LTXSRCFILES} \
		   ${PLAINFILES} ${PLAINDOCFILES} ${PLAINSRCFILES} \
		   ${GENERICFILES} ${GENDOCFILES} ${GENSRCFILES} \
		   ${SCRIPTFILES} ${SCRDOCFILES}

BUILDDIR = build

LATEXMK  = latexmk -pdf -quiet
ZIP      = zip -r
WEBBROWSER = firefox
GETVERSION = $(strip $(shell grep '=\*VERSION' -A1 ${MAINDTXS} | tail -n1))

AUXEXTS  = .aux .bbl .blg .cod .exa .fdb_latexmk .glo .gls .lof .log .lot .out .pdf .que .run.xml .sta .stp .svn .svt .toc
CLEANFILES = $(addprefix ${CONTRIBUTION}, ${AUXEXTS})

.PHONY: all doc clean distclean

all: doc

doc: ${MAINPDFS}

${MAINPDFS}: ${DTXFILES} README ${INSFILES} ${LTXFILES}
	${MAKE} --no-print-directory build
	cp "${BUILDDIR}/$@" "$@"

ifneq (${BUILDDIR},build)
build: ${BUILDDIR}
endif

${BUILDDIR}: ${MAINFILES}
	-mkdir ${BUILDDIR} 2>/dev/null || true
	cp ${FIXEDSRCFILES} README ${BUILDDIR}/
	$(foreach DTX,${MAINDTXS}, tex '\input ydocincl\relax\includefiles{${DTX}}{${BUILDDIR}/${DTX}}' && rm -f ydocincl.log;)
	cd ${BUILDDIR}; $(foreach INS, ${INSFILES}, tex ${INS};)
	cd ${BUILDDIR}; $(foreach DTX, ${MAINDTXS}, ${LATEXMK} ${DTX};)
	touch ${BUILDDIR}

$(addprefix ${BUILDDIR}/,$(sort ${TDSFILES} ${CTANFILES})): ${MAINFILES}
	${MAKE} --no-print-directory build

clean:
	latexmk -C ${CONTRIBUTION}.dtx
	${RM} ${CLEANFILES}
	${RM} -r ${BUILDDIR} ${TDSDIR} ${TDSZIP} ${CTAN_FILE}


distclean:
	latexmk -c ${CONTRIBUTION}.dtx
	${RM} ${CLEANFILES}
	${RM} -r ${BUILDDIR} ${TDSDIR}

CPORLN=cp

install: uninstall $(addprefix ${BUILDDIR}/,${TDSFILES})
ifneq ($(strip $(LTXFILES)),)
	test -d "${LTXDIR}" || mkdir -p "${LTXDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/,${LTXFILES}) "$(abspath ${LTXDIR})"
endif
ifneq ($(strip $(LTXSRCFILES)),)
	test -d "${LTXSRCDIR}" || mkdir -p "${LTXSRCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${LTXSRCFILES}) "$(abspath ${LTXSRCDIR})"
endif
ifneq ($(strip $(LTXDOCFILES)),)
	test -d "${LTXDOCDIR}" || mkdir -p "${LTXDOCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${LTXDOCFILES}) "$(abspath ${LTXDOCDIR})"
endif
ifneq ($(strip $(GENERICFILES)),)
	test -d "${GENERICDIR}" || mkdir -p "${GENERICDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${GENERICFILES}) "$(abspath ${GENERICDIR})"
endif
ifneq ($(strip $(GENSRCFILES)),)
	test -d "${GENSRCDIR}" || mkdir -p "${GENSRCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${GENSRCFILES}) "$(abspath ${GENSRCDIR})"
endif
ifneq ($(strip $(GENDOCFILES)),)
	test -d "${GENDOCDIR}" || mkdir -p "${GENDOCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${GENDOCFILES}) "$(abspath ${GENDOCDIR})"
endif
ifneq ($(strip $(PLAINFILES)),)
	test -d "${PLAINDIR}" || mkdir -p "${PLAINDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${PLAINFILES}) "$(abspath ${PLAINDIR})"
endif
ifneq ($(strip $(PLAINSRCFILES)),)
	test -d "${PLAINSRCDIR}" || mkdir -p "${PLAINSRCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${PLAINSRCFILES}) "$(abspath ${PLAINSRCDIR})"
endif
ifneq ($(strip $(PLAINDOCFILES)),)
	test -d "${PLAINDOCDIR}" || mkdir -p "${PLAINDOCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${PLAINDOCFILES}) "$(abspath ${PLAINDOCDIR})"
endif
ifneq ($(strip $(SCRIPTFILES)),)
	test -d "${SCRIPTDIR}" || mkdir -p "${SCRIPTDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${SCRIPTFILES}) "$(abspath ${SCRIPTDIR})"
endif
ifneq ($(strip $(SCRDOCFILES)),)
	test -d "${SCRDOCDIR}" || mkdir -p "${SCRDOCDIR}"
	${CPORLN} $(addprefix ${BUILDDIR}/, ${SCRDOCFILES}) "$(abspath ${SCRDOCDIR})"
endif
	touch ${TEXMF}
	-test -f ${TEXMF}/ls-R && texhash ${TEXMF} || true


installsymlinks: CPORLN=ln -sf
installsymlinks: BUILDDIR=${PWD}
installsymlinks: install

uninstall:
	${RM} -rf ${LTXDIR} ${LTXDOCDIR} ${LTXSRCDIR} \
		${GENERICDIR} ${GENDOCDIR} ${GENSRCDIR} \
		${PLAINDIR} ${PLAINDOCDIR} ${PLAINSRCDIR} \
		${SCRIPTDIR} ${SCRDOCDIR}
	-test -f ${TEXMF}/ls-R && texhash ${TEXMF} || true


ifneq (${TDSDIR},tdsdir)
tdsdir: ${TDSDIR}
endif
${TDSDIR}: $(addprefix ${BUILDDIR}/,${TDSFILES})
	${MAKE} --no-print-directory install TEXMF=${TDSDIR}

tdszip: ${TDSZIP}

${TDSZIP}: ${TDSDIR}
	-${RM} $@
	cd ${TDSDIR} && ${ZIP} $(abspath $@) *

zip: ${CTAN_FILE}

${CTAN_FILE}: $(addprefix ${BUILDDIR}/,${CTANFILES}) ${TDSZIP}
	-${RM} $@
	${ZIP} -j $@ $^

upload: VERSION = ${GETVERSION}

upload: ${CTAN_FILE}
	ctanupload -p

webupload: VERSION = ${GETVERSION}
webupload: ${CTAN_FILE}
	${WEBBROWSER} 'http://dante.ctan.org/upload.html?contribution=${CONTRIBUTION}&version=${VERSION}&name=${NAME}&email=${EMAIL}&summary=${SUMMARY}&directory=${DIRECTORY}&DoNotAnnounce=${DONOTANNOUNCE}&announce=${ANNOUNCEMENT}&notes=${NOTES}&license=${LICENSE}&freeversion=${FREEVERSION}' &


###############################################################################
TESTDIR = tests
TESTS = $(patsubst %.tex,%,$(subst ${TESTDIR}/,,$(wildcard ${TESTDIR}/test?.tex ${TESTDIR}/test??.tex))) # look for all test*.tex file names and remove the '.tex' 
TESTARGS = -output-directory ${TESTDIR}

LATEX_OPTIONS = -interaction=batchmode
LATEX = pdflatex ${LATEX_OPTIONS}

RED   = \033[01;31m
GREEN = \033[01;32m
WHITE = \033[00m

CP = cp -v
MV = mv -v
RMDIR = rm -rf
MKDIR = mkdir -p

.PHONY: testclean ${TESTS} ${CHECK_LOG}

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

# Make sure TeX finds the input files in TESTDIR
tests ${TESTS}: export TEXINPUTS:=${TEXINPUTS}:${TESTDIR}
tests ${TESTS}: LATEX_OPTIONS=

testclean:
	@${RM} $(foreach ext, aux log out pdf svn svx, tests/test*.${ext})

tests: testclean
	@echo "Running tests: ${TESTS}:"
	@${MAKE} -e -i --no-print-directory ${TESTS} \
		TESTARGS="-interaction=batchmode -output-directory=${TESTDIR}"\
		TESTPLOPT="-q"\
		> /dev/null

${TESTS}: % : ${TESTDIR}/%.tex testclean
	@-${LATEX} -interaction=nonstopmode ${TESTARGS} $< 1>/dev/null 2>/dev/null
	@if test -e ${TESTDIR}/$*.svn; then perl ./svn-multi.pl ${TESTDIR}/$* 1>/dev/null ; fi
	@if (${LATEX} ${TESTARGS} $< && (test ! -e ${TESTDIR}/$*.pl || ${TESTDIR}/$*.pl ${TESTPLOPT})); \
		then /bin/echo -e "${GREEN}$@ succeeded${WHITE}" >&2; \
		else /bin/echo -e "${RED}$@ failed!!!!!!${WHITE}" >&2; fi

###############################################################################

