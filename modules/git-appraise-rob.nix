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
  rob = false;
  nginx-port = 8080;
  git-appraise-rob-port = 8078;
  git-appraise-rob-listen = "${config.networking.hostName}:${toString git-appraise-rob-port}";
  user = "git-appraise-rob";
  group = "git-appraise-rob";

  git-appraise-web-rob = pkgs.buildGoModule rec {
    pname = "git-appraise-rob";
    version = "unstable-2024-09-08";

    src = pkgs.fetchFromGitHub {
      owner = "KoviRobi";
      repo = "git-appraise";
      rev = "845ef3274c9a6bcd2304e0d9175943075c6383e6";
      hash = "sha256-l2svLwmGXdBwWZ97zspCQUkZmiZEfO583VPUyaDjGjs=";
    };

    vendorHash = "sha256-zkfmILpUvkJMUSXqHOJ6ZKhPUNjoQ3E8NMe5Tn4/teY=";

    ldflags = [
      "-s"
      "-w"
    ];

    meta = with lib; {
      description = "Distributed code review system for Git repos";
      homepage = "https://github.com/KoviRobi/git-appraise";
      license = licenses.asl20;
      maintainers = with maintainers; [ kovirobi ];
      mainProgram = "git-appraise";
    };
  };

  git-appraise-web-upstream = pkgs.buildGoModule rec {
    pname = "git-appraise-web";
    version = "unstable-2024-09-08";

    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = pname;
      rev = "5cf242be17d4ea89bb17ea5b3e6a20e4d34d8435";
      sha256 = "sha256-qtOSTuvW0lBOQlwl/v6v8w8+Ia3w7pdMR+yHHWabDZk=";
    };

    vendorHash = "sha256-7JhHFaBaessek2XA6/6beFCtQ5LexhGeVLax7xS5DFE=";

    ldflags = [
      "-s"
      "-w"
    ];

    meta = with lib; {
      description = " Web UI for git-appraise";
      homepage = "https://github.com/google/git-appraise-web";
      license = licenses.asl20;
      maintainers = with maintainers; [ kovirobi ];
      mainProgram = "git-appraise-web";
    };
  };
  git-appraise-web = if rob then git-appraise-web-rob else git-appraise-web-upstream;
in
{
  services.nginx = {
    enable = true;
    additionalModules = [
      pkgs.nginxModules.spnego-http-auth
    ];
    recommendedProxySettings = true;

    gitweb.enable = true;
    gitweb.group = group;

    virtualHosts."_" = {
      default = true;
      listen = [
        {
          addr = config.networking.hostName;
          port = nginx-port;
        }
      ];
      locations =
        let
          authConf = lib.optionalString auth ''
            auth_gss on;
            auth_gss_keytab /tmp/krb5_nginx;
          '';
        in
        {
          "/" = {
            proxyPass = "http://${git-appraise-rob-listen}";
          };
          "~ ^(/git/.*)$" = {
            priority = 900;
            # This is where the repositories live on the server
            root = "/srv";

            # Setup FastCGI for Git HTTP Backend
            extraConfig =
              authConf
              + ''fastcgi_pass        ''
              + config.services.fcgiwrap.instances.git-http-backend.socket.type
              + ":"
              + config.services.fcgiwrap.instances.git-http-backend.socket.address
              + ''
                ;
                            include             ${config.services.nginx.package}/conf/fastcgi_params;
              '';

            fastcgiParams = {
              # All parameters below will be forwarded to fcgiwrap which then starts
              # the git http proces with the the params as environment variables except
              # for SCRIPT_FILENAME. See "man git-http-server" for more information on them.
              SCRIPT_FILENAME = "${pkgs.git}/bin/git-http-backend";
              GIT_PROJECT_ROOT = "/srv";
              # CAREFULL! only include this option if you want all the repos in $root to
              # to be read.
              GIT_HTTP_EXPORT_ALL = "";
              # use the path from the regex in the location
              PATH_INFO = "$1";
            };
          };
          ${config.services.nginx.gitweb.location} = {
            extraConfig = authConf;
          };
        };
    };
  };

  services.gitweb.gitwebTheme = true;
  services.gitweb.projectroot = "/srv/git";

  services.fcgiwrap.instances.git-http-backend = {
    process.user = user;
    process.group = group;
    socket.user = "nginx";
    socket.group = "nginx";
  };

  users.users.${user} = {
    isSystemUser = true;
    inherit group;
  };
  users.groups.${group} = { };

  systemd.services.git-appraise-rob = {
    description = "Git Appraise Rob Web";

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = [
      pkgs.git
      git-appraise-web
    ];

    environment = {
      HOME = "%S/git-appraise-rob";
      XDG_CONFIG_HOME = "%S/git-appraise-rob/.config";
    };

    serviceConfig = {
      CacheDirectory = "git-appraise-rob";
      User = user;
      Group = group;
      ExecStart = "${git-appraise-web}/bin/git-appraise-web --port ${toString git-appraise-rob-port}";
      LimitNOFILE = 4096;
      StandardOutput = "journal";
      StateDirectory = "git-appraise-rob";
      WorkingDirectory = "/srv/git";
    };
  };

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
          Port 29418
          HostKey /etc/ssh/ssh_host_ed25519_key_git
          ForceCommand ${cmd}
        '';
      in
      {
        ExecStart = "${pkgs.openssh}/bin/sshd -D -f ${conf} -p 29418 -o PidFile=%S/sshd.pid";
        CacheDirectory = "git-appraise-rob";
        StateDirectory = "git-appraise-rob";
        WorkingDirectory = "/srv/git";
      };

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
  };

  networking.firewall.allowedTCPPorts = lib.optional publish nginx-port;
}
