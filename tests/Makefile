#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

PREFIX ?= /usr/local
SRC	:= $(wildcard */Testfile)
SRC	:= $(sort $(SRC))

.PHONY: all
all: tests

.PHONY: $(SRC)
.SILENT: $(SRC)
$(SRC):
	./maketest "-C$(@D)"

.PHONY: tests
tests:
	./run.sh $(MFLAGS)

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

.PHONY: clean
clean:
	-for testfile in */Testfile; do \
		dir=$${testfile%/*}; \
		rm -f $$dir/{true,false,*.sh}; \
	done

