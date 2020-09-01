# nix build -f '<nixpkgs/nixos>' config.system.build.isoImage -I nixos-config=iso-image.nix
{ config, lib, pkgs, ... }:
let mypkgs = import ./pkgs/all-packages.nix { nixpkgs = pkgs; };
  inherit (lib) mkOverride mkDefault mkForce;
in
{
  imports =
    [
      <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
      <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
      <nixpkgs/nixos/modules/installer/scan/detected.nix>
      <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      <nixpkgs/nixos/modules/profiles/all-hardware.nix>
      <nixpkgs/nixos/modules/profiles/base.nix>
    ];

  # Since it is a brand-new build
  system.stateVersion = lib.versions.majorMinor lib.version;

  environment.etc.nixos.source = "${builtins.fetchGit https://github.com/KoviRobi/nixos-config}";
  # Because the above is in the nix store, so immutable
  environment.etc."nixos/configurations/default.nix".enable = false;
  environment.etc."nixos/targets/default.nix".enable = false;

  # ISO naming.
  isoImage.isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

  isoImage.volumeID = "NIXOS_ISO";

  # EFI booting
  isoImage.makeEfiBootable = true;

  # USB booting
  isoImage.makeUsbBootable = true;

  # Add Memtest86+ to the CD.
  boot.loader.grub.memtest86.enable = true;

  boot.postBootCommands = ''
    mkdir /mnt
  '';

  # Enable in installer, even if the minimal profile disables it.
  documentation.enable = mkForce true;

  # Show the manual.
  documentation.nixos.enable = mkForce true;
  services.nixosManual.showManual = true;

  # Allow the user to log in without a password.
  users.users.rmk35.initialHashedPassword = "";
  users.users.rmk35.openssh.authorizedKeys.keyFiles = [ ~/.ssh/id_rsa.pub ];
  users.users.root.initialHashedPassword = "";

  # Allow passwordless sudo from wheel users
  security.sudo = {
    enable = mkDefault true;
    wheelNeedsPassword = mkForce false;
  };

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = "rmk35";

  # Some more help text.
  services.mingetty.helpLine = ''
    The "rmk35" and "root" accounts have empty passwords.

    Type `sudo systemctl start sshd` to start the SSH daemon.
    You then must set a password for either "root" or "rmk35"
    with `passwd` to be able to login.
  '' + lib.optionalString config.services.xserver.enable ''
    Type `sudo systemctl start display-manager' to
    start the graphical user interface.
  '';

  # Allow sshd to be started manually through "systemctl start sshd".
  security.pam.services.sshd.googleAuthenticator.enable = lib.mkForce false;
  services.openssh =
    {
      enable = true;
      permitRootLogin = "no";
      extraConfig = lib.mkForce "";
    };
  systemd.services.sshd.wantedBy = mkOverride 50 [ ];

  # Tell the Nix evaluator to garbage collect more aggressively.
  # This is desirable in memory-constrained environments that don't
  # (yet) have swap set up.
  environment.variables.GC_INITIAL_HEAP_SIZE = "1M";

  # Make the installer more likely to succeed in low memory
  # environments.  The kernel's overcommit heustistics bite us
  # fairly often, preventing processes such as nix-worker or
  # download-using-manifests.pl from forking even if there is
  # plenty of free memory.
  boot.kernel.sysctl."vm.overcommit_memory" = "1";

  # To speed up installation a little bit, include the complete
  # stdenv in the Nix store on the CD.
  system.extraDependencies = with pkgs;
    [
      stdenv
      stdenvNoCC # for runCommand
      busybox
      jq # for closureInfo
    ];

  # Show all debug messages from the kernel but don't log refused packets
  # because we have the firewall enabled. This makes installs from the
  # console less cumbersome if the machine has a public IP.
  networking.firewall.logRefusedConnections = mkDefault false;
}
