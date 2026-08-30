{
  stdenv,
  requireFile,
  binwalk,
  dtc,
  xz,
}:
stdenv.mkDerivation {
  pname = "Qualcomm Adreno X1-85 Graphics Driver";
  version = "31.0.160.0_A13";
  src = requireFile {
    url = "https://www.dell.com/support/product-details/en-uk/product/inspiron-14-7441-laptop/drivers";
    name = "Qualcomm-Adreno-X1-85-Graphics-Driver_3HD62_WINARM64_31.0.160.0_A13.EXE";
    sha256 = "866a16460c46c27d45c1be92d3e7e3796c5c0a4e1e3f4e050f9cd1bf5b71ccde";
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
