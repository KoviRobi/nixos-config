{ inputs }:
final: prev: {
  inherit (inputs.zmx.packages.${final.system}) zmx;

  workspaces = final.writeShellApplication {
    name = "workspaces";
    runtimeInputs = [
      final.sway
      final.jq
    ];
    text = builtins.readFile ./workspaces.sh;
  };

  osc7 = final.writeShellApplication {
    name = "osc7";
    text = builtins.readFile ./osc7.sh;
  };

  osc7-spawn = final.writeShellApplication {
    runtimeInputs = [
      final.coreutils
      final.osc7
      final.zmshosts
    ];
    name = "osc7-spawn";
    text = builtins.readFile ./osc7-spawn.sh;
  };

  zms = final.writeShellApplication {
    name = "zms";
    runtimeInputs = [
      final.coreutils
      final.fzf
      final.gnused
      final.osc7
      final.osc7-spawn
      final.zmx
      final.workspaces
    ];
    text = builtins.readFile ./zms.sh;
  };

  zmshosts = final.writeShellApplication {
    name = "zmshosts";
    runtimeInputs = [ ];
    text = builtins.readFile ./zmshosts.sh;
  };

  zmssh = final.writeShellApplication {
    name = "zmssh";
    runtimeInputs = [
      final.coreutils
      final.fzf
      final.gnused
      final.openssh
      final.zmshosts
    ];
    text = builtins.readFile ./zmssh.sh;
  };
}
