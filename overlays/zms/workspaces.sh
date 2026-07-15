#!/usr/bin/env bash

# Output workspaces, with selected workspace as the first item

set -euo pipefail

swaymsg -t get_workspaces |
    jq --raw-output 'sort_by(.focused | not)|map(.name)|join("\n")'
