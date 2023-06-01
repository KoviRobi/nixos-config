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
        sha256 = "sha256-qUntgq0ZMNEY3d/RGIpZ6MEqtqC0DDIfaL6B0FB4ocw=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.19.2" = "sha256-oc+h5tCQ6QM9yXsSGPjXzoqMTgZdvh1eUqcY6s6+Sw0=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
