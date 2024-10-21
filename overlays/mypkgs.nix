final: prev:
{
  st = (prev.st.override {
    extraLibs = [ final.gd ];
    patches = prev.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
      ../patches/st-0.8.5-worddelimiters.patch
      ../patches/st-0.8.5-netwmicon-v2.patch
      ../patches/st-0.8.5-desktopentry.patch
      ../patches/st-true-color.patch
      ../patches/st-0.8.5-solarized-swap.patch
      ../patches/st-0.8.5-solarized-swap-default-light.patch
    ];
  }).overrideAttrs (attrs: {
    ICONSRC = "${final.paper-icon-theme}/share/icons/Paper/32x32/apps/utilities-terminal-alt.png";
    meta.priority = -10;
  });

  dhcp-helper = final.stdenv.mkDerivation rec {
    pname = "dhcp-helper";
    version = "1.2";
    src = final.fetchurl {
      url = "https://thekelleys.org.uk/dhcp-helper/${pname}-${version}.tar.gz";
      sha256 = "sha256-rp5YnsUPG1vjAufruBEa1zShHiQiqc9h0I94WOojZq0=";
    };
    makeFlags = [ "PREFIX=${placeholder "out"}" ];
  };

  zsh-manydots-magic = final.runCommand "zsh-manydots-magic" { } ''
    outdir=$out/share/zsh/site-functions/zsh-manydots-magic
    mkdir -p $outdir
    install ${final.fetchFromGitHub {
      owner = "knu";
      repo = "zsh-manydots-magic";
      rev = "4372de0718714046f0c7ef87b43fc0a598896af6";
      hash = "sha256-lv7e7+KBR/nxC43H0uvphLcI7fALPvxPSGEmBn0g8HQ=";
    }}/manydots-magic $outdir/manydots-magic.zsh
  '';

  pystack =
    let
      ppkgs = final.python3.pkgs;
    in
      ppkgs.buildPythonApplication rec {
        pname = "pystack";
        version = "1.4.1";
        src = final.fetchFromGitHub {
          owner = "bloomberg";
          repo = "pystack";
          rev = "v${version}";
          hash = "sha256-j+M7GgPUqVtHKkekr5MZXWsseAJtoHTzyCx+yRJk0V8=";
        };
        buildInputs = [ final.libdwarf final.elfutils ];
        nativeBuildInputs = [ final.pkg-config ];
        propagatedBuildInputs = [ ppkgs.pkgconfig ppkgs.cython ];
      };
}
