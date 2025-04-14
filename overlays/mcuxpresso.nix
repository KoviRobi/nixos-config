final: prev:
let
  pname = "mcuxpressoide";
  version = "24.9.25";
  description = "MCUXpresso IDE";
  filename = "${pname}-${version}.x86_64.deb";

  src = final.stdenv.mkDerivation {
    inherit version description;
    name = "${pname}-src";
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
      mv ./usr/local/${pname}-${version}/ide/* ./usr/local/${pname}-${version}/ide/.* final/eclipse
      mv final/eclipse/mcuxpressoide final/eclipse/eclipse
      mv final/eclipse/mcuxpressoide.ini final/eclipse/eclipse.ini

      # Create custom .eclipseproduct file
      rm final/eclipse/.eclipseproduct
      echo "name=${pname}
      id=com.nxp.${pname}
      version=${version}
      " > final/eclipse/.eclipseproduct

      # Install udev rules
      mkdir -p final/lib/udev/rules.d
      mv ./lib/udev/rules.d/56-pemicro.rules ./lib/udev/rules.d/85-mcuxpresso.rules final/lib/udev/rules.d/

      # Additional files
      mv ./usr/local/${pname}-${version}/mcu_data final/mcu_data

      cd ./final
      tar -czf $out ./
    '';
  };

  mcuxpresso = final.pkgs.eclipses.buildEclipse {
    inherit pname description src;
  };
in
{
  mcuxpresso = final.stdenv.mkDerivation {
    inherit pname version description;
    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${mcuxpresso}/bin/eclipse $out/bin/mcuxpresso
    '';
  };
}
