# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{ imports =
  [ ./base-configuration.nix
    ../modules/ssh.nix
    (import ../modules/avahi.nix { publish = true; })
    (import ../modules/music.nix { music-fs-uuid = "3a0b0492-af85-426c-8c1f-ee6a0df3bd48"; })
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.kr2 =
  { name = "kr2";
    group = "users";
    extraGroups =
    [ "wheel" "video" "audio" "networkmanager"
      "dialout" "docker" "wireshark" "xen"
      "docker" "games"
    ];
    uid = 1000;
    createHome = true;
    home = "/home/kr2";
    shell = pkgs.zsh;
  };
}
