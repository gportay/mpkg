#!/usr/bin/gmake -f
#
# Copyright 2016 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#
# User variables:
# ---------------
#
# The user must specify at least the pkg-m variable. This variable honors the list of packages that are been generated.
# Both pkg-y and pkg-n define the output result after the test has run:
#  * pkg-y lists the packages that should be marked as installed and
#  * pkg-n lists the packages that should no be marked as installed
#
# Note: if pkg-y is unset, 
# -----
#
# - root-y: the list of packages to be installed to prepare the rootfs (initial conditions; before root-m).
# - root-m: the list of packages to be installed after the rootfs is prepared (after root-y and before root-n).
# - root-n: the list of packages to be removed after installation (after root-y).
#
# - pkg-m: list of packages that should be generated.
#   ------
#
# Examples where a b c are to be generated:
#        pkg-m := a b c
#
# - pkg-y: list of packages that will be installed.
#
# Examples where a is to be installed:
#        pkg-y := a
#
# - pkg-n: list of packages that will not be installed.
#   ------
#
# Example where b and c are not to be installed:
#        pkg-n := b c
#
# - <pkg>-vers: defines the package version.
#   -----------
# It left empty, version is set to 0.
#
# Examples:
# <pkg>-vers := 0
# <pkg>-vers := 1.0
#
# - <pkg>-preinst: defines if package has preinst script.
#   --------------
# If left empty, the archive will not contain a preinst script.
# It represents a command to run, usually:
# * true to exit successfully or
# * false to exit with failure.
#
# Examples:
# <pkg>-preinst := true
# <pkg>-preinst := false
#
# - <pkg>-postinst, <pkg>-prerm and <pkg>-postrm: act like <pkg>-preinst.
#   ---------------------------------------------
#
# Internal variables:
# -------------------
#
# - tgzdir: the directory where the archives are generated (ie. the repository).
#   -------
#
# - tgzdir-y: lists archive directories from pkg-m variable.
#   ---------
#
# - tgz-y: lists archives from pkgdir-y.
#   ------
#
# Note: tgz*-n and tgz*-m are not used.
# -----

ifeq (,$(TGZ_INCLUDED))
TGZ_INCLUDED := 1

PREFIX	:= /var/lib/mpkg
tgzdir	:= $(tmpdir)tgz

repos := local
local-uri := file://$(tgzdir)/Index
$(rootdir)/etc/mpkg/repo.d/local.conf: $(tgzdir)/Index

.PHONY: all
all: $(tgzdir)/Index

define do_pkg_run_deps
ifneq (,$($(1)-deps))
$(foreach pkg,$($(1)-deps),$(eval $(call do_pkg_run_deps,$(pkg))))
pkg-m		+= $($(1)-deps)
endif
endef

$(foreach pkg,$(root-y) $(root-m),$(eval $(call do_pkg_run_deps,$(pkg))))
pkg-m		+= $(root-y) $(root-m)
pkg-m		:= $(sort $(pkg-m))

define do_pkg_script =
ifneq (,$($(1)-$(3)))
.SILENT: $(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/$(3)
$(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/$(3):
	install -d $$(@D)
	echo "#!/bin/sh" >$$@
	echo "$$($(1)-$(3))" >>$$@
	chmod a+x $$@
	echo "$(3): $$($(1)-$(3))" | sed 's/^.\| [a-z]/XXX-\U&/'

$(1)-$(2)-script-y += $(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/$(3)
$(1)-$(2)-m += $(PREFIX)/info/$(1)/$(3)
endif
endef

define do_pkg_control =
.SILENT: $(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/control
$(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/control:
	install -d $$(@D)
	echo "Package: $(1)" >$$@
	echo "Version: $(2)" >>$$@
	if [ -n "$$($(1)-$(2)-deps)" ]; then \
		echo "Depends: $$($(1)-$(2)-deps)" >>$$@; \
	elif [ -n "$$($(1)-deps)" ]; then \
		echo "Depends: $$($(1)-deps)" >>$$@; \
	fi
	echo
	cat $$@

$(foreach script,preinst postinst prerm postrm,$(eval $(call do_pkg_script,$(1),$(2),$(script))))

pkgfiles-m += $(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/control $($(1)-$(2)-script-y)
pkgdirs-m  += $(tgzdir)/$(1)-$(2)

$(tgzdir)/$(1)-$(2).tgz: $(tgzdir)/$(1)-$(2)$(PREFIX)/info/$(1)/control $($(1)-$(2)-script-y)

$(1)-$(2)-m += $(PREFIX)/info/$(1)/control $(PREFIX)/info/$(1)/files
endef

define do_pkg =
$(foreach vers,$(if $($(1)-vers),$($(1)-vers),1),$(eval $(call do_pkg_control,$(1),$(vers))))
endef

$(foreach pkg,$(pkg-m),$(eval $(call do_pkg,$(pkg))))

tgz-m 	:= $(patsubst %,%.tgz,$(pkgdirs-m))

.SILENT: $(tgzdir)
$(tgzdir):
	install -d $@

$(tgzdir)/%.tgz: | $(tgzdir)
	@( cd $(@D)/ && mpkg-build $* )

.SILENT: $(tgzdir)/Index
$(tgzdir)/Index: $(tgz-m) | $(tgzdir)
	( cd $(@D)/ && mpkg-make-index ) >$@

.PHONY: tgz_clean
tgz_clean:
	rm -Rf $(tgzdir)/

clean: tgz_clean

endif
