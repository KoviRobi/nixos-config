# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  inputs,
  ...
}:

{
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useUserPackages = true;
    users.default-user =
      { ... }:
      {
        imports = [
          ../home
          "${inputs.feh-random-background}/home-manager-service.nix"
        ];
        nixos = {
          inherit (config.networking) hostName;
          services.xserver.dpi = config.services.xserver.dpi;
          inherit (config) fileSystems;
          users.users.default-user.uid = config.users.users.default-user.uid;
        };
      };
    users.root =
      { ... }:
      {
        imports = [
          ../home
          "${inputs.feh-random-background}/home-manager-service.nix"
        ];
        nixos = {
          inherit (config.networking) hostName;
          services.xserver.dpi = config.services.xserver.dpi;
          inherit (config) fileSystems;
          users.users.default-user.uid = config.users.users.root.uid;
        };
      };
    backupFileExtension = "~";
  };
}
