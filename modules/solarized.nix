{ config, lib, pkgs, ... }:

let
  cfg = config.solarized;
in
{
  options.solarized = with lib; {
    brightness = mkOption {
      type = types.enum [ "dark" "light" ];
      default = "light";
      description = ''
        Whether to use solarized dark or light by default.
      '';
    };
  };

  config = {
    home-manager.users.default-user.solarized.brightness = cfg.brightness;

    nixpkgs.overlays = [
      (self: super: {
        st = super.st.override {
          patches = super.st.patches ++ [
            ../patches/st-0.8.5-solarized-swap.patch
          ] ++ lib.optional (cfg.brightness == "light")
            ../patches/st-0.8.5-solarized-swap-default-light.patch
          ;
        };
      })
    ];
  };
}
