{ ... }:
let
  config = builtins.getEnv "NixOS_Configuration";
  target = builtins.getEnv "NixOS_Target";
in
{
  imports = [
    (./configurations + ("/" + config))
    (./targets + ("/" + target))
  ];

  environment.etc."nixos/configurations/default.nix" =
    { source = "/etc/nixos/configurations/${config}"; };
  environment.etc."nixos/targets/default.nix" =
    { source = "/etc/nixos/targets/${target}"; };
}
