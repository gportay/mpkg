#!/bin/bash
#
# Copyright 2016-2017 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

set -e

run() {
	__id=$((__id+1))
	__test="#$__id: $@"
	echo -e "\e[1mRunning $__test...\e[0m"
}

ok() {
	__ok=$((__ok+1))
	echo -e "\e[1m$__test: \e[32m[OK]\e[0m"
	echo
}

ko() {
	__ko=$((__ko+1))
	echo -e "\e[1m$__test: \e[31m[KO]\e[0m"
	echo
}

result() {
	if [ -n "$__ok" ]; then
		echo -e "\e[1m\e[32m$__ok test(s) succeed!\e[0m"
	fi

	if [ -n "$__ko" ]; then
		echo -e "\e[1mError: \e[31m$__ko test(s) failed!\e[0m" >&2
		exit 1
	fi
}

PATH="${0##*/}../bin:$PATH"
export PATH
trap 'result' 0

for testfile in [0-9]*/Testfile; do
	run "$testfile"
	if ./maketest "-C${testfile%/*}" "$@"; then
		ok
	else
		ko
	fi
done
