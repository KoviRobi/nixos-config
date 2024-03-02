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
      version = "unstable-2023-12-18";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-FvFQnu9idTEAQEzwLO87MyAZL6o7bookzStKGrXnGsI=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.29.0" = "sha256-59w3CFg+z7gM2Im2xJouJCWpkKAMT/dwlcyNDClKInw=";
          # "lsp-server-0.7.4" = "sha256-TEYr3dOEXBt714uKx1uEsI4pB1TkUjXazfN1Z8icyEU=";
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
