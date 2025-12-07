{ lib, ... }: with lib; {
  system.stateVersion = "25.11";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # users.mutableUsers = mkDefault false;
}
