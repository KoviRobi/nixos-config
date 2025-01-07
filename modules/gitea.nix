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
  gitea-port = 3000;
  gitea-listen = "${config.networking.hostName}:${toString gitea-port}";
  gitea-db-secret = "/etc/secrets/gitea-db";
  git-sshd-port = 29418;
  user = "gitea";
  group = "gitea";
  uid = 999;
  gid = 999;
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
          reverse_proxy http://${gitea-listen}
        '';
      };
    };

    gitea = {
      enable = true;
      database = {
        passwordFile = gitea-db-secret;
        type = "postgres";
        inherit (config.services.postgresql.settings) port;
      };
      repositoryRoot = "/srv/git";
      settings.server.HTTP_PORT = gitea-port;
      settings.server.ROOT_URL = "http://${caddy-listen}";
      inherit user group;
    };

    postgresql.enable = true;
  };

  security.pam.services.gitea = {
    unixAuth = false;
  };

  users.users.${user} = {
    isSystemUser = true;
    inherit uid;
    inherit group;
  };
  users.groups.${group} = { inherit gid; };

  security.sudo.extraRules = [
    {
      users = [ "ALL" ];
      groups = [ "ALL" ];
      commands = [
        {
          command = "${pkgs.git}/bin/git-shell";
          options = [ "NOPASSWD" ];
        }
      ];
      runAs = "${user}:${group}";
    }
  ];
  systemd.services.git-sshd = {
    description = "Git SSH endpoint";
    serviceConfig =
      let
        cmd = pkgs.writeShellScript "git-sshd" ''
          sudo -n -u "${user}" -g "${group}" ${pkgs.git}/bin/git-shell -c "$SSH_ORIGINAL_COMMAND"
        '';
        conf = pkgs.writeText "git-sshd_config" ''
          AuthorizedPrincipalsFile none
          Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
          PasswordAuthentication yes
          PermitRootLogin no
          PrintMotd no
          StrictModes yes
          UseDns no
          UsePAM yes
          X11Forwarding no
          Banner none

          AddressFamily any
          Port ${toString git-sshd-port}
          HostKey /etc/ssh/ssh_host_ed25519_key_git
          ForceCommand ${cmd}
        '';
      in
      {
        ExecStart = "${pkgs.openssh}/bin/sshd -D -f ${conf} -p 29418 -o PidFile=%S/sshd.pid";
        CacheDirectory = "gitea";
        StateDirectory = "gitea";
        WorkingDirectory = "/srv/git";
      };

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };

  networking.firewall.allowedTCPPorts = lib.optionals publish [
    caddy-port
    git-sshd-port
  ];

  systemd.services.generate-gitea-db-secret = {
    script = ''
      ${pkgs.coreutils}/bin/mkdir -p $(${pkgs.coreutils}/bin/dirname ${config.nix.settings.secret-key-files})

      </dev/random ${pkgs.coreutils}/bin/tr -dc '[:print:]' | \
        ${pkgs.coreutils}/bin/head -c12 >${gitea-db-secret}

      chown ${user}:${group} ${gitea-db-secret}
      chmod 0600 ${config.nix.settings.secret-key-files}
    '';
    wantedBy = [ "nix-daemon.service" ];
    unitConfig = {
      Type = "oneshot";
      ConditionPathExists = "!${config.nix.settings.secret-key-files}";
      Before = [ "nix-daemon.service" ];
    };
  };
}
