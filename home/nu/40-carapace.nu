let carapace_completer = {|spans|
    carapace $spans.0 nushell $spans | from json
}

let-env config = ($env.config | update completions.external.completer {$carapace_completer})
