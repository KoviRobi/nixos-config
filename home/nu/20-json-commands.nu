export def "ip a" [...rest] { ip --json address $rest | from json }
export def "ip l" [...rest] { ip --json link $rest | from json }
export def "ip r" [...rest] { ip --json route $rest | from json }

export def "ns" [...rest] { nix search --json $rest | from json }
export def "nev" [
  pkg # Package to evaluate in nixpkgs, e.g. nushell
  flake? = "nixpkgs" # Flake to use, defaults to nixpkgs
] {
  nix eval --json $"($flake)#($pkg).drvAttrs" | from json
}
export def nixos-version [] { ^nixos-version --json | from json }
