let-env prev = (0..4 | each --keep-empty {null})

def v [index:int=0] {
  $env.prev | get -i $index
}

def-env maybe_explore [] {
  let-with-metadata data metadata = $in
  $env.peek_output = (
    try {
      let expanded = ($data | table -e | into string)
      if (term size).rows < ($expanded | size).lines {
        $data | set-metadata $metadata | explore -p
      } else if ($data | describe) == closure {
        view-source $data
      }
    }
  )
  $env.prev = ([$data] ++ $env.prev | take 5)
  $data |
    set-metadata $metadata |
    if (term size).columns >= 100 { table -e } else { table }
}

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
