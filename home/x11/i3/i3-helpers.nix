{ pkgs, pye-menu }:
let
  sh = "${pkgs.bash}/bin/bash";
  rofi = "${pkgs.rofi}/bin/rofi";
  dmenu = "${rofi} -dmenu";
  stest = "${pkgs.dmenu}/bin/stest";
  cat = "${pkgs.coreutils}/bin/cat";
  dirname = "${pkgs.coreutils}/bin/dirname";
  sort = "${pkgs.coreutils}/bin/sort";
  i3-msg = "${pkgs.i3}/bin/i3-msg";
  jq = "${pkgs.jq}/bin/jq";
  killall = "${pkgs.psmisc}/bin/killall";
  socat = "${pkgs.socat}/bin/socat";
  mpc = "${pkgs.mpc_cli}/bin/mpc";
  tmux = "${pkgs.tmux}/bin/tmux";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  amixer = "${pkgs.alsa-utils}/bin/amixer";
  xbacklight = "${pkgs.xorg.xbacklight}/bin/xbacklight";
  dc = "${pkgs.bc}/bin/dc";
  rfkill = "${pkgs.util-linux}/bin/rfkill"; # Updated from pkgs.rfkill
  mpd_pass = builtins.readFile ../../../mpd-password.secret;
  actions = rec {
    lock = pkgs.writeShellScript "lock-screen-dunst-i3lock" ''
      ${killall} -SIGUSR1 .dunst-wrapped # pause
      ( ${pkgs.i3lock}/bin/i3lock -c 111111 -n; ${killall} -SIGUSR2 .dunst-wrapped ) &
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
  actions-dir = pkgs.linkFarm "i3-actions-dir"
    (pkgs.lib.mapAttrsToList
      (k: v: { name = k; path = v; })
      actions
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
  dmenu-workspace = pkgs.writeShellScript "i3-dmenu-workspace" ''
    RES=`${i3-msg} -t get_workspaces | \
        ${jq} --raw-output 'map(.name)|join("\n")' | \
        ${dmenu}`
    ${i3-msg} "$1 $RES"
  '';
  tmux-current-workspace = pkgs.writeShellScript "i3-tmux-current-workspace" ''
    #!/bin/sh
    name=`${i3-msg} -t get_workspaces | \
          ${jq} --raw-output '.[] | select(.focused) | .name'`
    exec ${tmux} new-session -t "''${name#*:}"
  '';
  workspace-renumber =
    let drv = pkgs.python3.pkgs.callPackage ./workspace-renumber { };
    in "${drv}/bin/workspace_renumber";
  pen-pye-menu = pye-menu.packages."${pkgs.system}".pen-menu;
}
