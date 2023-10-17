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
        sha256 = "sha256-7BsxbNXzog3ClRd/RMkTlTw/Bj6JfJRmkdikXBxMyyM=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          # "reedline-0.24.0" = "sha256-nFIioq2dHcHD7NaoNHF47f/TwzyPP6MEm3DOICCLx/U=";
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
