{ lib, config, modulesPath, ... }: with lib;
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {

    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-amd" "kvm-intel" "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
    boot.extraModulePackages = [ ];

    services.qemuGuest.enable = true;

    fileSystems."/" =
      {
        device = "/dev/disk/by-partlabel/root";
        fsType = "ext4";
        autoResize = true;
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-partlabel/EFI";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    boot.growPartition = mkDefault true;

    swapDevices = [ ];
    networking.useDHCP = mkDefault true;

    nixpkgs.hostPlatform = mkDefault "x86_64-linux";

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
  };
}
