self: super:
{
  linuxPackagesFor = kernel:
    (super.linuxPackagesFor kernel).extend (self': super': {
      yogabook-c930-eink-driver = self'.callPackage
        (self.fetchgit {
          url = "https://github.com/KoviRobi/yogabook-c930-linux-eink-driver";
          rev = "d990b6295034436c3ac8aa451526eb2864553d9b";
          sha256 = "0ysz0y0bxr17fpzys2k8a0frzb681g4qvdnm4i9arcqc38b61xha";
          fetchSubmodules = false;
        }) { };
    });

  pye-menu = self.callPackage
    (self.fetchgit {
      url = "https://github.com/KoviRobi/Pye-Menu.git";
      rev = "bbf1c268a7a3d9494c854e4d034b2af15aa0d1b2";
      sha256 = "0qjssnb62dryqj87rrlqyznv2wx02as6bp9xahpipwpsknwma1mz";
      fetchSubmodules = false;
    }) { };

  pavucontrol = super.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = super.st.override {
    patches = [
      ../patches/st-0.8.4-font-size.patch
      ../patches/st-0.8.4-solarized-swap.patch
    ];
  };
}
