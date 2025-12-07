# This is an exemplary nixos hardware configuration if our (noxa's) automated testing VMs.
#
# Feel free to remove this file and create your own hardware configuration in this folder.
{ pkgs
, lib
, config
, modulesPath
, ...
}: with lib;
{
  # Enable automatic disk resizing on boot
  boot.growPartition = mkDefault true;

  # Required kernel modules for qemu virtual machines
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  # Enable QEMU guest services
  services.qemuGuest.enable = mkDefault true;

  # Target architecture
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";

  # File systems
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  # Bootloader configuration
  boot.loader.grub = {
    enable = mkDefault false;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
    ];
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.systemd-boot.enable = mkDefault true;
}
