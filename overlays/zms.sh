#!/usr/bin/env bash

set -euo pipefail

zmx-select() {
  local display
  display=$( ( zmx list 2>/dev/null || true ) | \
      while IFS=$'\t' read -r name pid clients _created dir; do
    name=${name#*name=}
    pid=${pid#pid=}
    clients=${clients#clients=}
    dir=${dir#started_in=}
    printf "%s\tpid:%s\tclients:%s\t%s\n" "$name" "$pid" "$clients" "$dir"
  done | sort -t$'\t' -k3.9n,4 -k1,1)

  local output query key name rc
  # shellcheck disable=SC2016 # Expanded in fzf
  set +e
  output=$(
  { [[ -n "$display" ]] && echo "$display"; } | fzf \
    --print-query \
    --expect=ctrl-d \
    --bind $'tab:transform-query:echo "${${FZF_CURRENT_ITEM}/\t*/}"' \
    --bind 'load:transform:column -t' \
    --reverse \
    --prompt="zmx> " \
    --header="Enter: accept | Tab: complete | Ctrl-D: z and create new" \
    --preview=$'zmx history "${${FZF_CURRENT_ITEM}/\t*/}"' \
    --preview-window=down:75%:follow
  )
  rc=$?
  set -e

  query=$(echo "$output" | sed -n '1p')
  key=$(echo "$output" | sed -n '2p')
  selected=$(echo "$output" | sed -n '3p')

  if [[ "$key" == "ctrl-d" && -n "$query" ]]; then
    # zoxide and spawn
    name="$query"
    cd "$(zoxide query "$name")" || true
    osc7
    ${ZMX_EXEC:+exec} zmx attach "$name"
  elif [[ -n "$query" ]]; then
    name="$query"
    ${ZMX_EXEC:+exec} zmx attach "$name"
  elif [[ $rc -eq 0 ]]; then
    name=${selected/	*/}
    ${ZMX_EXEC:+exec} zmx attach "$name"
  else
    return 130
  fi
}

zmx-select "$@"
