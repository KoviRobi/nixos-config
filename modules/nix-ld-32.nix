{ pkgs, lib, config, ... }:
let
  cfg = config.programs.nix-ld32;

  nix-ld32-libraries = pkgs.pkgsi686Linux.buildEnv {
    name = "ld-library-path";
    pathsToLink = [ "/lib" ];
    paths = map lib.getLib cfg.libraries;
    # TODO make glibc here configurable?
    postBuild = ''
      ln -s ${pkgs.pkgsi686Linux.stdenv.cc.bintools.dynamicLinker} $out/share/nix-ld32/lib/ld.so
    '';
    extraPrefix = "/share/nix-ld32";
    ignoreCollisions = true;
  };
in
{
  meta.maintainers = [ lib.maintainers.mic92 ];
  options.programs.nix-ld32 = {
    enable = lib.mkEnableOption ''nix-ld, Documentation: <https://github.com/Mic92/nix-ld>'';
    package = lib.mkPackageOption pkgs.pkgsi686Linux "nix-ld" { };
    libraries = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = "Libraries that automatically become available to all programs. The default set includes common libraries.";
      default = [ ];
      defaultText = lib.literalExpression "baseLibraries derived from systemd and nix dependencies.";
    };
  };

  config = lib.mkIf config.programs.nix-ld32.enable {
    environment.ldso32 = "${cfg.package}/libexec/nix-ld";

    environment.systemPackages = [ nix-ld32-libraries ];

    environment.pathsToLink = [ "/share/nix-ld32" ];

    environment.variables = {
      NIX_LD_i686_linux = "/run/current-system/sw/share/nix-ld32/lib/ld.so";
      NIX_LD_LIBRARY_PATH_i686_linux = "/run/current-system/sw/share/nix-ld32/lib";
    };

    # We currently take all libraries from systemd and nix as the default.
    # Is there a better list?
    programs.nix-ld32.libraries = with pkgs.pkgsi686Linux; [
      zlib
      zstd
      stdenv.cc.cc
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd
    ];
  };
}
