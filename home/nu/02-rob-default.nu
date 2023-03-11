export-env {
  let-env config = ($env.config | update cd.abbreviations true)
  let-env config = ($env.config | update table.trim {methodology: "truncating", truncating_suffix: "…"})
  let-env config = ($env.config | update history.file_format "sqlite")
  let-env config = ($env.config | update show_banner false)
  let-env config = ($env.config | update menus {|cfg|
                      $cfg.menus | update marker {|menu|
                        "\r" + $menu.marker}})
}
