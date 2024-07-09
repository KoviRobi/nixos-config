final: prev: {
  libsigrok = prev.libsigrok.overrideAttrs (oldAttrs: {
    src = final.fetchgit {
      url = "git://sigrok.org/libsigrok";
      rev = "b503d24cdf56abf8c0d66d438ccac28969f01670";
      hash = "sha256-9EW0UCzU6MqBX6rkT5CrBsDkAi6/CLyS9MZHsDV+1IQ=";
    };
    nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.autoreconfHook ];
  });
  libsigrokdecode = prev.libsigrokdecode.overrideAttrs (oldAttrs: {
    src = final.fetchgit {
      url = "git://sigrok.org/libsigrokdecode";
      rev = "0235970293590f673a253950e6c61017cefa97df";
      hash = "sha256-NyETufyThvKMKujhbgZZw08CGIIrGLIIE8qPqNL5thQ=";
    };
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
