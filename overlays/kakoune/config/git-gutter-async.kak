hook global -group git-gutter-setup BufCreate /.* %{
  add-highlighter buffer/git-diff flag-lines Default git_diff_flags
  try %{ git show-diff }

  hook buffer -group git-gutter-buffer FocusIn .* %{
    try %{ git update-diff }
  }
  hook buffer -group git-gutter-buffer BufReload .* %{
    try %{ git update-diff }
  }
  hook buffer -group git-gutter-buffer BufWritePost .* %{
    try %{ git update-diff }
  }
  hook buffer -group git-gutter-buffer NormalIdle .* %{
    try %{ git update-diff }
  }
}
