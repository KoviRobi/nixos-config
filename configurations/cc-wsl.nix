# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports = [
    ./cc.nix
  ];

  services.udisks2.enable = true;

  nix.settings.trusted-substituters = (map
    (address:
      "ssh://nix-ssh@${address}"
        + "?trusted=1"
        + "&compress=1"
        + "&ssh-key=/root/.ssh/nix-store-ed25519"
        + "&base64-ssh-public-host-key="
        + "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU5JdW1pb2NMZEE5NExHa"
        + "E95WFM1Vko0d1hrQWh2S2JzK1NrTWtkQUh5Z3EK")
    [ "100.99.255.67" "rmk-cc-pc-nixos-a.uk.cambridgeconsultants.com" ]) ++ (map
    (address:
      "ssh://nix-ssh@${address}"
        + "?trusted=1"
        + "&compress=1"
        + "&ssh-key=/root/.ssh/nix-store-ed25519"
        + "&base64-ssh-public-host-key="
        + "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUZsY0FoNEdLN080cm55"
        + "S251TE81Nmt1UWZ6VkVyc1lDaVlPRVBKeEN0QUUgcm9vdEBybWstY2MtYgo=")
    [ "rmk-cc-b.badger-toad.ts.net" "rmk-cc-b.uk.cambridgeconsultants.com" ]);

  wsl.docker-desktop.enable = true;

  wsl.wslConf.network.generateHosts = false;

  home-manager.users.default-user.programs.starship.settings.shlvl.threshold = 2;

  # To setup:
  # 1. Install WireGuard on Windows
  # 2. Add an empty tunnel, call it WSL2-VPN
  # 3. Start/activate it
  # 4. Edit WSL2-VPN, copy public key
  # 5. Put public key to "/etc/secrets/wireguard/WSL2-VPN.HOST.pub"
  # 6. Start WSL service WSL2-VPN (the service defined below)
  # 7. Use `sudo wg` to get the WSL2 side public key
  # 8. Edit the tunnel in Windows, add the following
  #
  #    ```
  #    ListenPort = 65126
  #    Address = 10.0.0.1/24
  #
  #    [Peer]
  #    PublicKey = <key from previous step>
  #    AllowedIPs = 10.0.0.0/24
  #    ```
  #
  # 9. Run in Windows `Set-NetConnectionProfile -InterfaceAlias WSL2-VPN -NetworkCategory Private`
  environment.systemPackages = with pkgs; [ wireguard-tools ];
  systemd.services."WSL2-VPN" = {
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PassEnvironment = "WSL_INTEROP";
    };
    unitConfig = {
      ConditionPathExists = [ "/etc/secrets/wireguard/WSL2-VPN.HOST.pub" ];
    };
    wantedBy = [ "default.target" ];
    path = with pkgs; [ coreutils iproute2 jq wireguard-tools ];
    script = ''
      set -eux

      # The following files contain private keys
      umask 0077

      # Don't regenerate keys if not necessary, this helps keep the connection
      # when the unit is restarted
      WSLKEY=/etc/secrets/wireguard/WSL2-VPN.WSL.key
      test -f $WSLKEY || wg genkey > $WSLKEY

      HOSTPUB=/etc/secrets/wireguard/WSL2-VPN.HOST.pub

      if ! ip link show dev WSL2-VPN; then
        ip link add dev WSL2-VPN type wireguard
        ip addr add 10.0.0.2/24 dev WSL2-VPN
        ip link set dev WSL2-VPN up
      fi

      WSLPORT=55204
      WSLPUB=$(wg pubkey < $WSLKEY)

      HOST=$(ip -j route show default | jq -r '.[].gateway')
      HOSTPORT=65126

      wg set WSL2-VPN              \
        listen-port $WSLPORT       \
        private-key $WSLKEY        \
        peer $(cat $HOSTPUB)       \
          endpoint $HOST:$HOSTPORT \
          allowed-ips 10.0.0.0/24
    '';
  };

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = 10.0.0.1;
  '';
}
