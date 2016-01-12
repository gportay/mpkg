.SILENT: $(outdir)files
$(outdir)files:
	for f in $(allfiles-y); do \
		echo "$$f"; \
	done | sort >$@

.SILENT: check-files
check-files: $(outdir)files
	echo -n "Checking files... "
	find $(tmpdir)root/ -type f | \
	sed -e "s,^$(rootdir),," -e "\:/var/cache/mpkg/:d" | sort | \
	diff - $<
	echo "done"

check: check-files

