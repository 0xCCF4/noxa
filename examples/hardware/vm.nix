{
    disko,
pkgs,
lib,
config,
modulesPath,
...
}:
{
  imports = [
    (import ./disko.nix {
      device = "/dev/sda";
      bootType = "bios";
      espSize = "1G";
    })
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.growPartition = lib.mkDefault true;
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];

  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  services.qemuGuest.enable = lib.mkDefault true;

  security.sudo.wheelNeedsPassword = lib.mkDefault false; # Don't ask for passwords
  services.openssh = {
    enable = lib.mkDefault true;
    settings.PasswordAuthentication = lib.mkDefault false;
    settings.KbdInteractiveAuthentication = lib.mkDefault false;
  };
  programs.ssh.startAgent = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
