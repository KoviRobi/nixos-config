final: prev: {
  easytag = prev.easytag.overrideAttrs (old: {
    CFLAGS =
      old.CFLAGS or ""
      + " -std=c11"
      + " -Wno-error=pointer-compare"
      + " -Wno-error=cast-function-type"
      + " -Wno-error=implicit-function-declaration"
      + " -Wno-error=array-bounds"
      + " -Wno-error=enum-conversion"
      + " -Wno-error=deprecated-declarations";
    CXXFLAGS = old.CXXFLAGS or "" + " -Wno-error=deprecated-declarations";
    patches = old.patches or [ ] ++ [
      ./0001-Fix-missing-strings.h-providing-strcasecmp.patch
      ./0002-Fix-missing-const-qualifier.patch
    ];
  });
}
