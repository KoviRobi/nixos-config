{
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs.url = "git+file:///home/rmk35/programming/nix/pkgs/unstable";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, home-manager }: {

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

    nixosConfigurations."pc-nixos-a" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          (import ./configurations/pc.nix)
          (import ./targets/pc.nix)

          # Let 'nixos-version --json' know about the Git revision
          # of this flake.
          # From https://www.tweag.io/blog/2020-07-31-nixos-flakes/
          {
            system.configurationRevision =
              if self ? rev
              then self.rev
              else throw "Refusing to build from a dirty Git tree!";
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }
        ];
    };
  };
}
