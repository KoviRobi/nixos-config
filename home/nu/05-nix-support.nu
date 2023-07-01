export-env {
  $env.ENV_CONVERSIONS = ($env | get -i ENV_CONVERSIONS | default {} | merge {
    NIX_PATH : ({
      from_string: {|str|
        $str | split row : | parse -r '(?:(?<name>[[:alnum:]-_]*)=)?(?<path>.*)'
      }
      to_string: {|table|
        $table | each {|cols|
          if "name" in $cols and $cols.name != "" {
            $"($cols.name)=($cols.path)"
          } else if "path" in $cols {
            $cols.path
          }
        } | str join :
      }
    })
  })
}
