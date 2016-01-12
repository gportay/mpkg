root-y		:= a b
pkg-m		:= a b

include list-installed.mk files.mk

allfiles-y += $(user-y)
allfiles-y += $(a-1-m)
allfiles-y += $(b-1-m)

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 1" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@
	@echo "Package: b" >>$@
	@echo "Version: 1" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@

