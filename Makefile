#!/usr/bin/gmake -f
#
# Copyright 2015-2016 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

VERSION		 = 0
PATCHLEVEL	 = 1
SUBLEVEL	 = 1
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
mpkg-tools-bin	:= bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index

all::

.PHONY:: all

.SILENT:: all version

define do_install =
.SILENT:: tgz/$(1)_$(2)/$(3)
tgz/$(1)_$(2)/$(3): $(3)
	install -d $$(@D)
	install -m 755 $$< $$(@D)
	chmod a+x $$@

$(1)-$(2)-bin-y += tgz/$(1)_$(2)/$(3)
endef

define do_install_dir =
tgz/$(1)_$(2)/$(3):
	echo "Doing $$@..."
	install -m 644 -d $$@

$(1)-$(2)-dir-y += tgz/$(1)_$(2)/$(3)
endef

define do_pkg_info =
.SILENT:: tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/control
tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/control:
	install -d $$(@D)
	echo "Package: $(1)" >$$@
	echo "Version: $(2)" >>$$@
	echo
	cat $$@

$(1)-$(2)-info-y += tgz/$(1)_$(2)$(localstatedir)/lib/mpkg/info/$(1)/control
endef

define do_pkg =
$(foreach dir,$($(1)-dir),$(eval $(call do_install_dir,$(1),$(RELEASE),$(dir))))
$(foreach bin,$($(1)-sbin),$(eval $(call do_install,$(1),$(RELEASE),$(bin))))
$(foreach bin,$($(1)-bin),$(eval $(call do_install,$(1),$(RELEASE),$(bin))))
$(eval $(call do_pkg_info,$(1),$(RELEASE)))

pkgdirs-m  += tgz/$(1)_$(RELEASE)
tgz/$(1)_$(RELEASE).tgz:: $($(1)-$(RELEASE)-info-y) $($(1)-$(RELEASE)-bin-y) $($(1)-$(RELEASE)-dir-y)
endef

$(foreach pkg,$(pkg-m),$(eval $(call do_pkg,$(pkg))))

tgz-m := $(patsubst %,%.tgz,$(pkgdirs-m))

tgz/%.tgz:
	( cd $(@D)/ && fakeroot -- mpkg-build $* )

tgz/Index: $(tgz-m)
	( cd $(@D)/ && mpkg-make-index ) >$@
	cat $@

all:: tgz/Index

version:
	echo "$(RELEASE)"

clean:
	rm -rf tgz/

