{ device ? throw "Set this to your disk device, e.g. /dev/sda"
, rootTmpfs ? false
, swapSize ? null
, espSize ? "2G"
, tmpSize ? "1G"
, ...
}:
{
  disko.devices =
    {
      nodev =
        { }
        // (
          if rootTmpfs then
            {
              "/" = {
                fsType = "tmpfs";
                mountOptions = [ "size=${tmpSize}" ];
              };
            }
          else
            {
              "/tmp" = {
                fsType = "tmpfs";
                mountOptions = [ "size=${tmpSize}" ];
              };
            }
        );
      disk.main = {
        inherit device;
        type = "disk";
        content = {
          type = "gpt";
          partitions =
            let
              BOOT = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
              ESP = {
                size = espSize;
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  extraArgs = [ "-n" "nixos-boot" ]; # no more than 11 characters
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  extraArgs = [ "-L" "nixos-root" ];
                };
              };
              swap = if swapSize == null then { } else {
                swap = {
                  name = "swap";
                  size = swapSize;
                  content = {
                    type = "swap";
                  };
                };
              };
            in
            {
              inherit BOOT ESP root;
            } // swap;
        };
      };
    };
}
