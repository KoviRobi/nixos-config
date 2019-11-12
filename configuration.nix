{...}:
{ imports = [ (./configurations + ("/" + builtins.getEnv "NixOS_Configuration"))
              (./targets + ("/" + builtins.getEnv "NixOS_Target")) ];
}
