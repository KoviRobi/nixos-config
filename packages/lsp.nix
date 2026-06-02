{ pkgs, config, ... }:
with pkgs;
[
  # C/C++
  clang-tools
  ccls
  bear

  gopls

  nixd

  # Markdown
  mpls

  # Python
  ruff
  pyright
  black
  isort

  # Shell
  shfmt
  shellcheck
  bash-language-server

  lua-language-server

  # JSON/YAML
  vscode-json-languageserver
  yaml-language-server

  neocmakelsp

  editorconfig-checker
]
