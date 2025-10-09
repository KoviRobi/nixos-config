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
      config.color_scheme = 'GruvboxDark'
      config.prefer_egl = true
      config.window_decorations = 'RESIZE'
      config.use_cap_height_to_scale_fallback_fonts = true
      config.font = wezterm.font_with_fallback {
          { family = 'CaskaydiaCove Nerd Font Mono' },
          'Noto Emoji',
          'Noto Sans Symbols',
          'Noto Sans Symbols 2',
      }
      config.font_size = 12
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
