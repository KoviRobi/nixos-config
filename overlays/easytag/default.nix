final: prev: {
  easytag = prev.easytag.overrideAttrs (old: {
    CFLAGS =
      old.CFLAGS or ""
      + " -std=c11"
      + " -Wno-error=cast-function-type"
      + " -Wno-error=implicit-function-declaration"
      + " -Wno-error=array-bounds"
      + " -Wno-error=enum-conversion"
      + " -Wno-error=deprecated-declarations";
    CXXFLAGS = old.CXXFLAGS or "" + " -Wno-error=deprecated-declarations";
    patches = old.patches or [ ] ++ [
      ./0001-Fix-missing-strings.h-providing-strcasecmp.patch
      ./0002-Fix-missing-const-qualifier.patch
      (final.fetchpatch {
        url = "https://gitlab.gnome.org/GNOME/easytag/-/commit/d0c05132e6e32f907044fbe5ebd4fe90888b5010.patch";
        hash = "sha256-pr3enGztBn+uDUFO2S43utCWNxUQ0J5AMS72vasSlgc=";
      })
    ];
  });
}
