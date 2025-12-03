{
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/programs/helix.nix"
  ];
  programs.helix.enable = true;
  programs.helix.settings.theme = "solarized-light";
}
