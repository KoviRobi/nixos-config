hook global ModuleLoaded wezterm %{
    require-module wezterm-repl
}

provide-module wezterm-repl %{

declare-option -docstring "window id of the REPL window" str wezterm_repl_id

define-command -docstring %{
    wezterm-repl [<arguments>]: create a new window for repl interaction
    All optional parameters are forwarded to the new window
} \
    -params .. \
    wezterm-repl %{ wezterm-terminal-window sh -c %{
        printf "evaluate-commands -try-client $1 \
            'set-option current wezterm_repl_id ${WEZTERM_PANE}'" | kak -p "$2"
        shift 2;
        [ "$1" ] && "$@" || "$SHELL"
    } -- %val{client} %val{session} %arg{@}
}
complete-command wezterm-repl shell

define-command wezterm-send-text -params 0..1 -docstring %{
        wezterm-send-text [text]: Send text to the REPL window.
        If no text is passed, then the selection is used
        } %{
    evaluate-commands %sh{
        @wezterm@ cli send-text --pane-id "${kak_opt_wezterm_repl_id}" "${kak_selection}"
    }
}

alias global repl-new wezterm-repl
alias global repl-send-text wezterm-send-text

}
