{
  lib,
  pkgs,
  ...
}:
{
  systemd.user.services.ringboard-server = {
    Unit = {
      Description = "Ringboard server";
      Documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];
      After = [ "multi-user.target" ];
    };
    Install.WantedBy = [ "default.target" ];
    Service = {
      Type = "notify";
      ExecStart = "${pkgs.ringboard}/bin/ringboard-server";
      Environment = "RUST_LOG=trace";
      Restart = "on-failure";
      Slice = "session-ringboard.slice";
    };
  };

  systemd.user.services.ringboard-listener = {
    Unit = {
      Description = "Ringboard clipboard listener";
      Documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];
      Requires = [ "ringboard-server.service" ];
      After = [
        "ringboard-server.service"
        "graphical-session.target"
      ];
      BindsTo = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      Type = "exec";
      ExecStart = "${pkgs.ringboard}/bin/ringboard-x11";
      Environment = "RUST_LOG=trace";
      Restart = "on-failure";
      Slice = "session-ringboard.slice";
    };
  };

  systemd.user.slices.session-ringboard = {
    Unit.Description = "Ringboard clipboard services";
  };

  home.packages = [
    pkgs.ringboard
  ];
}
