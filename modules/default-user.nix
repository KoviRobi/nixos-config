# vim: set ts=2 sts=2 sw=2 et :
{ name ? "rmk35", user-options ? {}, group-options ? {} }:
{ config, pkgs, ... }:

{ users.users.default-user =
  { inherit name;
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "users" "wheel" "cdrom" "dialout" "networkmanager" "input" ];
    uid = 3749;
    group = config.users.groups.default-user.name;
  } // user-options;
  users.groups.default-user =
  { inherit name;
    gid = 3749;
    members = [ name ];
  } // group-options;
}
