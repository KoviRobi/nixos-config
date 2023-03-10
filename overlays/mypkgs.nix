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
      self = prev.nushell.override {
        sdk = prev.darwin.apple_sdk_11_0.MacOSX-SDK;
        inherit (prev.darwin.apple_sdk_11_0.frameworks) AppKit Foundation Security;
      };
    in
    rustPlatform.buildRustPackage rec {
      pname = "nushell";
      version = "unstable-2023-02-02";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-NhXKRox8spyI9nyHifgYnO2LctfTDBYwEAQP4Sl+k0g=";
      };

      cargoLock = {
        lockFile = ./nushell-Cargo.lock;
        outputHashes = {
          "reedline-0.15.0" = "sha256-Ju9dg4ZmzwkUux574tXtxIxLrY3J5e7Vx8Dv/uPX/8A=";
        };
      };

      buildFeatures = prev.nushell.buildFeatures ++ [ "dataframe" ];

      inherit (prev.nushell) cargoPatches nativeBuildInputs buildInputs
        doCheck checkPhase meta passthru;
    };

  dhcp-helper = final.stdenv.mkDerivation rec {
    pname = "dhcp-helper";
    version = "1.2";
    src = final.fetchurl {
      url = "https://thekelleys.org.uk/dhcp-helper/${pname}-${version}.tar.gz";
      sha256 = "sha256-rp5YnsUPG1vjAufruBEa1zShHiQiqc9h0I94WOojZq0=";
    };
    makeFlags = [ "PREFIX=${placeholder "out"}" ];
  };
}
