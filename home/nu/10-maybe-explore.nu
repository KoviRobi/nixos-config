export-env {
  let-env prev = (0..4 | each --keep-empty {|| null})
  let-env config = ($env.config | update hooks.display_output {|| {|| maybe_explore}})

  let-env ENV_CONVERSIONS = ($env | get -i ENV_CONVERSIONS | default {} | merge {
    prev: ({
      from_string: {}
      to_string: {}
    })
    peek_output: ({
      from_string: {}
      to_string: {}
    })
  })
}

export def v [index:int=0] {
  $env.prev | get -i $index
}

export def-env maybe_explore [] {
  let metadata = (metadata --data)
  $env.peek_output = (
    try {
      let expanded = ($metadata.data | table -e | into string)
      if (term size).rows < ($expanded | size).lines {
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
