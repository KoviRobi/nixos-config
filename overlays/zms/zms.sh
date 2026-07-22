#!/usr/bin/env bash

set -euo pipefail

zmx-select() {
  local display
  display=$( ( zmx list 2>/dev/null || true ) | \
      while IFS=$'\t' read -r name pid clients _created dir; do
    name=${name#*name=}
    pid=${pid#pid=}
    clients=${clients#clients=}
    dir=${dir#start_dir=}
    printf "%s\tpid:%s\tclients:%s\t%s\n" "$name" "$pid" "$clients" "$dir"
  done | sort -t$'\t' -k3.9n,4 -k1,1 | column -ts$'\t' -o$' | ')

  local workspace output query key name rc
  workspace=${DEFAULT_WORKSPACE:-$(workspaces | head -n1 || true)}
  workspace=${workspace#*:}
  # shellcheck disable=SC2016 # Expanded in fzf
  set +e
  output=$(
  { [[ -n "$display" ]] && echo "$display"; } | fzf \
    --print-query \
    --query "${workspace}" \
    --expect=ctrl-d \
    --bind $'tab:transform-query:echo "${FZF_CURRENT_ITEM}" | sed "s/ *|.*$//"' \
    --reverse \
    --prompt="zmx> " \
    --header="Enter: accept | Tab: complete | Ctrl-D: z and create new" \
    --preview=$'zmx history "$(echo "${FZF_CURRENT_ITEM}" | sed "s/ *|.*//")"' \
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
    dir="${query%.*}"
    # We want word splitting but not globs, see
    # https://www.shellcheck.net/wiki/SC2086
    # shellcheck disable=SC2086
    cd "$( ( set -f; zoxide query $dir || true ) )" || true
  elif [[ -n "$query" ]]; then
    name="$query"
  elif [[ $rc -eq 0 ]]; then
    name=${selected%%[ |]*}
    dir=${selected##*[ |]}
    cd "$dir"
  else
    return 130
  fi

  # No number suffix
  if [ "${name%.*}" = "${name}" ]; then
    display=$(zmx list --short | grep "^$name" || true)
    num=$(echo "$display" | wc -l)
    for n in $(seq $((num + 1))); do
      if ! echo "$display" | grep -q "$name.$n"; then
        name=$name.$n
        break
      fi
    done
  fi

  osc7
  ${ZMX_EXEC:+exec} zmx attach "$name"
}

zmx-select "$@"
