# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  ...
}:

{
  home-manager = {
    useUserPackages = true;
    users.default-user =
      { ... }:
      {
        imports = [ ../home ];
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
        imports = [ ../home ];
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
