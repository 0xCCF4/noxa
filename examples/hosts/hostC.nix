{ ... }:
{
  imports = [
    ../hardware/vm.nix
    ../shared.nix
  ];

  networking.hostName = "hostC";

  noxa.wireguard.interfaces.wg-service = {
    deviceNumber = 3;
  };

  system.stateVersion = "25.11";
}
