#!/bin/sh
#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

set -e

# Install required directories
mkdir -p "/etc/mpkg/repo.d/" "/var/lib/mpkg/info/mpkg/"
touch "/var/lib/mpkg/info/mpkg/.user"

# Self-extract archive
# Important: no code beyong the next line!
exec sh -c "sed -n -e '/----- >8 -----/,\${//d;p}' $0 | tar xz -C / && mpkg update"
