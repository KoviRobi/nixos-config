export-env {
  $env.prev = (0..4 | each --keep-empty {|| null})
  $env.config = ($env.config | update hooks.display_output {|| {|| maybe_explore}})

  $env.ENV_CONVERSIONS = ($env | get -i ENV_CONVERSIONS | default {} | merge {
    prev: ({
      from_string: {|s| null}
      to_string: {|s| ""}
    })
    peek_output: ({
      from_string: {|s| null}
      to_string: {|s| ""}
    })
  })
}

export def v [index:int=0] {
  $env.prev | get -i $index
}

export def --env maybe_explore [] {
  let metadata = (metadata --data)
  $env.peek_output = (
    try {
      let expanded = ($metadata.data | table -e | into string)
      if (term size).rows < ($expanded | str stats).lines {
        $metadata.data | set-metadata $metadata | explore -p
      } else if ($metadata.data | describe) == closure {
        view source $metadata.data | nu-highlight
      }
    }
  )
  $env.prev = ([$metadata.data] ++ $env.prev | take 5)
  $metadata.data |
    set-metadata $metadata |
    if (term size).columns >= 100 { table -e } else { table }
}
