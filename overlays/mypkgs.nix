self: super:
{
  pavucontrol = super.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = (super.st.override {
    extraLibs = [ self.gd ];
    patches = super.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
      ../patches/st-0.8.5-worddelimiters.patch
      ../patches/st-0.8.5-netwmicon-v2.patch
      ../patches/st-0.8.5-desktopentry.patch
    ];
  }).overrideDerivation (oldDrv: {
    ICONSRC = "${self.paper-icon-theme}/share/icons/Paper/32x32/apps/utilities-terminal-alt.png";
  });

  nu_scripts = super.fetchFromGitHub {
    owner = "nushell";
    repo = "nu_scripts";
    rev = "3334cad9aaad4da6d902645e936e5fbbd8c4cbcf";
    sha256 = "sha256-HuvHMREsyjgMELOWsgWogXs5WI6Ea84rA+W699XbAa8=";
  };
}
