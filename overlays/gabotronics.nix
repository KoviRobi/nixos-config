final: prev: {
  xscopes-qt =
    let
      pkg =
        { stdenv
        , fetchFromGitHub
        , cmake
        , pkg-config
        , wrapQtAppsHook
        , qtbase
        , qtserialport
        , libusb1
        }:
        stdenv.mkDerivation {
          pname = "xscopes-qt";
          version = "2021-11-02";
          src = fetchFromGitHub {
            owner = "ganzziani";
            repo = "xscopes-qt";
            rev = "d514ee9b4c8d3eacc8a0341ee2c6e19317df63dc";
            sha256 = "sha256-LTiCZBftArnNtE/Oj7gyT+LirwalNtpeyiIRKcJHJYk=";
          };

          patchPhase = ''
            runHook prePatch
            substituteInPlace CMakeLists.txt \
              --replace '/usr/bin' "/bin" \
              --replace '/lib/udev/rules.d/' "''${DESTDIR}/lib/udev/rules.d/"
            runHook postPatch
          '';

          cmakeFlags = [ "-DDESTDIR=${placeholder "out"}" ];

          nativeBuildInputs = [ cmake pkg-config wrapQtAppsHook ];
          buildInputs = [ qtbase qtserialport libusb1 ];
        };
      drv = final.qt5.callPackage pkg { };
    in
    drv;
}
