root-y		:= a
pkg-m		:= a
a-preinst	:= false

MPKGEXIT_install	 = true

include list-installed.mk files.mk

$(outdir)list-installed:
	@echo -n "" >$@

