#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PREFIX		:= /var/lib/mpkg
MPKGOPTS	:= --root $(ROOTDIR)

include tgz.mk

repo		?= local
local-uri	?= file://$(TGZDIR)/Index

$(ROOTDIR) $(ROOTDIR)/etc/mpkg/repo.d:
	mkdir -p $@

define do_repo =
$(ROOTDIR)/etc/mpkg/repo.d/$(1).conf: | $(ROOTDIR)/etc/mpkg/repo.d
	echo "$($(1)-uri)" >$$@

file-y	+= /etc/mpkg/repo.d/$(1).conf
file-y	+= $(PREFIX)/lists/$(1).conf
repo-y += $(ROOTDIR)/etc/mpkg/repo.d/$(1).conf
endef

$(foreach repo,$(repo),$(eval $(call do_repo,$(repo))))

MPKGEXIT_list-installed	?= false
MPKGEXIT_install	?= false
MPKGARGS_install	 = $(install-y)

.PHONY:
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

.SILENT: mpkg-install
mpkg-%: $(repo-y) FORCE | $(ROOTDIR)
	if ! bash mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*) \
	   && ! $(MPKGEXIT_$*); then \
		echo "Error: command has failed $(MPKGEXIT_$*)!" >&2; \
		echo "       mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*)" >&2; \
		false; \
	fi

.PHONY: mpkg_clean
mpkg_clean:
	rm -Rf $(ROOTDIR)/ $(O)*.out

clean-y ?= $(rootfs-y) $(install-y)
.PHONY: mpkg_rootfs_clean
mpkg_rootfs_clean: | $(ROOTDIR)
	echo -n "Cleaning up $(clean-y)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) --force remove $(clean-y); then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) list-installed | \
	diff - /dev/null
	echo "done"
	echo

mpkg_clean: mpkg_rootfs_clean

define do_user =
ifneq (false,$($(1)-preinst))
user-y += $(PREFIX)/info/$(1)/.user
endif
endef

$(foreach pkg,$(root-y),$(eval $(call do_user,$(pkg))))

.PHONY: clean
clean: mpkg_clean

$(O)%-files.out: %-files | $(O)
	sort $< >$@

$(O)%.out: % | $(O)
	cp $< $@

