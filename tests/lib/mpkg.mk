#!/usr/bin/gmake -f
#
# Copyright 2016 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#
ifeq (,$(MPKG_INCLUDED))
include lib/tgz.mk
MPKG_INCLUDED := 1

PREFIX		:= /var/lib/mpkg
MPKGOPTS	:= --root $(rootdir) --update

feed		?= local
mpkg-files	+= /etc/mpkg/feeds.conf
mpkg-files	+= $(PREFIX)/lists/$(feed)

mpkg_cmds	:= update list-installed fetch install

MPKGEXIT_update		?= false

MPKGEXIT_list-installed	?= false

MPKGEXIT_install	?= false
MPKGOPTS_install	 = --update
MPKGARGS_install	 = $(root-y)

MPKGEXIT_fetch		?= false
MPKGARGS_fetch		 = --update
MPKGARGS_fetch		 = $(root-y)

.SILENT: $(mpkg_cmds)
$(mpkg_cmds): $(rootdir)/etc/mpkg/feeds.conf | $(rootdir)
	if ! mpkg $(MPKGOPTS) $(MPKGOPTS_$@) $(EXTRA_MPKGOPTS) $@ $(MPKGARGS_$@); then \
		if [ -z "$(MPKGEXIT_$@)" ]; then \
			echo "Warning: The command \"$@\" has failed and the variable \"MPKGEXIT_$@\" is undefined!" >&2; \
			false; \
		else \
			echo "command has failed!" >&2; \
			$(MPKGEXIT_$@); \
		fi; \
	fi

allfiles-y	+= $(mpkg-files)

define do_user =
ifneq (false,$($(1)-preinst))
user-y += $(PREFIX)/info/$(1)/.user
endif
endef

$(foreach pkg,$(root-y),$(eval $(call do_user,$(pkg))))

$(rootdir)/etc/mpkg:
	install -d $@

$(rootdir)/etc/mpkg/feeds.conf: | $(rootdir)/etc/mpkg
	echo "$(feed) $($(feed)-uri)" >$@

endif
