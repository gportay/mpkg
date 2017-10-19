#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

.PHONY: check
check: check-list-installed

$(O)%.out: % | $(O)
	cp $< $@

.SILENT: list-installed
list-installed:
	/bin/echo -e "\e[31;1mError:\e[31;0m $(CURDIR)/$@ is missing!\e[0m" >&2
	echo "$$ cat <<EOF >$(CURDIR)/$@" >&2
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d' >&2
	echo "EOF" >&2
	false

.SILENT: check-list-installed
.PHONY: check-list-installed
check-list-installed: $(O)list-installed.out mpkg-install
	echo -n "Checking list-installed... "
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d' | \
	diff - $<
	echo "done"
	echo

