{ config, lib, pkgs, ... }:

with lib;
{
  options = {
    dpi = mkOption {
      type = types.ints.unsigned;
      default = 96;
      example = 200;
      description = ''
        DPI of the X11 server, set it to the value of NixOS'
        config.services.xserver.dpi
      '';
    };
  };
}
