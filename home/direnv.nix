{ pkgs, lib, ... }:
{
  programs.direnv = {
    enable = true;
    stdlib = ''
      # Load environment variables from `nix-shell` and export it out.
      #
      # Usage: use_nix [-s <nix-expression>] [-w <path>] [-w <path>] ...
      #   -s nix-expression: The nix expression to use for building the shell environment.
      #   -w path: watch a file for changes. It can be specified multiple times. The
      #      shell specified with -s is automatically watched.
      #
      #   If no nix-expression were given with -s, it will attempt to find and load
      #   the shell using the following files in order: shell.nix and default.nix.
      #
      # Example:
      #   -  use_nix
      #   -  use_nix -s shell.nix -w .nixpkgs-version.json
      #
      # The dependencies pulled by nix-shell are added to Nix's garbage collector
      # roots, such that the environment remains persistent.
      #
      # Nix-shell is invoked only once per environment, and the output is cached for
      # better performance. If any of the watched files change, then the environment
      # is rebuilt.
      #
      # To remove old environments, and allow the GC to collect their dependencies:
      # rm -f .direnv

      use_nix() {
        # define all local variables
        local shell
        local files_to_watch=()
        local PURE=""
        local RESTARGS

        local opt OPTARG OPTIND # define vars used by getopts locally
        while getopts ":n:s:w:p:-" opt; do
          case "''${opt}" in
            s)
              shell="''${OPTARG}"
              files_to_watch=("''${files_to_watch[@]}" "''${shell}")
              ;;
            w)
              files_to_watch=("''${files_to_watch[@]}" "''${OPTARG}")
              ;;
            :)
              fail "Invalid option: $OPTARG requires an argument"
              ;;
            p)
              PURE=--pure
              ;;
            -)
              ;;
            \?)
              fail "Invalid option: $OPTARG"
              ;;
          esac
        done
        shift $((OPTIND -1))

        if [[ -z "''${shell}" ]]; then
          if [[ -f shell.nix ]]; then
            shell=shell.nix
            files_to_watch=("''${files_to_watch[@]}" shell.nix)
          elif [[ -f default.nix ]]; then
            shell=default.nix
            files_to_watch=("''${files_to_watch[@]}" default.nix)
          else
            fail "ERR: no shell was given"
          fi
        fi

        local f
        for f in "''${files_to_watch[@]}"; do
          if ! [[ -f "''${f}" ]]; then
            fail "cannot watch file ''${f} because it does not exist"
          fi
        done

        # compute the hash of all the files that makes up the development environment
        local env_hash="$(hash_contents "''${files_to_watch[@]}")"

        # define the paths
        local dir="$(direnv_layout_dir)"
        local wd="''${dir}/wd-''${env_hash}"
        local drv="''${wd}/env.drv"
        local dump="''${wd}/dump.env"

        # Generate the environment if we do not have one generated already.
        if [[ ! -f "''${drv}" ]]; then
          ${pkgs.coreutils}/bin/mkdir -p "''${wd}"

          log_status "use nix: deriving new environment"
          IN_NIX_SHELL=1 ${pkgs.nix}/bin/nix-instantiate --add-root "''${drv}" --indirect "''${shell}" "$@" > /dev/null
          ${pkgs.nix}/bin/nix-store -r $(${pkgs.nix}/bin/nix-store --query --references "''${drv}") --add-root "''${wd}/dep" --indirect > /dev/null
          if [[ "''${?}" -ne 0 ]] || [[ ! -f "''${drv}" ]]; then
            ${pkgs.coreutils}/bin/rm -rf "''${wd}"
            fail "use nix: was not able to derive the new environment. Please run 'direnv reload' to try again."
          fi

          log_status "use nix: updating cache"
          ${pkgs.nix}/bin/nix-shell $PURE "''${drv}" --run "$(join_args "$direnv" dump bash)" "$@" > "''${dump}"
          if [[ "''${?}" -ne 0 ]] || [[ ! -f "''${dump}" ]] || ! ${pkgs.gnugrep}/bin/grep -q IN_NIX_SHELL "''${dump}"; then
            rm -rf "''${wd}"
            fail "use nix: was not able to update the cache of the environment. Please run 'direnv reload' to try again."
          fi
        fi

        for d in ''${dir}/*; do
          if [ "$wd" != "$d" ]; then
            echo "Old direnv working directory: $d"
          fi
        done

        # evaluate the dump created by nix-shell earlier, but have to merge the PATH
        # with the current PATH
        # NOTE: we eval the dump here as opposed to direnv_load it because we don't
        # want to persist environment variables coming from the shell at the time of
        # the dump. See https://github.com/direnv/direnv/issues/405 for context.
        local path_backup="''${PATH}"
        eval $(${pkgs.coreutils}/bin/cat "''${dump}")
        export PATH="''${PATH}:''${path_backup}"

        # cleanup the environment of variables that are not requried, or are causing issues.
        unset shellHook  # when shellHook is present, then any nix-shell'd script will execute it!

        # watch all the files we were asked to watch for the environment
        for f in "''${files_to_watch[@]}"; do
          watch_file "''${f}"
        done
      }

      fail() {
        log_error "''${@}"
        exit 1
      }

      hash_contents() {
        ${pkgs.coreutils}/bin/cat "''${@}" | \
        ${pkgs.coreutils}/bin/sha256sum | \
        ${pkgs.coreutils}/bin/cut -c -64
      }

      hash_file() {
        ${pkgs.coreutils}/bin/sha256sum "''${@}" | \
        ${pkgs.coreutils}/bin/cut -c -64
      }
    '';
  };
}
