root-y		:= a
pkg-m		:= a
a-vers		:= 1 2

include list-installed.mk files.mk

allfiles-y += $(user-y)
allfiles-y += $(a-1-m)

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 2" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@

