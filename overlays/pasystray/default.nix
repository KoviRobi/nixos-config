final: prev: {
  pasystray = prev.pasystray.overrideAttrs (old: {
    patches = old.patches or [ ] ++ [
      ./0001-Fix-pasystray-compilation.patch
      ./0002-Fix-pre-C23-any-type-headers.patch
    ];
  });
}
