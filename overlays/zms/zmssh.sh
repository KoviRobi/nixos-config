#!/usr/bin/env bash

usage() {
        test -z "${ROFI_RETV:-}" || return
        cat <<EOF >&2
$0 [host] [session]

Join all the remote sessions on the given host.
EOF
}

if [ -n "${ROFI_RETV:-}" ]; then
    set -f
    # shellcheck disable=SC2086
    set -- ${ROFI_DATA:-} "$@"
    set +f
else
    trap 'usage; exit 1' ERR
fi

set -euo pipefail

if [ $# -lt 1 ]; then
        zmshosts
        usage
        exit 1
fi

REMOTE=$1

if [ -n "${ROFI_RETV:-}" ]; then
    printf '\x00data\x1f%s\n' "$REMOTE"
fi

if [ $# -lt 2 ]; then
        ssh "$REMOTE" zmx list --short | sed 's/\..*$//' | sort | uniq
        exit 1
fi

PREFIX=$2

if SESSIONS=$(ssh "$REMOTE" zmx list --short | grep "^$PREFIX"); then
    if [ -n "${2:-}" ]; then
            SESSIONS=$(echo "$SESSIONS" | grep "$2")
    fi
    for session in $SESSIONS; do
            nohup rofi-sensible-terminal ssh -t "$REMOTE" zmx attach "$session" >/dev/null &
    done

else
    nohup rofi-sensible-terminal ssh -t "$REMOTE" zmx attach "$PREFIX.1" >/dev/null &
fi
