args: {
  imports = [
    ./default.nix
  ];

  home.packages = import ../packages/base.nix args;
}
