#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PREFIX		:= /var/lib/mpkg
MPKGOPTS	:= --root $(ROOTDIR)

include tgz.mk

repo		?= local
local-uri	?= file://$(TGZDIR)Index

$(ROOTDIR) $(ROOTDIR)/etc/mpkg/repo.d:
	mkdir -p $@

define do_repo =
$(ROOTDIR)/etc/mpkg/repo.d/$(1).conf: | $(ROOTDIR)/etc/mpkg/repo.d
	echo "$($(1)-uri)" >$$@

repo-y += $(ROOTDIR)/etc/mpkg/repo.d/$(1).conf
endef

$(foreach repo,$(repo),$(eval $(call do_repo,$(repo))))

MPKGEXIT_list-installed	?= false
MPKGEXIT_install	?= false
MPKGARGS_install	 = $(install-y)

remove-y		?= $(install-y)
MPKGEXIT_remove		?= false
MPKGARGS_remove		 = $(remove-y)

upgrade-y		?=
MPKGEXIT_upgrade	?= false
MPKGARGS_upgrade	 = $(upgrade-y)

ifneq (,$(install-y))
mpkg-upgrade: | mpkg-install
mpkg-remove: | mpkg-install
endif

.PHONY: FORCE
FORCE:

rootfs: mpkg_rootfs
ifneq (,$(rootfs-y))
mpkg_rootfs: $(repo-y) FORCE | $(ROOTDIR)
	echo -n "Initialize $(rootfs-y)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) --update install $(rootfs-y); then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	echo "done"
	echo
else
mpkg_rootfs: $(repo-y) FORCE | $(ROOTDIR)
	echo -n "Initialize (empty)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) update; then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	echo "done"
	echo
endif

.SILENT: mpkg-install mpkg-remove mpkg-upgrade
mpkg-%: mpkg_rootfs
	if ! bash mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*) \
	   && ! $(MPKGEXIT_$*); then \
		echo "Error: command has failed $(MPKGEXIT_$*)!" >&2; \
		echo "       mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*)" >&2; \
		false; \
	fi

.PHONY: mpkg_clean
mpkg_clean:
	rm -Rf $(ROOTDIR)/ $(O)*.out

rootfs-n ?= $(filter-out $(remove-y),$(rootfs-y) $(install-y))
ifneq (,$(rootfs-n))
.PHONY: mpkg_rootfs_clean
mpkg_rootfs_clean: | $(ROOTDIR)
	echo -n "Cleaning up $(rootfs-n)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) --force remove $(rootfs-n); then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) list-installed | \
	diff - /dev/null
	echo "done"
	echo

mpkg_clean: mpkg_rootfs_clean
endif

.PHONY: clean
clean: mpkg_clean

$(O)%-files.out: %-files | $(O)
	sort $< >$@

$(O)%.out: % | $(O)
	cp $< $@

%.sh:
	install -d $(@D)
	echo "#!/bin/sh" >$@
	echo "# Automatically generated script: remove me" >>$@
	echo "# mpkg $(RELEASE) maketest" >>$@
	echo "# $(shell date)" >>$@
	echo "echo $(@F)" >>$@
	chmod a+x $@

.SILENT: true false
true false:
	install -d $(@D)
	echo "#!/bin/sh" >$@
	echo "# Automatically generated script: remove me" >>$@
	echo "# mpkg $(RELEASE) maketest" >>$@
	echo "# $(shell date)" >>$@
	echo "$(@F)" >>$@
	chmod a+x $@

