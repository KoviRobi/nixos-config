{pkgs, config, ...}: {
  imports = [
    ./default.nix
  ];

  home.packages = import ../packages/base.nix {inherit pkgs config;};
}
