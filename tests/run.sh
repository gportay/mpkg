#!/bin/bash
#
# Copyright 2016 Gaël PORTAY <gael.portay@gmail.com>
#
# Licensed under the MIT license.
#

set -e

run() {
	local id=$((id+1))
	local test="#$id: $@"
	echo -e "\e[1mRunning $test...\e[0m"
}

ok() {
	ok=$((ok+1))
	echo -e "\e[1m$test: \e[32m[OK]\e[0m"
	echo
}

ko() {
	ko=$((ko+1))
	echo -e "\e[1m$test: \e[31m[KO]\e[0m"
	echo
}

result() {
	if [ -n "$ok" ]; then
		echo -e "\e[1m\e[32m$ok test(s) succeed!\e[0m"
	fi

	if [ -n "$ko" ]; then
		echo -e "\e[1mError: \e[31m$ko test(s) failed!\e[0m" >&2
		exit 1
	fi
}

PATH="${0##*/}../bin:$PATH"
trap result 0

for test in ${@:-[0-9]*.mk}; do
	run "$test"
	if make -Ilib/ TEST=$test check; then
		ok
	else
		ko
	fi
done

make clean
