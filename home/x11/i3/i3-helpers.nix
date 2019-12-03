pkgs:
let sh = "${pkgs.bash}/bin/bash";
    dmenu = "${pkgs.dmenu}/bin/dmenu";
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
    mpd_pass = builtins.readFile ../../../mpd-password.secret;
    dmenu-run-cache = "$HOME/.cache/dmenu_run.cache";
    actions = rec {
      lock = pkgs.writeShellScript "i3-action-lock" "${loginctl} lock-session";
      music = pkgs.writeShellScript "i3-action-music" ''
        export MPD_PORT=6612
        export MPD_HOST="${mpd_pass}@localhost"
        PROGFILE="$HOME/.cache/music_prog"

        cmd=$(basename $0)
        if [ "$cmd" = "music" ]; then
        cmd="$1"; shift # $@ doesn't contain cmd
        fi

        if [ "$cmd" = "mpd" -o "$cmd" = "mpv" ]; then
        echo "$cmd">$PROGFILE
        cmd="$1"; shift
        fi
        PROG="$(${cat} $PROGFILE)"

        if [ "$PROG" = "mpv" ]; then
        if [ "$cmd" = "pause" ]; then
          echo '{ "command": ["set_property", "pause", true] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        elif [ "$cmd" = "play" ]; then
          echo '{ "command": ["set_property", "pause", false] }' | ${socat} - UNIX-CONNECT:/tmp/mpv-socket
        fi
        elif [ "$PROG" = "mpd" -o -z "$PROG" ]; then
        if [ -n "$cmd" ]; then
          ${mpc} "$cmd" "$@"
        fi
        fi
      '';
      quit = pkgs.writeShellScript "i3-action-quit" "${i3-msg} exit";
      rehash = pkgs.writeShellScript "i3-action-rehash" ''
        test -d $(${dirname} ${dmenu-run-cache}) || mkdir -p $(${dirname} ${dmenu-run-cache})
        IFS=:
        ${stest} -flx $PATH | ${sort} -u > ${dmenu-run-cache}
      '';
      single = music;
      seek = music;
      stop = music;
      toggle = music;
      next = music;
      pause = music;
      play = music;
      prev = music;
    };
    actions-dir = pkgs.linkFarm "i3-actions-dir"
      (pkgs.lib.mapAttrsToList (k: v: { name = k; path = v; })
        actions);
in
{
  inherit actions;
  dmenu-action = pkgs.writeShellScript "i3-dmenu-action" ''
    ${dmenu} <<EOF | sed "s|^|${actions-dir}/|" | ${sh} &
    ${builtins.concatStringsSep "\n" (builtins.attrNames actions)}
    EOF
  '';
  dmenu-run = pkgs.writeShellScript "i3-dmenu-run" ''
    test -e ${dmenu-run-cache} || ${actions.rehash}
    < ${dmenu-run-cache} dmenu "$@" | ${sh} &
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
  workspace-renumber = pkgs.writeScript "workspace-renumber" ''
    #!${pkgs.python3.withPackages (p: with p; [ i3ipc ])}/bin/python3
    # vi: tabstop=4 softtabstop=4 expandtab
    import sys, re
    import i3ipc


    def rename_ws(i3, name, new_name):
        message = 'rename workspace "{!s}" to "{!s}"'.format(name, new_name)
        [resp] = i3.command(message)
        if not resp['success']:
            print("Error in {}: {}".format(message, resp['error']))


    class FreeNums:
        """
        A class for giving the first available free number in a finite list of
        numbers, bounded by a maximum, allowing for ticking off numbers early (but
        not late, obviously).

        E.g.
        self = FreeNums(4)
        self.next() # = 0
        self.skip(2)
        self.next() # = 1
        self.next() # = 3
        self.next() # = None

        NOTE: The numbers are from 0...max-1, not from 1...max
        """
        def __init__(self, max):
            self.len = max
            self.nums = [False for n in range(max)]
            self.index = 0

        def skip(self, i):
            if 0 <= i and i < self.len:
                self.nums[i] = True

        def next(self):
            # Find and use the first unused number
            for i in range(self.index, self.len):
                used = self.nums[i]
                if not used:
                    self.nums[i] = True
                    self.index = i
                    return i

    class FreeNums1Based(FreeNums):
        """"
        A one-indexed variant of FreeNums, because in keyboards 0 is after 9 and
        that annoys me
        """
        def skip(self, i):
            super().skip(i-1)
        def next(self):
            return super().next()+1


    def renumber_workspaces(i3, e=None):
        workspaces = i3.get_workspaces()
        nums = FreeNums1Based(len(workspaces))
        for ws in workspaces:
            name = ws['name']
            if name.isnumeric():
                nums.skip(int(name))
        for ws in workspaces:
            name = ws['name']
            if not name.isnumeric():
                new_name = "{:d}:{:s}".format(
                        nums.next(),
                        re.sub("^[^:]*:", "", name))
                rename_ws(i3, name, new_name)


    if __name__ == "__main__":
        i3 = i3ipc.Connection()
        if len(sys.argv) == 1 and sys.argv[0] == "renumber":
            renumber_workspaces(i3)
        else:
            i3.on('workspace::init', renumber_workspaces)
            i3.on('workspace::empty', renumber_workspaces)
            i3.main()
  '';
  workspace-action = pkgs.writeShellScript "i3-workspace-action" ''
    if [ "$2" -eq 0 ]; then
      WSNAME=0
    elif ! WSNAME=`${i3-msg} -t get_workspaces | \
          ${jq} --raw-output --exit-status ".[$2-1].name"`; then
      WSNAME=$2
    fi

    CMD="$1 $WSNAME"
    ${i3-msg} "$CMD"
  '';
}
