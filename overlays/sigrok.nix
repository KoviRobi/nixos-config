final: prev: {
  libsigrok = prev.libsigrok.overrideAttrs (oldAttrs: {
    src = final.fetchgit {
      url = "git://sigrok.org/libsigrok";
      rev = "fd2a8a5056aabd4231a1b0f3c72c70dab8207f26";
      sha256 = "sha256-kVrDeDaCJA2C/gNiMNkcoDl8PNA/27ymUfG7XAbNVyk=";
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
