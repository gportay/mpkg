root-y		:= a
pkg-m		:= a b
a-2-deps	:= b
a-vers		:= 1 2

include list-installed.mk files.mk

allfiles-y += $(user-y)
allfiles-y += $(a-2-m)
allfiles-y += $(b-1-m)

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 2" >>$@
	@echo "Depends: b" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@
	@echo "Package: b" >>$@
	@echo "Version: 1" >>$@
	@echo "" >>$@

