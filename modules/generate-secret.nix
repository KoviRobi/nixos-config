pkgs: attrs:
  with pkgs;
  let generate-secret-sh = builtins.toFile "generate-secret" ''
        PATH=$coreutils/bin
        tr -dc '[:alnum:]' < /dev/urandom | head -c$secretChars > $out
      '';
      foo = trace generate-secret-sh;
      defaultAttrs = {
        system = builtins.currentSystem;
        builder = "${pkgs.bash}/bin/bash";
        preferLocalBuild = true;
        allowSubstitutes = false;
        secretChars = 32;
        args = [ generate-secret-sh ];
        inherit (pkgs) coreutils;
      };
      drv = derivation (defaultAttrs // attrs);
      bar = trace "${drv}";
  in builtins.readFile "${drv}"
