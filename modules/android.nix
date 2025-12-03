{
  programs.adb.enable = true;
  users.users.default-user.extraGroups = [
    "adbusers"
    "kvm"
  ];
}
