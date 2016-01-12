root-y		:= a b
pkg-m		:= a b c d
a-deps		:= c
a-preinst	:= true
b-deps		:= d
b-preinst	:= false

MPKGEXIT_install	 = true

include list-installed.mk files.mk

allfiles-y += $(user-y)
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

