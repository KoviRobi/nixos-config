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
        sha256 = "sha256-zIx5uq2CdyMbe2hu6irzXNONDOpinLob3Sfs3bRPn34=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.21.0" = "sha256-sDt7jL/U110Yytc81gKcGRZLfaqAo4CXqR86YOtqGlc=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
