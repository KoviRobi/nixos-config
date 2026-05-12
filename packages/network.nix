{ pkgs, ... }:
{
  programs.tcpdump.enable = true;
  users.users.default-user.extraGroups = [ "pcap" ];
  environment.systemPackages = with pkgs; [
    wget
    netcat
    socat
    aria2
    rtorrent

    nmap

    dnsutils
    doggo

    bandwhich
    ddgr
    gping

    tcpdump
    libpcap

    dnsmasq
    dhcpcd

    upterm
  ];
}
