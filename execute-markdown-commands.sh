#!/bin/sh
set -eu

OLDIFS="$IFS"
IFS='
'

for line in `grep '^	' $1`; do
	echo "Execute '$line' (Y/n)?"
	read execute
	if [ "$execute" = "y" -o "$execute" = "Y" -o "$execute" = "" ]; then
		eval "$line"
	fi
done

IFS="$OLDIFS"
