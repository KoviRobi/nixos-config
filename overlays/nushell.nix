final: prev:
{
  nu_scripts = final.fetchFromGitHub {
    owner = "KoviRobi";
    repo = "nu_scripts";
    rev = "git-alias-caret-prefix";
    sha256 = "sha256-J4oQp3s+NcFexi3WuShvCS2SSNqFFFw54GtTpUf7cf8=";
  };

  nushell =
    prev.nushell.overrideAttrs (oldAttrs: rec {
      pname = "nushell";
      version = "unstable-2023-03-10";

      src = final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = pname;
        rev = "rob";
        sha256 = "sha256-2L+XeAujia+deiG19VtNWWC7oNKmjsl2egdYU3sqaJk=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
