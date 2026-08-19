provide-module my-git %{
    alias global g git
    define-command git-merge-markers %{ set-register slash '^[<|=>]{7}[^\n]*$\n?' }
    define-command gg -params 0.. -docstring "git log --oneline --graph" %{ git log --oneline %arg{@} }
    define-command ga -params 0.. -docstring "git add" %{ git add %arg{@} }
    define-command gs -params 0.. -docstring "git status" %{ git status %arg{@} }
    define-command gd -params 0.. -docstring "git diff" %{ git diff %arg{@} }
    define-command gds -params 0.. -docstring "git diff --staged" %{ git diff --staged %arg{@} }
    define-command gc -params 0.. -docstring "git commit" %{ git commit %arg{@} }
    define-command gcF -params 0.. -docstring "git commit --amend" %{ git commit --amend %arg{@} }
    alias global gc! gcF
    define-command gcf -params 0.. -docstring "git commit --amend --no-edit" %{ git commit --amend --reuse-message HEAD %arg{@} }
    define-command gsh -params 0.. -docstring "git show" %{ git show %arg{@} }
    define-command gre -params 0.. -docstring "git reset" %{ git reset %arg{@} }
    define-command grb -params 0.. -docstring "git rebase" %{
        evaluate-commands %sh{
            if ! fifo_dir="$(mktemp -d "${TMPDIR:-/tmp}/kak-git-rebase-XXXXXX")" ||
               ! mkfifo "${fifo_dir}/response_fifo"
            then
                echo "fail %{failed to run git rebase (see *debug* buffer)}"
                [ -n "${fifo_dir}" ] && rmdir "${fifo_dir}"
                exit 1
            fi
            {
                trap 'rm -r "${fifo_dir}"' EXIT
                export GIT_EDITOR="$(git rev-parse --sq-quote \
                    "${KAKOUNE_POSIX_SHELL:-/bin/sh}" \
                    "${kak_runtime}/rc/tools/blocking-editor-in-client" \
                    "${fifo_dir}" "${kak_session}" "${kak_client}")"
                failed=false
                if err="$(git rebase "$@" 2>&1)"; then
                    cmd="eval -try-client ${kak_client} %{
                        echo -markup '{Information}Rebase succeeded'
                    }"
                elif [ -f "${fifo_dir}/cancelled" ]; then
                    cmd="eval -try-client ${kak_client} %{
                        echo -markup '{Information}Rebase cancelled'
                    }"
                else
                    failed=true
                    cmd="eval -try-client ${kak_client} %{
                        try %{
                            edit! -fifo $(kakquote "${fifo_dir}/response_fifo") '*git-rebase*'
                        }
                        echo -markup '{Error}Rebase failed'
                    }"
                fi
                printf %s "${cmd}" | kak -p "${kak_session}"
                if [ ${failed} = true ]; then
                    printf %s "$err" >"${fifo_dir}/response_fifo"
                fi
            } 2>/dev/null 1>&2 </dev/null &
        }
    }
    define-command gri -params 0.. -docstring "git rebase -i" %{ grb -i %arg{@} }
    define-command grc -params 0.. -docstring "git rebase --continue" %{ grb --continue %arg{@} }
    define-command gra -params 0.. -docstring "git rebase --abort" %{ grb --abort %arg{@} }
    define-command gred -params 0.. -docstring "git rebase --edit" %{ grb --edit %arg{@} }
    define-command grec -params 0.. -docstring "git rebase --edit; --continue" %{ grb --edit %arg{@}; grc }

    define-command -override git-hunk-object %{
        evaluate-commands -save-regs caret %sh{
            if [ "$kak_select_mode" = "extend" ]; then
                echo "execute-keys -save-regs '' 'Z'"
            fi
            case "$kak_object_flags" in
                to_begin) # [/{
                    echo "git prev-hunk"
                    ;;
                to_end) # ]/}
                    echo "git next-hunk"
                    ;;
                to_begin|to_end) # <a-a>
                    ;;
                to_begin|to_end|inner) # <a-i>
                    ;;
            esac
            if [ "$kak_select_mode" = "extend" ]; then
                echo "execute-keys -save-regs '' '<a-z>a'"
            fi
        }
    }
    map global object h '<a-;> git-hunk-object<ret>'
}
