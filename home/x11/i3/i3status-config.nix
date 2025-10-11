{ config, pkgs, ... }:
let
  fileSystems = builtins.attrNames config.nixos.fileSystems;
  inherit (builtins) concatStringsSep;
  baseNameOf = s: if s == "/" then s else builtins.baseNameOf s;
in
pkgs.writeText "i3status-config" ''
  # i3status configuration file.
  # see "man i3status" for documentation.

  # It is important that this file is edited as UTF-8.
  # The following line should contain a sharp s:
  # ß
  # If the above line is not correctly displayed, fix your editor first!

  general {
          colors = true
          interval = 5
  }

  order += "ipv6"
  order += "wireless _first_"
  order += "ethernet _first_"
  order += "cpu_temperature package"
  ${concatStringsSep "\n" (map (fs: ''order += "disk ${fs}"'') fileSystems)}
  order += "load"
  order += "memory"
  order += "battery bat"
  order += "tztime local"

  ipv6 {
          format_down = ""
  }

  wireless _first_ {
          format_up = "W: (%quality at %essid) %ip"
          format_down = ""
  }

  ethernet _first_ {
          format_up = "E: %ip (%speed)"
          format_down = ""
  }

  battery bat {
          format = "%status %percentage %remaining@%consumption"
          format_down = ""
          status_chr = "⚡"
          status_bat = "🔋"
          status_unk = "🔋?"
          status_full = "☻"
          path = "/sys/class/power_supply/qcom-battmgr-bat/uevent"
          low_threshold = 10
  }

  ${concatStringsSep "\n" (
    map (fs: ''
      disk "${fs}" {
              format = "${baseNameOf fs}: %avail"
      }

    '') fileSystems
  )}

  load {
          format = "%1min"
  }

  memory {
          format = "%used + %available"
          threshold_degraded = "1G"
          format_degraded = "MEMORY < %available"
  }

  tztime local {
          format = "%Y-%m-%d %H:%M:%S"
  }

  cpu_temperature package {
    format = "%degrees°C"
    path = "/sys/class/thermal/thermal_zone1/temp"
  }
''
