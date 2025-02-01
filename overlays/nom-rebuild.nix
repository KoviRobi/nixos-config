final: prev: {
  nom-rebuild = final.nixos-rebuild.overrideAttrs (old: {
    name = "nom-rebuild";
    src = final.substitute {
      inherit (old) src;
      substitutions = [
        "--replace"
        "nixos-rebuild"
        "nom-rebuild"
        "--replace"
        "nix-build"
        "${final.nix-output-monitor}/bin/nom-build"
        "--replace"
        "nix \"\${flakeFlags[@]}\" build"
        "${final.nix-output-monitor}/bin/nom build \"\${flakeFlags[@]}\""
      ];
    };
  });
}
