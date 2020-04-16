{ lib
, python3
, i3ipc # python3.pkgs.
, buildPythonApplication # python3.pkgs.
}:
buildPythonApplication rec {
  pname = "workspace-renumber";
  version = "1.0";
  src = ./src;
  propagatedBuildInputs = [ i3ipc ];

  strictDeps = false;

  meta = with lib; {
    description = "Renumber i3 workspaces";
    license = licenses.mit;
    maintainers = with maintainers; [ kovirobi ];
  };
}
