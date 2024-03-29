final: prev:
{
  acme-lsp = final.buildGoModule {
    pname = "acme-lsp";
    version = "0.11.0-unstable-2023-07";
    src = final.fetchFromGitHub {
      owner = "KoviRobi";
      repo = "acme-lsp";
      rev = "89d4211d1b053cb330f3c330d4b7c5b5c0f34b70";
      hash = "sha256-Dkiu6CNzo2U0WI4bhwj3SoPWf1FW8fHuNxXKCFjWDGo=";
    };

    meta = with final.lib; {
      description = "Acme language-server protocol client";
      homepage = "https://github.com/fhs/acme-lsp";
      license = licenses.mit;
      maintainers = with maintainers; [ kovirobi ];
      platforms = platforms.unix;
    };
    vendorHash = "sha256-TraHSOkSFHv5spIZyo2aqWEq98idoxS4vY4YU1jUZIU=";
    subPackages = [ "cmd/L" "cmd/acme-lsp" ];
    postInstall = ''
      mkdir -p $out/bin
      for cmd in comp def fmt hov impls refs rn sig syms type assist ws ws+ ws-; do
        echo '#!${final.plan9port}/plan9/bin/rc'  > $out/bin/L$cmd
        echo exec $out/bin/L $cmd '$*'           >> $out/bin/L$cmd
        chmod +x $out/bin/L$cmd
      done
      for sub in -e -E; do
        echo '#!${final.plan9port}/plan9/bin/rc'  > $out/bin/L$cmd
        echo exec $out/bin/L comp $sub '$*'      >> $out/bin/L$cmd
      done
    '';
  };

  acre = final.rustPlatform.buildRustPackage rec {
    pname = "acre";
    version = "0.5.5";

    src = final.fetchFromGitHub {
      owner = "mjibson";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-/RzNkprdMFSvSkMJ9hEH631F4/CT5CNeP6+EQyOv6/I=";
    };

    cargoHash = "sha256-0qNS/BIgoHnVNXz3fpxnoHuKS62S765ZwhzuWKxxNBY=";

    meta = {
      description = "Acme language server client written in rust";
      homepage = "https://github.com/mjibson/acre";
      license = final.lib.licenses.asl20;
      maintainers = [ final.lib.maintainers.kovirobi ];
    };
  };
}
