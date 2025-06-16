{ ... }:
{
  imports = [
    ../hardware/vm.nix
    ../shared.nix
  ];

  networking.hostName = "hostD";

  noxa.wireguard.interfaces.wg-service = {
    deviceNumber = 4;

    advertise.server = {
      listenPort = 51820;
      listenAddress = "2.2.2.2"; # public IP address of this host
    };
  };

  system.stateVersion = "25.11";
}
