{ ... }:
{
  imports = [
    ../hardware/vm.nix
    ../shared.nix
  ];

  networking.hostName = "hostB";

  noxa.wireguard.interfaces.wg-service = {
    deviceNumber = 2;
  };

  system.stateVersion = "25.11";
}
