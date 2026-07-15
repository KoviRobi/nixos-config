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
  shellAppBin = args: lib.getExe (pkgs.writeShellApplication args);
  # Accept the given arguments (env var $ACCEPT) or use the argument to
  # generate lists
  rofi-script-1arg =
    noarg:
    shellAppBin {
      name = "rofi-script-1arg-" + builtins.elemAt (builtins.match "([^ ]*/)?([^ /]*).*" noarg) 1;
      text = ''
        if [ $# -gt 0 ]; then
          eval "$ACCEPT"
          exit 0
        fi

        ${noarg}
      '';
    };
  rofi = shellAppBin {
    name = "sway-rofi";
    text =
      lib.getExe pkgs.rofi
      + " -modes run,workspace:${rofi-script-1arg (lib.getExe pkgs.workspaces)},"
      + "zmssh:${lib.getExe pkgs.zmssh},"
      + "unipicker:${rofi-script-1arg "${lib.getExe pkgs.unipicker} --list"},"
      + "drun,window,"
      + "action:${rofi-script-1arg "ls -1 ${actions-dir}"}"
      + " \"$@\"";
  };
  dmenu = "${rofi} -dmenu";
  cat = lib.getExe' pkgs.coreutils "cat";
  swaymsg = lib.getExe' pkgs.sway "swaymsg";
  killall = lib.getExe' pkgs.psmisc "killall";
  socat = lib.getExe pkgs.socat;
  mpc = lib.getExe pkgs.mpc;
  amixer = lib.getExe' pkgs.alsa-utils "amixer";
  xbacklight = lib.getExe' pkgs.xbacklight "xbacklight";
  dc = lib.getExe' pkgs.bc "dc";
  rfkill = lib.getExe' pkgs.util-linux "rfkill"; # Updated from pkgs.rfkill
  actions = rec {
    invert = pkgs.writeShellScript "invert-window-colors" ''
      PATH="${pkgs.xprop}/bin:${pkgs.xwininfo}/bin:${pkgs.gnused}/bin"
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
        ${lib.getExe pkgs.swaylock} \
          --color=${theme.bg} \
          --inside-color=${theme.bg} \
          --ring-color=${theme.blue}
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
    quit = pkgs.writeShellScript "i3-action-quit" "${swaymsg} exit";
    single = music;
    seek = music;
    stop = music;
    toggle = music;
    next = music;
    pause = music;
    play = music;
    prev = music;
    airplane = pkgs.writeShellScript "rfkill" "${rfkill} block all";
    mute = pkgs.writeShellScript "mute" "${amixer} sset Master toggle";
    voldn = pkgs.writeShellScript "voldn" "${amixer} sset Master 5%-";
    volup = pkgs.writeShellScript "volup" "${amixer} sset Master 5%+";
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
  inherit actions-dir rofi;
  dmenu-action = pkgs.writeShellScript "i3-dmenu-action" ''
    ${dmenu} <<EOF | sed "s|^|${actions-dir}/|" | ${sh} &
    ${builtins.concatStringsSep "\n" (builtins.attrNames actions)}
    EOF
  '';
  workspace-renumber =
    let
      drv = pkgs.python3.pkgs.callPackage ./workspace-renumber { };
    in
    "${drv}/bin/workspace_renumber";
}
