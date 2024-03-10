# vim: set ts=2 sts=2 sw=2 et :
{ name ? "rmk", user-options ? { }, group-options ? { } }:
{ config, pkgs, ... }:

{
  users.users.default-user =
    {
      inherit name;
      isNormalUser = true;
      shell = pkgs.zsh;
      extraGroups = [ "users" "wheel" "cdrom" "dialout" "networkmanager" "input" "video" "plugdev" ];
      uid = 1000;
      group = config.users.groups.default-user.name;
      openssh.authorizedKeys.keys = import ../pubkeys.nix;
    } // user-options;
  users.groups.default-user =
    {
      inherit name;
      gid = 1000;
      members = [ name ];
    } // group-options;
}
