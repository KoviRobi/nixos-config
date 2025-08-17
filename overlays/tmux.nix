final: prev: {
  tmux-easymotion-multipane = final.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-easymotion-multipane";
    rtpFilePath = "easymotion.tmux";
    version = "unstable-2025-08-01";
    src = final.fetchFromGitHub {
      owner = "ddzero2c";
      repo = "tmux-easymotion";
      rev = "156ac9881c51b5605d57c47077c2d1dfbab5881c";
      hash = "sha256-pYCwmUyqLtso0TtIJIIpZWRe8j5SJPg1tkdBiTUNDzU=";
    };
  };

  # Save ANSI screenshots/logs too
  tmux-logging = prev.tmuxPlugins.logging.overrideAttrs (old: {
    postPatch = old.postPatch or "" + ''
    sed -Ei 's/(.*tmux pipe-pane "exec cat.*)>> \$FILE"/\1 | tee \\"$FILE.ansi\\" >>\\"$FILE\\""/' \
        scripts/start_logging.sh
    sed -Ei 's/(.*tmux capture-pane)(.*) > "\''$\{file\}"/&\n\1 -e\2 > "''${file}.ansi"/' \
        scripts/screen_capture.sh
    '';
  });
}
