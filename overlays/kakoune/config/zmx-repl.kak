provide-module zmx-repl %{

declare-option -docstring "REPL target zmx session" str zmx_repl_session
declare-option -docstring "Use bracketed paste" bool zmx_bracketed_paste true
declare-option -docstring "Enter command (e.g. '\r\n' or '^[^M')" str zmx_enter ''

define-command -params 0..1 zmx-repl-set-session -docstring %{
        zmx-repl-set-session [session]: Set an existing zmx session
        for repl interaction If the session is not given, fzf selection
        is opened
    } %{
    set-option current zmx_repl_session %arg{1}
}

complete-command -menu zmx-repl-set-session shell-script-candidates %{
    zmx list --short
}

define-command -hidden zmx-send-text -params 0.. -docstring %{
        zmx-send-text [text...]: Send text to the REPL pane.
        If no text is passed, then the selection is used
    } %{
    evaluate-commands %sh{
        start=
        end=
        if $zmx_bracketed_paste; then
            start='\x1b[200~'
            end='\x1b[201~'
        fi
        if [ $# -eq 0 ]; then
            printf "$start%s$end$kak_opt_zmx_enter" "${kak_selections}" |
                zmx send $kak_opt_zmx_repl_session ||
                echo 'fail zmx-send-text: failed, see *debug* buffer for details'
        else
            printf "$start%s$end$kak_opt_zmx_enter" "$@" |
                zmx send $kak_opt_zmx_repl_session ||
                echo 'fail zmx-send-text: failed, see *debug* buffer for details'
        fi
    }
}

alias global repl-send-text zmx-send-text

}
