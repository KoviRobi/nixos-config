# vim: syntax=sh sw=2 ts=2 sts=2 et
artefact=os
action=switch
unset extraArgs profile

config_from_name() {
  case $1 in
    orfina)
      NixOS_Configuration=cl.cam.ac.uk.nix
      ;;
    as-nixos-b)
      NixOS_Configuration=acer-as.nix
      ;;
    C930-vbox)
      NixOS_Configuration=yoga-book-virtualbox.nix
      ;;
    C930-sd)
      NixOS_Configuration=yoga-book.nix
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
        NixOS_Configuration="${1%-iso}"
        ;&
      iso)
        NixOS_Target=iso-image.nix
        artefact=iso
        ;;
      *-disk)
        NixOS_Configuration="${1%-disk}"
        ;&
      disk)
        NixOS_Target=disk-image.nix
        artefact=disk
        ;;
      # To appease Zsh completion, which tries to figure out which make we are
      # (gnu make, bsd make, etc), by calling "make -v"
      -v)
        echo "Not a make"
        exit 1
        ;;
      -*)
        extraArgs="$extraArgs $1"
        ;;
      *)
        if [ -z "$NixOS_Configuration" -a -e "configurations/$1" ]; then
          NixOS_Configuration="$1"
        elif [ -z "$NixOS_Configuration" -a -e "$1" ]; then
          NixOS_Configuration="${1#configurations/}"
        elif [ -z "$NixOS_Target" -a -e "targets/$1" ]; then
          NixOS_Target="$1"
        elif [ -z "$NixOS_Target" -a -e "$1" ]; then
          NixOS_Target="${1#targets/}"
        else
          echo "Unknown option $1";
          exit 1
        fi
    esac
  fi
  shift
done

if [ -z "$NixOS_Configuration" ]; then
  config_from_name `hostname -s`
fi

if [ -z "$NixOS_Target" ]; then
  case `findmnt --noheadings --raw --output=UUID /` in
    b6eb23a1-3c46-4074-99cd-d0b401a0fa54)
      NixOS_Target=yoga-book-sd.nix
      ;;
    397a0f75-94e2-46ab-9993-6d6d02506420)
      NixOS_Target=yoga-book-virtualbox.nix
      ;;
    d5551e12-5224-4913-a2d5-72d5e4f1337e)
      NixOS_Target=orfina.nix
      profile=cl
      ;;
    485094b5-0e17-43d7-835d-cb5d4647cbb4)
      NixOS_Target=acer-as.nix
      ;;
  esac
fi

if [ -z "$NixOS_Configuration" -o ! -e "configurations/$NixOS_Configuration" -o \
     -z "$NixOS_Target"        -o ! -e "targets/$NixOS_Target" ]; then
  if [ -z "$NixOS_Configuration" -o ! -e configurations/"$NixOS_Configuration" ]; then
    echo "Don't know which configuration you want ($NixOS_Configuration):"
    ls -1 configurations/ | sed 's/^/  /'
  fi
  if [ -z "$NixOS_Target" -o ! -e targets/"$NixOS_Target" ]; then
    echo "Don't know which target you want ($NixOS_Target):"
    ls -1 targets/ | sed 's/^/  /'
  fi
  exit 1
fi

export NixOS_Configuration NixOS_Target

echo "NIX_PATH is"
echo $NIX_PATH | tr : '\n' | sed 's/^/  /'
echo Make $NixOS_Configuration for $NixOS_Target? C-c to cancel.
read

case $artefact in
  os)
    sudo --preserve-env=NixOS_Configuration,NixOS_Target,NIX_PATH \
      nixos-rebuild ${profile:+-p} ${profile} ${action} ${extraArgs}
    ;;
  iso)
    nix build -f '<nixpkgs/nixos>' config.system.build.isoImage ${extraArgs} -o result-iso
    ;;
  disk)
    #nix build -f '<nixpkgs/nixos>' config.system.build.diskImage ${extraArgs} -o result-disk
    nix-build '<nixpkgs/nixos>' -A config.system.build.diskImage ${extraArgs} -o result-disk
    ;;
esac
