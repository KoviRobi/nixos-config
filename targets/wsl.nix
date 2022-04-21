{
  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "rmk";
    startMenuLaunchers = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker.enable = true;
  };
  services.xserver.dpi = 100;
}
