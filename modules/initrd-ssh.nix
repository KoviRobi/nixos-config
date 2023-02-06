{ config, lib, ... }:
let cfg = config.initrd-ssh;
in {
  options.initrd-ssh = with lib; {
    interface = mkOption {
      type = types.str;
      example = "eth0";
    };
    udhcpcExtraArgs = mkOption {
      type = types.listOf types.str;
      example = [ "-t 10" "-b" ];
      default = [ ];
    };
  };

  config = {
    boot.initrd.availableKernelModules = [ "e1000e" "r8169" ];
    networking.interfaces.${cfg.interface}.useDHCP = true;
    boot.initrd.network.udhcpc.extraArgs =
      [ "-x hostname:${config.networking.hostName}" ] ++ cfg.udhcpcExtraArgs;

    boot.initrd.network.enable = true;
    boot.initrd.network.ssh.enable = true;
    boot.initrd.network.ssh.authorizedKeys = import ../pubkeys.nix;
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
  };
}
