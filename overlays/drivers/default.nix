final: prev: {
  Qualcomm = {
    Adreno-X1-85-Graphics = final.callPackage ./Qualcomm/Adreno-X1-85-Graphics.nix { };
    Audio = final.callPackage ./Qualcomm/Audio.nix { };
    Chipset = final.callPackage ./Qualcomm/Chipset.nix { };
    FastConnect-7800-Wi-Fi-and-Bluetooth =
      final.callPackage ./Qualcomm/FastConnect-7800-Wi-Fi-and-Bluetooth.nix
        { };
    MIPI-Camera = final.callPackage ./Qualcomm/MIPI-Camera.nix { };
  };
}
