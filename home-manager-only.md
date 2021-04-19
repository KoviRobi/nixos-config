# Install home-manager

	nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
	nix-channel --update

	export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

Install Home Manager and create the first Home Manager generation:

	nix-shell '<home-manager>' -A install

Once finished, Home Manager should be active and available in your user
environment.

If you do not plan on having Home Manager manage your shell configuration then
you must source the

	source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh

file in your shell configuration. Unfortunately, in this specific case we
currently only support POSIX.2-like shells such as Bash or Z shell.

Get overlays working

	ln -s ~/nixos/overlays/ ~/.config/nixpkgs/

Modify the home-manager config (~/.config/nixpkgs/home.nix) to include

```
{ config, pkgs, lib, ... }:
{
  // ...

  imports = [ ~/nixos/home/home-manager-only.nix ];

  nixos = {
    users.users.default-user.uid = XXX;
  };
  
}
```

then edit packages/base.nix (e.g. remove emacs; seems to require removing git).
And e.g. edit home/default.nix to not require X11. Then

```
home-manager switch
```
