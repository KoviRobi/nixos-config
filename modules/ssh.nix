# vim: set ts=2 sts=2 sw=2 et :
{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.google-authenticator ];

  security.pam.services = {
    sshd.googleAuthenticator.enable = true;
    # Set up a substack to be able to turn it off for users based on a listsfile
    sshd.rules.auth."no_google_authenticator.users" = {
      # Skip next (google-authenticator) if it is contained in the file, see
      # pam.d(3) for more details
      control = lib.mkForce "[success=1 default=ignore]";
      modulePath = "${pkgs.linux-pam}/lib/security/pam_listfile.so";
      settings = {
        item = "user";
        file = "/etc/pam/no_google_authenticator.users";
        sense = "allow";
        onerr = "fail";
      };
      order = config.security.pam.services.sshd.rules.auth.google_authenticator.order - 1;
    };
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.X11Forwarding = true;
  };
}
