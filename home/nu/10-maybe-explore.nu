export-env {
  $env.prev = (0..4 | each --keep-empty {|| null})
  $env.config = ($env.config | update hooks.display_output {|| {|| maybe_explore}})

  $env.ENV_CONVERSIONS = ($env | get -i ENV_CONVERSIONS | default {} | merge {
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
  let data = ($in)
  $env.peek_output = (
    try {
      let expanded = ($data | table -e | into string)
      if (term size).rows < ($expanded | size).lines {
        $data | explore -p
      } else if ($data | describe) == closure {
        view source $data | nu-highlight
      }
    }
  )
  $env.prev = ([$data] ++ $env.prev | take 5)
  $data |
    if (term size).columns >= 100 { table -e } else { table }
}
