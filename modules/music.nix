# vim: set ts=2 sts=2 sw=2 et :
{ music-fs-uuid
, music-fs-type ? "xfs"
}:
{ config, pkgs, lib, ... }:
let
  # Generate with e.g. "tr -dc '[:alnum:]' < /dev/urandom|head -c32"
  mpd_pass = builtins.readFile ../mpd-password.secret;
in
{
  systemd.services.mpd-password = {
    script = ''
      test -d /etc/secrets || mkdir -p /etc/secrets
      tr -dc '[:alnum:]' < /dev/urandom | head -c32 > /etc/secrets/mpd-password.secret
    '';
    unitConfig = { ConditionPathExists = "!/etc/secrets/mpd-password.secret"; };
    wantedBy = [ "default.target" ];
  };

  environment.systemPackages = with pkgs;
    [ mpc_cli gmpc vimpc pavucontrol ];

  fileSystems."/music" =
    {
      device = "/dev/disk/by-uuid/${music-fs-uuid}";
      fsType = music-fs-type;
      options = [ "ro" "noatime" "nofail" ];
    };

  hardware.pulseaudio.extraConfig =
    "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";

  users.users.default-user.extraGroups = [ "mpd" ];

  services.mpd =
    {
      enable = true;
      musicDirectory = "/music";
      network.port = 6612;
      credentials = [
        {
          passwordFile = "/etc/secrets/mpd-password.secret";
          permissions = [ "read" "add" "control" "admin" ];
        }
      ];

      extraConfig = ''
        audio_output {
          type            "pulse"
          name            "PulseAudio"
          server          "127.0.0.1"
        }
      '';
    };

}
