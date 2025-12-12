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

      tmux = ''
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

        define-command tmux-choose-repl %{
          nop %sh{
            tmux choose-tree -Z "run-shell 'echo set-option current tmux_repl_id \"%1\" | kak -p $kak_session'"
          }
        }
        map global normal <a-ret> ": tmux-choose-repl<ret>"
      '';

      tmux_repl = ''
        # http://tmux.github.io/
        # ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
        # Tmux version >= 2 is required to use this module

        hook global ModuleLoaded tmux %{
            require-module tmux-repl
        }

        provide-module -override tmux-repl %{

        declare-option -docstring "tmux pane id in which the REPL is running" str tmux_repl_id
        declare-option -docstring "whether to use bracketed paste" bool repl_bracketed_paste true

        define-command -hidden -params 1.. tmux-repl-impl %{
            evaluate-commands %sh{
                if [ -z "$TMUX" ]; then
                    echo 'fail This command is only available in a tmux session'
                    exit
                fi
                tmux_args="$1"
                if [ "''${1%%-*}" = split ]; then
                    tmux_args="$tmux_args -t ''${kak_client_env_TMUX_PANE}"
                elif [ "''${1%% *}" = new-window ]; then
                    session_id=$(tmux display-message -p -t ''${kak_client_env_TMUX_PANE} '#{session_id}')
                    tmux_args="$tmux_args -t $session_id"
                fi
                shift
                repl_pane_id=$(tmux $tmux_args -P -F '#{pane_id}' "$@")
                printf "set-option current tmux_repl_id '%s'" "$repl_pane_id"
            }
        }

        define-command tmux-repl-vertical -params 0.. -docstring "Create a new vertical pane for repl interaction" %{
            tmux-repl-impl 'split-window -v' %arg{@}
        }
        complete-command tmux-repl-vertical shell

        define-command tmux-repl-horizontal -params 0.. -docstring "Create a new horizontal pane for repl interaction" %{
            tmux-repl-impl 'split-window -h' %arg{@}
        }
        complete-command tmux-repl-horizontal shell

        define-command tmux-repl-window -params 0.. -docstring "Create a new window for repl interaction" %{
            tmux-repl-impl 'new-window' %arg{@}
        }
        complete-command tmux-repl-window shell

        define-command -params 0..1 tmux-repl-set-pane -docstring %{
                tmux-repl-set-pane [pane number]: Set an existing tmux pane for repl interaction
                If the address of new pane is not given, next pane is used
                (To get the pane number in tmux,
                use 'tmux display-message -p '#{pane_id}'" in that pane)
            } %{
            evaluate-commands %sh{
                if [ -z "$TMUX" ]; then
                    echo 'fail This command is only available in a tmux session'
                    exit
                fi
                if [ $# -eq 0 ]; then
                    curr_pane_no="''${kak_client_env_TMUX_PANE#%}"
                    tgt_pane=$((curr_pane_no+1))
                else
                    tgt_pane="$1"
                fi
                curr_win="$(tmux display-message -t ''${kak_client_env_TMUX_PANE} -p '#{window_id}')"
                if tmux list-panes -t "$curr_win" -F \#D | grep -Fxq "%"$tgt_pane; then
                    printf "set-option current tmux_repl_id '%s'" %$tgt_pane
                else
                    echo 'fail The correct pane is not there. Activate using tmux-terminal-* or some other way'
                fi
            }
        }

        define-command -hidden tmux-send-text -params 0..1 -docstring %{
                tmux-send-text [text]: Send text to the REPL pane.
                If no text is passed, then the selection is used
            } %{
            evaluate-commands %sh{
                if [ $# -eq 0 ]; then
                    tmux set-buffer -b kak_selection -- "''${kak_selections}"
                else
                    tmux set-buffer -b kak_selection -- "$1"
                fi
                tmux paste-buffer ''${kak_opt_repl_bracketed_paste:+-p} -b kak_selection -t "$kak_opt_tmux_repl_id" ||
                echo 'fail tmux-send-text: failed to send text, see *debug* buffer for details'
            }
        }

        alias global repl-new tmux-repl-horizontal
        alias global repl-send-text tmux-send-text

        }
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
      lsp = ''
        eval %sh{${final.lib.getExe final.kakoune-lsp}}
        map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'
        map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
        map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
        map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
        map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
        map global object t '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
        map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
        map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

        hook global BufSetOption filetype=python %{
          set-option buffer lsp_servers %{
            [ruff]
            root_globs = ["requirements.txt", "setup.py", ".git", ".hg"]
            command = "ruff"
            args = ["server"]
            settings_section = "_"

            [ruff.settings._.globalSettings]
            organizeImports = true
            fixAll = true

            [pyright]
            root_globs = ["requirements.txt", "setup.py", ".git", ".hg"]
            command = "pyright-langserver"
            args = ["--stdio"]
          }
        }

        hook global BufSetOption filetype=markdown %{
          set-option buffer lsp_servers %{
            [marksman]
            root_globs = ["*.md"]
            [mpls]
            root_globs = ["*.md"]
          }
        }

        hook global BufSetOption filetype=cmake %{
          set-option buffer lsp_servers %{
            [neocmakelsp]
            root_globs = ["CMakePresets.json", "CMakeLists.txt", ".git", ".hg"]
            args = ["stdio"]
          }
        }

        map global goto d "<esc>: lsp-definition<ret>" -docstring 'LSP definition'
        map global goto r "<esc>: lsp-references<ret>" -docstring 'LSP references'
        map global goto y "<esc>: lsp-type-definition<ret>" -docstring 'LSP type definition'

        set-option global modelinefmt "%opt{lsp_modeline} %opt{modelinefmt}"

        lsp-enable
      '';
    in
    final.writeTextDir "share/kak/kakrc.local" ''
      colorscheme %sh{
        if [ "$(tput colors)" -eq 8 ]; then
          echo plain
        else
          echo "gruvbox-$(cat ~/.local/state/brightness || echo light)";
        fi
      }

      add-highlighter global/ show-matching
      add-highlighter global/show-trailing-whitespaces regex '\h+$' 0:,rgba:80000040,red+c
      add-highlighter global/show-inconsistent-tabs-1 regex '( +)(\t+)' 2:,rgba:80000040,red+c
      add-highlighter global/show-inconsistent-tabs-2 regex '(\t+)( +)' 1:,rgba:80000040,red+c

      define-command wrap "add-highlighter global/wrap wrap -word -marker ⏎"
      define-command nowrap "remove-highlighter global/wrap"
      define-command hl "add-highlighter global/highlight-search dynregex '%%reg{/}' 0:,rgba:80800040+i"
      define-command nohl "remove-highlighter global/highlight-search"
      wrap
      hl

      set-option global scrolloff 3,2

      # UI options
      set-option global ui_options terminal_set_title=true terminal_status_on_top=true terminal_assistant=none terminal_enable_mouse=true terminal_change_colors=true    terminal_builtin_key_parser=false

      # Key mappings
      hook global WinCreate .* %{ kakboard-enable }

      ${git-gutter}
      ${tmux}
      ${tmux_repl}
      ${c_w_and_c_u}
      ${man_improvements}
      ${lsp}
      eval %sh{${final.kakoune-cr}/bin/kcr init kakoune}

      define-command mkdir %{ nop %sh{ mkdir -p $(dirname $kak_buffile) } }

      # Shortcut to quickly exit the editor
      define-command -docstring "save and quit" x "write; delete-buffer"
      define-command -docstring "save and quit" xa "write-all-quit"

      # Subject-verb
      alias global bd delete-buffer
      alias global bd! delete-buffer!

      alias global qa kill
      alias global qa! kill!

      define-command -docstring "quit with status 1" "cq" "quit 1"
      define-command -docstring "quit! with status 1" "cq-force" "quit! 1"
      alias global cq! cq-force

      set-option global grepcmd "rg --vimgrep"

      require-module byline
      map global normal 'X' ": byline-drag-up<ret>"
      map global normal 'x' ": byline-drag-down<ret>"

      map global user f ': fzf-mode<ret>' -docstring "FZF mode"

      map global insert <c-d> '<a-;><lt>'
      map global insert <c-t> '<a-;><gt>'
      map global insert <a-d> '<a-;><a-lt>'
      map global insert <a-t> '<a-;><a-gt>'

      set global make_error_pattern '^([^:\n]+):(\d+):(?:(\d+):)? (?i)(?:fatal )?(fail(ed|ure)|error|warn(ing)?|info|note):?([^\n]+)?'

      # For active-window-kak
      set-face global InactiveCursor rgba:80808040,rgba:80808040

      hook global WinDisplay .* %{
        set-option -add global ui_options "terminal_title=%val{buffile}"
      }

      hook global WinSetOption filetype=nix %{
        set-option window indentwidth 2
      }
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
        p.kakoune-easymotion
        final."kakrc.local"
      ];
    }
  );
  kakman = final.writeShellApplication {
    name = "kakman";
    text = ''
      ${final.lib.getExe final.kakoune} -e "man $*"
    '';
  };
}
