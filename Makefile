name = praxis
version = 20200121

prefix ?=
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
localstatedir ?= $(prefix)/var

libdir := $(libdir)/$(name)

builddir := $(localstatedir)/tmp/$(name)/build
dbdir := $(localstatedir)/db/$(name)
cachedir := $(localstatedir)/cache/$(name)

BINS := $(patsubst %.in, %, $(wildcard bin/*.in))
LIBS := $(patsubst %.in, %, $(wildcard lib/*.in))
MANS := $(patsubst %.adoc, %, $(wildcard man/*.adoc))
HTMLS := $(patsubst %.adoc, %.html, $(wildcard man/*.adoc))

INSTALLS := \
	$(addprefix $(DESTDIR)$(bindir)/,$(BINS:bin/%=%)) \
	$(addprefix $(DESTDIR)$(libdir)/,$(LIBS:lib/%=%))

.PHONY: all
all: bin lib man html

.PHONY: clean
clean:
	rm -f $(BINS) $(LIBS) $(MANS) $(HTMLS)

.PHONY: install
install: $(INSTALLS)
	mkdir -p $(DESTDIR)$(builddir)
	mkdir -p $(DESTDIR)$(cachedir)
	mkdir -p $(DESTDIR)$(cachedir)/distfiles
	mkdir -p $(DESTDIR)$(dbdir)
	mkdir -p $(DESTDIR)$(dbdir)/repositories

.PHONY: lint
lint:
	printf '%s\n' $(patsubst %,%.in,$(BINS)) $(patsubst %,%.in,$(LIBS)) | xargs shellcheck

.PHONY: fmt
fmt:
	printf '%s\n' $(patsubst %,%.in,$(BINS)) $(patsubst %,%.in,$(LIBS)) | xargs shfmt -d

.PHONY: test
test: check

.PHONY: check
check: bin lib
	shellspec $(SHELLSPEC_FLAGS)

.PHONY: bin
bin: $(BINS)

.PHONY: lib
lib: $(LIBS)

.PHONY: man
man: $(MANS)

.PHONY: html
html: $(HTMLS)

bin/%: bin/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$$\{PRAXIS_LIBDIR:-$(libdir)\}|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-$(builddir)\}|g" \
		-e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-$(cachedir)\}|g" \
		-e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-$(dbdir)\}|g" \
		$< > $@
	chmod +x $@

lib/%: lib/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$$\{PRAXIS_LIBDIR:-$(libdir)\}|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@builddir@@|$$\{PRAXIS_BUILDDIR:-$(builddir)\}|g" \
		-e "s|@@cachedir@@|$$\{PRAXIS_CACHEDIR:-$(cachedir)\}|g" \
		-e "s|@@dbdir@@|$$\{PRAXIS_DBDIR:-$(dbdir)\}|g" \
		$< > $@

.DELETE_ON_ERROR: man/%.html
man/%.html: man/%.adoc
	asciidoctor --failure-level=WARNING -b html5 -B $(PWD) -o $@ $<

.DELETE_ON_ERROR: man/%
man/%: man/%.adoc
	asciidoctor --failure-level=WARNING -b manpage -B $(PWD) -d manpage -o $@ $<

$(DESTDIR)$(bindir)/%: bin/%
	install -D $< $@

$(DESTDIR)$(libdir)/%: lib/%
	install -D -m 0644 $< $@

