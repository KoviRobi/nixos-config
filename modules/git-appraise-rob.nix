{ auth, publish ? false }:
{ config, lib, pkgs, ... }:

let
  nginx-port = 8080;
  git-appraise-rob-port = 8078;
  git-appraise-rob-listen = "${config.networking.hostName}:${toString git-appraise-rob-port}";

  git-appraise-rob =
    pkgs.buildGoModule rec {
      pname = "git-appraise-rob";
      version = "unstable-2024-09-08";

      src = pkgs.fetchFromGitHub {
        owner = "KoviRobi";
        repo = "git-appraise";
        rev = "845ef3274c9a6bcd2304e0d9175943075c6383e6";
        hash = "sha256-l2svLwmGXdBwWZ97zspCQUkZmiZEfO583VPUyaDjGjs=";
      };

      vendorHash = "sha256-zkfmILpUvkJMUSXqHOJ6ZKhPUNjoQ3E8NMe5Tn4/teY=";

      ldflags = [ "-s" "-w" ];

      meta = with lib; {
        description = "Distributed code review system for Git repos";
        homepage = "https://github.com/KoviRobi/git-appraise";
        license = licenses.asl20;
        maintainers = with maintainers; [ kovirobi ];
        mainProgram = "git-appraise";
      };
    };
in
{
  services.nginx = {
    enable = true;
    additionalModules = [
      pkgs.nginxModules.spnego-http-auth
    ];
    recommendedProxySettings = true;

    gitweb.enable = true;
    gitweb.group = "git-appraise-rob";

    virtualHosts."_" = {
      default = true;
      listen = [{ addr = config.networking.hostName; port = nginx-port; }];
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
            extraConfig = authConf + ''
              fastcgi_pass        '' +
              config.services.fcgiwrap.instances.git-http-backend.socket.type +
              ":" +
              config.services.fcgiwrap.instances.git-http-backend.socket.address +
              '';
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
    process.user = "git-appraise-rob";
    process.group = "git-appraise-rob";
    socket.user = "nginx";
    socket.group = "nginx";
  };

  users.users.git-appraise-rob.isSystemUser = true;
  users.users.git-appraise-rob.group = "git-appraise-rob";
  users.groups.git-appraise-rob = { };

  systemd.services.git-appraise-rob = {
    description = "Git Appraise Web";

    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    path = [
      pkgs.git
      git-appraise-rob
    ];

    environment = {
      HOME = "%S/git-appraise-rob";
      XDG_CONFIG_HOME = "%S/git-appraise-rob/.config";
    };

    serviceConfig = {
      CacheDirectory = "git-appraise-rob";
      User = "git-appraise-rob";
      Group = "git-appraise-rob";
      ExecStart = "${git-appraise-rob}/bin/git-appraise-web --port ${toString git-appraise-rob-port}";
      LimitNOFILE = 4096;
      StandardOutput = "journal";
      StateDirectory = "git-appraise-rob";
      WorkingDirectory = "/srv/git";
    };
  };

  networking.firewall.allowedTCPPorts = lib.optional publish nginx-port;
}
