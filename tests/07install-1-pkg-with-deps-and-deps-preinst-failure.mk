root-y		:= a
pkg-m		:= a b
a-deps		:= b c
b-preinst	:= false

MPKGEXIT_install	 = true

include list-installed.mk files.mk

$(outdir)list-installed:
	@echo -n "" >$@

