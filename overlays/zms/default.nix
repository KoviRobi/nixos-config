{ inputs }:
final: prev: {
  inherit (inputs.zmx.packages.${final.system}) zmx;

  osc7 = final.writeShellApplication {
    name = "osc7";
    text = builtins.readFile ./osc7.sh;
  };

  osc7-spawn = final.writeShellApplication {
    runtimeInputs = [
      final.coreutils
      final.osc7
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
      final.sway
      final.jq
    ];
    text = builtins.readFile ./zms.sh;
  };
}
