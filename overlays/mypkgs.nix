final: prev: {
  st =
    (prev.st.override {
      extraLibs = [
        final.gd
        final.harfbuzz
      ];
      patches = prev.st.patches ++ [
        ../patches/st/0001-Patch-st-0.8.5-font2.patch.patch
        ../patches/st/0002-Patch-st-0.8.5-worddelimiters.patch.patch
        ../patches/st/0003-Set-_NET_WM_ICON-with-a-png-image.patch
        ../patches/st/0004-Create-a-desktop-entry-for-st.patch
        ../patches/st/0005-Patch-st-true-color.patch.patch
        ../patches/st/0006-Patch-st-0.8.5-solarized-swap.patch.patch
        ../patches/st/0007-Patch-st-0.8.5-solarized-swap-default-light.patch.patch
        ../patches/st/0008-Patch-st-ligatures-20240427-0.9.2.diff.patch
        ../patches/st/0009-Patch-st-shift-backspace.patch.patch
        ../patches/st/0010-Patch-st-undercurl-0.9-20240103.diff.patch
        ../patches/st/0011-Read-brightness-state-file-if-it-exists.patch
      ];
    }).overrideAttrs
      (attrs: {
        ICONSRC = "${final.paper-icon-theme}/share/icons/Paper/32x32/apps/utilities-terminal-alt.png";
        meta.priority = -10;
      });

  dhcp-helper = final.stdenv.mkDerivation rec {
    pname = "dhcp-helper";
    version = "1.2";
    src = final.fetchurl {
      url = "https://thekelleys.org.uk/dhcp-helper/${pname}-${version}.tar.gz";
      sha256 = "sha256-rp5YnsUPG1vjAufruBEa1zShHiQiqc9h0I94WOojZq0=";
    };
    makeFlags = [ "PREFIX=${placeholder "out"}" ];
  };

  zsh-manydots-magic = final.runCommand "zsh-manydots-magic" { } ''
    outdir=$out/share/zsh/site-functions/zsh-manydots-magic
    mkdir -p $outdir
    install ${
      final.fetchFromGitHub {
        owner = "knu";
        repo = "zsh-manydots-magic";
        rev = "4372de0718714046f0c7ef87b43fc0a598896af6";
        hash = "sha256-lv7e7+KBR/nxC43H0uvphLcI7fALPvxPSGEmBn0g8HQ=";
      }
    }/manydots-magic $outdir/manydots-magic.zsh
  '';

  pystack =
    let
      ppkgs = final.python3.pkgs;
    in
    ppkgs.buildPythonApplication rec {
      pname = "pystack";
      version = "1.4.1";
      src = final.fetchFromGitHub {
        owner = "bloomberg";
        repo = "pystack";
        rev = "v${version}";
        hash = "sha256-j+M7GgPUqVtHKkekr5MZXWsseAJtoHTzyCx+yRJk0V8=";
      };
      buildInputs = [
        final.libdwarf
        final.elfutils
      ];
      nativeBuildInputs = [ final.pkg-config ];
      propagatedBuildInputs = [
        ppkgs.pkgconfig
        ppkgs.cython
      ];
    };

  vimPlugins = prev.vimPlugins.extend (
    final': prev': {
      vim-localvimrc = prev'.vim-localvimrc.overrideAttrs {
        src = final.fetchFromGitHub {
          owner = "embear";
          repo = "vim-localvimrc";
          rev = "77657ae78007758832f0e5350ab640a50d6acd23";
          hash = "sha256-YpyPmpfhh+MgpqJQOXnt3IFCXf0VXG/HucTdx1omR0U=";
        };
      };
    }
  );

  pyc = final.writeScriptBin "pyc" ''
    #!${final.lib.getExe (final.pkgs.python3.withPackages (ps: [ ]))}

    import collections
    import functools
    import itertools
    import os
    import re
    import sys
    import traceback
    from math import *
    from pathlib import Path

    try:
        while line := input():
            try:
                print(eval(line))
            except:
                traceback.print_exc()
    except EOFError:
        pass
  '';

  tmux-gruvbox-v1 = final.tmuxPlugins.mkTmuxPlugin {
    pluginName = "gruvbox";
    rtpFilePath = "gruvbox-tpm.tmux";
    version = "unstable-2022-04-19";
    src = final.fetchFromGitHub {
      owner = "egel";
      repo = "tmux-gruvbox";
      rev = "3f9e38d7243179730b419b5bfafb4e22b0a969ad";
      hash = "sha256-jvGCrV94vJroembKZLmvGO8NknV1Hbgz2IuNmc/BE9A=";
    };
  };

  qcom-firmware-extract = final.runCommand "qcom-firmware-extract-dell-inspiron-plus-7441" { } ''
    cp -r ${../qcom-firmware-extract} $out
  '';

  open_dp100 =
    import
      (final.fetchFromGitHub {
        owner = "KoviRobi";
        repo = "open_dp100";
        rev = "0be45eb4ac6664b027cfe70fe157cba38ffbbcc5";
        hash = "sha256-k7GN4MCsdh8qDFC0RGMWMKPXmLlgi4ysEZ4NmGIRYRA=";
      })
      {
        pkgs = final;
        version = "unstable-2025-12-11";
      };
}
