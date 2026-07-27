{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm Chipset Driver";
  version = "2.1.0.35_A17";
  src = requireFile {
    url = "https://dl.dell.com/FOLDER13654064M/4/Qualcomm-Chipset-Driver_4RYYV_WINARM64_2.1.0.35_A17.EXE";
    name = "Qualcomm-Chipset-Driver_4RYYV_WINARM64_2.1.0.35_A17.EXE";
    sha256 = "094724765a4f0565bf6a7312e56d65558e3370d0e72c46cc52adbe61cc746ff6";
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
