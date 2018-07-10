version              =1

ifeq ($(wildcard ./config.mak),)
all:
	$(error You need to run configure first)
else
    include ./config.mak
endif

BINS                :=$(notdir $(basename $(basename $(wildcard $(srcdir)/bin/*.sh.in))))
LIBS                :=$(notdir $(basename $(basename $(wildcard $(srcdir)/lib/*.sh.in))))
TESTS               :=$(notdir $(basename $(basename $(wildcard $(srcdir)/test/*.sh))))

all: bin lib

bin/:
	mkdir -p bin
lib/:
	mkdir -p lib

bin: bin/ $(foreach b,$(BINS),bin/$(b).sh)
lib: lib/ $(foreach l,$(LIBS),lib/$(l).sh)

watch:
	while true; do \
	    { find ./test -name '*.sh'; find . -name 'configure' -or -name '*.sh.in' -or -name 'Makefile'; } | entr -c sh -c 'make clean && make reconfigure && make check && make install'; \
	done

reconfigure:
	@sh -x -c 'eval $$(head -n 2 config.mak | tail -n 1 | cut -d" " -f2-)'

$(DESTDIR)$(builddir):
	mkdir -p "$(DESTDIR)$(builddir)"
	touch $(DESTDIR)$(builddir)/.keep

$(DESTDIR)$(cachedir):
	mkdir -p "$(DESTDIR)$(cachedir)"
	touch $(DESTDIR)$(cachedir)/.keep

$(DESTDIR)$(repodir):
	mkdir -p "$(DESTDIR)$(repodir)"
	touch $(DESTDIR)$(repodir)/.keep

$(DESTDIR)$(installdir):
	mkdir -p "$(DESTDIR)$(installdir)"
	touch $(DESTDIR)$(installdir)/.keep

$(DESTDIR)$(bindir):
	mkdir -p "$(DESTDIR)$(bindir)"

$(DESTDIR)$(libdir)/riot:
	mkdir -p "$(DESTDIR)$(libdir)/riot"

$(DESTDIR)$(bindir)/%: $(DESTDIR)$(bindir) $(srcdir)/bin/$(notdir %).sh
	install -m 755 "$(srcdir)/bin/$*.sh" "$@"

$(DESTDIR)$(libdir)/riot/%.sh: $(DESTDIR)$(libdir)/riot $(srcdir)/lib/$(notdir %).sh
	install -m 644 "$(srcdir)/lib/$*.sh" "$@"

install: $(DESTDIR)$(builddir) $(DESTDIR)$(cachedir) $(DESTDIR)$(repodir) $(DESTDIR)$(installdir)
install: $(foreach b,$(BINS),$(DESTDIR)$(bindir)/$(b))
install: $(foreach l,$(LIBS),$(DESTDIR)$(libdir)/riot/$(l).sh)

clean:
	-rm -f $(foreach b,$(BINS),bin/$(b).sh)
	-rm -f $(foreach l,$(LIBS),lib/$(l).sh)

test: check
check: bin lib
	$(srcdir)/test/test.sh "$(srcdir)"

lint: bin lib
	find $(srcdir) -type f -name *.sh -print0 | xargs -0 shellcheck

.PHONY:	all bin lib clean test lint install reconfigure watch check

