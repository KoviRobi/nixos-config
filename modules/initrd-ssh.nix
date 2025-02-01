{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.initrd-ssh;
  udhcpcScript = pkgs.writeScript "udhcp-script" ''
    #! /bin/sh
    if [ "$1" = bound ]; then
      ip address add "$ip/$mask" dev "$interface"
      if [ -n "$mtu" ]; then
        ip link set mtu "$mtu" dev "$interface"
      fi
      if [ -n "$staticroutes" ]; then
        echo "$staticroutes" \
          | sed -r "s@(\S+) (\S+)@ ip route add \"\1\" via \"\2\" dev \"$interface\" ; @g" \
          | sed -r "s@ via \"0\.0\.0\.0\"@@g" \
          | /bin/sh
      fi
      if [ -n "$router" ]; then
        ip route add "$router" dev "$interface" # just in case if "$router" is not within "$ip/$mask" (e.g. Hetzner Cloud)
        ip route add default via "$router" dev "$interface"
      fi
      if [ -n "$dns" ]; then
        rm -f /etc/resolv.conf
        for server in $dns; do
          echo "nameserver $server" >> /etc/resolv.conf
        done
      fi
    fi
  '';
  udhcpcArgs =
    let
      chars = lib.strings.stringToCharacters config.networking.hostName;
      hexes = map (char: lib.toHexString (lib.strings.charToInt char)) chars;
    in
    toString (
      [
        "-x"
        "hostname:${lib.concatStrings hexes}"
      ]
      ++ cfg.udhcpcExtraArgs
    );
in
{
  options.initrd-ssh = with lib; {
    interface = mkOption {
      type = types.str;
      example = "eth0";
    };
    udhcpcExtraArgs = mkOption {
      type = types.listOf types.str;
      example = [
        "-t 10"
        "-b"
      ];
      default = [ ];
    };
  };

  config = {
    boot = {
      initrd = {
        kernelModules = [ "af_packet" ];
        availableKernelModules = [
          "e1000e"
          "r8169"
        ];
        network = {

          enable = true;
          ssh = {
            enable = true;
            authorizedKeys = builtins.attrValues (import ../pubkeys.nix);
            hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
          };
        };

        extraUtilsCommands = ''
          copy_bin_and_libs ${pkgs.klibc}/lib/klibc/bin.static/ipconfig
        '';

        preLVMCommands = ''
          # Bring up all interfaces.
          echo "bringing up network interface ${cfg.interface}..."
          ip link set "${cfg.interface}" up && ifaces="$ifaces ${cfg.interface}"

          # Acquire DHCP leases.
          echo "acquiring IP address via DHCP on ${cfg.interface}..."
          udhcpc --background -i ${cfg.interface} -O staticroutes --script ${udhcpcScript} ${udhcpcArgs} &
        '';

        postMountCommands = ''
          for iface in $ifaces; do
            ip address flush "$iface"
            ip link set "$iface" down
          done
        '';
      };
    };
    # Make sure ordinary users can't access initrd SSH host key
    fileSystems."/boot".options =
      if config.boot.loader.supportsInitrdSecrets then
        [ "fmask=0077" ]
      else
        throw ''
          Not building as bootloader doesn't support initrd secrets, private host key
          would be visible in the nix store
        '';
  };
}
