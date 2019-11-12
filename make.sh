unset profile NixOS_Configuration NixOS_Target

select_name() {
  case $1 in
    orfina)
      NixOS_Configuration=cl.cam.ac.uk.nix
      NixOS_Target=orfina.nix
      ;;
    *)
      return 1;
  esac
}

while [ $# -gt 0 ]; do
  if !select_name $1; then
    case $1 in
      *-iso)
        NixOS_Configuration=${1%-iso}
        NixOS_Target=iso-image.nix
        ;;
      iso)
        NixOS_Target=iso-image.nix
        ;;
      *)
        echo "Unknown option $1";
        exit 1
    esac
  fi
  shift
done

if [ -z "$NixOS_Configuration" ]; then
  select_name `hostname -s`
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

sudo --preserve-env=NixOS_Configuration,NixOS_Target \
  nixos-rebuild ${profile:+-p} ${profile} \
  -I nixos-config=/etc/nixos/configuration.nix boot
