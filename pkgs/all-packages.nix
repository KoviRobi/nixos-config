{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;
rec {
  myLinuxPackagesFor = kernel: lib.makeExtensible (self: with self; {
    callPackage = newScope self;

    inherit kernel;
    inherit (kernel) stdenv; # in particular, use the same compiler by default

    yogabook-c930-eink-driver = callPackage ./yogabook-c930-linux-eink-driver {};
  });

  linuxPackages = myLinuxPackagesFor pkgs.linux;
  linuxPackages_latest = myLinuxPackagesFor pkgs.linux_latest;
}
