{ pkgs, lib, config, ... }:
with pkgs;
[
  audacity
  easytag
  inkscape
] ++
lib.optionals (pkgs.buildPlatform == pkgs.hostPlatform) [
  cura
  antimicroX
]
