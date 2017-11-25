#!/usr/bin/make -f
#
# Copyright 2015-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

include dir.mk

VERSION		 = 0
PATCHLEVEL	 = 1
SUBLEVEL	 = 5
EXTRAVERSION	 = 
NAME		 = I am not an Hero!
RELEASE		 = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

export RELEASE

.SILENT: all
.PHONY: all
all:

.SILENT: version
.PHONY: version
version:
	echo "$(RELEASE)"

.PHONY: install
install:
	install -d $(DESTDIR)$(sbindir)/
	install -m 644 bin/mpkg* $(DESTDIR)$(sbindir)/
	install -d $(DESTDIR)$(REPODIR)/
	install -d $(DESTDIR)$(LOCALSTATEDIR)/

.PHONY: release
release: export TGZDIR=tgz/
release:
	$(MAKE) dist
	$(MAKE) sign
	install -d releases/$(RELEASE)/
	for f in tgz/Index tgz/*.tgz tgz/*.sig; do \
		cp $$f releases/$(RELEASE)/; \
	done

.PHONY: dist sign
dist sign:
	$(MAKE) -f $@.mk

.PHONY: verify
verify:
	$(MAKE) -f sign.mk $@

.PHONY: check shellcheck
check shellcheck:
	shellcheck bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index
	shellcheck bin/mpkg -s bash -e SC2162 -e SC2002 -e SC2086

.PHONY: tests
tests:
	$(MAKE) -C tests --silent $(MFLAGS)

.PHONY: github-pages
github-pages:
	$(MAKE) -f github-pages.mk

.PHONY: clean
clean:
	$(MAKE) -C tests $@
	$(MAKE) -f sign.mk $@
	$(MAKE) -f dist.mk $@
	rm -rf tgz/

mpkg-$(RELEASE)-bootstrap.sh: bootstrap.sh tgz/mpkg_$(RELEASE).tgz
	cat $^ >$@
	chmod a+x $@

.PHONY: bootstrap
bootstrap: mpkg-$(RELEASE)-bootstrap.sh
