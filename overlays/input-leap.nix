final: prev:
{
  input-leap = prev.input-leap.overrideAttrs (attrs: {
    pname = "input-leap";
    version = "unstable-2023-08-08";

    src = final.fetchFromGitHub {
      owner = "input-leap";
      repo = "input-leap";
      rev = "edaa634551eb530a4ae6eaf1d31d62a72d70c961";
      hash = "sha256-NOhbwUar5Ag//kiQQsoQNvxPVDTwX30FoQgzd4T3TCc=";
      fetchSubmodules = true;
    };
  });
}
