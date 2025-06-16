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
    server.advertiseListenPort = 51820;
    server.advertiseListenAddress = "1.1.1.1"; # public IP address of this host
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
