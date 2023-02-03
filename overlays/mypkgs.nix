final: prev:
{
  pavucontrol = prev.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = (prev.st.override {
    extraLibs = [ final.gd ];
    patches = prev.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
      ../patches/st-0.8.5-worddelimiters.patch
      ../patches/st-0.8.5-netwmicon-v2.patch
      ../patches/st-0.8.5-desktopentry.patch
    ];
  }).overrideAttrs (attrs: {
    ICONSRC = "${final.paper-icon-theme}/share/icons/Paper/32x32/apps/utilities-terminal-alt.png";
  });

  nu_scripts = final.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "3334cad9aaad4da6d902645e936e5fbbd8c4cbcf";
    sha256 = "sha256-HuvHMREsyjgMELOWsgWogXs5WI6Ea84rA+W699XbAa8=";
  };

  nushell =
    let
      inherit (final) lib stdenv rustPlatform;
    in
    rustPlatform.buildRustPackage rec {
      pname = "nushell";
      version = "unstable-2023-02-02";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "a90e5967ec611956dd7d093b5cd659c45e52147d";
        sha256 = "sha256-l+0oEkp4iXrRRTR+v3sNDdF78k2zTeHoHwnBUa1s5gM=";
      };

      cargoLock = {
        lockFile = ./nushell-Cargo.lock;
        outputHashes = {
          "reedline-0.15.0" = "sha256-Ju9dg4ZmzwkUux574tXtxIxLrY3J5e7Vx8Dv/uPX/8A=";
        };
      };

      inherit (prev.nushell) cargoPatches nativeBuildInputs buildInputs
        buildFeatures doCheck checkPhase meta passthru;
    };
}
