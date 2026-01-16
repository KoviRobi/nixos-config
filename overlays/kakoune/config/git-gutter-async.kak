provide-module git-gutter-async %{
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
}
