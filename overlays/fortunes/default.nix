final: prev: {
  jargon-cookie = final.runCommand "jargon-cookie" { } ''
  '';

  apf2cookie = final.poetry2nix.mkPoetryApplication { projectDir = ./src; };

  apf = final.fetchurl {
    url = "https://www.lspace.org/ftp/words/apf/apf";
    hash = "sha256-nRVFkWMm/Melf6zARlwZelHFM/XeVlZWvWV4JJo7Gk8=";
  };

  apf-cookie =
    let
      pname = "apf-cookie";
      version = "9.0.6";
      nativeBuildInputs = [ final.buildPackages.apf2cookie final.buildPackages.fortune ];
    in
    final.runCommand "${pname}-${version}" { inherit nativeBuildInputs; } ''
      apf2cookie ${final.apf} > apf-cookie
      strfile             apf-cookie
      mkdir -p                     "$out/share/games/fortunes"
      cp apf-cookie apf-cookie.dat "$out/share/games/fortunes"
    '';
}
