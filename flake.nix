{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-registry = {
      url = "github:NixOS/flake-registry";
      flake = false;
    };

    NixOS-WSL = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    go-catprinter = {
      url = "github:KoviRobi/go-catprinter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    feh-random-background = {
      url = "github:KoviRobi/feh-random-background";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      home-manager,
      flake-registry,
      NixOS-WSL,
      deploy-rs,
      nix-index-database,
      poetry2nix,
      go-catprinter,
      ...
    }@inputs:
    {

      overlays =
        let
          inherit (builtins)
            attrValues
            elemAt
            filter
            listToAttrs
            map
            mapAttrs
            match
            readDir
            ;
          get_nix_name =
            name:
            let
              m = match "^(.*)\.nix$" name;
            in
            if m == null then null else elemAt m 0;
          contents = attrValues (
            mapAttrs (name: type: {
              inherit name type;
              base = get_nix_name name;
            }) (readDir ./overlays)
          );
          nix_or_dirs = filter (attrs: attrs.base != null || attrs.type == "directory") contents;
          imported = map (attrs: {
            name = if attrs.type == "directory" then attrs.name else attrs.base;
            value = import (./overlays + ("/" + attrs.name));
          }) nix_or_dirs;
        in
        listToAttrs imported
        // {
          poetry2nix = poetry2nix.overlays.default;
          go-catprinter = final: prev: {
            go-catprinter = go-catprinter.packages.${final.stdenv.hostPlatform.system}.default;
          };
        };

      homeModules.simple = [
        ./home/direnv.nix
        ./home/git
        ./home/shell.nix
        ./home/gruvbox.nix
        ./home/tmux.nix
      ];

      homeModules.full = [ ./home ];

      legacyPackages = utils.lib.eachDefaultSystemMap (system: {
        nixpkgs = import nixpkgs {
          inherit system;
          overlays = builtins.attrValues self.overlays;
        };
      });

      packages = utils.lib.eachDefaultSystemMap (system: {
        neovim =
          let
            inherit (self.packages.${system}.homeConfigurations) simple;
          in
          simple.pkgs.writeShellScriptBin "neovim" ''
            XDG_CONFIG_HOME=${simple.config.home-files}/.config ${simple.pkgs.lib.getExe simple.config.programs.neovim.finalPackage} "$@"
          '';

        vim-plugins =
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          nixpkgs.lib.callPackagesWith (
            pkgs // { inherit (pkgs.vimUtils) buildVimPlugin; }
          ) ./home/neovim/myplugins.nix { };

        inherit (self.legacyPackages.${system}.nixpkgs) st;

        homeConfigurations =
          builtins.mapAttrs
            (
              name: value:
              home-manager.lib.homeManagerConfiguration {
                modules = value ++ [
                  ./home/neovim

                  {
                    kovirobi.neovim.enable = true;
                    home = {
                      username = "rmk";
                      homeDirectory = "/home/rmk";
                      stateVersion = "22.11";
                    };
                  }
                ];
                pkgs = self.legacyPackages.${system}.nixpkgs;
              }
            )
            {
              inherit (self.homeModules) simple full;
            };

        netboot =
          let
            inherit system;
            pkgs = self.legacyPackages.${system}.nixpkgs;
            netboot-system = self.nixosConfigurations.netboot;
            kernel-cmdline = [ "init=${toplevel}/init" ] ++ netboot-system.config.boot.kernelParams;
            inherit (netboot-system.config.system.build) kernel netbootRamdisk toplevel;
          in
          pkgs.writeShellApplication {
            name = "netboot";
            text = ''
              cat <<EOF
              Don't forget to open the following ports in the firewall:
              UDP: 67 69 4011
              TCP: 64172

              This can be done via

                  sudo iptables -I nixos-fw 1 -i enp4s0 -p udp -m udp --dport 67    -j nixos-fw-accept
                  sudo iptables -I nixos-fw 2 -i enp4s0 -p udp -m udp --dport 69    -j nixos-fw-accept
                  sudo iptables -I nixos-fw 3 -i enp4s0 -p udp -m udp --dport 4011  -j nixos-fw-accept
                  sudo iptables -I nixos-fw 4 -i enp4s0 -p tcp -m tcp --dport 64172 -j nixos-fw-accept

              (change enp4s0 to the interface you are using).

              And once you are done, closed via

                  sudo iptables -D nixos-fw -i enp4s0 -p udp -m udp --dport 67    -j nixos-fw-accept
                  sudo iptables -D nixos-fw -i enp4s0 -p udp -m udp --dport 69    -j nixos-fw-accept
                  sudo iptables -D nixos-fw -i enp4s0 -p udp -m udp --dport 4011  -j nixos-fw-accept
                  sudo iptables -D nixos-fw -i enp4s0 -p tcp -m tcp --dport 64172 -j nixos-fw-accept

              If you need to do DHCP also, consider

                  sudo ip addr add 192.168.10.1/24 dev enp4s0
                  sudo nix run 'nixpkgs#dnsmasq' -- \\
                    --interface enp4s0 \\
                    --dhcp-range 192.168.10.10,192.168.10.254 \\
                    --dhcp-leasefile=dnsmasq.leases \\
                    --no-daemon
              EOF
              nix run nixpkgs\#pixiecore -- \
                boot ${kernel}/bzImage ${netbootRamdisk}/initrd \
                --cmdline "${builtins.concatStringsSep " " kernel-cmdline}" \
                --debug --dhcp-no-bind --port 64172 --status-port 64172 \
                "$@"
            '';
          };

      });

      nixosConfigurations =
        builtins.mapAttrs
          (
            name: value:
            nixpkgs.lib.nixosSystem rec {
              system = "x86_64-linux";
              modules = value ++ [
                { networking.hostName = name; }

                # Let 'nixos-version --json' know about the Git revision
                # of this flake.
                # From https://www.tweag.io/blog/2020-07-31-nixos-flakes/
                {
                  system.configurationRevision = self.rev or (throw "Refusing to build from a dirty Git tree!");
                }

                { nixpkgs.overlays = builtins.attrValues self.overlays; }

                (
                  { config, pkgs, ... }:
                  {
                    nix = {
                      settings.experimental-features = [
                        "nix-command"
                        "flakes"
                      ];
                      # Pin nixpkgs for e.g. nix search
                      registry.nixpkgs.flake = nixpkgs;
                      registry.nixos-config.flake = self;

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

                      nixPath = [
                        "nixpkgs=${nixpkgs}"
                        "home-manager=${home-manager}"
                        "${nixpkgs}"
                      ];
                    };

                    environment.shellAliases.nixrepl = "nix repl --expr 'builtins.getFlake \"${self}\"'";
                  }
                )

                home-manager.nixosModules.home-manager
                (
                  { pkgs, ... }:
                  {
                    environment.systemPackages = [
                      home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager
                    ];
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                  }
                )

                nix-index-database.nixosModules.nix-index
              ];
              specialArgs = { inherit inputs; };
            }
          )
          {
            "pc-nixos-b" = [
              ./configurations/pc.nix
              ./targets/pc.nix
            ];
            "hp-nixos-a" = [
              ./configurations/hp.nix
              ./targets/hp.nix
            ];
            "acer-nixos-a" = [
              ./configurations/hp.nix
              ./targets/acer.nix
            ];
            "c930" = [
              ./configurations/yoga-book.nix
              ./targets/yoga-book-flash.nix
            ];
            "rmk-cc-pc-nixos-a" = [
              ./configurations/cc-pc.nix
              ./targets/cc-pc.nix
            ];
            "rmk-cc-b" = [
              ./configurations/cc-pc.nix
              ./targets/rmk-cc-b.nix
            ];
            "cc-wsl" = [
              NixOS-WSL.nixosModules.wsl
              ./configurations/cc-wsl.nix
              ./targets/wsl.nix
            ];
            "pc-wsl" = [
              NixOS-WSL.nixosModules.wsl
              ./configurations/pc-wsl.nix
              ./targets/wsl.nix
            ];
            "promethium-wsl" = [
              NixOS-WSL.nixosModules.wsl
              ./configurations/carallon-wsl.nix
              ./targets/wsl.nix
            ];
            "promethium-nix1" = [
              ./configurations/promethium.nix
              ./targets/promethium.nix
            ];
            "iso" = [
              ./configurations/cc.nix
              (import ./targets/iso-image.nix { inherit self nixpkgs; })
            ];
            "inspiron-wsl" = [
              NixOS-WSL.nixosModules.wsl
              ./configurations/inspiron-wsl.nix
              ./targets/wsl.nix
              { nixpkgs.system = "aarch64-linux"; }
            ];
            "inspiron" = [
              ./configurations/inspiron.nix
              ./targets/inspiron.nix
              { nixpkgs.system = "aarch64-linux"; }
            ];
          }
        // {
          "netboot" = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              "${nixpkgs}/nixos/modules/installer/netboot/netboot.nix"

              # Profiles of this basic netboot media
              "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
              "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
              (
                { pkgs, lib, ... }:
                {
                  system.extraDependencies = lib.mkForce [ ];
                  documentation.enable = lib.mkForce false;

                  netboot.squashfsCompression = "zstd -Xcompression-level 6";

                  users.users.nixos.openssh.authorizedKeys.keys = builtins.attrValues (import ./pubkeys.nix);

                  nix = {
                    settings = {
                      # To allow using custom substituters (e.g. netboot host)
                      trusted-users = [ "nixos" ];
                      flake-registry = "${flake-registry}/flake-registry.json";
                      experimental-features = [
                        "nix-command"
                        "flakes"
                      ];
                    };
                  };

                  environment.systemPackages = with pkgs; [
                    cryptsetup
                    gptfdisk
                    gitMinimal
                  ];
                }
              )
            ];
          };
        };

      deploy.nodes = {
        rmk-cc-pc-nixos-a = {
          sshUser = "rmk";
          sshOpts = [ "-tt" ];
          user = "root";
          hostname = "rmk-cc-pc-nixos-a.uk.cambridgeconsultants.com";
          profiles.system = {
            user = "rmk";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.rmk-cc-pc-nixos-a;
          };
        };

        c930 = {
          sshUser = "rmk";
          sshOpts = [ "-tt" ];
          user = "root";
          hostname = "10.42.0.229";
          profiles.system = {
            user = "rmk";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.c930;
          };
        };
      };
    };
}
