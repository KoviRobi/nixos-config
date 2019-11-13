# My NixOS Configuration
I tried to break it up to (1) 'modules', reused but sometimes parametric files;
(2) 'configurations' or settings for a class of machine (e.g. netbook, work,
home); (3) 'targets' which are the details of a specific install (e.g.  mount
points, system.stateVersion, host name) and it includes 'abstract' targets such
as an iso-image; and (4) 'home', which are the files managed by home-manager.

I use the configuration.nix file as the entry, which uses the
NixOS_Configuration and NixOS_Target environment variables.

I use the `make` shell script to make something.
