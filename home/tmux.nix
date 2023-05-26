{ pkgs, config, lib, ... }:
{
  systemd.user.services.tmux-server = lib.mkIf pkgs.hostPlatform.isLinux {
    Unit = {
      Description = "Tmux server";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      Type = "forking";
      ExecStart = "${pkgs.tmux}/bin/tmux -f ${config.xdg.configHome}/tmux/tmux.conf start-server";
      ExecStartPost = "${pkgs.tmux}/bin/tmux -f ${config.xdg.configHome}/tmux/tmux.conf new-session -d -s float atop";
      ExecStop = "${pkgs.tmux}/bin/tmux kill-server";
      Environment = [ "TMUX_TMPDIR=/run/user/${toString config.nixos.users.users.default-user.uid}" ];
      PassEnvironment = [ "PATH" "WSL_INTEROP" ];
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    terminal = "screen-256color";
    escapeTime = 0;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      copycat
      prefix-highlight
      sidebar
      urlview
      yank
      fpp
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
      set -g default-command nu
      set -g exit-empty off

      set -g renumber-windows on
      bind-key . command-prompt "swap-window -t '%%'"

      set -g history-limit 10000

      bind-key C new-window -c "#{pane_current_path}"

      # Tmux and I disagree on what is horizontal and what is vertical
      # I take the view that Vim does
      bind-key \\ split-window -h
      bind-key | split-window -h -c "#{pane_current_path}"
      bind-key - split-window -v
      bind-key _ split-window -v -c "#{pane_current_path}"

      bind-key @ choose-tree 'join-pane -hs %%'
      bind-key \# choose-tree 'join-pane -s %%'

      bind-key Q choose-tree 'send-keys %%'

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
