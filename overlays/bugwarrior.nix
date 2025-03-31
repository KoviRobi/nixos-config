final: prev: {
  bugwarrior =
    let
      pypkgs = final.python3.pkgs;
      inherit (final) lib fetchFromGitHub;
    in
    pypkgs.buildPythonApplication {
      pname = "bugwarrior";
      version = "1.8.0";
      format = "setuptools";

      src = fetchFromGitHub {
        owner = "GothenburgBitFactory";
        repo = "bugwarrior";
        rev = "11f3fa7cb76446cc0179a5f2b9c62d7a34013bf6";
        hash = "sha256-cXRIT8TedqtX0Dfr9WvE1MmZ7bpI70ONq/qz4wV7u3E=";
      };

      propagatedBuildInputs = [
        pypkgs.setuptools
        pypkgs.twiggy
        pypkgs.requests
        pypkgs.offtrac
        pypkgs.pbr
        pypkgs.python-bugzilla
        pypkgs.pydantic
        pypkgs.taskw
        pypkgs.python-dateutil
        pypkgs.pytz
        pypkgs.keyring
        pypkgs.six
        pypkgs.jinja2
        pypkgs.pycurl
        pypkgs.dogpile-cache
        pypkgs.lockfile
        pypkgs.click
        pypkgs.pyxdg
        pypkgs.future
        pypkgs.jira
      ];

      # for the moment oauth2client <4.0.0 and megaplan>=1.4 are missing for running the test suite.
      doCheck = false;

      meta = with lib; {
        homepage = "https://github.com/GothenburgBitFactory/bugwarrior";
        description = "Sync github, bitbucket, bugzilla, and trac issues with taskwarrior";
        license = licenses.gpl3Plus;
        platforms = platforms.all;
        maintainers = with maintainers; [ pierron ];
      };
    };
}
