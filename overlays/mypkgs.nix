self: super:
{
  pavucontrol = super.pavucontrol.overrideAttrs (attrs:
    {
      patches = (if attrs ? patches then attrs.patches else [ ]) ++
        [ ../patches/pavucontrol-no-feedback.patch ];
    }
  );

  st = super.st.override {
    patches = super.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
    ];
  };
}
