root-y		:= a
pkg-m		:= a b c d e f
a-deps		:= b c
b-deps		:= d e
d-deps		:= f
c-preinst	:= false

MPKGEXIT_install	 = true

include list-installed.mk files.mk

$(outdir)list-installed:
	@echo -n "" >$@

