# vim: set ts=2 sts=2 sw=2 et :
{ name ? "rmk35" }:
{ config, pkgs, ... }:

{ users.users.default-user =
  { inherit name;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "users" "wheel" "cdrom" "dialout" "networkmanager" ];
    uid = 3749;
    group = config.users.groups.default-user.name;
  };
  users.groups.default-user =
  { inherit name;
    gid = 3749;
    members = [ name ];
  };
}
