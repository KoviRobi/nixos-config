# vim: set ts=2 sts=2 sw=2 et :
{ icecast ? false,
  music-fs-uuid, music-fs-type ? "xfs"
}:
{ config, pkgs, lib, ... }:

let
  # Generate with e.g. "tr -dc '[:alnum:]' < /dev/urandom|head -c32"
  mpd_pass = builtins.readFile ../mpd-password.secret;
  icecast_pass = builtins.readFile ../icecast-password.secret;
  icecast_admin_pass = builtins.readFile ../icecast-admin-password.secret;
in
{ environment.systemPackages = with pkgs;
  [ mpc_cli gmpc vimpc pavucontrol ];

  fileSystems."/music" =
  { device = "/dev/disk/by-uuid/${music-fs-uuid}";
    fsType = music-fs-type;
    options = [ "ro,noatime" ];
  };

  hardware.pulseaudio.extraConfig =
  "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";

  services.mpd =
  { enable = true;
    musicDirectory = "/music";
    network.port = 6612;

    extraConfig = ''
      password          "${mpd_pass}@read,add,control,admin"
      audio_output {
        type            "pulse"
        name            "PulseAudio"
        server          "127.0.0.1"
      }
        ${lib.optionalString icecast ''
          audio_output {
            type            "shout"
            name            "Orfina stream"
            host            "localhost"
            port            "${toString config.services.icecast.listen.port}"
            mount           "/mpd"
            password        "${icecast_pass}"
            quality         "5.0"
            #bitrate         "128"
            format          "44100:16:2"
            encoding        "mp3"
          }''}
    '';
  };

  services.icecast =
  { enable = icecast;
    hostname = config.networking.hostName;
    admin.user = "rmk35";
    admin.password = "${icecast_admin_pass}";
    listen.port = 8123;
    extraConf = ''
      <location>SC11</location>
      <admin>rmk35@cl.cam.ac.uk</admin>

      <authentication>
          <source-password>${icecast_pass}</source-password>
      </authentication>
    '';
  };
}
