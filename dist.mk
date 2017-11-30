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

pkg-m		:= mpkg mpkg-tools
mpkg-vers	:= $(RELEASE)
mpkg-dir	:= $(sysconfdir)/mpkg/repos.d $(localstatedir)/lib/mpkg/lists
mpkg-sbin	:= mpkg
mpkg-postinst	:= support/postinst
mpkg-tools-vers	:= $(RELEASE)
mpkg-tools-bin	:= mpkg-build mpkg-deb2tgz mpkg-make-index

include tests/tgz.mk
