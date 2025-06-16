{ ... }:
{
  imports = [
    # top to bottom dependency order
    ./options.nix
    ./routes.nix
    ./secrets.nix
    ./interfaces.nix
  ];
}
