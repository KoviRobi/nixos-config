final: prev:
let
  inherit (final.lib)
    attrNames
    concatMapStringsSep
    getExe
    ;
  inherit (final.lib.strings) escapeShellArg;
  config-files = {
    "zmx-repl.kak" = { };
    "man-improved.kak" = {
      mandoc = getExe final.mandoc;
    };
    "c-w_and_c-u.kak" = { };
    "git-async.kak" = {
      perl = getExe final.perl;
    };
    "git-gutter-async.kak" = { };
    "lsp.kak" = {
      kakoune-lsp = getExe final.kakoune-lsp;
    };
    "my-git.kak" = { };
  };
  kovirobi-kakoune-config = final.stdenv.mkDerivation {
    name = "kovirobi-kakoune-config";
    src = ./config;
    buildPhase = ''
      runHook preBuild

      target=$out/share/kak/autoload/plugins/kovirobi-config
      mkdir -p "$target"

      cp "$src/kakrc.local" "$out/share/kak/kakrc.local"

      ${concatMapStringsSep "\n" (
        file:
        ''substitute "$src"/${escapeShellArg file} "$target"/${escapeShellArg file}''
        + (concatMapStringsSep " " (
          name: " --replace-fail @${escapeShellArg name}@ ${escapeShellArg config-files.${file}.${name}}"
        ) (attrNames config-files.${file}))
      ) (attrNames config-files)}

      runHook postBuild
    '';
  };
in
{
  kakounePlugins = prev.kakounePlugins or { } // {
    explorer-kak = prev.kakouneUtils.buildKakounePluginFrom2Nix {
      pname = "explorer-kak";
      version = "2019-03-20";
      src = final.fetchgit {
        url = "https://github.com/Delapouite/explore.kak";
        rev = "11f8dffce92ba38b1e2abe6e97dfdf9c8de141a8";
        hash = "sha256-T33a96XCHGvYtbOpcf+SlgcoMzNjMVdKM1UEJb+Vtv8=";
      };
      meta.homepage = "https://github.com/Delapouite/explore.kak";
    };

    kak-ansi = prev.kakounePlugins.kak-ansi.overrideAttrs (old: {
      patches = old.patches or [ ] ++ [
          ./kak-ansi-no-man.patch
      ];
    });
  };

  kakoune = prev.kakoune.override (
    old:
    let
      p = final.kakounePlugins;
    in
    {
      plugins = old.plugins or [ ] ++ [
        p.kak-ansi
        p.active-window-kak
        p.fzf-kak
        p.kak-byline
        p.explorer-kak
        # p.kakoune-easymotion
        kovirobi-kakoune-config
      ];
    }
  );
  kakman = final.writeShellApplication {
    name = "kakman";
    text = ''
      args=""
      for arg in "$@"; do
        section=''${arg##*.}
        page=''${arg%.*}
        if [ "$section" != "$arg" ]; then
          args="$args''${args:+;}man $page($section)"
        else
          args="$args''${args:+;}man $arg"
        fi
      done
      ${getExe final.kakoune} -e "$args"
    '';
  };
  inherit kovirobi-kakoune-config;
}
