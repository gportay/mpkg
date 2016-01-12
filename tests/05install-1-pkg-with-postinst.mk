root-y		:= a
pkg-m		:= a
a-postinst	:= true

include list-installed.mk files.mk

allfiles-y += $(user-y)
allfiles-y += $(a-1-m)

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 1" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "" >>$@

