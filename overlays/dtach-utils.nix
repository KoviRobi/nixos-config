final: prev:
let
  dtach = final.lib.getExe final.dtach;
in
{
  dtach-new-session = final.writeShellScriptBin "dtach-new-session" ''
    dtachdir="$XDG_RUNTIME_DIR/dtach"
    mkdir -p "$dtachdir"
    max=0
    for f in "$dtachdir"/*; do
        if [ -e "$f" ] && [ ! -x "$f" ]; then
            export DTACH_SOCK="$f"
            exec ${dtach} -A "$DTACH_SOCK" "$@"
        fi
        num="''${f##*/}"
        if [ "$max" -lt "''$num" ]; then
            max="$num"
        fi
    done
    max=$(( max + 1 ))
    export DTACH_SOCK="$dtachdir/$max"
    if [ $# -eq 0 ]; then
        set -- "$SHELL"
    fi
    exec ${dtach} -A "$DTACH_SOCK" "$@"
  '';
  dtach-ls-sessions = final.writeShellScriptBin "dtach-ls-sessions" ''
    dtachdir="$XDG_RUNTIME_DIR/dtach"
    mkdir -p "$dtachdir"
    max=0
    for f in "$dtachdir"/*; do
        if [ -e "$f" ]; then
            if [ ! -x "$f" ]; then
                echo "  $f"
            else
                echo "* $f"
            fi
        fi
    done
  '';
}
