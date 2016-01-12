#!/usr/bin/make -f
#
# Copyright 2016 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PATH	:= $(PWD)/../bin:$(PATH)
tmpdir	:= $(patsubst %.mk,tmp/%,$(TEST))
rootdir	:= $(tmpdir)root
outdir	:= $(tmpdir)out

.PHONY: all
all:

.PHONY: help
help:
	@echo  "Usage: make TEST=<test> check"
	@echo

ifeq (,$(TEST))
ifeq (,$(root-y))
all:
	./run.sh
else
#
# Example:
# --------
#
# Install package a and e packages to setup initial condition,
# then install the f package and finally removes the a package.
#

#a-deps		:= b
#b-deps		:= c d
#c-deps		:= d
#root-y		:= a e
#root-m		:= f
#root-n		:= a
#root-y		:= a

INCPATH = lib

include list-installed.mk

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 1" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@

all:
	echo "root-y:    $(root-y)"
	echo "pkg-m:     $(pkg-m)"
	echo "           $(sort $(pkg-m))"
	echo "pkgdirs-m: $(pkgdirs-m)"
	echo "tgz-m:     $(tgz-m)"

endif
else
include $(TEST)
endif

include lib/mpkg.mk

.PHONY: clean
clean:
	rm -Rf $(rootdir)/* tmp/* run/*

