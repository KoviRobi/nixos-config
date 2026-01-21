{ lib, pkgs, ... }:
let
  theme = {
    bg = "282828";
    red = "CC241D";
    green = "98971A";
    yellow = "D79921";
    blue = "458588";
    purple = "B16286";
    aqua = "689D6A";
    gray = "A89984";
    alt = {
      gray = "928374";
      red = "FB4934";
      green = "B8BB26";
      yellow = "FABD2F";
      blue = "83A598";
      purple = "D3869B";
      aqua = "8EC07C";
    };
    fg = "EBDBB2";
  };
  sh = lib.getExe pkgs.bash;
  rofi = lib.getExe pkgs.rofi;
  dmenu = "${rofi} -dmenu";
  cat = lib.getExe' pkgs.coreutils "cat";
  wc = lib.getExe' pkgs.coreutils "wc";
  sed = lib.getExe pkgs.gnused;
  i3-msg = lib.getExe' pkgs.i3 "i3-msg";
  jq = lib.getExe pkgs.jq;
  killall = lib.getExe' pkgs.psmisc "killall";
  socat = lib.getExe pkgs.socat;
  mpc = lib.getExe pkgs.mpc;
  dtach = lib.getExe pkgs.dtach;
  amixer = lib.getExe' pkgs.alsa-utils "amixer";
  xbacklight = lib.getExe' pkgs.xorg.xbacklight "xbacklight";
  dc = lib.getExe' pkgs.bc "dc";
  rfkill = lib.getExe' pkgs.util-linux "rfkill"; # Updated from pkgs.rfkill
  actions = rec {
    invert = pkgs.writeShellScript "invert-window-colors" ''
      PATH="${pkgs.xorg.xprop}/bin:${pkgs.xorg.xwininfo}/bin:${pkgs.gnused}/bin"
      WID=$(xwininfo | sed -n 's/.*Window id: \(\w*\) .*/\1/p')
      VAL=$(xprop -notype -id "$WID" 8i INVERT | sed -n 's/INVERT = //p')
      if [ "$VAL" = 1 ]; then
        xprop -id "$WID" -format INVERT 8i -set INVERT 0
      else
        # Including not found
        xprop -id "$WID" -format INVERT 8i -set INVERT 1
      fi
    '';
    lock = pkgs.writeShellScript "lock-screen-dunst-i3lock" ''
      ${killall} -SIGUSR1 .dunst-wrapped # pause
      (
        ${pkgs.i3lock-color}/bin/i3lock-color \
          --color=${theme.bg} \
          --inside-color=${theme.bg} \
          --ring-color=${theme.blue} \
          --keyhl-color=${theme.green} \
          --bshl-color=${theme.red} \
          --clock \
          --keylayout=0 \
          --time-color=${theme.blue} \
          --date-color=${theme.purple} \
          --layout-color=${theme.green} \
          --nofork;
        ${killall} -SIGUSR2 .dunst-wrapped
      ) &
    '';
    music = pkgs.writeShellScript "i3-action-music" ''
      export MPD_PORT=6612
      export MPD_HOST="$(cat /etc/secrets/mpd-password.secret)@localhost"
      PROGFILE="$HOME/.cache/music_prog"

      cmd=$(basename $0)
      if [ "$cmd" = "music" ]; then
        cmd="$1"; shift # $@ doesn't contain cmd
      fi

      if [ "$cmd" = "mpd" -o "$cmd" = "mpv" -o "$cmd" = "playerctl" ]; then
        echo "$cmd">$PROGFILE
        cmd="$1"; shift
      fi
      PROG="$(${cat} $PROGFILE)"

      if [ "$PROG" = "mpv" ]; then
        if [ "$cmd" = "pause" ]; then
          echo '{ "command": ["set_property", "pause", true] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "play" ]; then
          echo '{ "command": ["set_property", "pause", false] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "toggle" ]; then
          echo '{ "command": ["cycle", "pause"] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "prev" ]; then
          echo '{ "command": ["add", "chapter", -1] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "next" ]; then
          echo '{ "command": ["add", "chapter", 1] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "back" ]; then
          echo '{ "command": ["seek", -20] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "forward" ]; then
          echo '{ "command": ["seek", 20] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        fi
      elif [ "$PROG" = "mpd" ]; then
        if [ -n "$cmd" ]; then
          ${mpc} "$cmd" "$@"
        fi
      elif [ "$PROG" = "playerctl" -o -z "$PROG" ]; then
        if [ "$cmd" = "single" ]; then
          ${pkgs.playerctl}/bin/playerctl play-pause
        elif [ "$cmd" = "toggle" ]; then
          ${pkgs.playerctl}/bin/playerctl play-pause
        elif [ "$cmd" = "prev" ]; then
          ${pkgs.playerctl}/bin/playerctl previous
        elif [ "$cmd" = "back" ]; then
          ${pkgs.playerctl}/bin/playerctl position 20-
        elif [ "$cmd" = "forward" ]; then
          ${pkgs.playerctl}/bin/playerctl position 20+
        else
          ${pkgs.playerctl}/bin/playerctl $cmd
        fi
      fi
    '';
    quit = pkgs.writeShellScript "i3-action-quit" "${i3-msg} exit";
    single = music;
    seek = music;
    stop = music;
    toggle = music;
    next = music;
    pause = music;
    play = music;
    prev = music;
    airplane = pkgs.writeShellScript "rfkill" ''${rfkill} block all'';
    mute = pkgs.writeShellScript "mute" ''${amixer} sset Master toggle'';
    voldn = pkgs.writeShellScript "voldn" ''${amixer} sset Master 5%-'';
    volup = pkgs.writeShellScript "volup" ''${amixer} sset Master 5%+'';
    bldec = pkgs.writeShellScript "bldec" ''${xbacklight} -set $(${dc} --expression="$(${xbacklight} -get) 2 / p")'';
    blinc = pkgs.writeShellScript "blinc" ''${xbacklight} -set $(${dc} --expression="$(${xbacklight} -get) 2 * p")'';
  };
  actions-dir = pkgs.linkFarm "i3-actions-dir" (
    pkgs.lib.mapAttrsToList (k: v: {
      name = k;
      path = v;
    }) actions
  );
in
{
  inherit actions-dir;
  dmenu-action = pkgs.writeShellScript "i3-dmenu-action" ''
    ${dmenu} <<EOF | sed "s|^|${actions-dir}/|" | ${sh} &
    ${builtins.concatStringsSep "\n" (builtins.attrNames actions)}
    EOF
  '';
  dmenu-run = pkgs.writeShellScript "i3-dmenu-run" ''
    ${rofi} -show run
  '';
  dmenu-window = pkgs.writeShellScript "i3-dmenu-run" ''
    ${rofi} -window-thumbnail -theme fullscreen-preview -show window
  '';
  dmenu-drun = pkgs.writeShellScript "i3-dmenu-drun" ''
    ${rofi} -show-icons -show drun
  '';
  dmenu-workspace = pkgs.writeShellScript "i3-dmenu-workspace" ''
    RES=`${i3-msg} -t get_workspaces | \
        ${jq} --raw-output 'map(.name)|join("\n")' | \
        ${dmenu}`
    ${i3-msg} "$1 $RES"
  '';
  dtach-new-session = pkgs.writeShellScript "dtach-new-session" ''
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
    exec ${dtach} -A "$DTACH_SOCK" "$@"
  '';
  workspace-renumber =
    let
      drv = pkgs.python3.pkgs.callPackage ./workspace-renumber { };
    in
    "${drv}/bin/workspace_renumber";
  inherit (pkgs) pen-pye-menu;
}
