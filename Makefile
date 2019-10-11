a ?= switch
action ?= $(a)

.PHONY: all cl generic

all: generic cl

cl:
	sudo nixos-rebuild -p cl -I nixos-config=/etc/nixos/cl.cam.ac.uk.nix $(a)

generic: generic-configuration.nix
	sudo nixos-rebuild -p generic -I nixos-config=/etc/nixos/generic-configuration.nix $(a)
