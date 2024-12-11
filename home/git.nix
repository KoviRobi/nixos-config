{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.programs.git;
in
{
  programs.git = {
    enable = true;
    userName = "Kovacsics Robert";
    userEmail = lib.mkDefault "kovirobi@gmail.com";
    aliases = {
      g = "log --oneline --graph";
      lg = "log --oneline";
      pcc = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=master";
      prich = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=richmond";
      pgl = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='rmk' -o merge_request.target=master";
      absorb = "!git-absorb";
    };
    includes = [
      {
        path = ./git-personal.gitconfig;
        condition = "hasconfig:remote.*.url:git@github.com:KoviRobi/**";
      }
      {
        path = ./git-personal.gitconfig;
        condition = "hasconfig:remote.*.url:https://github.com/KoviRobi/**";
      }
      {
        condition = "gitdir:~/pdev/**";
        path = ./git-personal.gitconfig;
      }
      {
        path = ./git-carallon.gitconfig;
        condition = "hasconfig:remote.*.url:ssh://*@code.office.carallon.com/**";
      }
      {
        condition = "gitdir:~/dev/**";
        path = ./git-carallon.gitconfig;
      }
    ];
    extraConfig = {
      am.threeWay = true;
      commit.verbose = true;
      core.commitGraph = true;
      core.fsmonitor = true;
      core.untrackedCache = true;
      credential.helper = "libsecret";
      diff.colorMoved = true;
      diff.colorMovedWS = "ignore-all-space";
      diff.submodule = "log";
      feature.manyFiles = true;
      fetch.writeCommitGraph = true;
      gpg.format = "ssh";
      help.autoCorrect = 10;
      init.defaultBranch = "main";
      init.templateDir =
        let
          pre-push-local = pkgs.writeShellApplication {
            name = "pre-push-hook";
            runtimeInputs = [
              cfg.package
              pkgs.coreutils
            ];
            text = ''
              # This hook is called with the following parameters:
              #
              # $1 -- Name of the remote to which the push is being done
              # $2 -- URL to which the push is being done
              #
              # If pushing without using a named remote those arguments will be equal.
              #
              # Information about the commits which are being pushed is supplied as lines to
              # the standard input in the form:
              #
              #   <local ref> <local oid> <remote ref> <remote oid>
              #
              # This prevents push of commits where the log message starts with
              # "local!".

              # remote="$1"
              # url="$2"

              zero=$(git hash-object --stdin </dev/null | tr '0-9a-f' '0')

              while read -r local_ref local_oid _remote_ref remote_oid
              do
                if test "$local_oid" = "$zero"
                then
                  # Handle delete
                  :
                else
                  if test "$remote_oid" = "$zero"
                  then
                    # New branch, examine all commits
                    range="$local_oid"
                  else
                    # Update to existing branch, examine new commits
                    range="$remote_oid..$local_oid"
                  fi

                  # Check for 'local!' or 'drop!' commit
                  commit=$(git rev-list -n 1 --grep '^\(local!\|drop!\)' "$range")
                  if test -n "$commit"
                  then
                    echo >&2 "Found local-only commit in $local_ref, not pushing"
                    exit 1
                  fi
                fi
              done

              exit 0
            '';
          };
        in
        "${pkgs.runCommandLocal "git-template" { dontFixup = true; } ''
          cp --no-preserve=mode --dereference -r "${cfg.package}/share/git-core/templates" "$out"
          cp '${lib.getExe pre-push-local}' "$out/hooks/pre-push"
          find $out -type f -exec \
            sed -i 's:#!/nix/store/[^/]\+/\(bin/.*\):/run/current-system/sw/\1:' {} \;
        ''}";
      merge.tool = "nvimdiff";
      mergetool.nvimdiff.layout = "LOCAL,BASE,REMOTE / MERGED + BASE,LOCAL + BASE,REMOTE";
      pull.ff = "only";
      rebase.autoSquash = true;
      rebase.autoStash = true;
      status.submoduleSummary = true;
      user.signingKey = "~/.ssh/id_ed25519.pub";
    };
  };
}
