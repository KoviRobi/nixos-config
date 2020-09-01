{ pkgs, lib, ... }:
let
  xclip = "${pkgs.xclip}/bin/xclip";
  i3 = "${pkgs.i3}";
in
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    escapeTime = 0;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      copycat
      tmux-colors-solarized
      prefix-highlight
      sidebar
      urlview
      yank
      fpp
    ];
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -g renumber-windows on
      set -g mouse on
      set -g set-titles on
      set -g alternate-screen off

      bind-key C new-window -c "#{pane_current_path}"

      # Tmux and I disagree on what is horizontal and what is vertical
      # I take the view that Vim does
      bind-key v if-shell "${i3}/bin/i3-msg split horizontal" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window\"" \
          "split-window -h"
      bind-key V if-shell "${i3}/bin/i3-msg split horizontal" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window -c #{pane_current_path}\""  \
          "split-window -h -c #{pane_current_path}"
      bind-key h if-shell "${i3}/bin/i3-msg split vertical" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window\"" \
          "split-window -v"
      bind-key H if-shell "${i3}/bin/i3-msg split vertical" \
          "run-shell -b \"xterm -e tmux new-session -t #{session_group} '\;' new-window -c #{pane_current_path}\"" \
          "split-window -v -c #{pane_current_path}"
      bind-key -T root C-PageUp copy-mode -eu

      bind-key s capture-pane -e -b screenshot_raw\;\
          capture-pane -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'
      bind-key S capture-pane -e -S - -E - -b screenshot_raw\;\
          capture-pane -S - -E - -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'

      bind-key -T copy-mode    WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode    WheelDownPane send-keys -X scroll-down
      bind-key -T copy-mode-vi WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down

      bind-key -T copy-mode    C-PageUp      send-keys -X page-up
      bind-key -T copy-mode-vi C-PageUp      send-keys -X page-up
      bind-key -T copy-mode    C-PageDown    send-keys -X page-down
      bind-key -T copy-mode-vi C-PageDown    send-keys -X page-down

      bind-key -T copy-mode    MouseDragEnd1Pane  send-keys -X copy-pipe "${xclip} -i -selection primary"
      bind-key -T copy-mode-vi MouseDragEnd1Pane  send-keys -X copy-pipe "${xclip} -i -selection primary"
    '';
  };
}
