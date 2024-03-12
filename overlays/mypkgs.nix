final: prev:
{
  pavucontrol = prev.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = (prev.st.override {
    extraLibs = [ final.gd ];
    patches = prev.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
      ../patches/st-0.8.5-worddelimiters.patch
      ../patches/st-0.8.5-netwmicon-v2.patch
      ../patches/st-0.8.5-desktopentry.patch
      ../patches/st-true-color.patch
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
}
