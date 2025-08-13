final: prev: {
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

    git-async = prev.kakouneUtils.buildKakounePluginFrom2Nix {
      pname = "git-async";
      version = "2025-03-18";
      src = final.fetchgit {
        url = "https://github.com/evannjohnson/git-async.kak.git";
        rev = "1d99328317b67d03b3ba54caf3217127b82deaaf";
        hash = "sha256-Wq0qoEFMdO8AeRL02AenNVWpVWtFtxLNORM50Jydykc";
      };
      meta.homepage = "https://github.com/evannjohnson/git-async.kak.git";
    };

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

  "kakrc.local" =
    let
      git-gutter = ''
        add-highlighter global/git-diff flag-lines Default git_diff_flags

        hook global -group git-gutter-hooks BufCreate .* %{
          try %{ git show-diff }
        }
        hook global -group git-gutter-hooks FocusIn .* %{
          try %{ git-async update-diff-via-git }
        }
        hook global -group git-gutter-hooks BufReload .* %{
          try %{ git-async update-diff-via-git }
        }
        hook global -group git-gutter-hooks BufWritePost .* %{
          try %{ git-async update-diff-via-git }
        }
        hook global -group git-gutter-hooks NormalIdle .* %{
          try %{ git-async update-diff-via-git }
        }
      '';

      tmux-split = ''
        define-command -docstring "v [<commands>]: split tmux vertically" -params .. v %{
          tmux-terminal-horizontal kak -c %val{session} -e "%arg{@}"
        }
        complete-command v command

        define-command -docstring "h [<commands>]: split tmux horizontally" -params .. h %{
          tmux-terminal-vertical kak -c %val{session} -e "%arg{@}"
        }
        complete-command h command

        define-command -docstring "tab [<commands>]: split tmux horizontally" -params .. tab %{
          tmux-terminal-window kak -c %val{session} -e "%arg{@}"
        }
        complete-command tab command
      '';

      c_w_and_c_u = ''
        define-command erase_characters_before_cursor_to_line_begin %{
          evaluate-commands -draft %{
            execute-keys '<a-h>'
            evaluate-commands -draft -itersel -verbatim -- try %{
              execute-keys '<a-k>^.\z<ret>'
            } catch %{
              execute-keys '<a-k>^\h+.\z<ret><a-:>Hd'
            } catch %{
              execute-keys '<a-k>^\h+\H<ret>WL<a-:>Hd'
            } catch %{
              execute-keys '<a-:>Hd'
            } catch %{}
          }
          execute-keys '<a-;><a-:><a-;><a-;>'
        }

        define-command erase_word_before_cursor %{
          evaluate-commands -draft %{
            execute-keys ';<a-_>'
            evaluate-commands -draft -itersel -verbatim -- try %{
              execute-keys -draft '<a-k>^.\z<ret>'
            } catch %{
              execute-keys -draft 'h<a-k>^.\z<ret>d'
            } catch %{
              execute-keys -draft 'h<a-k>\b\w|\B[^\w\h]<ret>d'
            } catch %{
              execute-keys -draft 'hBd'
            } catch %{}
          }
        }

        map global insert <c-u> '<a-;>: erase_characters_before_cursor_to_line_begin<ret>'
        map global insert <c-w> '<a-;>: erase_word_before_cursor<ret>'
      '';

      # Use manpath; use MANWIDTH=width-1
      man_improvements = ''
        define-command -override -hidden -params ..3 man-impl %{ evaluate-commands %sh{
            buffer_name="$1"
            if [ -z "''${buffer_name}" ]; then
                exit
            fi
            shift
            manout=$(mktemp "''${TMPDIR:-/tmp}"/kak-man.XXXXXX)
            manerr=$(mktemp "''${TMPDIR:-/tmp}"/kak-man.XXXXXX)
            colout=$(mktemp "''${TMPDIR:-/tmp}"/kak-man.XXXXXX)
            env MANWIDTH=$(($kak_window_width - 1)) man "$@" > "$manout" 2> "$manerr"
            retval=$?
            if command -v col >/dev/null; then
                col -b -x > ''${colout} < ''${manout}
            else
                sed 's/.//g' > ''${colout} < ''${manout}
            fi
            rm ''${manout}

            if [ "''${retval}" -eq 0 ]; then
                printf %s\\n "
                        edit -scratch %{*$buffer_name ''${*}*}
                        execute-keys '%|cat<space>''${colout}<ret>gk'
                        nop %sh{ rm ''${colout}; rm ''${manerr} }
                        set-option buffer filetype man
                        set-option window manpage $buffer_name $*
                "
            else
                printf '
                    fail %%{%s}
                    nop %%sh{ rm "%s"; rm "%s" }
                ' "$(cat "$manerr")" "''${colout}" "''${manerr}"
            fi
        } }

        # Improve man completion
        complete-command man shell-script-candidates %{
            find -L $(manpath | sed 's/:/ /g') -name '*.[1-8]*' |
                sed 's,^.*/\(.*\)\.\([1-8][a-zA-Z]*\).*$,\1(\2),' }
      '';
    in
    final.writeTextDir "share/kak/kakrc.local" ''
      colorscheme solarized-light

      set-option global autoinfo command|onkey|normal

      add-highlighter global/ wrap -word -marker ⏎
      add-highlighter global/ show-matching
      add-highlighter global/highlight-search dynregex '%reg{/}' 0:+i
      add-highlighter global/show-trailing-whitespaces regex '\h+$' 0:,,red+u
      add-highlighter global/show-inconsistent-tabs-1 regex '( +)(\t+)' 2:,,red+u
      add-highlighter global/show-inconsistent-tabs-2 regex '(\t+)( +)' 1:,,red+u

      set-option global scrolloff 3,2

      # UI options
      set-option global ui_options terminal_set_title=false terminal_status_on_top=true terminal_assistant=none terminal_enable_mouse=true terminal_change_colors=true    terminal_builtin_key_parser=false

      # Key mappings
      map global normal / '/(?i)'

      hook global WinCreate .* %{ kakboard-enable }

      ${git-gutter}
      ${tmux-split}
      ${c_w_and_c_u}
      ${man_improvements}

      define-command mkdir %{ nop %sh{ mkdir -p $(dirname $kak_buffile) } }

      # Shortcut to quickly exit the editor
      define-command -docstring "save and quit" x "write-all; kill"

      # Subject-verb
      alias global bd delete-buffer
      alias global bd! delete-buffer!

      alias global qa kill
      alias global qa! kill!

      set-option global grepcmd "rg --vimgrep"

      require-module powerline
      powerline-enable
      powerline-theme-solarized-light

      require-module byline
      map global normal 'X' ": byline-drag-up<ret>"
      map global normal 'x' ": byline-drag-down<ret>"

      eval %sh{${final.lib.getExe final.kakoune-lsp}}
      lsp-enable

      map global user f ': fzf-mode<ret>'
    '';

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
        p.git-async
        p.explorer-kak
        final."kakrc.local"
      ];
    }
  );
}
