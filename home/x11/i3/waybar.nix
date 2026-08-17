{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = [
        "sway-session.target"
      ];
    };
    settings.bar-0 = {
      reload_style_on_change = true;
      layer = "top";
      position = "bottom";
      spacing = 4;
      modules-left = [
        "sway/workspaces"
        "sway/mode"
        "sway/scratchpad"
        "custom/media"
      ];
      modules-center = [
        "sway/window"
        "privacy"
      ];
      modules-right = [
        "mpd"
        "idle_inhibitor"
        "pulseaudio"
        "network"
        "power-profiles-daemon"
        "cpu"
        "memory"
        "temperature"
        "battery"
        "clock"
        "tray"
        "custom/power"
      ];

      "sway/workspaces" = {
        disable-scroll-wraparound = true;
      };
      keyboard-state = {
        numlock = true;
        capslock = true;
        format = "{name} {icon}";
        format-icons = {
          locked = "";
          unlocked = "";
        };
      };
      "sway/mode" = {
        format = "<span style=\"italic\">{}</span>";
      };
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = [
          ""
          ""
        ];
        tooltip = true;
        tooltip-format = "{app}: {title}";
      };
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
        tooltip-format-activated = "No idle";
        tooltip-format-deactivated = "Can idle";
      };
      tray = {
        spacing = 10;
      };
      clock = {
        tooltip-format = "<tt><big>{calendar}</big></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "left";
          on-scroll = 1;
          on-click-right = "mode";
          format = {
            months = "<span color='#FFEAD3'>{}</span>";
            weeks = "<span color='#EBDBB2'>W{}</span>";
            weekdays = "<span color='#ffcc66'>{}</span>";
            days = "<span color='#D5C4A1'>{}</span>";
            today = "<span background='#FBF1C7' color='#020E38'><b>{}</b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
        format = "{:%Y-%m-%d %H:%M}";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
      };
      memory = {
        format = "{}% ";
      };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [
          ""
          ""
          ""
        ];
      };
      battery = {
        states = {
          full = 100;
          good = 90;
          warning = 30;
          critical = 15;
        };
        format = "{capacity}% {icon}";
        format-full = "{capacity}% {icon}";
        format-charging = "{capacity}% 󰂄";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };
      power-profiles-daemon = {
        format = "{icon}";
        tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        tooltip = true;
        format-icons = {
          default = "";
          performance = "";
          balanced = "";
          power-saver = "";
        };
      };
      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} 🖧";
        tooltip-format = "{ifname} via {gwaddr} 󰲝";
        format-linked = "{ifname} (No IP) 󰛵";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
      pulseaudio = {
        format = "{volume}% {icon}  {format_source}";
        format-bluetooth = "{volume}% {icon}  {format_source}";
        format-bluetooth-muted = " {icon}  {format_source}";
        format-muted = "  {format_source}";
        format-source = "{volume}% ";
        format-source-muted = "";
        format-icons = {
          headphone = "";
          hands-free = "󰓃";
          headset = "󰓃";
          phone = "";
          portable = "";
          car = "";
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "pavucontrol";
      };
      "custom/power" = {
        format = "⏻";
        tooltip = false;
        menu = "on-click";
        menu-file = "$HOME/.config/waybar/power_menu.xml";
        menu-actions = {
          shutdown = "shutdown";
          reboot = "reboot";
          suspend = "systemctl suspend";
          hibernate = "systemctl hibernate";
        };
      };
    };
    style = ''
      @import url("general.css");
      @import url("brightness.css");

      * {
          /* `otf-font-awesome` is required to be installed for icons */
          font-family: "CaskaydiaCove Nerd Font:weight=light";
          font-size: 10pt;
      }

      #waybar {
          background-color: @bg0;
          border: none;
          color: @fg0;
          transition-property: background-color;
          transition-duration: .5s;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover,
      #idle_inhibitor:hover,
      #network:hover,
      #battery:hover,
      #clock:hover,
      #pulseaudio:hover,
      #custom-power:hover {
          box-shadow: inset 0 3px @fg1;
      }

      #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: @fg0;
      }

      #workspaces button:hover {
          background: @bg1;
      }

      #workspaces button.focused, #workspaces button.active {
          background-color: @bg2;
          box-shadow: inset 0 3px @fg3;
      }

      #workspaces button.urgent {
          background-color: @red;
      }

      #mode {
          background-color: @bg4;
          box-shadow: inset 0 3px @fg3;
      }

      /* Things which behave more like text */
      #pulseaudio,
      #temperature,
      #tray,
      #mode,
      #scratchpad,
      #clock,
      #custom-power {
          padding: 0 5px;
      }

      /* Things which have a trailing wide emoji */
      #battery,
      #cpu,
      #memory,
      #disk,
      #backlight,
      #network,
      #wireplumber,
      #custom-media,
      #idle_inhibitor,
      #power-profiles-daemon,
      #mpd {
          padding-left: 5px;
          padding-right: 12px;
          color: @fg0;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #battery.warning {
          color: @fg0;
          background-color: @yellow;
      }

      #battery.good {
          color: @fg0;
          background-color: @green;
      }

      @keyframes blink {
          to {
              background-color: @fg0;
              color: @bg0;
          }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
          background-color: @red;
          color: @fg0;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }

      label:focus {
          background-color: @bg0;
      }

      #tray > :hover {
          box-shadow: inset 0 3px @fg2;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: @red;
      }

      #idle_inhibitor.activated {
          background-color: @bg2;
      }

      #scratchpad {
          background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
          background-color: transparent;
      }

      #privacy {
          padding: 0;
      }

      #privacy-item {
          padding: 0 5px;
          color: @fg0;
          background-color: @bg2;
      }
    '';
  };
}
