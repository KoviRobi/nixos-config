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
  inherit (lib) genAttrs attrNames;
  vlanNames = attrNames vlans;
  default-uid = toString config.users.users.default-user.uid;
  default-gid = toString config.users.groups.default-user.gid;
in
{
  networking = {
    useDHCP = true;
    useNetworkd = true;
    # Otherwise we get duplicate routes
    interfaces.${interface}.useDHCP = false;
    vlans = genAttrs vlanNames (name: {
      id = vlans.${name};
      inherit interface;
    });
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
    networks = genAttrs vlanNames (
      name:
      let
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
        inherit name;
        matchConfig.Kind = "vlan";
        linkConfig.ActivationPolicy = if activate then "up" else "manual";
        networkConfig = {
          Description = "Promethium ethernet split, ${name} vlan";
          DHCP = externalConfig;
          DHCPServer = !externalConfig;
          LLDP = activate;
          EmitLLDP = activate;
        };
        dhcpServerConfig = lib.optionalAttrs (!externalConfig && name != "netboot") {
          ServerAddress = "10.${toString vlans.${name}}.0.1/24";
        };
        address = lib.optional (name == "netboot") "172.30.0.2";
      }
    );
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
