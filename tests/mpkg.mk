#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PREFIX		:= /var/lib/mpkg
MPKGOPTS	:= --root $(ROOTDIR)

include tgz.mk

feed		?= local
local-uri	?= file://$(TGZDIR)Index

$(ROOTDIR) $(ROOTDIR)/etc/mpkg:
	mkdir -p $@

$(ROOTDIR)/etc/mpkg/feeds.conf: | $(ROOTDIR)/etc/mpkg
	echo "$(feed) $($(feed)-uri)" >$@

MPKGEXIT_list-installed	?= false
MPKGEXIT_install	?= false
MPKGARGS_install	 = $(install-y)

remove-y		?= $(install-y)
MPKGEXIT_remove		?= false
MPKGARGS_remove		 = $(remove-y)

.PHONY: FORCE
FORCE:

rootfs: mpkg_rootfs
ifneq (,$(rootfs-y))
mpkg_rootfs: $(ROOTDIR)/etc/mpkg/feeds.conf FORCE | $(ROOTDIR)
	echo -n "Initialize $(rootfs-y)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) --update install $(rootfs-y); then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	echo "done"
	echo
else
mpkg_rootfs: $(ROOTDIR)/etc/mpkg/feeds.conf FORCE | $(ROOTDIR)
	echo -n "Initialize (empty)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) update; then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	echo "done"
	echo
endif

.SILENT: mpkg-install mpkg-remove
mpkg-%: $(ROOTDIR)/etc/mpkg/feeds.conf | $(ROOTDIR)
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

