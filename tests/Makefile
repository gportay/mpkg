#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PREFIX ?= /usr/local

.PHONY: all
all: tests

.PHONY: tests
tests:
	./run.sh -s

.PHONY: install
install:
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 755 mpkgtest $(DESTDIR)$(PREFIX)/bin/
	sed -e '/^DATADIR/s,=.*,=$(PREFIX)/share/mpkgtest,' \
	    -i $(DESTDIR)$(PREFIX)/bin/mpkgtest
	install -d $(DESTDIR)$(PREFIX)/share/mpkgtest/
	install -m 644 Maketest *.mk $(DESTDIR)$(PREFIX)/share/mpkgtest/

.PHONY: uninstall
uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/mpkgtest
	rm -Rf $(DESTDIR)$(PREFIX)/share/mpkgtest/

