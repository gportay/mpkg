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

STATEDIR	 = $(localstatedir)/lib/mpkg
pkg-m		:= mpkg mpkg-tools
mpkg-vers	:= $(RELEASE)
mpkg-dir	:= $(sysconfdir)/mpkg/ $(localstatedir)/lib/mpkg/lists
mpkg-sbin	:= bin/mpkg
mpkg-tools-vers	:= $(RELEASE)
mpkg-tools-bin	:= bin/mpkg-build bin/mpkg-deb2tgz bin/mpkg-make-index

include tests/tgz.mk
