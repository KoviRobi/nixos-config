final: prev:
{
  nu_scripts = final.fetchFromGitHub {
    owner = "KoviRobi";
    repo = "nu_scripts";
    rev = "git-alias-caret-prefix";
    sha256 = "sha256-ZIQ1TZQG8bmauxemrlov/VjiWPZWKoD8iyXNTEO4cfI=";
  };

  nushell =
    prev.nushell.overrideAttrs (oldAttrs: rec {
      pname = "nushell";
      version = "unstable-2023-03-10";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-ldc4bel1cHqYLderqHPMESD5cGLAJ0wVrmcEHPoUVFE=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
        outputHashes = {
          "nu-ansi-term-0.46.0" = "sha256-gx6DxsQYpxMee0bXKqD7VbRPQw1nunxoNxxzvfmm5gM=";
          "reedline-0.16.0" = "sha256-MmRxWUD0ZrED24uMp/h5JFmvKZciR/a2uF+xWngLyRM=";
        };
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });

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
