{ config, ... }:
{
  boot.initrd.availableKernelModules = [ "e1000e" "r8169" ];
  networking.interfaces.eno1.useDHCP = true;
  boot.initrd.network.udhcpc.extraArgs = [ "-t 10" "-x hostname:rmk-nixos-a" ];

  boot.initrd.network.enable = true;
  boot.initrd.network.ssh.enable = true;
  boot.initrd.network.ssh.authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILaP5itEgT3/sUeln+cvaIfBznr4e17cjXgCP6X63GYD rmk@cc-nixos-a;ed25519"
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
