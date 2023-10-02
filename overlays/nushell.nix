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
        sha256 = "sha256-4FXmKL0hLInXdRPQSUkGbD1Us3Hr6bL7XgMDaV8H4S0=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.24.0" = "sha256-nFIioq2dHcHD7NaoNHF47f/TwzyPP6MEm3DOICCLx/U=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
