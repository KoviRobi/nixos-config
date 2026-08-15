provide-module man-improved %{

    define-command -override -hidden -params ..3 man-impl %{

        evaluate-commands %sh{
            dir="$(mktemp -d "${TMPDIR:-/tmp}"/kak-fifo.XXXXXXXX)"
            output="${dir}/fifo"
            mkfifo ${output}
            (
                shift # Pop `man`
                # width-4 for: gutter, newline select, plus minor margin
                @mandoc@ \
                    -T utf8 \
                    -O "width=$(($kak_window_width - 4))" \
                    "$@" | col -b -x \
                    > ${output} 2>&1 &
            ) > /dev/null 2>&1 < /dev/null

            printf '
                edit -fifo %q *%q*
                hook -always -once buffer BufCloseFifo .* %%{ nop %sh{ rm -r %q } }
            ' \
                "${output}" "${*}" \
                "${dir}"

        }

        set-option window manpage %arg{@}
        set-option window filetype man
    }

    # Improve man completion
    complete-command man shell-script-candidates %{
        find -L ${MANPATH//:/ } -name '*.[1-8]*' |
            sed 's,^.*/\(.*\)\.\([1-8][a-zA-Z]*\).*$,\1(\2),' }

}
