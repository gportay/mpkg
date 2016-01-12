root-y		:= a
pkg-m		:= a
a-postinst	:= false

include list-installed.mk files.mk

allfiles-y += $(user-y)
allfiles-y += $(a-1-m)
allfiles-y += /var/lib/mpkg/info/a/.configure

$(outdir)list-installed:
	@echo "Package: a" >$@
	@echo "Version: 1" >>$@
	@echo "User-Installed: yes" >>$@
	@echo "Configure-Required: yes" >>$@
	@echo "" >>$@

