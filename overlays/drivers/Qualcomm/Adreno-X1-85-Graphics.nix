{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm Adreno X1-85 Graphics Driver";
  version = "31.0.121.0_A10";
  src = requireFile {
    url = "https://dl.dell.com/FOLDER13623365M/2/Qualcomm-Adreno-X1-85-Graphics-Driver_RT0DF_WINARM64_31.0.121.0_A10.EXE";
    name = "Qualcomm-Adreno-X1-85-Graphics-Driver_RT0DF_WINARM64_31.0.121.0_A10.EXE";
    sha256 = "45a4001614d8d40944e68fef93a8a0227d741eba09ca4f7baca62abe144aadb3";
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
