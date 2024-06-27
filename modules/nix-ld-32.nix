{ pkgs, lib, config, ... }:
let
  cfg = config.programs.nix-ld32;

  patchedPackage = cfg.package.overrideAttrs (old: {
    postPatch = old.postPatch or "" + ''
      find -type f | xargs sed -i 's/"NIX_LD/"NIX_LD32/g'
      find -type f | xargs sed -i 's|/run/current-system/sw/share/nix-ld|/run/current-system/sw/share/nix-ld32|g'
    '';
    doCheck = false;
  });

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
    environment.ldso32 = "${patchedPackage}/libexec/nix-ld";

    environment.systemPackages = [ nix-ld32-libraries ];

    environment.pathsToLink = [ "/share/nix-ld32" ];

    environment.variables = {
      NIX_LD32 = "/run/current-system/sw/share/nix-ld32/lib/ld.so";
      NIX_LD32_LIBRARY_PATH = "/run/current-system/sw/share/nix-ld32/lib";
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
