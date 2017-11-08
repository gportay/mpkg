#
# Copyright 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Licensed under the MIT license.
#

.PHONY: check
check: check-install

.PHONY: check-install
check-install: check-install-list-installed

.PHONY: check-install-list-installed
check-install-list-installed: $(O)install-list-installed.out mpkg-install
	echo -n "Checking list-installed after install... "
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d' | \
	diff - $<
	echo "done"
	echo

.PHONY: check-install-files
check-install-files: $(O)install-files.out
	echo -n "Checking files after install... "
	find $(ROOTDIR)/ -type f | \
	sed -e "s,^$(ROOTDIR),," -e "\:/var/cache/mpkg/:d" | sort | \
	diff - $<
	echo "done"
	echo

