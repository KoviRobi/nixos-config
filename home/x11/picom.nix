{ lib, ... }:
{
  services.picom.enable = true;
  xdg.configFile."picom/picom.conf".text = lib.mkForce ''
    backend = "glx";
    fading = false;
    shadow = false;
    vsync = true;
    rules = (
      { match = "class_i = 'kiwix-desktop'";                  invert-color = true; },
      { match = "class_i = 'i3lock'";                         opacity = 1;         },
      { match = "_NET_WM_STATE@ = '_NET_WM_STATE_HIDDEN'";    opacity = 0;         },
      { match = "_NET_WM_STATE@[0] = '_NET_WM_STATE_HIDDEN'"; opacity = 0;         },
      { match = "_NET_WM_STATE@[1] = '_NET_WM_STATE_HIDDEN'"; opacity = 0;         },
      { match = "_NET_WM_STATE@[2] = '_NET_WM_STATE_HIDDEN'"; opacity = 0;         },
      { match = "_NET_WM_STATE@[3] = '_NET_WM_STATE_HIDDEN'"; opacity = 0;         },
      { match = "_NET_WM_STATE@[4] = '_NET_WM_STATE_HIDDEN'"; opacity = 0;         },
      { match = "class_i %= 'scratch_*'";                     opacity = 0.87;      },
      { match = "class_i = 'st-256color'";                    opacity = 0.91;      },
      { match = "class_i = 'ghostty'";                        opacity = 0.91;      },
      { match = "class_i = 'org.wezfurlong.wezterm'";         opacity = 0.91;      },
    )
  '';
}
