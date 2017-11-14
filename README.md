# mpkg(1)

A **shell** script based *Package Manager*

## DESCRIPTION

*mPKG* is a **lightweight** *package manager*. It comes with absolutely **no
dependencies**! Nothing but some of *core utilities* of any **POSIX** system
(such as *sh*, *sed*, *grep*, *tar*, *wget*...).

*mPKG* is written in pure **shell**. Thus, **no exotic** interpreter is
required. This makes *mPKG* suitable for *embedded* devices that usually embeds
*Busybox* which provides everything it needs in a very *single* binary.

Because of *mPKG* is **shell** based, it is certainly not the *most* efficient
*package manager*. But the *time process* is **mostly lost** when packages are
*downloaded*.

### SCRIPTS

The project is composed of

* a *run-time* script that is designed to be run on the target
* two *build-time* scripts that create a *package* and *index*

### SIMPLE

*mPKG* is **simple**. The installation step can be *summed up* into 3 steps

1. *Resolving* all dependencies
1. *Fetching* archive
1. *Unpacking* it to root

... **nothing** more!

## DEBIAN STYLE

The implementation is *mostly* inspired of **Debian** packages.

*mPKG* combines both **APT** and **DPKG** features; as **OPKG**, a *Debian*
compatible *package manager* dedicated to *embedded* systems.

*mPKG* tries to follow and to remain, as close as it is *relevant*, to the
**behavior** defined by *Debian*
[policies](https://www.debian.org/doc/debian-policy/index.html).

Same `preinst`/`postinst` and `prerm`/`postrm` maintainer scripts.
*None-trivial* cases, such as *error handling*, are simply *dropped-out*!

## BUT NOT DEBIAN COMPATIBLE

*mPKG* is different.

### CONTROL FIELDS

Only an **essential** set of *control fields* is handled. `Package`, `Version`
and `Depends` defines the *package* while `Filename` and `MD5Sum` are used by
the *index* to definces the *URI* to fetch and its *checksum*.

This means that there is no `Provides`, `Breaks`, `Conflicts` nor `Pre-depends`
relationships. The goal is to keep *mPKG* **simple**!

Furthermore, because it is easier to parse in *shell*, lists are **space**
separated values; not *comma*! For example, package dependencies look like

	Package: meta
	Depends: busybox mpkg

### ARCHIVE FORMAT

Packages are **simple** *gzipped* *tar* archives.

Unlike *Debian* **.deb** packages, *control* data is a part of the archive. The
archive is an image of the *root-fs*; the package *metadata* is stored under
`/var/lib/mpkg`.

A *minimal* package consists in a single file `/var/lib/mpkg/info/pn/control`
containing a single line, where *pn* is the package name.

	Package: pn

### STATUS DATABASE

The common **status** database which references all *installed packages* has
disappeared.

Instead, it lets place to a whole *file system* hierarchy; one *status* file per
package. It **minimizes** every *not-yet-synchronized* write into the
*monolithic* status database. The *FS* handles it. A critical error, such as an
unexpected reboot, breaks the concerned package and not the whole database.

Because of the *limited amount* of memory in *embedded* devices, the package
content is *unpacked* directly into *root-fs*.

First *metadata* is extracted to a temporary context; outside of the database
hierarchy in order to resume an interrupted installation. Then data is extracted
to *root-fs* and finally *metadata* is moved to the database *file system*
hierarchy.

## CLI

*mPKG* provides the 2 main operations of a classical *package manager*:

1. `install`
1. `remove`

The `upgrade` will come later to keep the system *up-to-date*.

## TODO

In the **TODO** list

* Add `upgrade` feature to keep the system *up-to-date*
* Manage `Conffiles` and add `--purge` option when package is *removed*
* Extra features such as `whatprovides`/`whatdepends` package or `find/search`
for files which are useful but not essential
* Index *conversion* from *control* to *HTML*

## WONT DO

Here are some features that are not *implemented* and **WILL NOT BE**

* *version constraints* such as `Depends: busybox (>= 1.23.1)`
* `Recommends` and `Suggests` relationships; `Depends` is enough!
* `Provides`, `Breaks` and `Conflicts`; keep relationship *simple*
* *architecture* looks absolutely *not essential*

## INSTALL

*mPKG* is *easy* to install. Because it is a *shell* script, it does not need to
be compiled.

Download [script](https://raw.githubusercontent.com/gazoo74/mpkg/todo/bin/mpkg)
and copy it somewhere in your `$PATH`.

	$ sudo su
	# cd /usr/sbin
	# wget https://raw.githubusercontent.com/gazoo74/mpkg/master/bin/mpkg
	# chmod +x mpkg

*mPKG* needs at least a *repository feed* in `/etc/mpkg/feeds.conf` file.

	# mkdir -p /etc/mpkg/
	# echo "me http://tgz.me/Index" >/etc/mpkg/feeds.conf

## AUTHOR

Written by Gaël PORTAY *gael.portay@gmail.com*

## COPYRIGHT

Copyright (c) 2015 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the MIT License.
