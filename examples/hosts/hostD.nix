{ ... }:
{
  configuration = { lib, config, ... }: {
    noxa.wireguard.interfaces.wg-service = {
      deviceNumber = 4;

      advertise.server = {
        listenPort = 51820;
        listenAddress = "2.2.2.2"; # public IP address of this host
      };
    };
  };
}
