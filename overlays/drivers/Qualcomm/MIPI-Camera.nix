{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm MIPI Camera Driver";
  version = "1.1.0.60_A11";
  src = requireFile {
    url = "https://dl.dell.com/FOLDER13639308M/1/Qualcomm-MIPI-Camera-Driver_YY0GD_WINARM64_1.1.0.60_A11.EXE";
    name = "Qualcomm-MIPI-Camera-Driver_YY0GD_WINARM64_1.1.0.60_A11.EXE";
    sha256 = "48895953bd5fb95f2f66333acb96e717749e7a1e41cde76ee3510d20658b91d4";
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
