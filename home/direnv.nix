{
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/programs/direnv.nix"
  ];
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
