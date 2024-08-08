final: prev:
{
  st = (prev.st.override {
    extraLibs = [ final.gd ];
    patches = prev.st.patches ++ [
      ../patches/st-0.8.5-font2.patch
      ../patches/st-0.8.5-worddelimiters.patch
      ../patches/st-0.8.5-netwmicon-v2.patch
      ../patches/st-0.8.5-desktopentry.patch
      ../patches/st-true-color.patch
    ];
  }).overrideAttrs (attrs: {
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
    install ${final.fetchFromGitHub {
      owner = "knu";
      repo = "zsh-manydots-magic";
      rev = "4372de0718714046f0c7ef87b43fc0a598896af6";
      hash = "sha256-lv7e7+KBR/nxC43H0uvphLcI7fALPvxPSGEmBn0g8HQ=";
    }}/manydots-magic $outdir/manydots-magic.zsh
  '';

  autosubsync-mpv = final.stdenvNoCC.mkDerivation rec {
    pname = "autosubsync-mpv";
    version = "unstable-2022-12-26";
    src = final.fetchFromGitHub {
      owner = "joaquintorres";
      repo = "autosubsync-mpv";
      rev = "22cb928ecd94cc8cadaf8c354438123c43e0c70d";
      sha256 = "sha256-XQPFC7l9MTZAW5FfULRQJfu/7FuGj9bbjQUZhNv0rlc=";
    };
    # While nixpkgs only packages alass, we might as well make that the default
    patchPhase = ''
      runHook prePatch
      substituteInPlace autosubsync.lua                                       \
        --replace 'alass_path = ""' 'alass_path = "${final.alass}/bin/alass-cli"'       \
        --replace 'audio_subsync_tool = "ask"' 'audio_subsync_tool = "alass"' \
        --replace 'altsub_subsync_tool = "ask"' 'altsub_subsync_tool = "alass"'
      runHook postPatch
    '';
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -m755 -d $out/share/mpv/scripts/autosubsync-mpv
      install -m644 -t $out/share/mpv/scripts/autosubsync-mpv *.lua
      runHook postInstall
    '';
    passthru.scriptName = "autosubsync-mpv";

    meta = with final.lib; {
      description = "Automatically sync subtitles in mpv using the `n` button";
      homepage = "https://github.com/joaquintorres/autosubsync-mpv";
      maintainers = with maintainers; [ kovirobi ];
      license = licenses.mit;
    };
  };

}
