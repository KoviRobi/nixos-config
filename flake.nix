{
  inputs.nixpkgs.url = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.pye-menu.url = "github:KoviRobi/Pye-Menu";
  inputs.pye-menu.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager, pye-menu }: {

    devShell.x86_64-linux =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.mkShell {
        buildInputs = [
          pkgs.nixFlakes
        ];
      };

    nixosConfigurations = builtins.mapAttrs
      (name: value:
        nixpkgs.lib.nixosSystem
          {
            system = "x86_64-linux";
            modules =
              (map import value) ++ [
                { networking.hostName = name; }

                # Let 'nixos-version --json' know about the Git revision
                # of this flake.
                # From https://www.tweag.io/blog/2020-07-31-nixos-flakes/
                {
                  system.configurationRevision =
                    if self ? rev
                    then self.rev
                    else throw "Refusing to build from a dirty Git tree!";
                }

                ({ config, pkgs, ... }: {
                  # https://www.arcadianvisions.com/2021/nix-registry.html
                  nix.registry.nixpkgs = {
                    from = {
                      type = "indirect";
                      id = "nixpkgs";
                    };
                    to = {
                      type = "git";
                      url = "file:///nixpkgs";
                    };
                  };

                  nix.package = pkgs.nixFlakes;
                  nix.extraOptions = ''
                    experimental-features = nix-command flakes
                  '';

                  nix.nixPath = [
                    "nixpkgs=/nixpkgs"
                    "home-manager=${home-manager}"
                    "/nixpkgs"
                  ];
                })

                home-manager.nixosModule
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.extraSpecialArgs = { inherit pye-menu; };
                }
              ];
          }
      )
      {
        "as-nixos-b" = [ ./configurations/acer-as.nix ./configurations/acer-as.nix ];
        "pc-nixos-a" = [ ./configurations/pc.nix ./targets/pc.nix ];
        "cc-vm-nixos-a" = [ ./configurations/cc-vm.nix ./targets/cc-vm.nix ];
        "rmk-cc-pc-nixos-a" = [ ./configurations/cc-pc.nix ./targets/cc-pc.nix ];
      };
  };
}
