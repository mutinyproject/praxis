name = praxis
version = 20200121

prefix ?= 
bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib
localstatedir ?= $(prefix)/var

libdir := $(libdir)/$(name)

builddir := $(localstatedir)/tmp/$(name)/build
dbdir := $(localstatedir)/db/$(name)

BINS := $(patsubst %.in, %, $(wildcard bin/*.in))
LIBS := $(patsubst %.in, %, $(wildcard lib/*.in))

INSTALLS := \
	$(addprefix $(DESTDIR)$(bindir)/,$(BINS:bin/%=%)) \
	$(addprefix $(DESTDIR)$(libdir)/,$(LIBS:lib/%=%)) \
	$(dbdir)/ \
	$(builddir)/

.PHONY: all
all: $(BINS) $(LIBS)

.PHONY: clean
clean:
	rm -f $(BINS) $(LIBS)

.PHONY: install
install: $(INSTALLS)

.PHONY: bin
bin: $(BINS)

.PHONY: lib
lib: $(LIBS)

bin/%: bin/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$(libdir)|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@dbdir@@|$(dbdir)|g" \
		-e "s|@@builddir@@|$(builddir)|g" \
		$< > $@
	chmod +x $@

lib/%: lib/%.in
	sed \
		-e "s|@@name@@|$(name)|g" \
		-e "s|@@version@@|$(version)|g" \
		-e "s|@@prefix@@|$(prefix)|g" \
		-e "s|@@bindir@@|$(bindir)|g" \
		-e "s|@@libdir@@|$(libdir)|g" \
		-e "s|@@localstatedir@@|$(localstatedir)|g" \
		-e "s|@@dbdir@@|$(dbdir)|g" \
		-e "s|@@builddir@@|$(builddir)|g" \
		$< > $@

$(DESTDIR)$(bindir)/%: bin/%
	install -D $< $@

$(DESTDIR)$(libdir)/%: lib/%
	install -D -m 0644 $< $@

$(DESTDIR)$(dbdir)/:
$(DESTDIR)$(builddir)/:
	mkdir -p $@
