{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm Audio Driver";
  version = "1.100.4293.6502_A12";
  src = requireFile {
    url = "https://dl.dell.com/FOLDER13611199M/1/Qualcomm-Audio-Driver_FJ44K_WINARM64_1.100.4293.6502_A12.EXE";
    name = "Qualcomm-Audio-Driver_FJ44K_WINARM64_1.100.4293.6502_A12.EXE";
    sha256 = "27ec2993b33130ba7a3167e921e59c5b7195eca72ac5d364b9428e54fd85ed89";
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
