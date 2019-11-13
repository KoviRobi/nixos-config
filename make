# vim: syntax=sh sw=2 ts=2 sts=2 et
set -x
artefact=os
action=switch
unset extraArgs profile NixOS_Configuration NixOS_Target

config_from_name() {
  case $1 in
    orfina)
      NixOS_Configuration=cl.cam.ac.uk.nix
      ;;
    *)
      return 1;
  esac
}

while [ $# -gt 0 ]; do
  if ! config_from_name $1; then
    case $1 in
      boot|switch|dry-run)
        action=$1
        ;;
      *-iso)
        NixOS_Configuration=${1%-iso}
        NixOS_Target=iso-image.nix
        artefact=iso
        ;;
      iso)
        NixOS_Target=iso-image.nix
        artefact=iso
        ;;
      *-sd-image)
        NixOS_Configuration=${1%-sd-image}
        NixOS_Target=sd-image.nix
        artefact=sd
        ;;
      sd)
        NixOS_Target=sd-image.nix
        artefact=sd
        ;;
      -*)
        extraArgs="$extraArgs $1"
        ;;
      *)
        echo "Unknown option $1";
        exit 1
    esac
  fi
  shift
done

if [ -z "$NixOS_Configuration" ]; then
  config_from_name `hostname -s`
fi

if [ -z "$NixOS_Target" ]; then
  case `findmnt --noheadings --raw --output=UUID /` in
    b50309e4-2660-4306-8c2f-73d50af1bbf8)
      NixOS_Target=yoga-book-sd.nix
      ;;
    397a0f75-94e2-46ab-9993-6d6d02506420)
      NixOS_Target=yoga-book-virtualbox.nix
      ;;
    d5551e12-5224-4913-a2d5-72d5e4f1337e)
      NixOS_Target=orfina.nix
      profile=cl
      ;;
    *)
      echo "Don't know which target you want";
      exit 1
      ;;
  esac
fi

export NixOS_Configuration NixOS_Target

echo $NixOS_Configuration-$NixOS_Target

case $artefact in
  os)
    sudo --preserve-env=NixOS_Configuration,NixOS_Target \
      nixos-rebuild ${profile:+-p} ${profile} ${action} ${extraArgs}
    ;;
  iso)
    nix build -f '<nixpkgs/nixos>' config.system.build.isoImage ${extraArgs} -o result-iso
    ;;
  sd)
    nix build -f '<nixpkgs/nixos>' config.system.build.sdImage ${extraArgs} -o result-sd
    ;;
esac
