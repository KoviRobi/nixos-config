self: super:
{
  linuxPackagesFor = kernel:
    (super.linuxPackagesFor kernel).extend (self': super': {
      yogabook-c930-eink-driver = self'.callPackage (self.fetchgit {
        url = "https://github.com/KoviRobi/yogabook-c930-linux-eink-driver";
        rev = "d990b6295034436c3ac8aa451526eb2864553d9b";
        sha256 = "0ysz0y0bxr17fpzys2k8a0frzb681g4qvdnm4i9arcqc38b61xha";
        fetchSubmodules = false;
    }) {};
  });
}
