{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm FastConnect 7800 Wi-Fi and Bluetooth Driver";
  version = "1.0.4392.1500_A10";
  src = requireFile {
    url = "https://dl.dell.com/FOLDER13711958M/3/Qualcomm-FastConnect-7800-Wi-Fi-and-Bluetooth-Driver_R84JF_WINARM64_1.0.4392.1500_A10.EXE";
    name = "Qualcomm-FastConnect-7800-Wi-Fi-and-Bluetooth-Driver_R84JF_WINARM64_1.0.4392.1500_A10.EXE";
    sha256 = "d9d0afb6d25e231e37668b2593445aa7083367956a50af91a8b2a86f1b09f5ba";
  };
  nativeBuildInputs = [
    binwalk
    dtc
    xz
  ];
  unpackPhase = ''
    mkdir -p extracted/
    binwalk --extract --matryoshka $src --directory extracted/
  '';
  installPhase = ''
    mkdir -p $out/lib/firmware/qcom/x1e80100/dell/inspiron-14-plus-7441/
    find extracted/ -type f -exec \
      mv {} $out/lib/firmware/qcom/x1e80100/dell/inspiron-14-plus-7441/ \;
  '';
}
