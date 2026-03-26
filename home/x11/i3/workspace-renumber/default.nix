{
  lib,
  i3ipc, # python3.pkgs.
  buildPythonApplication, # python3.pkgs.
  setuptools, # python3.pkgs
}:
buildPythonApplication {
  pname = "workspace-renumber";
  version = "1.1";
  src = ./src;
  pyproject = true;
  build-system = [ setuptools ];
  propagatedBuildInputs = [ i3ipc ];

  strictDeps = false;

  meta = with lib; {
    description = "Renumber i3/sway workspaces";
    license = licenses.mit;
    maintainers = with maintainers; [ kovirobi ];
  };
}
