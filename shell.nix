let
  rev = "12c64ca55c1014cdc1b16ed5a804aa8576601ff2";
  flake = (import
    (
      fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${rev}.tar.gz";
        sha256 = "sha256:0jm6nzb83wa6ai17ly9fzpqc40wg1viib8klq8lby54agpl213w5";
      }
    )
    {
      src = ./.;
    });
in
flake.shellNix
