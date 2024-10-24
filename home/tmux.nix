{ pkgs, config, lib, ... }:
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    terminal = "screen-256color";
    escapeTime = 0;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      logging
    ];

    extraConfig = ''
      set -g status-position top
      set -g status-right "#{?window_bigger,[#{window_offset_x}#,#{window_offset_y}] ,}\"#{client_user}@#h:#{=21:pane_current_path}\" %H:%M %d-%b-%y"
      set -g mouse on
      set -g set-titles on
      set -g pane-border-lines heavy
      set -g pane-border-indicators arrows
      set -g display-panes-time 2000
      set -g exit-empty off
      set -sa terminal-overrides ",st-256color:Tc"

      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="${pkgs.procps}/bin/ps -o state= -o comm= -t '#{pane_tty}' \
          | ${pkgs.gnugrep}/bin/grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'
      bind-key -n 'M-;' if-shell "$is_vim" 'send-keys "M-;"'  'last-pane'

      bind-key -T copy-mode-vi 'M-h' select-pane -L
      bind-key -T copy-mode-vi 'M-j' select-pane -D
      bind-key -T copy-mode-vi 'M-k' select-pane -U
      bind-key -T copy-mode-vi 'M-l' select-pane -R
      bind-key -T copy-mode-vi 'M-;' last-pane

      set -g renumber-windows on
      bind-key . command-prompt "swap-window -t '%%'"

      set -g history-limit 10000

      bind-key C new-window -c "#{pane_current_path}"

      # Tmux and I disagree on what is horizontal and what is vertical
      # I take the view that Vim does
      bind-key = split-window -h
      bind-key + split-window -h -c "#{pane_current_path}"
      bind-key - split-window -v
      bind-key _ split-window -v -c "#{pane_current_path}"

      bind-key @ choose-tree 'join-pane -hs %%'
      bind-key \# choose-tree 'join-pane -s %%'

      bind-key Q choose-tree 'send-keys %%'

      bind-key \\ choose-session { switch-client -t "%1" }

      bind-key "'" last-window

      bind-key s capture-pane -e -b screenshot_raw\;\
          capture-pane -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'
      bind-key S capture-pane -e -S - -E - -b screenshot_raw\;\
          capture-pane -S - -E - -b screenshot_plain\;\
          save-buffer -b screenshot_raw 'tmux_screenshot_raw'\;\
          save-buffer -b screenshot_plain 'tmux_screenshot_plain'

      bind-key -T root C-PageUp copy-mode -eu

      bind-key -T copy-mode    WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode    WheelDownPane send-keys -X scroll-down
      bind-key -T copy-mode-vi WheelUpPane   send-keys -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down

      bind-key -T copy-mode    C-PageUp      send-keys -X page-up
      bind-key -T copy-mode-vi C-PageUp      send-keys -X page-up
      bind-key -T copy-mode    C-PageDown    send-keys -X page-down
      bind-key -T copy-mode-vi C-PageDown    send-keys -X page-down

      bind-key -T copy-mode    MouseDragEnd1Pane  send-keys -X copy-pipe-no-clear
      bind-key -T copy-mode-vi MouseDragEnd1Pane  send-keys -X copy-pipe-no-clear
    '';
  };
}
