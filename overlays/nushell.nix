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
        sha256 = "sha256-K4jRdArekOEwcntvNOr0YwECqVkaGxDC9b2gTUnSXGQ=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.19.0" = "sha256-izwaRuQRN+sSFcbk10NG5QpOmy4UPVc6nc5jhB4QqaE=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
