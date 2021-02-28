{ config, lib, pkgs, ... }:

with lib;
{
  options = {
    nixos = mkOption {
      type = with types; attrs;
      default = {
        services.xserver.dpi = 72;
        fileSystems = { "/" = { }; };
        users.users.default-user.uid = 1000;
      };
      example = {
        services.xserver.dpi = 72;
        fileSystems = { "/" = { }; "/home" = { }; };
        users.users.default-user.uid = 3749;
      };
      description = ''
        Any configuration to import from NixOS.
        Currently uses `fileSystems` to configure i3status,
        `services.xserver.dpi`, and `config.users.users.default-user.uid`.
      '';
    };
  };
}
