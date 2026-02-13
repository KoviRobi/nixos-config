{ lib, ... }:
{
  services.picom.enable = true;
  xdg.configFile."picom/picom.conf".text = lib.mkForce ''
    backend = "glx";
    fading = false;
    shadow = false;
    vsync = true;
    transparent-clipping = true;
    rules = (
      { match = "_NET_WM_BYPASS_COMPOSITOR > 0"; transparent-clipping = false; },

      { match = "!_NET_WM_WINDOW_OPACITY && class_i = 'kiwix-desktop'"; invert-color = true;  },
      { match = "INVERT@ = 1";                                          invert-color = true;  },
      { match = "INVERT@ = 0";                                          invert-color = false; },

      { match = "!_NET_WM_WINDOW_OPACITY && class_i = 'ringboard-egui'";         opacity = 0.87; },
      { match = "!_NET_WM_WINDOW_OPACITY && class_i %= 'scratch_*'";             opacity = 0.87; },
      { match = "!_NET_WM_WINDOW_OPACITY && class_i = 'st-256color'";            opacity = 0.91; },
      { match = "!_NET_WM_WINDOW_OPACITY && class_i = 'ghostty'";                opacity = 0.91; },
      { match = "!_NET_WM_WINDOW_OPACITY && class_i = 'org.wezfurlong.wezterm'"; opacity = 0.91; },
      { match = "_NET_WM_STATE@[*] = '_NET_WM_STATE_HIDDEN'";                    opacity = 0;    },
      { match = "class_i = 'i3lock'";                                            opacity = 0.4;  },
    )
  '';
}
