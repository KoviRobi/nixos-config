$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = ($env.config | update hooks ($env.config.hooks | default [] pre_prompt))
$env.config = ($env.config | update hooks.pre_prompt ($env.config.hooks.pre_prompt | append {
  code: "
    let direnv = (/nix/store/wq5805kdns8g1wbcm4f1xkh14mvclbpj-direnv-2.32.3/bin/direnv export json | from json)
    let direnv = if ($direnv | length) == 1 { $direnv } else { {} }
    $direnv | load-env
    "
}))
