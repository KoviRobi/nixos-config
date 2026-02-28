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

  lua-language-server

  # JSON/YAML
  vscode-json-languageserver
  yaml-language-server

  neocmakelsp

  editorconfig-checker
]
