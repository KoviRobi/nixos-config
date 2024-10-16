{ config, lib, pkgs, ... }:

with lib;
let cfg = config.clipboard;
in
{
  options.clipboard = {
    default-selection = mkOption {
      type = types.listOf types.str;
      default = [ "--clipboard" ];
      description = ''
        Argument to the copy/paste program for the default selection (e.g.
        CTRL-C/CTRL-V).
      '';
    };
    alternate-selection = mkOption {
      type = types.listOf types.str;
      default = [ "--primary" ];
      description = ''
        Argument to the copy/paste program for the default selection (e.g.
        CTRL-C/CTRL-V).
      '';
    };
    copy-command = mkOption {
      type = types.listOf types.str;
      default = [ (lib.getExe pkgs.xsel) "-i" ];
      description = ''
        Can be used to override the copy command for programs (e.g. tmux, vim).
        For example use win32yank https://github.com/equalsraf/win32yank/ under
        Windows/WSL.
      '';
    };
    paste-command = mkOption {
      type = types.listOf types.str;
      default = [ (lib.getExe pkgs.xsel) "-o" ];
      description = ''
        Can be used to override the paste command for programs (e.g. vim). For
        example use win32yank https://github.com/equalsraf/win32yank/ under
        Windows/WSL.
      '';
    };
  };
  config = {
    programs.tmux.extraConfig = ''
      set -g copy-command "${toString cfg.copy-command}"
    '';
  };
}
