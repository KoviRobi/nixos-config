#!/usr/bin/env bash

set -euo pipefail

osc7() {
  # shellcheck disable=SC1003 # ASNI ST escape
  LC_ALL=C printf '\x1b]7;file://%s%s\x1b\\' "${HOSTNAME:-$(hostname)}" "${PWD:-$(pwd)}"
}

osc7
