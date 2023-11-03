final: prev: {
  ripgrep =
    prev.ripgrep.overrideAttrs (oldAttrs: rec {
      pname = "ripgrep";
      version = "unstable-2023-10-10";

      src = final.fetchFromGitHub {
        owner = "BurntSushi";
        repo = pname;
        rev = "7099e174acbcbd940f57e4ab4913fee4040c826e";
        sha256 = "sha256-QlXgKcjxv/zuURhHz8f0Sc8ZDFMCiLUdxJt4s6HrpWs=";
      };

      doCheck = false;

      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = "${src}/Cargo.lock";
      };
    });
}
