{ pkgs, config, ... }:
{
  imports = [
    ./default.nix
    ./x11/ghostty.nix
  ];

  home.packages = import ../packages/base.nix { inherit pkgs config; };
}
