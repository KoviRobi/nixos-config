{
  auth,
  publish ? false,
}:
{
  config,
  lib,
  pkgs,
  ...
}:

let
  caddy-port = 80;
  caddy-listen = "${config.networking.hostName}:${toString caddy-port}";
  forgejo-port = 3000;
  forgejo-listen = "${config.networking.hostName}:${toString forgejo-port}";
  forgejo-db-secret = "/etc/secrets/forgejo-db";
in
{
  services = {
    caddy = {
      enable = true;
      email = "robertkovacsics@carallon.com";
      globalConfig = ''
        auto_https off
        http_port ${toString caddy-port}
      '';
      virtualHosts."http://" = {
        listenAddresses = [
          config.networking.hostName
          "localhost"
        ];
        extraConfig = ''
          reverse_proxy http://${forgejo-listen}
        '';
      };
    };

    forgejo = {
      enable = true;
      database = {
        passwordFile = forgejo-db-secret;
        type = "postgres";
        inherit (config.services.postgresql.settings) port;
      };
      repositoryRoot = "/srv/git";
      settings.server.HTTP_PORT = forgejo-port;
      settings.server.ROOT_URL = "http://${caddy-listen}";
    };

    postgresql.enable = true;
  };

  security.pam.services.forgejo = {
    unixAuth = false;
  };

  networking.firewall.allowedTCPPorts = lib.optionals publish [
    caddy-port
  ];

  systemd.services.generate-forgejo-db-secret = {
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${config.nix.settings.secret-key-files})

      </dev/random ${pkgs.coreutils}/bin/tr -dc '[:print:]' | \
        ${pkgs.coreutils}/bin/head -c12 >${forgejo-db-secret}

      chown forgejo:forgejo ${forgejo-db-secret}
      chmod 0600 ${config.nix.settings.secret-key-files}
    '';
    wantedBy = [ "forgejo.service" ];
    unitConfig = {
      Type = "oneshot";
      ConditionPathExists = "!${forgejo-db-secret}";
      Before = [ "forgejo.service" ];
    };
  };
}
