def "ip a" [...rest] { ip --json address $rest | from json }
def "ip l" [...rest] { ip --json link $rest | from json }
def "ip r" [...rest] { ip --json route $rest | from json }

def "ns" [...rest] { nix search --json $rest | from json }
def "nev" [
  pkg # Package to evaluate in nixpkgs, e.g. nushell
  flake? = "nixpkgs" # Flake to use, defaults to nixpkgs
] {
  nix eval --json $"($flake)#($pkg).drvAttrs" | from json
}
def nixos-version [] { ^nixos-version --json | from json }
