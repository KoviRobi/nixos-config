# vim: set ts=2 sts=2 sw=2 et :
{ config, lib, pkgs, ... }:

{
  imports = [
    ./cc.nix
    ../modules/graphical.nix
  ];

  nix.settings.substituters = [ "ssh://nix-ssh@rmk-cc-pc-nixos-a.uk.cambridgeconsultants.com?trusted=1&ssh-key=/root/.ssh/nix-store-ed25519" ];

  wsl.wslConf.network.generateHosts = "false";

  programs.starship.settings.shlvl.threshold = 2;

  environment.systemPackages = with pkgs; [ wireguard-tools ];
  systemd.services."WSL2-VPN".serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = true;
    PassEnvironment = "WSL_INTEROP";
  };
  systemd.services."WSL2-VPN".wantedBy = [ "default.target" ];
  systemd.services."WSL2-VPN".path = with pkgs; [ coreutils iproute2 jq wireguard-tools ];
  systemd.services."WSL2-VPN".script = ''
    set -eux

    # The following files contain private keys
    umask 0077

    # Don't regenerate keys if not necessary, this helps keep the connection
    # when the unit is restarted
    WSLKEY=/etc/WSL2-VPN.WSL.key
    test -f $WSLKEY || wg genkey > $WSLKEY
    HOSTKEY=/etc/WSL2-VPN.HOST.key
    test -f $HOSTKEY || wg genkey > $HOSTKEY

    if ip link show dev WSL2-VPN; then
      ip link del dev WSL2-VPN
    fi
    ip link add dev WSL2-VPN type wireguard
    ip addr add 10.0.0.2/24 dev WSL2-VPN
    ip link set dev WSL2-VPN up

    WSL=$(ip -j addr | jq -r '.[] | select(.ifname == "eth0") | .addr_info[] | select(.family == "inet") | .local')
    WSLPORT=55204
    WSLPUB=$(wg pubkey < $WSLKEY)

    HOST=$(ip -j route show default | jq -r '.[].gateway')
    HOSTPORT=65126
    HOSTPUB=$(wg pubkey < $HOSTKEY)

    cat >/etc/WSL2-VPN.WSL.conf <<EOF
    [Interface]
    ListenPort = $WSLPORT
    PrivateKey = $(cat $WSLKEY)

    [Peer]
    PublicKey  = $HOSTPUB
    AllowedIPs = 10.0.0.0/24
    Endpoint   = $HOST:$HOSTPORT
    EOF

    cat >/etc/WSL2-VPN.HOST.conf <<EOF
    [Interface]
    ListenPort = $HOSTPORT
    PrivateKey = $(cat $HOSTKEY)
    # Address    = 10.0.0.1/24

    [Peer]
    PublicKey  = $WSLPUB
    AllowedIPs = 10.0.0.0/24
    Endpoint   = $WSL:$WSLPORT
    EOF

    wg setconf WSL2-VPN /etc/WSL2-VPN.WSL.conf

    /mnt/c/windows/System32/WindowsPowerShell/v1.0/powershell.exe -Command "& { \
      Start-Process \
      -FilePath 'C:\Program Files\WireGuard\wg.exe' \
      -Verb RunAs \
      -ArgumentList 'syncconf','WSL2-VPN.HOST','\\\\wsl\$\\NixOS\\etc\\WSL2-VPN.HOST.conf'
    }"
  '';

  systemd.user.services.pulseaudio.enable = false;
  hardware.pulseaudio.extraClientConf = ''
    default-server = 10.0.0.1;
  '';
}
