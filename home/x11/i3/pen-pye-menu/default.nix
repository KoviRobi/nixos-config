{ lib
, pye-menu
, i3
, mpc_cli
, systemd
, python3 # following are from python3.pkgs.*
, pycairo
, buildPythonApplication
}:
buildPythonApplication rec {
  pname = "pen-pye-menu";
  version = "1.0";
  src = ./src;
  propagatedBuildInputs = [ pye-menu pycairo ];

  i3msg = "${i3}/bin/i3-msg";
  mpc = "${mpc_cli}/bin/mpc";
  loginctl = "${systemd}/bin/loginctl";
  preConfigure = ''
    substituteAllInPlace general_menu
    substituteAllInPlace window_menu
  '';

  strictDeps = false;

  meta = with lib; {
    description = "Python library and application for makig pie menus";
    license = licenses.mit;
    maintainers = with maintainers; [ kovirobi ];
  };
}
