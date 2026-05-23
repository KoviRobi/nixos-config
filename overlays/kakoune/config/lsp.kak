provide-module lsp %{
  eval %sh{@kakoune-lsp@}
  map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'
  map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
  map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
  map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
  map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
  map global object t '<a-semicolon>lsp-object Class Interface Struct<ret>' -docstring 'LSP class interface or struct'
  map global object d '<a-semicolon>lsp-diagnostic-object --include-warnings<ret>' -docstring 'LSP errors and warnings'
  map global object D '<a-semicolon>lsp-diagnostic-object<ret>' -docstring 'LSP errors'

  hook global BufSetOption filetype=c   %{ map global goto "'" '<esc>: c-alternative-file<ret>'   -docstring 'C alternative file' }
  hook global BufSetOption filetype=cpp %{ map global goto "'" '<esc>: cpp-alternative-file<ret>' -docstring 'C++ alternative file' }

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
}
