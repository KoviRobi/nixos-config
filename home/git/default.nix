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
    package =
      if config.programs.ssh.enable then
        pkgs.gitFull.override { openssh = config.programs.ssh.package; }
      else
        pkgs.gitFull;
    userName = "Kovacsics Robert";
    userEmail = lib.mkDefault "kovirobi@gmail.com";
    aliases = {
      g = "log --format='%C(auto)%h%d %C(cyan)%G?%Creset %s' --graph";
      lg = "log --format='%C(auto)%h%d %C(cyan)%G?%Creset %s'";
      pcc = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=master";
      prich = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='robert.kovacsics' -o merge_request.target=richmond";
      pgl = "push -o merge_request.create -o merge_request.remove_source_branch -o merge_request.assign='rmk' -o merge_request.target=master";
    };
    includes = [
      {
        path = ./personal.gitconfig;
        condition = "hasconfig:remote.*.url:git@github.com:KoviRobi/**";
      }
      {
        path = ./personal.gitconfig;
        condition = "hasconfig:remote.*.url:https://github.com/KoviRobi/**";
      }
      {
        condition = "gitdir:~/pdev/**";
        path = ./personal.gitconfig;
      }
      {
        path = ./carallon.gitconfig;
        condition = "hasconfig:remote.*.url:ssh://*@code.office.carallon.com:29418/**";
      }
      {
        condition = "gitdir:~/dev/**";
        path = ./carallon.gitconfig;
      }
    ];
    extraConfig = {
      am.threeWay = true;
      checkout.workers = 0;
      commit.gpgSign = true;
      commit.verbose = true;
      core = {
        commitGraph = true;
        fsmonitor = true;
        untrackedCache = true;
      };
      credential.helper = "libsecret";
      diff = {
        colorMoved = true;
        colorMovedWS = "ignore-all-space";
        submodule = "log";
      };
      feature.manyFiles = true;
      fetch.writeCommitGraph = true;
      gerrit.createChangeId = false;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.config/git/ssh-signers";
      help.autoCorrect = 10;
      init.defaultBranch = "main";
      init.templateDir = "${pkgs.runCommandLocal "git-template" { dontFixup = true; } ''
        cp --no-preserve=mode --dereference -r "${cfg.package}/share/git-core/templates" "$out"
        cp --no-preserve=mode --dereference -r ${./hooks}/* "$out/hooks/"
        chmod +x -R $out/hooks

        # Unpatch shebangs, to avoid nix GC breaking scripts
        find $out -type f -exec \
          sed -i 's:#!/nix/store/[^/]\+/\(bin/.*\):#!/run/current-system/sw/\1:' {} \;
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
