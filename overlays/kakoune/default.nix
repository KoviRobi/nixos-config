final: prev:
let
  inherit (final.lib)
    attrNames
    concatMapStringsSep
    getExe'
    getExe
    ;
  inherit (final.lib.strings) escapeShellArg;
  config-files = {
    # "abduco.kak" = { };
    # "tmux.kak" = { };
    # "tmux-repl.kak" = { };
    "man-improved.kak" = { };
    "c-w_and_c-u.kak" = { };
    "git-async.kak" = {
      perl = getExe final.perl;
    };
    "git-gutter-async.kak" = { };
    "lsp.kak" = {
      kakoune-lsp = getExe final.kakoune-lsp;
    };
  };
  kovirobi-kakoune-config = final.stdenv.mkDerivation {
    name = "kovirobi-kakoune-config";
    src = ./config;
    buildPhase = ''
      runHook preBuild

      target=$out/share/kak/autoload/plugins/kovirobi-config
      mkdir -p "$target"

      substitute "$src/kakrc.local" "$out/share/kak/kakrc.local" \
          --replace-fail @kakoune-cr@ ${getExe' final.kakoune-cr "kcr"}

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
    kak-byline = prev.kakouneUtils.buildKakounePluginFrom2Nix {
      pname = "kak-byline";
      version = "2025-03-31";
      src = final.fetchgit {
        url = "https://git.sr.ht/~ficd/kak-byline";
        rev = "e6f95597c20fb161edd6e6d33354676e3d4714aa";
        hash = "sha256-7FqMZexQ0Q8djlOjSn6ak8J0ydi7ir704GJAgzqiAwU=";
      };
      meta.homepage = "https://git.sr.ht/~ficd/kak-byline";
    };
    byline-kak = final.kak-byline;

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
        p.kakboard
        p.fzf-kak
        p.powerline-kak
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
      ${getExe final.kakoune} -e "man $*"
    '';
  };
  inherit kovirobi-kakoune-config;
}
