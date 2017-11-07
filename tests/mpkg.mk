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
MPKGOPTS_install	 = --update
MPKGARGS_install	 = $(root-y)

.PHONY:
FORCE:

.SILENT: mpkg-install
mpkg-%: $(repo-y) FORCE | $(ROOTDIR)
	if ! bash mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*) \
	   && ! $(MPKGEXIT_$*); then \
		echo "Error: command has failed $(MPKGEXIT_$*)!" >&2; \
		echo "       mpkg $(MPKGOPTS) $(MPKGOPTS_$*) $(EXTRA_MPKGOPTS) $* $(MPKGARGS_$*)" >&2; \
		false; \
	fi

clean-y ?= $(root-y)
.PHONY: mpkg_clean
mpkg_clean: tgz_clean | $(ROOTDIR)
	echo -n "Cleaning up $(clean-y)... "
	if ! bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) remove $(clean-y); then \
		echo "Error: command has failed!" >&2; \
		false; \
	fi
	bash mpkg $(MPKGOPTS) $(EXTRA_MPKGOPTS) list-installed | \
	diff - /dev/null
	echo "done"
	echo
	rm -Rf $(ROOTDIR)/ $(O)*.out

define do_user =
ifneq (false,$($(1)-preinst))
user-y += $(PREFIX)/info/$(1)/.user
endif
endef

$(foreach pkg,$(root-y),$(eval $(call do_user,$(pkg))))

.PHONY: clean
clean: mpkg_clean
