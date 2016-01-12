include mpkg.mk

.SILENT: check-list-installed
check-list-installed: $(outdir)list-installed install
	echo -n "Checking list-installed... "
	mpkg $(MPKGOPTS) $(MPKGOPTS_list-installed) $(EXTRA_MPKGOPTS) list-installed | \
	sed -e '/^MPKG-/d'| \
	diff - $<
	echo "done"

check: check-list-installed

