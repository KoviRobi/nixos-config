# vim: set ts=2 sts=2 sw=2 et :
{ config, pkgs, ... }:

let mpd_pass = "handcreme1protozoaguitarpick";
    icecast_pass = "paperclipOp131No14jugglingball";
    icecast_admin_pass = "callalily7segLED";
in
{ environment.systemPackages = with pkgs;
  [ mpc_cli gmpc vimpc pavucontrol ];

  fileSystems."/music" =
  { device = "/dev/disk/by-uuid/b5cb1ef0-7603-4d71-b107-c5ab11c76e17";
    fsType = "xfs";
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
      #audio_output {
      #  type            "shout"
      #  name            "Orfina stream"
      #  host            "localhost"
      #  port            "${toString config.services.icecast.listen.port}"
      #  mount           "/mpd"
      #  password        "${icecast_pass}"
      #  quality         "5.0"
      #  #bitrate         "128"
      #  format          "44100:16:2"
      #  encoding        "mp3"
      #}
    '';
  };

  #services.icecast =
  #{ enable = true;
  #  hostname = config.networking.hostName;
  #  admin.user = "rmk35";
  #  admin.password = "${icecast_admin_pass}";
  #  listen.port = 8123;
  #  extraConf = ''
  #    <location>SC11</location>
  #    <admin>rmk35@cl.cam.ac.uk</admin>

  #    <authentication>
  #        <source-password>${icecast_pass}</source-password>
  #    </authentication>
  #  '';
  #};
}
