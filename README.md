# My NixOS Configuration
I tried to break it up to (1) 'modules', reused but sometimes parametric files;
(2) 'configurations' or settings for a class of machine (e.g. netbook, work,
home); (3) 'targets' which are the details of a specific install (e.g.  mount
points, system.stateVersion, host name) and it includes 'abstract' targets such
as an iso-image; and (4) 'home', which are the files managed by home-manager.

I use the configuration.nix file as the entry, which uses the
NixOS_Configuration and NixOS_Target environment variables. The
configuration.nix symlinks the configurations/default.nix and
targets/default.nix to the one used to build the current configuration, so that
those environment variables need not be set at all times.

I use the `make` shell script to make something. E.g. to create an ISO for the
unstable nixpkgs, I could use `./make configurations/yoga-book.nix iso -I\
nixpkgs=channel:nixos-unstable` (assuming I have a channel named
nixos-unstable).


## Home-manager only

To extract the commands from this section, just run
```
sed -n -e '/^## Home-manager only/,/^#\{1,2\}/{/^\t/p}' < README.md
```

Install home-manager

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
