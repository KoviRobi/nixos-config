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
      version = "unstable-2023-09-04";

      src = final.fetchFromGitHub {
        owner = "nushell";
        repo = pname;
        rev = "ce378a68a68eb9961ab2430bb8a0f32b4e15811c"; # main
        sha256 = "sha256-JwgtTkdZa/yenAE5V9WLefkdGgYCB7fxGIoB66i0UTY=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        outputHashes = {
          "reedline-0.23.0" = "sha256-wfJd6RyomkMjv2y0/rdwiP6dvw1WoY6En03/oN104o4=";
        };

        lockFile = "${src}/Cargo.lock";
      };

      buildFeatures = oldAttrs.buildFeatures or [ ] ++ [ "dataframe" ];
    });
}
