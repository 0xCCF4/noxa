/**
  Noxa's flake-parts module.

  A consumer imports the result of this function into their own
  `flake-parts.lib.mkFlake` call. It pulls in ez-configs for host
  discovery, then adds Noxa's own options on top: `noxa.managedNodes`
  and `noxa.wireguard`.
*/
{ noxaFlake, nixNetLib, ezConfigsFlakeModule }:
{ ... }:
{
  imports = [
    ezConfigsFlakeModule
    ./assertions.nix
    ./managedNodes.nix
    ./wireguard.nix
  ];

  _module.args = {
    inherit noxaFlake nixNetLib;
  };
}
