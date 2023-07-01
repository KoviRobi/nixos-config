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
        sha256 = "sha256-FBapIUCKzAzc1vtYl+G/DkJBrnaPra7kUXKuxIf4SAU=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          # "reedline-0.20.0" = "sha256-bgOH6MtPIsG6B5HIPP44Z7VeZkazrCVGGetHPtmUplA=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
