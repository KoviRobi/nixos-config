final: prev: {
  # Left here as a template
  # # https://github.com/NixOS/nixpkgs/pull/451245/files
  # pamixer = prev.pamixer.overrideAttrs (old: {
  #   postPatch =
  #     if old.version != "1.6" || old ? postPatch then
  #       throw "PR landed #451245"
  #     else
  #       ''
  #         # icu76 headers (included via cxxopts) require c++17 features
  #         substituteInPlace meson.build \
  #           --replace-fail 'cpp_std=c++11' 'cpp_std=c++17'
  #       '';
  # });
}
