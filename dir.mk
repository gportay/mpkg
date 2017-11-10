#
# Copyright 2017 Gaël PORTAY <gael.portay@savoirfairelinux.com>
#
# Licensed under the MIT license.
#

RELEASE		?= 1
PATH		:= $(CURDIR)/bin:$(PATH)
sysconfdir	:= /etc
localstatedir	:= /var

PREFIX		?= /usr/local
EPREFIX		?= $(PREFIX)
bindir		?= $(EPREFIX)/bin
sbindir		?= $(EPREFIX)/sbin
libexecdir	?= $(EPREFIX)/libexec
sysconfdir	?= $(PREFIX)/etc
sharedstatedir	?= $(PREFIX)/com
localstatedir	?= $(PREFIX)/var
libdir		?= $(EPREFIX)/lib
includedir	?= $(PREFIX)/include
oldincludedir	?= /usr/include
datarootdir	?= $(PREFIX)/share
datadir		?= $(datarootdir)
infodir		?= $(datarootdir)
localedir	?= $(datarootdir)/locale
mandir		?= $(datarootdir)/man
docdir		?= $(datarootdir)/doc/mpkg
htmldir		?= $(datarootdir)
dvidir		?= $(datarootdir)
pdfdir		?= $(datarootdir)
psdir		?= $(datarootdir)
