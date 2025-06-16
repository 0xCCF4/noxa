{ ... }:
{
  imports = [
    ../hardware/vm.nix
    ../shared.nix
  ];

  networking.hostName = "hostA";

  noxa.wireguard.interfaces.wg-service = {
    deviceNumber = 1;

    # This node is the wireguard turn server, advertise its interface
    # to other nodes so they can connect to it.
    advertise.server = {
      listenPort = 51820;
      listenAddress = "1.1.1.1"; # public IP address of this host
      defaultGateway = true; # this host will be the default gateway for clients
    };
  };

  noxa.secrets.def = [{
    hostSecret = {
      module = "test";
      name = "dummy-key";
    };
    generator.script = "dummy";
    generator.tags = [ "example" ];
  }];

  system.stateVersion = "25.11";
}
