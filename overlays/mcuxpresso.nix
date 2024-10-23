final: prev:
let
  name = "mcuxpressoide";
  version = "24.9.25";
  description = "MCUXpresso IDE";
  filename = "${name}-${version}.x86_64.deb";

  src = final.stdenv.mkDerivation {
    inherit version description;
    name = "${name}-src";
    src = final.requireFile {
      url = "https://www.nxp.com/design/software/development-software/mcuxpresso-software-and-tools-/mcuxpresso-integrated-development-environment-ide:MCUXpresso-IDE";
      name = "${filename}.bin";
      hash = "sha256-e3g7rzZQ1WFLcUakkjaufpHMtw3qkw5lwxJuCKs6L+k=";
    };

    buildCommand = ''
      # Unpack tarball.
      mkdir -p deb
      sh $src --target deb || true
      ar -xv deb/${filename}
      tar xfvz data.tar.gz -C .

      mkdir -p ./final/eclipse
      mv ./usr/local/${name}-${version}/ide/* ./usr/local/${name}-${version}/ide/.* final/eclipse
      mv final/eclipse/mcuxpressoide final/eclipse/eclipse
      mv final/eclipse/mcuxpressoide.ini final/eclipse/eclipse.ini

      # Create custom .eclipseproduct file
      rm final/eclipse/.eclipseproduct
      echo "name=${name}
      id=com.nxp.${name}
      version=${version}
      " > final/eclipse/.eclipseproduct

      # Install udev rules
      mkdir -p final/lib/udev/rules.d
      mv ./lib/udev/rules.d/56-pemicro.rules ./lib/udev/rules.d/85-mcuxpresso.rules final/lib/udev/rules.d/

      # Additional files
      mv ./usr/local/${name}-${version}/mcu_data final/mcu_data

      cd ./final
      tar -czf $out ./
    '';
  };

  mcuxpresso = final.pkgs.eclipses.buildEclipse {
    name = "${name}-eclipse";
    inherit description src;
  };
in
{
  mcuxpresso = final.stdenv.mkDerivation {
    inherit name version description;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${mcuxpresso}/bin/eclipse $out/bin/mcuxpresso
    '';
  };
}
