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

Install home-manager

```bash
nix shell home-manager
home-manager init
```

Once finished, Home Manager should be active and available in your user
environment.

Get overlays working

```bash
ln -s ~/nixos/overlays/ ~/.config/nixpkgs/
```

Modify the home-manager config (~/.config/home-manager/flake.nix) to include

```nix
diff --git a/flake.nix b/flake.nix
index b587eb5..6ae4a68 100644
--- a/flake.nix
+++ b/flake.nix
@@ -8,10 +8,14 @@
       url = "github:nix-community/home-manager";
       inputs.nixpkgs.follows = "nixpkgs";
     };
+    nixos-config = {
+      url = "github:KoviRobi/nixos-config";
+      inputs.nixpkgs.follows = "nixpkgs";
+    };
+    nixGL = {
+      url = "github:nix-community/nixGL";
+      inputs.nixpkgs.follows = "nixpkgs";
+    };
   };

   outputs =
-    { nixpkgs, home-manager, ... }:
+    { nixpkgs, home-manager, nixos-config, nixGL, ... }:
     let
       system = "aarch64-linux";
       pkgs = nixpkgs.legacyPackages.${system};
@@ -22,7 +26,13 @@

         # Specify your home configuration modules here, for example,
         # the path to your home.nix.
-        modules = [ ./home.nix ];
+        modules = [
+          "${nixos-config}/home/home-manager-only.nix"
+          ./home.nix
+          (
+            { config, ... }:
+            {
+              nixGL.packages = nixGL.packages;
+              home.packages = [
+                (config.lib.nixGL.wrap pkgs.ghostty // { meta.priority = 1; })
+              ];
+              nixpkgs = {
+                overlays = builtins.attrValues nixos-config.overlays;
+                config.allowUnfree = true;
+              };
+            }
+          )
+        ];

         # Optionally use extraSpecialArgs
         # to pass through arguments to home.nix
```

then edit packages/base.nix (e.g. remove emacs; seems to require removing git).
And e.g. edit home/default.nix to not require X11. Then

```bash
home-manager switch
```
