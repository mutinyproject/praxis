name = praxis
version = 20200121

prefix ?= /usr/local
bindir ?= ${prefix}/bin
datarootdir ?= ${prefix}/share
datadir ?= ${datarootdir}
docdir ?= ${datadir}/doc/${name}
htmldir ?= ${docdir}
libdir ?= ${prefix}/lib
localstatedir ?= ${prefix}/var
mandir ?= ${datadir}/man
man1dir ?= ${mandir}/man1
man5dir ?= ${mandir}/man5
man7dir ?= ${mandir}/man7

ASCIIDOCTOR ?= asciidoctor
ASCIIDOCTOR_FLAGS += --failure-level=WARNING
ASCIIDOCTOR_FLAGS += -a manmanual="Mutineer's Guide - ${name}"
ASCIIDOCTOR_FLAGS += -a mansource="Mutiny"

SHELLCHECK ?= shellcheck
SHELLSPEC ?= shellspec

-include config.mk

libdir := ${libdir}/${name}
builddir := ${localstatedir}/tmp/${name}/build
dbdir := ${localstatedir}/db/${name}
cachedir := ${localstatedir}/cache/${name}

BINS = \
    pkg-gen \
    repo-lint \
    repo-list \
    repo-update \
    theory-construct-action \
    theory-construct-metadata

LIBS = \
    theory.sh

PUBLICS = \
    action.in

MAN1 = ${BINS:=.1}
MAN5 = \
    theory.5

MAN7 = \
    ${name}.7

MANS = ${MAN1} ${MAN5} ${MAN7}
HTMLS = ${MANS:=.html}

all: FRC ${BINS} ${LIBS} ${MANS}
dev: FRC README all html lint check

bin: FRC ${BINS}
lib: FRC ${LIBS}
man: FRC ${MANS}
html: FRC ${HTMLS}

# NOTE: disable built-in rules which otherwise mess up creating .sh files
.SUFFIXES:

# ${IDIOMS_LIBDIR} is used to allow for testing prior to installation.
.SUFFIXES: .in
.in:
	sed \
	    -e "s|@@name@@|${name}|g" \
	    -e "s|@@version@@|${version}|g" \
	    -e "s|@@prefix@@|${prefix}|g" \
	    -e "s|@@bindir@@|${bindir}|g" \
	    -e "s|@@libdir@@|\$${PRAXIS_LIBDIR:-${libdir}}|g" \
	    -e "s|@@mandir@@|${mandir}|g" \
	    -e "s|@@man1dir@@|${man1dir}|g" \
	    -e "s|@@man5dir@@|${man5dir}|g" \
	    -e "s|@@man7dir@@|${man7dir}|g" \
	    -e "s|@@localstatedir@@|${localstatedir}|g" \
	    -e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-${builddir}\}|g" \
	    -e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-${cachedir}\}|g" \
	    -e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-${dbdir}\}|g" \
	    $< > $@
	chmod +x $@

.sh:
	sed \
	    -e "s|@@name@@|${name}|g" \
	    -e "s|@@version@@|${version}|g" \
	    -e "s|@@prefix@@|${prefix}|g" \
	    -e "s|@@bindir@@|${bindir}|g" \
	    -e "s|@@libdir@@|\$${PRAXIS_LIBDIR:-${libdir}}|g" \
	    -e "s|@@mandir@@|${mandir}|g" \
	    -e "s|@@man1dir@@|${man1dir}|g" \
	    -e "s|@@man5dir@@|${man5dir}|g" \
	    -e "s|@@man7dir@@|${man7dir}|g" \
	    -e "s|@@localstatedir@@|${localstatedir}|g" \
	    -e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-${builddir}\}|g" \
	    -e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-${cachedir}\}|g" \
	    -e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-${dbdir}\}|g" \
	    $< > $@

.SUFFIXES: .adoc .html

.adoc.html: footer.adoc
	${ASCIIDOCTOR} -b html5 ${ASCIIDOCTOR_FLAGS} -o $@ $<

.adoc: footer.adoc
	${ASCIIDOCTOR} -b manpage -d manpage ${ASCIIDOCTOR_FLAGS} -o $@ $<

install-html: FRC ${HTMLS}
	install -d ${DESTDIR}${htmldir}
	for html in ${HTMLS}; do install -m0644 $${html} ${DESTDIR}${htmldir}; done

install: FRC all
	install -d \
	    ${DESTDIR}${bindir} \
	    ${DESTDIR}${libdir} \
	    ${DESTDIR}${libdir}/public \
	    ${DESTDIR}${man1dir} \
	    ${DESTDIR}${man5dir} \
	    ${DESTDIR}${man7dir} \
	    ${DESTDIR}${builddir} \
	    ${DESTDIR}${cachedir} \
	    ${DESTDIR}${cachedir}/distfiles \
	    ${DESTDIR}${dbdir} \
	    ${DESTDIR}${dbdir}/repositories

	for bin in ${BINS}; do install -m0755 $${bin} ${DESTDIR}${bindir}; done
	for lib in ${LIBS}; do install -m0644 $${lib} ${DESTDIR}${libdir}; done
	for public in ${PUBLICS}; do install -m0644 $${public} ${DESTDIR}${libdir}/public; done
	for man1 in ${MAN1}; do install -m0644 $${man1} ${DESTDIR}${man1dir}; done
	for man5 in ${MAN5}; do install -m0644 $${man5} ${DESTDIR}${man5dir}; done
	for man7 in ${MAN7}; do install -m0644 $${man7} ${DESTDIR}${man7dir}; done

clean: FRC
	rm -f ${BINS} ${LIBS} ${MANS} ${HTMLS}

.DELETE_ON_ERROR: README
README: ${name}.7
	man ./$? | col -bx > $@

lint: FRC ${BINS} ${LIBS}
	${SHELLCHECK} ${BINS} ${LIBS}

check: FRC ${BINS} ${LIBS}
	${SHELLSPEC} ${SHELLSPEC_FLAGS}

FRC:
