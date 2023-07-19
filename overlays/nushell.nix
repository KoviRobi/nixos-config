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
        sha256 = "sha256-5qXAVESfn3i1SBGicgxqg5kcw589jf5GjGXoX5avgXE=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.21.0" = "sha256-WEzMmnVTL/7WY/ZpJyZXo4T5nXXi9VMdjAuKhz73Few=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
