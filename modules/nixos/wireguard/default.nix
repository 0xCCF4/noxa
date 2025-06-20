/**
  Multi-host wireguard module
  This module is designated to facilitate easy multi-host
  wireguard network configuration.

  Each host may setup wireguard networks, while
  being automatically added to the specific
  network configuration on each host.

  Public/Private/Preshared connection keys are
  automatically shared between communication
  participants.
*/
{ ... }:
{
  imports = [
    # top to bottom dependency order
    ./options.nix
    ./routes.nix
    ./secrets.nix
    ./interfaces.nix

    # Add the deviceNumber option to interfaces
    ./simple.nix
  ];
}
