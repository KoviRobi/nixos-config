{ pkgs, lib, config, ... }:
let cfg = config.programs.git; in
{
  programs.git = {
    enable = true;
    difftastic.enable = true;
    userName = "Kovacsics Robert";
    userEmail = lib.mkDefault "kovirobi@gmail.com";
    aliases = {
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      pcc = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=master";
      prich = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=richmond";
      pgl = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='rmk' -o merge_request.target=master";
      absorb = "!git-absorb";
    };
    extraConfig = {
      gpg.format = "ssh";
      user.signingKey = "~/.ssh/id_ed25519.pub";
      rebase.autoSquash = true;
      rebase.autoStash = true;
      pull.ff = "only";
      help.autoCorrect = 10;
      credential.helper = "libsecret";
      commit.verbose = true;
      merge.tool = "nvimdiff";
      diff.colorMoved = true;
      diff.colorMovedWS = "ignore-all-space";
      init.defaultBranch = "main";
      am.threeWay = true;
      init.templateDir = "${pkgs.symlinkJoin {
        name = "git-template";
        paths = [
          "${cfg.package}/share/git-core/templates"
          (pkgs.writeTextFile rec {
            name = "pre-push-hook";
            executable = true;
            destination = "/hooks/pre-push";
            text = ''
              #!${pkgs.runtimeShell}

              export PATH="${lib.makeBinPath [ cfg.package pkgs.coreutils ]}"

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

              remote="$1"
              url="$2"

              zero=$(git hash-object --stdin </dev/null | tr '[0-9a-f]' '0')

              while read local_ref local_oid remote_ref remote_oid
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

            checkPhase = ''
              ${pkgs.stdenv.shellDryRun} "$target"
            '';
            meta.mainProgram = name;
          })
        ];
      }}";
    };
  };
}
