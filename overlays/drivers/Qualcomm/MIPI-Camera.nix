{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm MIPI Camera Driver";
  version = "1.1.0.63_A13";
  src = requireFile {
    url = "https://www.dell.com/support/product-details/en-uk/product/inspiron-14-7441-laptop/drivers";
    name = "Qualcomm-MIPI-Camera-Driver_1Y8F9_WINARM64_1.1.0.63_A13.EXE";
    sha256 = "98a11d93b42a41a52aa51eac8d249ae2a34fa0955e861f24b5289028941ff732";
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
