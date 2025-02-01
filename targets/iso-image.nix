{ self, nixpkgs }:
# nix build -f '<nixpkgs/nixos>' config.system.build.isoImage -I nixos-config=iso-image.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault mkForce;
in
{
  imports = [
    "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    "${nixpkgs}/nixos/modules/installer/scan/detected.nix"
    "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
    "${nixpkgs}/nixos/modules/profiles/base.nix"
  ];

  # Since it is a brand-new build
  system.stateVersion = lib.versions.majorMinor lib.version;

  environment = {
    etc = {
      nixos.source = self;
      # Because the above is in the nix store, so immutable
      "nixos/configurations/default.nix".enable = false;
      "nixos/targets/default.nix".enable = false;
    };

    # Tell the Nix evaluator to garbage collect more aggressively.
    # This is desirable in memory-constrained environments that don't
    # (yet) have swap set up.
    variables.GC_INITIAL_HEAP_SIZE = "1M";
  };

  isoImage = {
    # ISO naming.
    isoName = "${config.isoImage.isoBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.iso";

    volumeID = "NIXOS_ISO";

    squashfsCompression = "zstd -Xcompression-level 6";

    # EFI booting
    makeEfiBootable = true;

    # USB booting
    makeUsbBootable = true;
  };

  boot = {
    # Add Memtest86+ to the CD.
    loader.grub.memtest86.enable = true;

    postBootCommands = ''
      mkdir /mnt
    '';

    # Make the installer more likely to succeed in low memory
    # environments.  The kernel's overcommit heustistics bite us
    # fairly often, preventing processes such as nix-worker or
    # download-using-manifests.pl from forking even if there is
    # plenty of free memory.
    kernel.sysctl."vm.overcommit_memory" = "1";
  };

  # Enable in installer, even if the minimal profile disables it.
  documentation.enable = mkForce true;

  # Show the manual.
  documentation.nixos.enable = mkForce true;

  # Allow the user to log in without a password.
  users.users.default-user.initialPassword = "";
  users.users.root.initialPassword = "";

  # Automatically log in at the virtual consoles.
  services.mingetty.autologinUser = config.users.users.default-user.name;

  services.xserver.dpi = 72;

  # To speed up installation a little bit, include the complete
  # stdenv in the Nix store on the CD.
  system.extraDependencies = with pkgs; [
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
