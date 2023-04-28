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
      version = "unstable-2023-03-10";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-UN0MPhmAlKCQl0Fhn+foTY9AOTJXqeRjkh/k0ADQJzo=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          # "reedline-0.18.0" = "sha256-icyWTGyZ7a5PIF80WXQOFU5RvbdGwgBqFdj5CjOPMiY=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
