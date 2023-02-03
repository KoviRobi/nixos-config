{ pkgs, lib, config, ... }:
{
  imports = [ ./starship.nix ];

  home.packages = with pkgs; [ thefuck carapace ];

  home.sessionVariables = {
    BROWSER = "links -g";
    EDITOR = "nvim";
    PAGER = "less";
    LESS = "-iRq -j5 --mouse --wheel-lines=3 --redraw-on-quit";
    LESSOPEN = "|${pkgs.lesspipe}/bin/lesspipe.sh %s";
    GS_OPTIONS = "-sPAPERSIZE=a4";
  };

  programs.nushell =
    {
      enable = true;
      extraEnv = ''
        ${pkgs.zoxide}/bin/zoxide init nushell | save --force ${config.xdg.configHome}/nushell/zoxide.nu
      '';
      extraConfig = ''
        use ${pkgs.nu_scripts}/themes/themes/solarized-light.nu *
        use ${pkgs.nu_scripts}/themes/themes/solarized-dark.nu *

        let carapace_completer = {|spans|
            ${pkgs.carapace}/bin/carapace $spans.0 nushell $spans | from json
        }

        let-env prev = (0..4 | each --keep-empty {null})
        def v [index:int=0] {
          $env.prev | get -i $index
        }
        def-env maybe_explore [] {
          let-with-metadata data metadata = $in
          $env.peek_output = (
            if ($data | describe) not-in [closure nothing] {
              let expanded = ($data | table -e)
              if (term size).rows < ($expanded | size).lines {
                $data | set-metadata $metadata | explore -p
              } else if ($data | describe) == closure {
                view-source $data
              }
            }
          )
          $env.prev.4 = $env.prev.3
          $env.prev.3 = $env.prev.2
          $env.prev.2 = $env.prev.1
          $env.prev.1 = $env.prev.0
          $env.prev.0 = $data
          $data |
            set-metadata $metadata |
            if (term size).columns >= 100 { table -e } else { table }
        }

        let-env ENV_CONVERSIONS = {
          NIX_PATH : ({
            from_string: {|str|
              $str | split row : | parse -r '((?<name>[[:alnum:]-_]*)=)?(?<path>.*)' | select name path
            }
            to_string: {|table|
              $table | each {|cols|
                if "name" in $cols and $cols.name != "" {
                  $"($cols.name)=($cols.path)"
                } else if "path" in $cols {
                  $cols.path
                }
              } | str join :
            }
          })
        }

        let-env config = {
          ls: {
            use_ls_colors: true # use the LS_COLORS environment variable to colorize output
            clickable_links: true # enable or disable clickable links. Your terminal has to support links.
          }
          rm: {
            always_trash: false # always act as if -t was given. Can be overridden with -p
          }
          cd: {
            abbreviations: true # allows `cd s/o/f` to expand to `cd some/other/folder`
          }
          table: {
            mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
            index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
            trim: {
              methodology: truncating # wrapping or truncating
              wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
              truncating_suffix: "..." # A suffix used by the 'truncating' methodology
            }
          }

          explore: {
            help_banner: true
            exit_esc: true

            # command_bar_text: '#C4C9C6'
            # # command_bar: {fg: '#C4C9C6' bg: '#223311' }

            # status_bar_background: {fg: '#1D1F21' bg: '#C4C9C6' }
            # # status_bar_text: {fg: '#C4C9C6' bg: '#223311' }

            # highlight: {bg: 'yellow' fg: 'black' }

            # status: {
            #   # warn: {bg: 'yellow', fg: 'blue'}
            #   # error: {bg: 'yellow', fg: 'blue'}
            #   # info: {bg: 'yellow', fg: 'blue'}
            # }

            # try: {
            #   # border_color: 'red'
            #   # highlighted_color: 'blue'

            #   # reactive: false
            # }

            # table: {
            #   split_line: '#404040'

            #   cursor: true

            #   line_index: true
            #   line_shift: true
            #   line_head_top: true
            #   line_head_bottom: true

            #   show_head: true
            #   show_index: true

            #   # selected_cell: {fg: 'white', bg: '#777777'}
            #   # selected_row: {fg: 'yellow', bg: '#C1C2A3'}
            #   # selected_column: blue

            #   # padding_column_right: 2
            #   # padding_column_left: 2

            #   # padding_index_left: 2
            #   # padding_index_right: 1
            # }

            # config: {
            #   cursor_color: {bg: 'yellow' fg: 'black' }

            #   # border_color: white
            #   # list_color: green
            # }
          }

          history: {
            max_size: 10000 # Session has to be reloaded for this to take effect
            sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
            file_format: "sqlite" # "sqlite" or "plaintext"
          }

          completions: {
            case_sensitive: false # set to true to enable case-sensitive completions
            quick: true  # set this to false to prevent auto-selecting completions when only one remains
            partial: true  # set this to false to prevent partial filling of the prompt
            algorithm: "prefix"  # prefix or fuzzy
            external: {
              enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
              max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
              completer: $carapace_completer # check 'carapace_completer' above as an example
            }
          }
          filesize: {
            metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
            format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
          }
          color_config: (solarized_light)   # if you want a light theme, replace `$dark_theme` to `$light_theme`
          use_grid_icons: true
          footer_mode: "25" # always, never, number_of_rows, auto
          float_precision: 2
          buffer_editor: "nvim" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
          use_ansi_coloring: true
          edit_mode: emacs # emacs, vi
          shell_integration: true # enables terminal markers and a workaround to arrow keys stop working issue
          show_banner: false # true or false to enable or disable the banner
          render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.

          hooks: {
            pre_prompt: [{
              null  # replace with source code to run before the prompt is shown
            }]
            pre_execution: [{
              # 2 lines for border, 1 line for newline after table, 2 lines for prompt
              let-env config = ($env.config | update footer_mode ((term size).rows - 5))
            }]
            env_change: {
              PWD: [{|before, after|
                [$before $after] | debug
              }]
            }
            display_output: {
              maybe_explore
            }
          }
          menus: [
              # Configuration for default nushell menus
              # Note the lack of source parameter
              {
                name: completion_menu
                only_buffer_difference: false
                marker: "\r| "
                type: {
                    layout: columnar
                    columns: 4
                    col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                    col_padding: 2
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
              }
              {
                name: history_menu
                only_buffer_difference: true
                marker: "\r? "
                type: {
                    layout: list
                    page_size: 10
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
              }
              {
                name: help_menu
                only_buffer_difference: true
                marker: "\r? "
                type: {
                    layout: description
                    columns: 4
                    col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
                    col_padding: 2
                    selection_rows: 4
                    description_rows: 10
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
              }
              # Example of extra menus created using a nushell source
              # Use the source field to create a list of records that populates
              # the menu
              {
                name: commands_menu
                only_buffer_difference: false
                marker: "\r# "
                type: {
                    layout: columnar
                    columns: 4
                    col_width: 20
                    col_padding: 2
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
                source: { |buffer, position|
                    $nu.scope.commands
                    | where name =~ $buffer
                    | each { |it| {value: $it.name description: $it.usage} }
                }
              }
              {
                name: vars_menu
                only_buffer_difference: true
                marker: "\r# "
                type: {
                    layout: list
                    page_size: 10
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
                source: { |buffer, position|
                    $nu.scope.vars
                    | where name =~ $buffer
                    | sort-by name
                    | each { |it| {value: $it.name description: $it.type} }
                }
              }
              {
                name: commands_with_description
                only_buffer_difference: true
                marker: "\r# "
                type: {
                    layout: description
                    columns: 4
                    col_width: 20
                    col_padding: 2
                    selection_rows: 4
                    description_rows: 10
                }
                style: {
                    text: green
                    selected_text: green_reverse
                    description_text: yellow
                }
                source: { |buffer, position|
                    $nu.scope.commands
                    | where name =~ $buffer
                    | each { |it| {value: $it.name description: $it.usage} }
                }
              }
          ]
          keybindings: [
            {
              name: completion_menu
              modifier: none
              keycode: tab
              mode: [emacs vi_normal vi_insert]
              event: {
                until: [
                  { send: menu name: completion_menu }
                  { send: menunext }
                ]
              }
            }
            {
              name: completion_previous
              modifier: shift
              keycode: backtab
              mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
              event: { send: menuprevious }
            }
            {
              name: history_menu
              modifier: control
              keycode: char_r
              mode: emacs
              event: { send: menu name: history_menu }
            }
            {
              name: next_page
              modifier: control
              keycode: char_x
              mode: emacs
              event: { send: menupagenext }
            }
            {
              name: undo_or_previous_page
              modifier: control
              keycode: char_z
              mode: emacs
              event: {
                until: [
                  { send: menupageprevious }
                  { edit: undo }
                ]
               }
            }
            {
              name: yank
              modifier: control
              keycode: char_y
              mode: emacs
              event: {
                until: [
                  {edit: pastecutbufferafter}
                ]
              }
            }
            {
              name: unix-line-discard
              modifier: control
              keycode: char_u
              mode: [emacs, vi_normal, vi_insert]
              event: {
                until: [
                  {edit: cutfromlinestart}
                ]
              }
            }
            {
              name: kill-line
              modifier: control
              keycode: char_k
              mode: [emacs, vi_normal, vi_insert]
              event: {
                until: [
                  {edit: cuttolineend}
                ]
              }
            }
            # Keybindings used to trigger the user defined menus
            {
              name: commands_menu
              modifier: control
              keycode: char_t
              mode: [emacs, vi_normal, vi_insert]
              event: { send: menu name: commands_menu }
            }
            {
              name: vars_menu
              modifier: alt
              keycode: char_o
              mode: [emacs, vi_normal, vi_insert]
              event: { send: menu name: vars_menu }
            }
            {
              name: commands_with_description
              modifier: control
              keycode: char_s
              mode: [emacs, vi_normal, vi_insert]
              event: { send: menu name: commands_with_description }
            }
          ]
        }

        use ${pkgs.nu_scripts}/git/git.nu *

        use ${pkgs.nu_scripts}/custom-completions/git/git-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/nix/nix-completions.nu *
        use ${pkgs.nu_scripts}/custom-completions/tealdeer/tldr-completions.nu *

        source ${pkgs.nu_scripts}/custom-completions/auto-generate/parse-fish.nu

        use ${pkgs.nu_scripts}/cool-oneliners/cargo_search.nu *

        alias shell = (hide g; g)
        alias g = git
        alias nixrepl = nix repl --expr 'builtins.getFlake "nixos-config"';
        alias ll = ls -l
        alias la = ls -la
        alias n = nix
        alias nf = nix flake
        alias nb = nix build
        alias der = (cd /; cd -)
        alias termbin = nc termbin.com 9999

        # parses a input string in --help format and returns a table of parsed flags
        def parse-help [] {
            # help format  '        -s,                      --long                   <format>                 description   '
            $in | parse -r '\s\s+(?:-(?P<short>\w)[,\s]+)?(?:--(?P<long>[\w-]+))\s*(?:<(?P<format>.*)>)?\s*(?P<description>.*)?'
        }

        # takes a table of parsed help commands in format [short? long format? description]
        def make-completion [command_name: string] {
          "extern \"" + $command_name + "\" [\n" + ($in | each { |it|
              "\t--" + $it.long + (if ($it.short | is-empty) == false {
                  "(-" + $it.short + ")"
                } else {
                  ""
                }) + (if ($it.description | is-empty) == false {
                  "\t\t# " + $it.description
                } else {
                  ""
                })
              } | str join "\n") + "\n\t...args\n]"
        }

        source ${config.xdg.configHome}/nushell/zoxide.nu

        source "${config.xdg.configHome}/nushell/user-config.nu"
      '';
    };

  programs.zsh = {
    enable = true;
    initExtra = ''
      unsetopt beep
      setopt extendedglob

      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=white
      export VERSION_CONTROL=numbered


      bindkey -e
      autoload edit-command-line
      zle -N edit-command-line
      bindkey "^X^E" edit-command-line
      bindkey "^P" up-history
      bindkey "^N" down-history
      bindkey "^W" kill-region
      bindkey "^[u" up-case-word
      bindkey "^[l" down-case-word

      [ -z "''${terminfo[kcbt]}" ]  || bindkey "''${terminfo[kcbt]}"  reverse-menu-complete
      [ -z "''${terminfo[kdch1]}" ] || bindkey "''${terminfo[kdch1]}" delete-char
      [ -z "''${terminfo[kich1]}" ] || bindkey "''${terminfo[kich1]}" overwrite-mode
      [ -z "''${terminfo[khome]}" ] || bindkey "''${terminfo[khome]}" beginning-of-line
      [ -z "''${terminfo[kend]}" ]  || bindkey "''${terminfo[kend]}"  end-of-line

      # Often I do want to go back to underscores or hyphens
      WORDCHARS=""
      eval $(${pkgs.thefuck}/bin/thefuck --alias fck)


      # The following lines were added by compinstall
      zstyle ':completion:*' completer _complete _ignored
      zstyle ':completion:*' group-name ""
      zstyle ':completion:*' insert-unambiguous true
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=** r:|=**'
      zstyle ':completion:*' menu select
      zstyle :compinstall filename '/home/rmk/.zsh.comp'

      source <(${pkgs.carapace}/bin/carapace _carapace zsh)

      autoload -Uz compinit
      compinit
      # End of lines added by compinstall
      unsetopt flow_control
      bindkey "^Q" push-line
      setopt AUTO_PUSHD
      source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/history-substring-search/history-substring-search.plugin.zsh
      export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
    '';

    enableCompletion = true;
    enableVteIntegration = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    shellAliases = {
      "mnt" = "udisksctl mount -b";
      "umnt" = "udisksctl unmount -b";
      "nixinstall" = "nix-env -f '<nixpkgs>' -i";
      "nixeval" = "nix eval -f '<nixpkgs>' --raw";
      "nixpath" = "nix eval --raw";
      "poly" = "rlwrap poly";
      "e" = "\${=EDITOR}";
      "der" = "pushd /; popd";
      "ded" = "direnv edit";
      "dea" = "direnv allow";
      "termbin" = "nc termbin.com 9999";
      "gis" = "git status";
    };
  };
}
