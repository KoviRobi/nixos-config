{ config, lib, pkgs, ... }:

with lib;
{
  options = {
    fileSystems = mkOption {
      type = with types; listOf str;
      default = [ "/" ];
      example = [ "/" "/boot" ];
      description = ''
        File systems to print via i3status
      '';
    };
  };
}
