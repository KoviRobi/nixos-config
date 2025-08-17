final: prev: {
  tmux-easymotion-multipane = final.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-easymotion-multipane";
    rtpFilePath = "easymotion.tmux";
    version = "unstable-2025-08-01";
    src = final.fetchFromGitHub {
      owner = "KoviRobi";
      repo = "tmux-easymotion";
      rev = "07d61afe40e5b1d673e9774b04580c8bcd2afb43";
      hash = "sha256-g6krd/D7LLxOjGMqBHxCXBcZpezTL9ukeqVdOeeTsKc=";
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
