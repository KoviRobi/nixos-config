#!/usr/bin/env bash

zmx-select() {
  local display
  display=$(zmx list 2>/dev/null | while IFS=$'\t' read -r name pid clients created dir; do
    name=${name#*name=}
    pid=${pid#pid=}
    clients=${clients#clients=}
    dir=${dir#started_in=}
    printf "%-20s  pid:%-8s  clients:%-2s  %s\n" "$name" "$pid" "$clients" "$dir"
  done)

  local output query key selected name
  output=$({ [[ -n "$display" ]] && echo "$display"; } | fzf \
    --print-query \
    --expect=ctrl-n \
    --height=80% \
    --reverse \
    --prompt="zmx> " \
    --header="Enter: select | Ctrl-N: create new" \
    --preview='zmx history {1}' \
    --preview-window=right:60%:follow \
  )
  local rc=$?

  query=$(echo "$output" | sed -n '1p')
  key=$(echo "$output" | sed -n '2p')
  selected=$(echo "$output" | sed -n '3p')

  if [[ "$key" == "ctrl-n" && -n "$query" ]]; then
    name="$query"
  elif [[ $rc -eq 0 && -n "$selected" ]]; then
    name=$(echo "$selected" | awk '{print $1}')
  elif [[ -n "$query" ]]; then
    name="$query"
  else
    return 130
  fi

  exec zmx attach "$name"
}

zmx-select
