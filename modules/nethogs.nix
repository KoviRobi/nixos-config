{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ nethogs ];
  security.wrappers.nethogs = {
    owner = "root";
    group = "root";
    source = "${pkgs.nethogs}/bin/nethogs";
    capabilities = "cap_net_raw,cap_net_admin=eip";
  };
}
