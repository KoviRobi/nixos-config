provide-module man-improved %{
    define-command -override -hidden -params ..3 man-impl %{ evaluate-commands %sh{
        buffer_name="$1"
        if [ -z "${buffer_name}" ]; then
            exit
        fi
        shift
        manout=$(mktemp "${TMPDIR:-/tmp}"/kak-man.XXXXXX)
        manerr=$(mktemp "${TMPDIR:-/tmp}"/kak-man.XXXXXX)
        colout=$(mktemp "${TMPDIR:-/tmp}"/kak-man.XXXXXX)
        env MANWIDTH=$(($kak_window_width - 1)) man "$@" > "$manout" 2> "$manerr"
        retval=$?
        if command -v col >/dev/null; then
            col -b -x > ${colout} < ${manout}
        else
            sed 's/.//g' > ${colout} < ${manout}
        fi
        rm ${manout}

        if [ "${retval}" -eq 0 ]; then
            printf %s\\n "
                    edit -scratch %{*$buffer_name ${*}*}
                    execute-keys '%|cat<space>${colout}<ret>gk'
                    nop %sh{ rm ${colout}; rm ${manerr} }
                    set-option buffer filetype man
                    set-option window manpage $buffer_name $*
            "
        else
            printf '
                fail %%{%s}
                nop %%sh{ rm "%s"; rm "%s" }
            ' "$(cat "$manerr")" "${colout}" "${manerr}"
        fi
    } }

    # Improve man completion
    complete-command man shell-script-candidates %{
        find -L $(manpath | sed 's/:/ /g') -name '*.[1-8]*' |
            sed 's,^.*/\(.*\)\.\([1-8][a-zA-Z]*\).*$,\1(\2),' }
}
