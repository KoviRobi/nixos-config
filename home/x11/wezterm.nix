{ pkgs, ... }:
{
  systemd.user.services.wezterm-mux-server = {
    Service.ExecStart = "${pkgs.wezterm}/bin/wezterm-mux-server";
    Unit.Description = "Wezterm multiplexer";
    Install.WantedBy = [ "graphical-session.target" ];
  };
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'
      local act = wezterm.action

      -- This will hold the configuration.
      local config = wezterm.config_builder()

      -- I use undercurl
      config.term = 'wezterm'

      -- This is where you actually apply your config choices.
      fp = io.open(os.getenv("HOME") .. "/.local/state/brightness", "r")
      brightness = fp:read()
      fp:close()
      config.color_scheme = 'Gruvbox' .. brightness:gsub(".", string.upper, 1)
      config.prefer_egl = true
      config.window_decorations = 'RESIZE'
      config.window_padding = { left = 3, right = 3, top = 3, bottom = 3}
      config.tab_bar_at_bottom = true
      config.hide_tab_bar_if_only_one_tab = true

      config.keys = {
        -- Turn off the default Alt+Enter full screen
        {
          key = 'Enter',
          mods = 'ALT',
          action = act.DisableDefaultAssignment,
        },
        -- Semantic prompt
        { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
        { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
      }
      config.mouse_bindings = {
        {
          event = { Down = { streak = 4, button = 'Left' } },
          action = act.SelectTextAtMouseCursor 'SemanticZone',
          mods = 'NONE',
        },
        {
          event = { Down = { streak = 5, button = 'Left' } },
          action = act.SelectTextAtMouseCursor 'Block',
          mods = 'NONE',
        },
      }
      config.use_cap_height_to_scale_fallback_fonts = true
      config.freetype_load_target = "Light"
      config.font = wezterm.font_with_fallback {
          { family = 'CaskaydiaCove Nerd Font Mono' },
          'Noto Emoji',
          'Noto Sans Symbols',
          'Noto Sans Symbols 2',
      }
      config.font_size = 10
      config.font_rules = {
        {
          intensity = 'Half',
          italic = false,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'ExtraLight' },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Normal',
          italic = false,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Light' },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Bold',
          italic = false,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Regular' },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Half',
          italic = true,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'ExtraLight', style = "Italic" },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Normal',
          italic = true,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Light', style = "Italic" },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Bold',
          italic = true,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Regular', style = "Italic" },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
      }

      config.unix_domains = {
        {
          name = 'unix',
        },
      }

      -- Finally, return the configuration to wezterm:
      return config
    '';
  };
}
