{ ... }:
{
  configuration = { lib, config, ... }: {
    noxa.wireguard.interfaces.wg-service = {
      deviceNumber = 3;
    };
  };
}
