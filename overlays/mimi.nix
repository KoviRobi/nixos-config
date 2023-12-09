final: prev: {
  mimi = final.stdenvNoCC.mkDerivation {
    name = "mimi";
    version = "unstable-2020-10-31";
    src = final.fetchFromGitHub {
      owner = "march-linux";
      repo = "mimi";
      rev = "c9ce95803e833cfa4d3321492b12745803fe1be0";
      hash = "sha256-Z3dol8TaWuuQK5o7/Otv3eJ+CrcV8xNePNrzx8CGS/4=";
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      cp xdg-open $out/bin/xdg-open
    '';
  };
}
