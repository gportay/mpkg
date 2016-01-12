root-y		:= a b
pkg-m		:= a b c d e f g h
a-deps		:= c
b-deps		:= d e
d-deps		:= f g
f-deps		:= h
e-preinst	:= false

MPKGEXIT_install	 = true

include list-installed.mk files.mk

allfiles-y += /var/lib/mpkg/info/a/.user
allfiles-y += $(a-1-m)
allfiles-y += $(c-1-m)

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 1" >>$@
	@echo "Depends: c" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@
	@echo "Package: c" >>$@
	@echo "Version: 1" >>$@
	@echo "" >>$@

