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

  # Forgejo runner
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.local-forgejo-runner = {
      enable = true;
      name = "local-runner";
      tokenFile = "/etc/secrets/forgejo-runner-token";
      url = "http://localhost/";
      labels = [
        "node-22:docker://node:22-bookworm"
        "native:host"
      ];
      hostPackages = [
        pkgs.bash
        pkgs.coreutils
        pkgs.curl
        pkgs.gawk
        pkgs.git-cliff
        pkgs.gitMinimal
        pkgs.gnused
        pkgs.go
        pkgs.jq
        pkgs.nodejs
        pkgs.wget
      ];
      settings = {
        insecure = true; # localhost
        container.valid_volumes = [ "**" ];
      };
    };
  };
}
