{
  inputs.parent.url = "../..";
  outputs = { self, parent, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells.default =
        let
          inherit (parent.legacyPackages.${system}.nixpkgs) mkShell apf2cookie poetry pyright;
        in
        mkShell {
          inputsFrom = [ apf2cookie ];
          packages = [ poetry pyright ];
        };
    });
}
