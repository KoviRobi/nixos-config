final: prev:
{
  nu_scripts = final.fetchFromGitHub {
    owner = "KoviRobi";
    repo = "nu_scripts";
    rev = "git-alias-caret-prefix";
    sha256 = "sha256-HOUsyiFe4qeuGgXzj4UkKNDTsdRYyHeTjUJdNrYYnGU=";
  };

  nushell =
    prev.nushell.overrideAttrs (oldAttrs: rec {
      pname = "nushell";
      version = "unstable-2023-09-15";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-L+S6oBbg2303j5lwtALQEWIgG7Gu7/e1TldGzz6qbMU=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.25.0" = "sha256-J6AtZXoV8sRGQ75xq3ReRt3Hjz09bWLFzUnFDYCKg7s=";
          # "uu_cp-0.0.21" = "sha256-tM8+M+6TrAL839HnvSPTe9is4fMoi4S/D0Kg/C0juK4=";
          # "uucore-0.0.21" = "sha256-tM8+M+6TrAL839HnvSPTe9is4fMoi4S/D0Kg/C0juK4=";
          # "uucore_procs-0.0.21" = "sha256-tM8+M+6TrAL839HnvSPTe9is4fMoi4S/D0Kg/C0juK4=";
          # "uuhelp_parser-0.0.21" = "sha256-tM8+M+6TrAL839HnvSPTe9is4fMoi4S/D0Kg/C0juK4=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
