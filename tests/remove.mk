#
# Copyright 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Licensed under the MIT license.
#

.PHONY: check
check: check-remove

.PHONY: check-remove
check-remove: check-remove-list-installed

.PHONY: check-remove-list-installed
check-remove-list-installed: $(O)remove-list-installed.out | mpkg-remove
	echo -n "Checking list-installed after remove... "
	bash mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d' | \
	diff - $<
	echo "done"
	echo

.PHONY: check-remove-files
check-remove-files: $(O)remove-files.out | mpkg-remove
	echo -n "Checking files after remove... "
	find $(ROOTDIR)/ -type f | \
	sed -e "s,^$(ROOTDIR),," -e "\:/var/cache/mpkg/:d" | sort | \
	diff - $<
	echo "done"
	echo

