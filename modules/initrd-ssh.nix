{ config, wan-nic, ... }:
{
  boot.initrd.availableKernelModules = [ "e1000e" "r8169" ];
  networking.interfaces.enp34s0.useDHCP = true;
  boot.initrd.network.udhcpc.extraArgs = [ "-b" "-x hostname:${config.networking.hostName}" ];

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfojmpABobr3CEgN3eCu3mEqpr3oAs2h5NfY1ZtppIK ccl\rmk@RMKW10L2"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJCjMm+GhqvoboXvOJO/MuLccb606oJyHYyL4Mo3kuLO u0_a301@Legion Duel"
  ];
  boot.initrd.network.ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  # Make sure ordinary users can't access initrd SSH host key
  fileSystems."/boot".options =
    if config.boot.loader.supportsInitrdSecrets
    then [ "fmask=0077" ]
    else
      throw ''
        Not building as bootloader doesn't support initrd secrets, private host key
        would be visible in the nix store
      '';
}
