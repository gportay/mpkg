# mpkg(1)

Managing packages from a *shell* script

## DESCRIPTION

*mPKG* is a **lightweight** *package manager* written in pure **Shell**.

As a consequence, it does **not** require any extra **exotic** interpreter such
as *python*, *ruby*, *lua*...

*mPKG* uses standard utilities such as `sh`, `grep`, `tar`, `wget` and `awk`
that are shipped in any **POSIX** system.

This makes *mPKG* suitable for **embedded** devices that usually embed [Busybox]
which provides everything it needs in a *single* binary.

### CONTENTS

The project is composed of *three* scripts:

* One **run-time** script that is designed to be run on the [target]
* Two **host build-time** scripts that create [packages] and [index]

### INSTALLATION STEPS

*mPKG* is **simple**.

The installation step can be *summed up* in *3 steps*:

1. **Resolving** all dependencies
1. **Fetching** archive
1. **Unpacking** it to root

... **nothing** more!

## INSPIRED BY DEBIAN

The implementation is *mostly* inspired by **Debian** packages.

*mPKG* combines both **APT** and **DPKG** features; as **Opkg** does.

It follows and remains as close as it is *relevant* to the **behavior** defined
by the [Debian policies].

*mPKG* runs same `preinst/postinst` and `prerm/postrm` maintainer scripts.

## BUT NOT DEBIAN COMPATIBLE

But *mPKG* is **different**.

It is designed for **embedded systems** which are **limited** in term of
*space*, *memory*, and *CPU*.

*mPKG* does **not have staging** directory and *unpacks* directly archives to
the *root* file system.

Therefore, it **does not handle** complicated *maintainers* scripts *use-cases*
to *rewind* for error handling.

*mPKG* must **remain simple** and **relies** on the *maintainers' scripts* of
the distribution.

### CONTROL FIELDS SET

*mPKG* handles a **limited** set of *control fields*.

The **essentials** *archives fields* are `Package`, `Version`, and `Depends`.

The *index fields* `Filename` and `MD5Sum` are set in the **index** to defines
the *URI* where to fetch the archive and its *checksum* for integrity checking.

It means that there are no `Provides`, `Breaks`, `Conflicts`, and `Pre-depends`
relationships. The goal is to keep *mPKG* **simple**.

Furthermore, lists of dependencies are **space-separated**. It makes the parsing
easier in *shell* scripts because space is one of the default characters of the
`$IFS` variable.

Here is an example of a what a *control* file looks like:

	Package: meta
	Version: 2017.11
	Depends: busybox mpkg

### ARCHIVE FORMAT

Packages are **simple**.

*Debian* packages split *metadata* and *data* into two distinct archives:
*control.tar.gz* and *data.tar.gz*.

*mPKG* archives all data in a single **gzipped tar** archive.

The archive is an image of the *root file system*; the package *metadata* are
stored under `/var/lib/mpkg`.

A *minimal* package consists of a single file `/var/lib/mpkg/info/pn/control`
containing a single line, where *pn* is the name of the package.

	Package: pn

### DATABASE

There is **no single file** database.

Instead, the *status* file lets place to a whole *file system* hierarchy; one
directory per package.

It **minimizes** every *not-yet-synchronized* write to the *monolithic* status
database. Thus, the impact of critical errors, such as an unexpected reboot, is
limited to the concerned package and not the whole database.

*mPKG* delegates the *synchronization* to the *file system* layer.

## CLI API

*mPKG* provides the *2* main operations of a classical *package manager*:

1. `install`
1. `remove`

The `upgrade` will come later to keep the system *up-to-date*.

## TODO

*mPKG* is still in development.

### UPCOMING FEATURES

In the **TODO** list:

* Add `upgrade` feature to keep the system *up-to-date*
* Manage `Conffiles` and add `--purge` option when package is *removed*
* Extra features such as `whatprovides/whatdepends` package or `find/search`
for files are helpful
* Index *export* from *control* format to *HTML* or *JSON*

### WONT DO

Here are some features that are not *implemented* and **WILL NOT BE**:

* *version constraints* such as `Depends: busybox (>= 1.23.1)`
* `Recommends` and `Suggests` relationships; `Depends` is enough!
* `Provides`, `Breaks`, and `Conflicts`; keep relationship *simple*
* the *architecture* is *not* essential

## INSTALL

*mPKG* is **easy** to install.

Because it is a *shell* script, it does not need to be compiled.

Download [mpkg] and copy it somewhere in your `$PATH`.

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

Copyright (c) 2015-2017 Gaël PORTAY

This program is free software: you can redistribute it and/or modify it under
the terms of the MIT License.

[Busybox]: https://busybox.net/
[target]: bin/mpkg
[packages]: bin/mpkg-build
[index]: bin/mpkg-make-index
[Debian policies]: https://www.debian.org/doc/debian-policy/index.html
[mpkg]: bin/mpkg
