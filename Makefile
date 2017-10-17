#!/usr/bin/make -f
#
# Copyright 2015-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

VERSION		 = 0
PATCHLEVEL	 = 2
SUBLEVEL	 = 0
EXTRAVERSION	 = 
NAME		 = I am not an Hero!
RELEASE		 = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)

PATH		:= $(PWD)/bin:$(PATH)
sysconfdir	:= /etc
localstatedir	:= /var

PREFIX		?= /usr/local
EPREFIX		?= $(PREFIX)
bindir		?= $(EPREFIX)/bin
sbindir		?= $(EPREFIX)/sbin
libexecdir	?= $(EPREFIX)/libexec
sysconfdir	?= $(PREFIX)/etc
sharedstatedir	?= $(PREFIX)/com
localstatedir	?= $(PREFIX)/var
libdir		?= $(EPREFIX)/lib
includedir	?= $(PREFIX)/include
oldincludedir	?= /usr/include
datarootdir	?= $(PREFIX)/share
datadir		?= $(datarootdir)
infodir		?= $(datarootdir)
localedir	?= $(datarootdir)/locale
mandir		?= $(datarootdir)/man
docdir		?= $(datarootdir)/doc/mpkg
htmldir		?= $(datarootdir)
dvidir		?= $(datarootdir)
pdfdir		?= $(datarootdir)
psdir		?= $(datarootdir)

pkg-m		:= mpkg mpkg-tools
mpkg-dir	:= $(sysconfdir)/mpkg/repos.d $(localstatedir)/lib/mpkg/lists
mpkg-sbin	:= bin/mpkg
mpkg-postinst	:= mpkg.postinst
mpkg-tools-bin	:= bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index

all::

.PHONY:: all

.SILENT:: all version

define do_install =
tgz/$(1)_$(2)/$(3)/$(notdir $(4)): $(4)
	@install -d $$(@D)
	@install -m 755 $$< $$(@D)
	@chmod a+x $$@

$(1)-$(2)-bin-y += tgz/$(1)_$(2)/$(3)/$(notdir $(4))
endef

define do_install_dir =
tgz/$(1)_$(2)/$(3):
	@install -m 644 -d $$@

$(1)-$(2)-dir-y += tgz/$(1)_$(2)/$(3)
endef

define do_pkg_script =
ifneq (,$($(1)-$(3)))
tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/$(notdir $(3)): $($(1)-$(3))
	@install -d $$(@D)
	@install -m 755 $$< $$@
	@chmod a+x $$@

$(1)-$(2)-script-y += tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/$(notdir $(3))
endif
endef

define do_pkg_info =
tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/control:
	@install -d $$(@D)
	@echo "Package: $(1)" >$$@
	@echo "Version: $(2)" >>$$@
	@echo "---------------------------------------------------------------------- >8 -----"
	@cat $$@

$(1)-$(2)-info-y += tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/control $$($(1)-$(2)-script-y)
$(foreach script,preinst postinst prerm postrm,$(eval $(call do_pkg_script,$(1),$(2),$(script))))
$(foreach dir,$($(1)-dir),$(eval $(call do_install_dir,$(1),$(2),$(dir))))
$(foreach bin,$($(1)-sbin),$(eval $(call do_install,$(1),$(2),$(sbindir),$(bin))))
$(foreach bin,$($(1)-bin),$(eval $(call do_install,$(1),$(2),$(bindir),$(bin))))
endef

define do_pkg =
$(eval $(call do_pkg_info,$(1),$(RELEASE)))

pkgdirs-m  += tgz/$(1)_$(RELEASE)
tgz/$(1)_$(RELEASE).tgz:: $($(1)-$(RELEASE)-info-y) $($(1)-$(RELEASE)-bin-y) $($(1)-$(RELEASE)-dir-y)
endef

$(foreach pkg,$(pkg-m),$(eval $(call do_pkg,$(pkg))))

tgz-m := $(patsubst %,%.tgz,$(pkgdirs-m))

tgz/%.tgz:
	@echo -n "Filename: ./"
	@( cd $(@D)/ && fakeroot -- mpkg-build $* )
	@echo

tgz/Index: $(tgz-m)
	@echo "---------------------------------------------------------------------- >8 -----"
	@( cd $(@D)/ && mpkg-make-index ) >$@
	@cat $@

all:: tgz/Index

version:
	echo "$(RELEASE)"

.SECONDARY:: mpkg_rsa.pem mpkg_rsa.pub

keys: mpkg_rsa.pem mpkg_rsa.pub

setup:
ifeq (,$(findstring $(USER),$(shell grep -E "^mpkg:" /etc/group | cut -d: -f4 | sed 's/,/ /g')))
	groupadd --force --system mpkg
	usermod --append --groups mpkg $(USER)
else
	@echo "Your are already a member or mpkg group!"
endif

install-keys: mpkg_rsa.pem
ifeq (,$(shell grep -E "^mpkg:" /etc/group | cut -d: -f4 | sed 's/,/ /g'))
	make setup
endif
	install --owner root --group mpkg --directory $(datarootdir)/mpkg/keys.d/
	for key in $?; do \
		install --owner root --group mpkg --mode 0640 $$key $(datarootdir)/mpkg/keys.d/; \
	done

.SILENT:: $(datarootdir)/mpkg/keys.d/mpkg_rsa.pem
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

release: $(wildcard tgz/Index*) $(tgz-y) $(tgzsig-y)
	install -d releases/$(RELEASE)/
	for f in $?; do \
		cp $$f releases/$(RELEASE)/; \
	done

.PHONY:: root

root/etc/mpkg/repo.d/local:
	install -d $(@D)/
	echo "file://$(PWD)/tgz/Index" >$@

root: root/etc/mpkg/repo.d/local

shellcheck:
	shellcheck bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index
	shellcheck bin/mpkg -s bash -e SC2162 -e SC2001 -e SC2002 -e SC2086

.PHONY:: tests
tests:
	$(MAKE) -C tests

clean:
	rm -rf tgz/ root/

mpkg-$(RELEASE)-bootstrap.sh: bootstrap.sh tgz/mpkg_$(RELEASE).tgz
	cat $^ >$@
	chmod a+x $@

.PHONY:: bootstrap
bootstrap: mpkg-$(RELEASE)-bootstrap.sh
