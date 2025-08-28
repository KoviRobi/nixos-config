{ pkgs, config, ... }:
with pkgs;
[
  # C/C++
  clang-tools
  ccls

  gopls

  # Markdown
  marksman
  mpls

  # Python
  ruff
  pyright
  black
  isort

  # Shell
  shfmt
  shellcheck

  # JSON/YAML
  vscode-json-languageserver
  yaml-language-server

  neocmakelsp

  editorconfig-checker
]
