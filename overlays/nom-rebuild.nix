final: prev:
{
  nom-rebuild = (
    import
      (builtins.getFlake "github:KoviRobi/nixpkgs/d9461e3a3c31715c6475d7e366e36cf03fc43c5c")
      { inherit (final) system; }
  ).nixos-rebuild.overrideAttrs (_: {
    name = "nom-rebuild";
    nix3_build = "${final.nix-output-monitor}/bin/nom build";
    nix_build = "${final.nix-output-monitor}/bin/nom-build";
  });
}
