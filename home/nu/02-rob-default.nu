export-env {
  $env.config = ($env.config | update table.trim {methodology: "truncating", truncating_suffix: "…"})
  $env.config = ($env.config | update history.file_format "sqlite")
  $env.config = ($env.config | update show_banner false)
  $env.config = ($env.config | update menus {|cfg|
                      $cfg.menus | update marker {|menu|
                        "\r" + $menu.marker}})
}
