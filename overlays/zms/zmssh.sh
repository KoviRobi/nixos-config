#!/usr/bin/env bash

set -f
# shellcheck disable=SC2086
set -- ${ROFI_DATA:-} "$@"
set +f

usage() {
        test -z "${ROFI_RETV:-}" || return
        cat <<EOF >&2
$0 [host] [session]

Join all the remote sessions on the given host.
EOF
}

trap 'usage; exit 1' ERR

set -euo pipefail

if [ $# -lt 1 ]; then
        zmshosts
        usage
        exit 1
fi

REMOTE=$1

printf '\x00data\x1f%s\n' "$REMOTE"

if [ $# -lt 2 ]; then
        ssh "$REMOTE" zmx list --short | sed 's/\..*$//' | sort | uniq
        exit 1
fi

PREFIX=$2

SESSIONS=$(ssh "$REMOTE" zmx list --short | grep "^$PREFIX")
if [ -n "${2:-}" ]; then
        SESSIONS=$(echo "$SESSIONS" | grep "$2")
fi

for session in $SESSIONS; do
        nohup rofi-sensible-terminal ssh -t "$REMOTE" zmx attach "$session" >/dev/null &
done
