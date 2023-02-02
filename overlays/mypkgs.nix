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
        rev = "add-storing-and-setting-metadata";
        sha256 = "sha256-alMsAI+/VL61Zw/5VEUm8NB1zRgKiDs/QtLji9CNkig=";
      };

      cargoLock.lockFile = ./nushell-Cargo.lock;

      inherit (prev.nushell) cargoPatches nativeBuildInputs buildInputs
        buildFeatures doCheck checkPhase meta passthru;
    };
}
