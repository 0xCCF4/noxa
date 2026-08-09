# Applied to every host in `./hosts` (ez-configs imports this by default).
{ lib, noxa, home-manager, ... }: with lib; {
  imports = [
    noxa.nixosModules.secrets # Configure secrets management
    ../secrets
    home-manager.nixosModules.default # Add home manager to all hosts
  ];

  # Default state version for all hosts
  system.stateVersion = mkDefault "25.11";
}
