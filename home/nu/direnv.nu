$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = ($env.config | update hooks ($env.config.hooks | default [] pre_prompt))
$env.config = ($env.config | update hooks.pre_prompt ($env.config.hooks.pre_prompt | append {
  code: "
    let direnv = (/run/current-system/sw/bin/direnv export json | from json)
    let direnv = if ($direnv | describe) != nothing { $direnv } else { {} }
    $direnv | load-env
    "
}))
