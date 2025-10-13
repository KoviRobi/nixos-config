{
  programs.wezterm = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    extraConfig = ''
      -- Pull in the wezterm API
      local wezterm = require 'wezterm'

      -- This will hold the configuration.
      local config = wezterm.config_builder()

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
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'ExtraLight' },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Normal',
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Light' },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Bold',
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
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'ExtraLight', italic = true },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Normal',
          italic = true,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Light', italic = true },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
        {
          intensity = 'Bold',
          italic = true,
          font = wezterm.font_with_fallback {
              { family = 'CaskaydiaCove Nerd Font Mono', weight = 'Regular', italic = true },
              'Noto Emoji',
              'Noto Sans Symbols',
              'Noto Sans Symbols 2',
          },
        },
      }
      -- Finally, return the configuration to wezterm:
      return config
    '';
  };
}
