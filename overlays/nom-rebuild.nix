final: prev:
{
  nom-rebuild = final.nixos-rebuild.overrideAttrs (old: rec {
    name = "nom-rebuild";
    path = old.path + (final.lib.makeBinPath [ final.nix-output-monitor ]);
    src = final.substitute {
      src = old.src;
      substitutions = [
        "--replace" "nixos-rebuild" "nom-rebuild"
        "--replace" "nix-build" "nom-build"
        "--replace" "nix \"\${flakeFlags[@]}\" build" "nom build \"\${flakeFlags[@]}\""
      ];
    };
  });
}
