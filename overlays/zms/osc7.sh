#!/usr/bin/env bash

set -euo pipefail

osc7() {
  # shellcheck disable=SC1003 # ASNI ST escape
  LC_ALL=C printf '\e]7;file://%s%s\e\\' "${HOSTNAME:-$(hostname)}" "${PWD:-$(pwd)}"
}

osc7
