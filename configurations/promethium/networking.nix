{ lib, config, ... }:
let
  interface = "enp0s31f6";
  # VLAN ID 1 is for communicating to the management PC, and VLAN ID 4 is for
  # the Pi network
  vlans = {
    private = 1;
    carallon = 2;
    rnd = 3;
    pi = 4;
    manatee = 5;
    fiber = 6;
    netboot = 7;
  };
  macs = {
    carallon = "30:d0:42:ec:62:ef";
    rnd = "00:0a:cd:3e:4b:6a";
  };
  inherit (lib) genAttrs attrNames;
  vlanNames = attrNames vlans;
  default-uid = toString config.users.users.default-user.uid;
  default-gid = toString config.users.groups.default-user.gid;
in
{
  networking = {
    useDHCP = false;
    useNetworkd = true;

    # Otherwise we get duplicate routes
    interfaces.${interface}.useDHCP = false;

    vlans = genAttrs vlanNames (name: {
      id = vlans.${name};
      inherit interface;
    });

    bridges = genAttrs (map (name: "${name}-bridge") vlanNames) (
      bridge-name:
      let
        name = builtins.elemAt (builtins.match "(.*)-bridge" bridge-name) 0;
      in
      {
        interfaces = [ name ];
      }
    );

    # Override base-configuration.nix
    networkmanager.enable = lib.mkForce false;

    firewall.interfaces = {
      private.allowedUDPPorts = [
        67 # bootps
      ];
      pi.allowedUDPPorts = [
        67 # bootps
      ];
      netboot.allowedUDPPorts = [
        67 # bootps
        69 # tftp
        2049 # nfsv4
      ];
      netboot.allowedTCPPorts = [
        67 # bootps
        69 # tftp
        2049 # nfsv4
      ];
    };
  };
  systemd.network = {
    enable = true;

    netdevs = genAttrs (map (name: "40-${name}-bridge") vlanNames) (
      bridge-name:
      let
        name = builtins.elemAt (builtins.match "40-(.*)-bridge" bridge-name) 0;
      in
      {
        netdevConfig = {
          Name = "${name}-bridge";
          Kind = "bridge";
          MACAddress = macs.${name} or "none";
        };
      }
    );

    networks =
      genAttrs (map (name: "40-${name}") vlanNames) (
        systemd-name:
        let
          name = builtins.elemAt (builtins.match "40-(.*)" systemd-name) 0;
        in
        {
          inherit name;

          matchConfig.Kind = "vlan";
          networkConfig = {
            Description = "Promethium ethernet split, ${name} vlan";
            Bridge = "${name}-bridge";
          };
        }
      )
      // genAttrs (map (name: "40-${name}-bridge") vlanNames) (
        bridge-name:
        let
          name = builtins.elemAt (builtins.match "40-(.*)-bridge" bridge-name) 0;
          inherit (builtins) any;
          activate = any (n: n == name) [
            "pi"
            "private"
            "carallon"
            "netboot"
          ];
          externalConfig = any (n: name == n) [
            "carallon"
            "rnd"
          ];
        in
        {
          matchConfig.Name = "${name}-bridge";
          linkConfig = {
            ActivationPolicy = if activate then "up" else "manual";
          };
          networkConfig = {
            DHCP = externalConfig;
            DHCPServer = !externalConfig;
            LLDP = activate;
            EmitLLDP = activate;
          };
          dhcpServerConfig = lib.optionalAttrs (!externalConfig && name != "netboot") {
            ServerAddress = "10.${toString vlans.${name}}.0.1/24";
          };
          address = lib.optional (name == "netboot") "172.30.0.2/24";
        }
      )
      // {
        "40-${interface}".linkConfig.RequiredForOnline = "no";
      };
  };
  services.dnsmasq = {
    enable = true;
    settings = {
      bind-interfaces = true;
      listen-address = "172.30.0.2";
      port = 0;
      enable-tftp = true;
      tftp-root = "/srv/tftpboot";
      dhcp-range = [ "172.30.0.10,172.30.0.254" ];
      dhcp-option = [ "66,172.30.0.2" ];
    };
  };
  services.nfs = {
    server = {
      enable = true;
      createMountPoints = true;
      exports = ''
        /srv/nfs4        172.30.0.1/16(rw,sync,no_subtree_check,all_squash,anonuid=${default-uid},anongid=${default-gid})
      '';
    };
  };
}
