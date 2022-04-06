self: super:
{
  pye-menu = self.callPackage
    (self.fetchgit {
      url = "https://github.com/KoviRobi/Pye-Menu.git";
      rev = "bbf1c268a7a3d9494c854e4d034b2af15aa0d1b2";
      sha256 = "0qjssnb62dryqj87rrlqyznv2wx02as6bp9xahpipwpsknwma1mz";
      fetchSubmodules = false;
    })
    { };

  pavucontrol = super.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = super.st.override {
    patches = super.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
    ];
  };
}
