#
# Copyright 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Licensed under the MIT license.
#

.PHONY: all
all:

.PHONY: clean
clean:

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
	echo "Error: $(@F): Private key is missing!" >&2
	echo "       Either copy your private key into $(CURDIR)/$(@F)," >&2
	echo "       or generate your private key using $$ make -f sign.mk $(@F)," >&2
	echo "       then install it using $$ sudo make -f sign.mk install-keys" >&2
	false

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

tgz-m := $(wildcard $(TGZDIR)*.tgz)

tgzsig-m := $(patsubst %,%.sig,$(tgz-m))

.PHONY: sign
sign: $(TGZDIR)Index.sig $(tgzsig-m)

.PHONY: verify
verify: verify-Index $(patsubst %.sig,verify-%,$(tgzsig-m))

.PHONY: sign_clean
sign_clean:
	rm -Rf $(TGZDIR)Index.sig $(tgzsig-m)

all: sign

clean: sign_clean

