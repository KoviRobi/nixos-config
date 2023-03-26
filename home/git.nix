{ pkgs, lib, config, ... }:
{
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        side-by-side = true;
      };
    };
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
    };
  };
}
