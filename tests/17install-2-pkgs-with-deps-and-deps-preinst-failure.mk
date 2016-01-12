root-y		:= a b
pkg-m		:= a b c d
a-deps		:= c
b-deps		:= d
d-preinst	:= false

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

