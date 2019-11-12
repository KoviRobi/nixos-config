let
  inherit (builtins) listToAttrs concatMap attrNames readDir;

  /* From <nixpkgs/lib/attrsets> */
  nameValuePair = name: value: { inherit name value; };
  filterAttrs = pred: set:
    listToAttrs
    (concatMap
      (name: let v = set.${name};
             in if pred name v
                then [(nameValuePair name v)]
                else [])
      (attrNames set));
  /* End <nixpkgs/lib/attrsets> */

  overlayDir = /etc/nixos/overlays;
  overlayDirContents = readDir overlayDir;
  regulars = filterAttrs (k: v: v == "regular") overlayDirContents;
  names = attrNames regulars;
  files = map (n: overlayDir + ("/" + n)) names;
in
map import files
