final: prev: {
  abduco = prev.abduco.overrideAttrs (old: {
    patches = [
      ./0001-https-github.com-martanne-abduco-pull-22.patch
      ./0002-Exit-code-when-attaching-to-dead-session.patch
      ./0003-report-pixel-sizes-to-child-processes.patch
    ];
    src = final.fetchFromGitHub {
      owner = "legionus";
      repo = "abduco";
      rev = "7cd94a1eee48ed596a37d17034535beadda8e54a";
      hash = "sha256-PDJtSbz5uwdQRQ6Sapahi9hkzRVM9nDmut80tP7+YxA=";
    };
  });
}
