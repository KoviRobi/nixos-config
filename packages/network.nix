{ pkgs, ... }:
{
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
    yt-dlp
  ];
}
