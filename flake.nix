{
  inputs.nixpkgs.url = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.pye-menu.url = "github:KoviRobi/Pye-Menu";
  inputs.pye-menu.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-compat.url = "github:edolstra/flake-compat";
  inputs.flake-compat.flake = false;

  outputs = { self, nixpkgs, home-manager, pye-menu, flake-compat }: {

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

    packages.x86_64-linux.netboot =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
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

              sudo nix run nixpkgs\#dnsmasq -- \\
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

                environment.shellAliases.nixrepl =
                  "nix repl --expr 'builtins.getFlake \"${self}\"'";
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
        "netboot" = [
          "${nixpkgs}/nixos/modules/installer/netboot/netboot-minimal.nix"
          ({ pkgs, ... }: {
            users.users.nixos.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG9Dg3j/KJgDbtsUSyOJBF7+bQzfDQpLo4gqDX195rJ rmk@rmk-cc-pc-nixos-a"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxS1hIoi4jj4h00KoIfBJJX6aMF5TtdZZxBOqLRRKCH rmk35@pc-nixos-a"
            ];
            nix.settings.flake-registry = "${builtins.fetchGit {
              url = "https://github.com/NixOS/flake-registry";
              rev = "8634fb4e1db6c76ce037bc00ef80f9ebd2616476";
            }}/flake-registry.json";
            environment.systemPackages = with pkgs; [ git ];
          })
        ];
        "pc-nixos-a" = [ ./configurations/pc.nix ./targets/pc.nix ];
        "rmk-cc-pc-nixos-a" = [ ./configurations/cc-pc.nix ./targets/cc-pc.nix ];
        "cc-wsl" = [ ./configurations/cc-wsl.nix ./wsl-modules ./targets/wsl.nix ];
        "pc-wsl" = [ ./configurations/pc-wsl.nix ./wsl-modules ./targets/wsl.nix ];
        "iso" = [ ./configurations/cc.nix (import ./targets/iso-image.nix { inherit self nixpkgs; }) ];
      };
  };
}
