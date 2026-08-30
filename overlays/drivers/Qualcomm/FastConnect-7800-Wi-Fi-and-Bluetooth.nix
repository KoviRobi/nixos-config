{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm FastConnect 7800 Wi-Fi and Bluetooth Driver";
  version = "1.0.4610.7600_A13";
  src = requireFile {
    url = "https://www.dell.com/support/product-details/en-uk/product/inspiron-14-7441-laptop/drivers";
    name = "Qualcomm-FastConnect-7800-Wi-Fi-and-Bluetooth-Driver_D68GC_WINARM64_1.0.4610.7600_A13.EXE";
    sha256 = "702983640d6ea30cdb4b4a2fde616486050a76edd95a371b66a12ae56df0fe75";
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
