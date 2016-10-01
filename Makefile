version              =1
topdir               :=$(dir $(realpath $(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))))

ifeq ($(wildcard $(PWD)/config.mak),)
all:
	$(error You need to run $(topdir)configure first)
else
    include $(PWD)/config.mak
endif

BINS                :=$(notdir $(basename $(basename $(wildcard $(srcdir)/bin/*.sh.in))))
LIBS                :=$(notdir $(basename $(basename $(wildcard $(srcdir)/lib/*.sh.in))))
LIBEXECS            :=$(notdir $(basename $(basename $(wildcard $(srcdir)/libexec/*.sh.in))))
TESTS               :=$(notdir $(basename $(basename $(wildcard $(srcdir)/test/*.sh))))

defaultpath         ?=$(bindir):$(sbindir)
builddir            ?=$(localstatedir)/tmp/riot
cachedir            ?=$(localstatedir)/cache/riot
pkgdir              ?=$(localstatedir)/db/riot/pkg
installdbdir        ?=$(localstatedir)/db/riot/installed

all: $(foreach b,$(BINS),$(PWD)/bin/$(b).sh)
all: $(foreach l,$(LIBS),$(PWD)/lib/$(l).sh)
all: $(foreach le,$(LIBEXECS),$(PWD)/libexec/$(l).sh)

%.sh: %.sh.in
	cp "$<" "$@"
	sed \
	    -e "s|@prefix@|$(prefix)|g" \
	    -e "s|@exec_prefix@|$(exec_prefix)|g" \
	    -e "s|@bindir@|$(bindir)|g" \
	    -e "s|@sbindir@|$(sbindir)|g" \
	    -e "s|@libdir@|$(libdir)|g" \
	    -e "s|@libexecdir@|$(libexecdir)|g" \
	    -e "s|@datarootdir@|$(datarootdir)|g" \
	    -e "s|@datadir@|$(datadir)|g" \
	    -e "s|@docdir@|$(docdir)|g" \
	    -e "s|@mandir@|$(mandir)|g" \
	    -e "s|@BUILDDIR@|$(BUILDDIR)|g" \
	    -e "s|@CACHEDIR@|$(CACHEDIR)|g" \
	    -e "s|@INSTALLDBDIR@|$(INSTALLDBDIR)|g" \
	    -e "s|@PKGDIR@|$(PKGDIR)|g" \
	    -e "s|@defaultpath@|$(defaultpath)|g" \
	    -e "s|@version@|$(version)|g" \
	    -e "s|@CHOST@|$(CHOST)|g" \
	    -e "s|@CBUILD@|$(CBUILD)|g" \
	    -e "s|@CTARGET@|$(CTARGET)|g" \
	    -i "$@"
	sed \
	    -e "s|@defaultAR@|$(defaultAR)|g" \
	    -e "s|@defaultAS@|$(defaultAS)|g" \
	    -e "s|@defaultCC@|$(defaultCC)|g" \
	    -e "s|@defaultCPP@|$(defaultCPP)|g" \
	    -e "s|@defaultCXX@|$(defaultCXX)|g" \
	    -e "s|@defaultLD@|$(defaultLD)|g" \
	    -e "s|@defaultNM@|$(defaultNM)|g" \
	    -e "s|@defaultOBJCOPY@|$(defaultOBJCOPY)|g" \
	    -e "s|@defaultOBJDUMP@|$(defaultOBJDUMP)|g" \
	    -e "s|@defaultPKG_CONFIG@|$(defaultPKG_CONFIG)|g" \
	    -e "s|@defaultRANLIB@|$(defaultRANLIB)|g" \
	    -e "s|@defaultMAKEOPTS@|$(defaultMAKEOPTS)|g" \
	    -i "$@"
	sed \
	    -e "s|@pkgprefix@|$(pkgprefix)|g" \
	    -e "s|@pkgexec_prefix@|$(pkgexec_prefix)|g" \
	    -e "s|@pkgbindir@|$(pkgbindir)|g" \
	    -e "s|@pkgsbindir@|$(pkgsbindir)|g" \
	    -e "s|@pkglibdir@|$(pkglibdir)|g" \
	    -e "s|@pkglibexecdir@|$(pkglibexecdir)|g" \
	    -e "s|@pkgdatarootdir@|$(pkgdatarootdir)|g" \
	    -e "s|@pkgdatadir@|$(pkgdatadir)|g" \
	    -e "s|@pkgdocdir@|$(pkgdocdir)|g" \
	    -e "s|@pkginfodir@|$(pkginfodir)|g" \
	    -e "s|@pkgmandir@|$(pkgmandir)|g" \
	    -e "s|@pkgsysconfdir@|$(pkgsysconfdir)|g" \
	    -i "$@"
	[ "$$(basename $$(dirname $@) $(srcdir))" = bin ] && chmod +x "$@" || true

$(DESTDIR)$(BUILDDIR):
	mkdir -p "$(DESTDIR)$(BUILDDIR)"
	touch $(DESTDIR)$(BUILDDIR)/.keep

$(DESTDIR)$(CACHEDIR):
	mkdir -p "$(DESTDIR)$(CACHEDIR)"
	touch $(DESTDIR)$(CACHEDIR)/.keep

$(DESTDIR)$(PKGDIR):
	mkdir -p "$(DESTDIR)$(PKGDIR)"
	touch $(DESTDIR)$(PKGDIR)/.keep

$(DESTDIR)$(INSTALLDBDIR):
	mkdir -p "$(DESTDIR)$(INSTALLDBDIR)"
	touch $(DESTDIR)$(INSTALLDBDIR)/.keep

$(DESTDIR)$(bindir):
	mkdir -p "$(DESTDIR)$(bindir)"

$(DESTDIR)$(libdir)/riot:
	mkdir -p "$(DESTDIR)$(libdir)/riot"

$(DESTDIR)$(bindir)/%: $(DESTDIR)$(bindir) $(srcdir)/bin/$(notdir %).sh
	install -m 755 "$(srcdir)/bin/$*.sh" "$@"

$(DESTDIR)$(libdir)/riot/%.sh: $(DESTDIR)$(libdir)/riot $(srcdir)/lib/$(notdir %).sh
	install -m 644 "$(srcdir)/lib/$*.sh" "$@"

#$(DESTDIR)$(libexecdir)/%: $(srcdir)/libexec/$(notdir %)
#	install -D -m 755 "$<" "$@"

install: $(DESTDIR)$(PKGDIR) $(DESTDIR)$(BUILDDIR) $(DESTDIR)$(CACHEDIR)
install: $(foreach b,$(BINS),$(DESTDIR)$(bindir)/$(b))
install: $(foreach l,$(LIBS),$(DESTDIR)$(libdir)/riot/$(l).sh)
install: $(foreach le,$(LIBEXECS),$(DESTDIR)$(libexecdir)/riot/$(le))

test: build
	@cd $(srcdir)/test && ./test.sh "$(srcdir)"

lint: build
	find $(srcdir) -type f -name *.sh -print0 | xargs -0 shellcheck

.PHONY:	all build clean install test lint

