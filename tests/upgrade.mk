#
# Copyright 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Licensed under the MIT license.
#

.PHONY: check
check: check-upgrade

.PHONY: check-upgrade
check-upgrade: check-upgrade-list-installed

.PHONY: check-upgrade-list-installed
check-upgrade-list-installed: $(O)upgrade-list-installed.out mpkg-upgrade
	echo -n "Checking list-installed after upgrade... "
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d' | \
	diff - $<
	echo "done"
	echo

.PHONY: check-upgrade-list-outdated
check-upgrade-list-outdated: $(O)upgrade-list-outdated.out mpkg-upgrade
	echo -n "Checking list-outdated after upgrade... "
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-outdated) $(EXTRA_MPKGOPTS) list-outdated | \
	sed -n -e '/^\(Package\|Version\)/p' \
	       -e '/^$$/p' | \
	diff - $<
	echo "done"
	echo

.PHONY: check-upgrade-files
check-upgrade-files: $(O)upgrade-files.out
	echo -n "Checking files after upgrade... "
	find $(ROOTDIR)/ -type f | \
	sed -e "s,^$(ROOTDIR),," -e "\:/var/cache/mpkg/:d" | sort | \
	diff - $<
	echo "done"
	echo

