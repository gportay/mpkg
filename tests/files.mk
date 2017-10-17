#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

.PHONY: check
check: check-files

.SILENT: $(O)files.out
$(O)files.out: files | $(O)
	sort $< >$@

.SILENT: files.txt
files.txt:
	for f in $(file-y); do \
		echo "$$f"; \
	done | sort >$@

.SILENT: files
files:
	/bin/echo -e "\e[31;1mError:\e[31m $(CURDIR)/$@ is missing!\e[0m" >&2
	echo "$$ cat <<EOF >$(CURDIR)/$@" >&2
	for f in $(file-y); do \
		echo "$$f"; \
	done | sort
	echo "EOF" >&2
	false

.SILENT: check-files
.PHONY: check-files
check-files: $(O)files.out
	echo -n "Checking files... "
	find $(ROOTDIR)/ -type f | \
	sed -e "s,^$(ROOTDIR),," -e "\:/var/cache/mpkg/:d" | sort | \
	diff - $<
	echo "done"
	echo

