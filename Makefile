#!/usr/bin/make -f
#
# Copyright 2015-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

VERSION		 = 0
PATCHLEVEL	 = 1
SUBLEVEL	 = 4
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

include dir.mk

.SECONDARY: mpkg_rsa.pem mpkg_rsa.pub

.PHONY: keys
keys: mpkg_rsa.pem mpkg_rsa.pub

.PHONY: setup
setup:
ifeq (,$(findstring $(USER),$(shell grep -E "^mpkg:" /etc/group | cut -d: -f4 | sed 's/,/ /g')))
	groupadd --force --system mpkg
	usermod --append --groups mpkg $(USER)
else
	@echo "Your are already a member or mpkg group!"
endif

.PHONY: install-keys
install-keys: mpkg_rsa.pem
ifeq (,$(shell grep -E "^mpkg:" /etc/group | cut -d: -f4 | sed 's/,/ /g'))
	make setup
endif
	install --owner root --group mpkg --directory $(datarootdir)/mpkg/keys.d/
	for key in $?; do \
		install --owner root --group mpkg --mode 0640 $$key $(datarootdir)/mpkg/keys.d/; \
	done

.SILENT: $(datarootdir)/mpkg/keys.d/mpkg_rsa.pem
$(datarootdir)/mpkg/keys.d/mpkg_rsa.pem:
	@echo "Error: $(@F): Private key is missing!" >&2
	@echo "       Either copy your private key into $(CURDIR)/$(@F)," >&2
	@echo "       or generate your private key using $$ make $(@F)," >&2
	@echo "       then install it using $$ sudo make install-keys" >&2
	@false

%.pem:
	openssl genrsa -aes256 -out $@

%.pem-decrypted: %.pem
	openssl rsa -in $< -out $@

%.pub: %.pem
	openssl rsa -in $< -out $@ -outform PEM -pubout

%.sig: $(datarootdir)/mpkg/keys.d/mpkg_rsa.pem %
	openssl dgst -sha1 -sign $< $* >$@

verify-%: mpkg_rsa.pub %.sig
	openssl dgst -sha1 -verify $< -signature $*.sig $*

tgz-y := $(wildcard tgz/*.tgz)

tgzsig-y := $(wildcard tgz/*.tgz.sig)

tgzsig-m := $(patsubst %,%.sig,$(tgz-y))

sign: tgz/Index.sig $(tgzsig-m)

.PHONY: release
release: export TGZDIR=tgz/
release:
	$(MAKE) dist
	$(MAKE) sign
	install -d releases/$(RELEASE)/
	for f in tgz/Index tgz/*.tgz tgz/*.sig; do \
		cp $$f releases/$(RELEASE)/; \
	done

.PHONY: dist
dist:
	$(MAKE) -f $@.mk

.PHONY: shellcheck
shellcheck:
	shellcheck bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index
	shellcheck bin/mpkg -s bash -e SC2162 -e SC2002 -e SC2086

.PHONY: tests
tests:
	$(MAKE) -C tests --silent $(MFLAGS)

.PHONY: clean
clean:
	$(MAKE) -f dist.mk $@
	rm -rf tgz/

mpkg-$(RELEASE)-bootstrap.sh: bootstrap.sh tgz/mpkg_$(RELEASE).tgz
	cat $^ >$@
	chmod a+x $@

.PHONY: bootstrap
bootstrap: mpkg-$(RELEASE)-bootstrap.sh
