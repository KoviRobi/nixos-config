{
  inputs.nixpkgs.url = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.pye-menu.url = "github:KoviRobi/Pye-Menu";
  inputs.pye-menu.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;

  outputs = { self, nixpkgs, home-manager, pye-menu, flake-compat }: {

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

    homeConfigurations = {
      "rmk@cc-wsl" = home-manager.lib.homeManagerConfiguration {
        configuration = {
          imports = [ ./home ];
          nixpkgs.overlays = map
            (x: import (./overlays + ("/" + x)))
            (with builtins; attrNames (readDir ./overlays));
          nixos = {
            services.xserver.dpi = 100;
            fileSystems = { "/" = { }; };
            users.users.default-user.uid = 1000;
          };
        };
        system = "x86_64-linux";
        homeDirectory = "/home/rmk";
        username = "rmk";
        stateVersion = "21.05";
        extraSpecialArgs = { inherit pye-menu; };
      };
    };

    nixosConfigurations = builtins.mapAttrs
      (name: value:
        nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          modules =
            value ++ [
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
                nix.package = pkgs.nixFlakes;
                nix.extraOptions = ''
                  experimental-features = nix-command flakes
                '';
                # Pin nixpkgs for e.g. nix search
                nix.registry.nixpkgs.flake = nixpkgs;

                # ~/.config/nix/registry.json, if you want to use a local
                # checkout:
                #
                #     {
                #       "flakes": [
                #         {
                #           "exact": true,
                #           "from": {
                #             "id": "nixpkgs",
                #             "type": "indirect"
                #           },
                #           "to": {
                #             "type": "git",
                #             "url": "file:///nix/pkgs"
                #           }
                #         }
                #       ],
                #       "version": 2
                #     }

                nix.nixPath = [
                  "nixpkgs=${nixpkgs}"
                  "home-manager=${home-manager}"
                  "${nixpkgs}"
                ];
              })

              home-manager.nixosModule
              {
                environment.systemPackages = [ home-manager.defaultPackage.${system} ];
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit pye-menu; };
              }
            ];
        }
      )
      {
        "pc-nixos-a" = [ ./configurations/pc.nix ./targets/pc.nix ];
        "rmk-cc-pc-nixos-a" = [ ./configurations/cc-pc.nix ./targets/cc-pc.nix ];
        "cc-wsl" = [ ./configurations/cc-wsl.nix ./wsl-modules ./targets/wsl.nix ];
        "pc-wsl" = [ ./configurations/pc-wsl.nix ./wsl-modules ./targets/wsl.nix ];
        "iso" = [ ./configurations/cc.nix (import ./targets/iso-image.nix { inherit self nixpkgs; }) ];
      };
  };
}
