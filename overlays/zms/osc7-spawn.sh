#!/usr/bin/env bash

set -euo pipefail

OSC7=${OSC7:-$(osc7)}

# Local OSC7 handled by foot already
if [ -n "${OSC7##file://"${HOSTNAME}"/*}" ]; then
  #
  # shellcheck disable=SC1003 # ASNI ST escape
  LC_ALL=C printf '\e]7;%s\e\\' "${OSC7}"
  # Trusted hosts
  for host in promethium-nix1 inspiron kovirobi.uk; do
    if [ -z "${OSC7##file://"${host}"/*}" ]; then
      echo "${OSC7#file://"${host}"}"
      exec ssh -t "${host}" \
        "cd '${OSC7#file://"${host}"}'; \
         exec \"\$SHELL\" --login -c 'exec zms'"
    fi
  done
fi

ZMX_EXEC=1 zms "$@" || ( osc7; exec "$SHELL" "$@" )
