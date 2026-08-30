{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm Chipset Driver";
  version = "2.1.0.36_A18";
  src = requireFile {
    url = "https://www.dell.com/support/product-details/en-uk/product/inspiron-14-7441-laptop/drivers";
    name = "Qualcomm-Chipset-Driver_Y9XHN_WINARM64_2.1.0.36_A18.EXE";
    sha256 = "7a36e95c382b59710398f20f8679e2b25fcbf1b0efbdd3e23a8ad980f3d78a14";
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
