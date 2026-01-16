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
