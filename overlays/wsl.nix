self: super:
{
  npiperelay = super.buildGoModule rec {
    pname = "npiperelay";
    version = "0.1.0";

    src = super.fetchFromGitHub {
      owner = "jstarks";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-cg4aZmpTysc8m1euxIO2XPv8OMnBk1DwhFcuIFHF/1o=";
    };

    vendorHash = null;

    # For some reason, stripping produces a bad executable
    dontStrip = true;

    meta = with super.lib; {
      description = "npiperelay allows you to access Windows named pipes from WSL";
      homepage = "https://github.com/jstarks/npiperelay";
      license = licenses.mit;
      maintainers = with maintainers; [ kovirobi ];
      platforms = platforms.windows;
    };
  };
}
