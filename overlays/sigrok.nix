final: prev: {
  libsigrok = prev.libsigrok.overrideAttrs (oldAttrs: {
    src = final.fetchgit {
      sha256 = "sha256-mdKhcHJYPAbXe/7zCrrZyej1gERdy97UMH2Fm/SJVE4=";
      url = "git://sigrok.org/libsigrok";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.autoreconfHook ];
  });

  libsigrok-pico = prev.libsigrok.overrideAttrs (oldAttrs: {
    src = final.fetchFromGitHub {
      owner = "pico-coder";
      repo = "libsigrok";
      rev = "7aa830f96d0d088e147ae30d2122c35539207dcc";
      sha256 = "sha256-mOcMXp/EpwGi34GBidEdGmIpG9lgaoAzr5C7x37ENNA=";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.autoreconfHook ];
  });

  sigrok-pico = prev.sigrok.override { libsigrok = final.libsigrok-pico; };
  sigrok-cli-pico = prev.sigrok-cli.override { libsigrok = final.libsigrok-pico; };
  pulseview-pico = prev.pulseview.override { libsigrok = final.libsigrok-pico; };
}
